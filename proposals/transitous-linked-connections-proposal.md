# Transitous Linked Connections Integration Proposal

Reviewed: 2026-02-05

## Executive summary
This proposal defines a concrete blueprint to add a Linked Connections (LC) RDF interface to Transitous while preserving the existing MOTIS 2 API. The recommended MVP is **LC export**: generate LC fragments from Transitous’ canonical timetable model and publish them as RDF (JSON-LD default, TriG/N-Quads optional). A later phase adds **LC ingest** for federation from external LC publishers.

## Goals
- Provide an RDF-native Linked Connections API for Transitous data.
- Preserve existing MOTIS 2 API and ingestion pipeline.
- Enable CDN-friendly, cacheable, time-fragmented LC data.
- Provide stable URIs, dataset metadata, and license attribution.

## Non-goals
- Replace MOTIS 2 API.
- Implement full client-side CSA routing inside Transitous (future work).
- Solve all data licensing harmonization beyond metadata publication.

## Architecture overview (LC export-first)

```
┌────────────────────────────────────────────────────────────┐
│                         Transitous                          │
├────────────────────────────────────────────────────────────┤
│  GTFS / NeTEx / GTFS-RT Ingestion                           │
│      └─> Canonical Transit Model (stops/trips/routes/etc.)  │
│              └─> LC Export Pipeline                          │
│                  ├─ LcFragmenter                            │
│                  ├─ RdfSerializer (JSON-LD/TriG/NQ)          │
│                  ├─ FragmentStore (S3/FS)                    │
│                  └─ MetadataPublisher (DCAT/VoID + LC meta)  │
│                           └─> CDN + HTTP API                 │
└────────────────────────────────────────────────────────────┘

Optional (Phase 3): LC Ingest
  LC HTTP sources -> RdfParser -> Trip/Stop mapping -> Canonical Model
```

## Component blueprint

### 1) LcFragmenter
- Input: canonical model (trip patterns + stop times)
- Output: time-windowed LC fragments
- Responsibilities:
  - Generate lc:Connection resources (one per stop-to-stop segment)
  - Enforce deterministic IDs and ordering
  - Slice into fixed windows (e.g., 10-30 minutes)

### 2) RdfSerializer
- Serializations: JSON-LD (default), optional TriG and N-Quads
- Context: LC vocabulary + Linked GTFS + optional NeTEx/SIRI terms
- Emits RDF with stable URIs and language tags for labels

### 3) FragmentStore
- Backing store: filesystem or object storage (S3-compatible)
- Immutable fragments for static data
- Optional short-TTL fragments for real-time overlays

### 4) HydraPager
- Produces pagination links (hydra:next/hydra:previous)
- Supports time-based discovery (start/end timestamp parameters)

### 5) MetadataPublisher
- Dataset catalog (DCAT/VoID + LC metadata)
- Per-feed metadata: license, provenance, update cadence, coverage
- Exposes:
  - `/catalog` for dataset discovery
  - `/feeds/{feed_id}` for per-feed metadata

### 6) RealtimeOverlayPublisher
- Input: GTFS-RT delays, cancellations, platform changes
- Output: RDF deltas as separate resources
- Strategy:
  - Do not mutate static fragments
  - Publish `lc:departureDelay` / `lc:arrivalDelay` overlays

## URI patterns (proposed)

Base:
- `https://api.transitous.org/lc/`

Connections (fragmented):
- `/lc/connections/{feed_id}/{yyyy-mm-dd}/{hh-mm}.jsonld`
- Example: `/lc/connections/de_db/2026-02-05/08-00.jsonld`

Stops:
- `/lc/stops/{feed_id}/{stop_id}`

Routes:
- `/lc/routes/{feed_id}/{route_id}`

Trips:
- `/lc/trips/{feed_id}/{trip_id}`

Operators:
- `/lc/operators/{feed_id}/{agency_id}`

Catalog:
- `/lc/catalog`
- `/lc/feeds/{feed_id}`

Realtime overlays:
- `/lc/realtime/{feed_id}/{yyyy-mm-dd}/{hh-mm}.jsonld`

## Fragment schema (LC core)

Each fragment contains:
- `@context` (LC + GTFS vocab)
- `@graph` list of `lc:Connection`
- `hydra:next` / `hydra:previous` links

Connection fields (minimum):
- `@id` (stable URI)
- `@type: lc:Connection`
- `lc:departureStop` (URI)
- `lc:arrivalStop` (URI)
- `lc:departureTime` (xsd:dateTime)
- `lc:arrivalTime` (xsd:dateTime)
- `gtfs:trip` or `netex:serviceJourney`
- `gtfs:route` or `netex:line`

Optional:
- `lc:departureDelay`, `lc:arrivalDelay`
- `siri:departureStatus`, `siri:arrivalStatus`
- `gtfs:headsign`, `gtfs:wheelchairAccessible`

## Mapping tables

### Canonical -> LC
| Canonical field | LC/GTFS/NeTEx property |
| --- | --- |
| trip.id | `gtfs:trip` or `netex:serviceJourney` |
| route.id | `gtfs:route` or `netex:line` |
| stop.departure.id | `lc:departureStop` |
| stop.arrival.id | `lc:arrivalStop` |
| departure.time | `lc:departureTime` |
| arrival.time | `lc:arrivalTime` |
| departure.delay | `lc:departureDelay` |
| arrival.delay | `lc:arrivalDelay` |
| headsign | `gtfs:headsign` |
| operator | `gtfs:agency` or `netex:operator` |

### Realtime -> LC overlay
| GTFS-RT | LC property |
| --- | --- |
| delay (stop_time_update) | `lc:departureDelay` / `lc:arrivalDelay` |
| schedule_relationship=CANCELED | `siri:departureStatus` = `cancelled` |
| platform | `siri:platformRef` (optional) |

## Caching and HTTP semantics
- Static fragments are immutable and cacheable:
  - `Cache-Control: public, max-age=86400, immutable`
  - Strong `ETag` for CDN revalidation
- Realtime overlays are short-lived:
  - `Cache-Control: public, max-age=30, stale-while-revalidate=60`
- Content negotiation via `Accept: application/ld+json`, `text/trig`, `application/n-quads`

## Ingest option (Phase 3)
If Transitous ingests external LC feeds:
- Add `LinkedConnectionsDataSource` with RDF parsing + Hydra paging.
- Map LC connections into canonical model, with trip inference if `gtfs:trip` absent.
- Store provenance: external endpoint URL, license, freshness.

## Compatibility with MOTIS 2
- MOTIS 2 remains primary routing API.
- LC export is a read-only view of the same canonical schedule.
- Optional: provide lightweight helper that converts LC fragments into MOTIS queries for legacy clients.

## Security and rate limiting
- Anonymous access allowed; rate limiting at CDN or edge.
- Require `User-Agent` for large-scale usage.
- Provide `X-Transitous-Feed` headers to indicate data source.

## Phased delivery plan

### Phase 1: LC export MVP (4-6 weeks)
- Implement LcFragmenter + RdfSerializer
- Publish static LC fragments for 1-2 pilot feeds
- JSON-LD only, no realtime overlays

### Phase 2: Realtime overlays (4-6 weeks)
- Add RealtimeOverlayPublisher
- Publish short-TTL overlay fragments

### Phase 3: Full catalog + CDN hardening (3-4 weeks)
- DCAT/VoID metadata
- CDN caching, ETag, monitoring

### Phase 4: LC ingest federation (8-12 weeks)
- Add LinkedConnectionsDataSource and mapping to canonical model
- Trip inference, stop dereferencing, provenance

## Risks and mitigations
- **Data volume**: fragment small windows + CDN.
- **Trip inference errors**: prefer feed-provided trip IDs; fallback heuristics guarded by confidence thresholds.
- **License constraints**: attach license metadata per feed and propagate into catalog.
- **Cross-border ID collisions**: namespace URIs by feed_id.

## Deliverables
- LC fragment endpoint
- Realtime overlay endpoint
- Dataset catalog endpoint
- JSON-LD context and vocab mapping
- Operator documentation

