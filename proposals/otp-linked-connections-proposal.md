# OpenTripPlanner Linked Connections Integration: Technical Proposal

## Executive Summary

This proposal outlines a comprehensive architecture for integrating **Linked Connections** data sources into **OpenTripPlanner (OTP)**, enabling OTP to consume RDF-based transit data from European National Access Points (NAPs) and other Linked Data publishers. This integration will position OTP as the first major journey planner to natively support both traditional transit formats (GTFS, NeTEx, SIRI) and Linked Data approaches.

**Key Innovation**: Leverage OTP2's extensible architecture to create a **Linked Connections Data Source Plugin** that seamlessly integrates with OTP's RAPTOR routing algorithm while maintaining compatibility with existing OTP features.

---

## Table of Contents

1. [Background and Motivation](#1-background-and-motivation)
2. [Architecture Overview](#2-architecture-overview)
3. [Integration Strategies](#3-integration-strategies)
4. [Technical Design](#4-technical-design)
5. [Implementation Approach](#5-implementation-approach)
6. [Routing Algorithm Adaptation](#6-routing-algorithm-adaptation)
7. [Real-time Updates](#7-real-time-updates)
8. [Configuration and Usage](#8-configuration-and-usage)
9. [Performance Considerations](#9-performance-considerations)
10. [Implementation Roadmap](#10-implementation-roadmap)
11. [Benefits and Use Cases](#11-benefits-and-use-cases)
12. [Future Enhancements](#12-future-enhancements)

---

## 1. Background and Motivation

### 1.1 Current State

**OpenTripPlanner (OTP2)** currently supports:
- ✅ **GTFS** - Static transit schedules (CSV)
- ✅ **GTFS-RT** - Real-time updates (Protocol Buffers)
- ✅ **NeTEx** - European standard (XML, Nordic/EPIP profiles)
- ✅ **SIRI** - European real-time (XML, VM/ET/SX)
- ✅ **OpenStreetMap** - Street network data
- ✅ **Digital Elevation Models** - Terrain data

**What's Missing**:
- ❌ Native support for **Linked Data** transit sources
- ❌ Direct consumption of **RDF/JSON-LD** transit data
- ❌ Integration with **Linked Connections** frameworks
- ❌ Federated queries across distributed transit endpoints

### 1.2 Why Linked Connections?

**Linked Connections** offers unique advantages:

1. **HTTP-native**: RESTful, cacheable, CDN-friendly
2. **Distributed**: Data can be federated across multiple providers
3. **Linked Data**: RDF URIs enable semantic interoperability
4. **Client-side friendly**: Connection Scan Algorithm (CSA) optimized for streaming
5. **EU Alignment**: Compatible with NeTEx/SIRI RDF representations
6. **Open World**: Incremental data discovery, no complete dataset required

### 1.3 Strategic Benefits for OTP

**Technical**:
- Broaden data source ecosystem beyond XML/CSV
- Enable true federated routing across European NAPs
- Leverage Semantic Web technologies (SPARQL, RDF)
- Support distributed, scalable transit data architecture

**Community**:
- Position OTP at the intersection of transit and Linked Data communities
- Attract new contributors from Semantic Web domain
- Enable innovative research applications
- Compliance with emerging EU data standards

**Operational**:
- Reduce server-side computational load (client-side routing option)
- Improve cache hit rates with HTTP-based fragments
- Enable real-time data integration without custom protocols
- Support micro-service architectures

---

## 2. Architecture Overview

### 2.1 High-level Integration Model

```
┌─────────────────────────────────────────────────────────────────┐
│                    OpenTripPlanner (OTP2)                        │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│  ┌───────────────────────────────────────────────────────────┐ │
│  │               Graph Builder Module                         │ │
│  ├───────────────────────────────────────────────────────────┤ │
│  │                                                            │ │
│  │  Existing Data Sources:        NEW:                       │ │
│  │  ┌──────────┐ ┌──────────┐   ┌────────────────────────┐  │ │
│  │  │   GTFS   │ │  NeTEx   │   │  Linked Connections    │  │ │
│  │  │ Importer │ │ Importer │   │  Data Source Plugin    │  │ │
│  │  └────┬─────┘ └────┬─────┘   └──────────┬─────────────┘  │ │
│  │       │            │                     │                │ │
│  │       └────────────┴─────────────────────┘                │ │
│  │                          │                                │ │
│  │                          ▼                                │ │
│  │              ┌────────────────────────┐                   │ │
│  │              │   Transit Model        │                   │ │
│  │              │   (Unified Internal    │                   │ │
│  │              │    Representation)     │                   │ │
│  │              └────────────┬───────────┘                   │ │
│  └──────────────────────────┬────────────────────────────────┘ │
│                             │                                   │
│  ┌──────────────────────────▼────────────────────────────────┐ │
│  │                   Transit Graph                            │ │
│  │  (Stops, Routes, Trips, Stop Times, Patterns, Transfers)   │ │
│  └──────────────────────────┬────────────────────────────────┘ │
│                             │                                   │
│  ┌──────────────────────────▼────────────────────────────────┐ │
│  │            RAPTOR Routing Algorithm                        │ │
│  │  (Multi-criteria Range RAPTOR, Transfer Patterns)          │ │
│  └────────────────────────────────────────────────────────────┘ │
│                                                                  │
└─────────────────────────────────────────────────────────────────┘

                              │
                              ▼
                   ┌─────────────────────┐
                   │   Journey Plans      │
                   │   (API Responses)    │
                   └─────────────────────┘
```

### 2.2 Data Flow

```
┌──────────────────────────────────────────────────────────────┐
│ STEP 1: Fetch Linked Connections                             │
│   Source: HTTP endpoints (JSON-LD, Turtle, or plain JSON)   │
│   Method: HTTP GET with caching (ETag, Cache-Control)       │
│   Output: RDF triples or JSON objects                        │
└──────────────────────────────────────────────────────────────┘
                            ↓
┌──────────────────────────────────────────────────────────────┐
│ STEP 2: Parse and Validate                                   │
│   RDF: Apache Jena or RDF4J for triple parsing              │
│   JSON-LD: JSON-LD Java library for context processing      │
│   SHACL: Optional validation against LC specification       │
│   Output: Connection objects in memory                       │
└──────────────────────────────────────────────────────────────┘
                            ↓
┌──────────────────────────────────────────────────────────────┐
│ STEP 3: Map to OTP Transit Model                             │
│   Connections → StopTimes                                    │
│   Stops (lc:departureStop/arrivalStop) → Stop entities      │
│   Routes (netex:line, gtfs:route) → Route entities          │
│   Delays (lc:departureDelay) → Real-time updates            │
│   Output: OTP internal transit model objects                 │
└──────────────────────────────────────────────────────────────┘
                            ↓
┌──────────────────────────────────────────────────────────────┐
│ STEP 4: Build Transit Graph                                  │
│   Process: Standard OTP graph building                       │
│   Indexing: RAPTOR data structures (routes, patterns)       │
│   Transfers: Generate walking transfers between stops       │
│   Output: Routable transit graph                             │
└──────────────────────────────────────────────────────────────┘
                            ↓
┌──────────────────────────────────────────────────────────────┐
│ STEP 5: Route Planning with RAPTOR                           │
│   Algorithm: Range RAPTOR (multi-criteria optimization)     │
│   Query: Origin, destination, time constraints              │
│   Output: Pareto-optimal journey itineraries                │
└──────────────────────────────────────────────────────────────┘
```

### 2.3 Component Diagram

```
org.opentripplanner.ext.linkedconnections/
│
├── datasource/
│   ├── LinkedConnectionsDataSource.java       # Main data source interface
│   ├── HttpConnectionFetcher.java             # HTTP client for LC endpoints
│   ├── ConnectionsFragmentCache.java          # HTTP cache implementation
│   └── RdfParser.java                          # RDF/JSON-LD parser
│
├── model/
│   ├── LinkedConnection.java                   # LC data model
│   ├── ConnectionToStopTimeMapper.java        # LC → OTP StopTime mapping
│   └── UriResolver.java                        # URI dereferencing
│
├── importer/
│   ├── LinkedConnectionsGraphBuilder.java     # Graph builder implementation
│   ├── ConnectionAggregator.java              # Group connections into trips
│   └── StopPlaceExtractor.java                # Extract stops from connections
│
├── updater/
│   ├── LinkedConnectionsRealtimeUpdater.java  # Real-time LC updates
│   └── StreamingConnectionProcessor.java      # Process LC streams
│
└── config/
    └── LinkedConnectionsConfig.java            # Configuration model
```

---

## 3. Integration Strategies

### 3.1 Strategy A: Full Import (Recommended for MVP)

**Approach**: Download all Linked Connections and convert to OTP's internal transit model during graph build.

**Pros**:
- ✅ Leverages existing RAPTOR algorithm without modification
- ✅ Consistent performance with GTFS/NeTEx imports
- ✅ No runtime dependencies on external LC servers
- ✅ Simpler implementation (follows existing patterns)

**Cons**:
- ❌ Requires downloading complete dataset
- ❌ Cannot leverage client-side routing benefits
- ❌ Misses some distributed/federated advantages

**Use Cases**:
- Single-agency OTP deployments
- Offline/on-premise installations
- Performance-critical applications

**Implementation Complexity**: **Medium** (3-4 months)

---

### 3.2 Strategy B: Hybrid (Server-side RAPTOR + LC Fetching)

**Approach**: OTP fetches Linked Connections on-demand during routing, using RAPTOR on server-side but LC-based data retrieval.

**Pros**:
- ✅ Reduced initial graph build time
- ✅ Always uses latest data (no rebuild needed)
- ✅ Can federate across multiple LC sources
- ✅ Leverages HTTP caching

**Cons**:
- ❌ Network latency affects query performance
- ❌ Requires robust caching strategy
- ❌ More complex error handling
- ❌ Dependency on external services

**Use Cases**:
- Cloud-native deployments
- Multi-agency federations
- Research/experimental applications

**Implementation Complexity**: **High** (6-8 months)

---

### 3.3 Strategy C: Client-side CSA (Future)

**Approach**: OTP acts as a proxy/aggregator, pushing CSA computation to the client (browser/mobile app).

**Pros**:
- ✅ Minimal server load
- ✅ Highly scalable
- ✅ True Linked Data spirit (follow-your-nose)
- ✅ Innovative architecture

**Cons**:
- ❌ Requires complete OTP architectural shift
- ❌ Limited browser/mobile performance
- ❌ Multi-modal routing challenges
- ❌ Backward compatibility issues

**Use Cases**:
- Web/mobile app experimentation
- Distributed transit networks
- Academic research

**Implementation Complexity**: **Very High** (12+ months, research project)

---

### 3.4 Recommended Approach: **Phased Implementation**

**Phase 1**: Strategy A (Full Import) - MVP
**Phase 2**: Strategy B (Hybrid) - Production
**Phase 3**: Strategy C (Client-side) - R&D

---

## 4. Technical Design

### 4.1 LinkedConnectionsDataSource Interface

```java
package org.opentripplanner.ext.linkedconnections.datasource;

import org.opentripplanner.graph_builder.DataSource;
import org.opentripplanner.graph_builder.DataSourceConfig;
import org.opentripplanner.ext.linkedconnections.model.LinkedConnection;

import java.util.stream.Stream;

/**
 * Data source for Linked Connections transit data.
 * Implements OTP's DataSource interface to integrate with graph builder.
 */
public class LinkedConnectionsDataSource implements DataSource {

    private final LinkedConnectionsConfig config;
    private final HttpConnectionFetcher fetcher;
    private final RdfParser parser;

    public LinkedConnectionsDataSource(LinkedConnectionsConfig config) {
        this.config = config;
        this.fetcher = new HttpConnectionFetcher(config);
        this.parser = new RdfParser(config.getFormat());
    }

    /**
     * Fetch all connections from configured endpoints.
     * Supports pagination via Hydra collections.
     *
     * @return Stream of LinkedConnection objects
     */
    public Stream<LinkedConnection> fetchConnections() {
        return config.getEndpoints().stream()
            .flatMap(endpoint -> fetchConnectionsFromEndpoint(endpoint));
    }

    private Stream<LinkedConnection> fetchConnectionsFromEndpoint(String endpoint) {
        // Follow Hydra pagination
        String currentPage = endpoint;
        Stream.Builder<LinkedConnection> builder = Stream.builder();

        while (currentPage != null) {
            // Fetch page
            String content = fetcher.fetch(currentPage);

            // Parse RDF/JSON-LD
            List<LinkedConnection> connections = parser.parse(content);
            connections.forEach(builder::add);

            // Get next page (Hydra)
            currentPage = parser.getNextPageUrl(content);
        }

        return builder.build();
    }

    /**
     * Extract unique stops from connections.
     */
    public Set<Stop> extractStops() {
        return fetchConnections()
            .flatMap(conn -> Stream.of(conn.getDepartureStop(), conn.getArrivalStop()))
            .distinct()
            .map(this::resolveStopUri)
            .collect(Collectors.toSet());
    }

    private Stop resolveStopUri(String stopUri) {
        // Dereference URI to get stop details (name, location, etc.)
        // Use HTTP client with caching
        return fetcher.fetchAndParse(stopUri, Stop.class);
    }
}
```

### 4.2 LinkedConnection Data Model

```java
package org.opentripplanner.ext.linkedconnections.model;

import java.time.ZonedDateTime;

/**
 * Represents a Linked Connection (departure-arrival pair).
 * Maps to lc:Connection in RDF vocabulary.
 */
public class LinkedConnection {

    // Core properties (required)
    private String id;                           // @id
    private String departureStop;                // lc:departureStop (URI)
    private ZonedDateTime departureTime;         // lc:departureTime
    private String arrivalStop;                  // lc:arrivalStop (URI)
    private ZonedDateTime arrivalTime;           // lc:arrivalTime

    // Trip/Route information
    private String trip;                         // gtfs:trip or netex:serviceJourney (URI)
    private String route;                        // gtfs:route or netex:line (URI)
    private String headsign;                     // gtfs:headsign

    // Real-time information (optional)
    private Integer departureDelay;              // lc:departureDelay (seconds)
    private Integer arrivalDelay;                // lc:arrivalDelay (seconds)
    private String departureStatus;              // siri:departureStatus (onTime, delayed, cancelled)
    private String arrivalStatus;                // siri:arrivalStatus

    // Operator/Agency
    private String operator;                     // gtfs:agency or netex:operator (URI)

    // Accessibility
    private Boolean wheelchairAccessible;        // gtfs:wheelchairAccessible

    // Getters and setters...

    /**
     * Calculate scheduled (planned) departure time.
     */
    public ZonedDateTime getScheduledDepartureTime() {
        if (departureDelay != null) {
            return departureTime.minusSeconds(departureDelay);
        }
        return departureTime;
    }

    /**
     * Calculate scheduled (planned) arrival time.
     */
    public ZonedDateTime getScheduledArrivalTime() {
        if (arrivalDelay != null) {
            return arrivalTime.minusSeconds(arrivalDelay);
        }
        return arrivalTime;
    }

    /**
     * Check if connection is cancelled.
     */
    public boolean isCancelled() {
        return "cancelled".equalsIgnoreCase(departureStatus) ||
               "cancelled".equalsIgnoreCase(arrivalStatus);
    }

    /**
     * Get travel duration in seconds.
     */
    public long getDurationSeconds() {
        return arrivalTime.toEpochSecond() - departureTime.toEpochSecond();
    }
}
```

### 4.3 RDF Parser Implementation

```java
package org.opentripplanner.ext.linkedconnections.datasource;

import org.apache.jena.rdf.model.*;
import org.apache.jena.vocabulary.RDF;
import com.github.jsonldjava.core.*;

/**
 * Parses Linked Connections from RDF (Turtle, JSON-LD, etc.)
 */
public class RdfParser {

    private static final String LC_NS = "http://semweb.mmlab.be/ns/linkedconnections#";
    private static final String GTFS_NS = "http://vocab.gtfs.org/terms#";
    private static final String NETEX_NS = "http://data.europa.eu/949/";
    private static final String SIRI_NS = "http://www.siri.org.uk/siri#";

    private final String format; // "jsonld", "turtle", "ntriples"

    public RdfParser(String format) {
        this.format = format;
    }

    /**
     * Parse RDF content into LinkedConnection objects.
     */
    public List<LinkedConnection> parse(String content) {
        if ("jsonld".equalsIgnoreCase(format)) {
            return parseJsonLd(content);
        } else {
            return parseRdf(content);
        }
    }

    private List<LinkedConnection> parseJsonLd(String jsonLdContent) {
        List<LinkedConnection> connections = new ArrayList<>();

        try {
            // Parse JSON-LD
            Object jsonObject = JsonUtils.fromString(jsonLdContent);
            JsonLdOptions options = new JsonLdOptions();
            List<Object> expanded = JsonLdProcessor.expand(jsonObject, options);

            // Extract connections
            for (Object obj : expanded) {
                if (obj instanceof Map) {
                    Map<String, Object> map = (Map<String, Object>) obj;

                    // Check if it's a Connection
                    List<Object> types = (List<Object>) map.get("@type");
                    if (types != null && types.contains(LC_NS + "Connection")) {
                        connections.add(mapToConnection(map));
                    }

                    // Check for @graph (multiple connections)
                    if (map.containsKey("@graph")) {
                        List<Object> graph = (List<Object>) map.get("@graph");
                        for (Object item : graph) {
                            if (item instanceof Map) {
                                Map<String, Object> itemMap = (Map<String, Object>) item;
                                List<Object> itemTypes = (List<Object>) itemMap.get("@type");
                                if (itemTypes != null && itemTypes.contains(LC_NS + "Connection")) {
                                    connections.add(mapToConnection(itemMap));
                                }
                            }
                        }
                    }
                }
            }
        } catch (Exception e) {
            throw new RuntimeException("Failed to parse JSON-LD: " + e.getMessage(), e);
        }

        return connections;
    }

    private LinkedConnection mapToConnection(Map<String, Object> map) {
        LinkedConnection conn = new LinkedConnection();

        // ID
        conn.setId((String) map.get("@id"));

        // Departure
        conn.setDepartureStop(extractUri(map, LC_NS + "departureStop"));
        conn.setDepartureTime(extractDateTime(map, LC_NS + "departureTime"));
        conn.setDepartureDelay(extractInteger(map, LC_NS + "departureDelay"));

        // Arrival
        conn.setArrivalStop(extractUri(map, LC_NS + "arrivalStop"));
        conn.setArrivalTime(extractDateTime(map, LC_NS + "arrivalTime"));
        conn.setArrivalDelay(extractInteger(map, LC_NS + "arrivalDelay"));

        // Trip/Route
        conn.setTrip(extractUri(map, GTFS_NS + "trip", NETEX_NS + "serviceJourney"));
        conn.setRoute(extractUri(map, GTFS_NS + "route", NETEX_NS + "line"));
        conn.setHeadsign(extractString(map, GTFS_NS + "headsign"));

        // Status
        conn.setDepartureStatus(extractString(map, SIRI_NS + "departureStatus"));
        conn.setArrivalStatus(extractString(map, SIRI_NS + "arrivalStatus"));

        return conn;
    }

    private List<LinkedConnection> parseRdf(String rdfContent) {
        List<LinkedConnection> connections = new ArrayList<>();

        // Create Jena model
        Model model = ModelFactory.createDefaultModel();
        model.read(new StringReader(rdfContent), null, format);

        // Query for Connection resources
        Property rdfType = model.getProperty(RDF.uri + "type");
        Resource connectionType = model.getResource(LC_NS + "Connection");

        ResIterator iter = model.listResourcesWithProperty(rdfType, connectionType);
        while (iter.hasNext()) {
            Resource connRes = iter.nextResource();
            connections.add(mapResourceToConnection(connRes));
        }

        return connections;
    }

    private LinkedConnection mapResourceToConnection(Resource resource) {
        LinkedConnection conn = new LinkedConnection();

        conn.setId(resource.getURI());

        // Departure
        conn.setDepartureStop(getPropertyUri(resource, LC_NS + "departureStop"));
        conn.setDepartureTime(getPropertyDateTime(resource, LC_NS + "departureTime"));
        conn.setDepartureDelay(getPropertyInt(resource, LC_NS + "departureDelay"));

        // Arrival
        conn.setArrivalStop(getPropertyUri(resource, LC_NS + "arrivalStop"));
        conn.setArrivalTime(getPropertyDateTime(resource, LC_NS + "arrivalTime"));
        conn.setArrivalDelay(getPropertyInt(resource, LC_NS + "arrivalDelay"));

        // Trip/Route (try GTFS first, then NeTEx)
        conn.setTrip(
            getPropertyUri(resource, GTFS_NS + "trip", NETEX_NS + "serviceJourney")
        );
        conn.setRoute(
            getPropertyUri(resource, GTFS_NS + "route", NETEX_NS + "line")
        );

        return conn;
    }

    // Helper methods for extracting values from JSON-LD/RDF...
    private String extractUri(Map<String, Object> map, String... properties) {
        for (String prop : properties) {
            Object value = map.get(prop);
            if (value instanceof List) {
                List<?> list = (List<?>) value;
                if (!list.isEmpty() && list.get(0) instanceof Map) {
                    return (String) ((Map<?, ?>) list.get(0)).get("@id");
                }
            } else if (value instanceof Map) {
                return (String) ((Map<?, ?>) value).get("@id");
            }
        }
        return null;
    }

    private ZonedDateTime extractDateTime(Map<String, Object> map, String property) {
        Object value = map.get(property);
        if (value instanceof List) {
            List<?> list = (List<?>) value;
            if (!list.isEmpty() && list.get(0) instanceof Map) {
                String dateStr = (String) ((Map<?, ?>) list.get(0)).get("@value");
                return ZonedDateTime.parse(dateStr);
            }
        }
        return null;
    }

    private Integer extractInteger(Map<String, Object> map, String property) {
        Object value = map.get(property);
        if (value instanceof List) {
            List<?> list = (List<?>) value;
            if (!list.isEmpty() && list.get(0) instanceof Map) {
                Object intValue = ((Map<?, ?>) list.get(0)).get("@value");
                return intValue != null ? Integer.parseInt(intValue.toString()) : null;
            }
        }
        return null;
    }

    private String extractString(Map<String, Object> map, String property) {
        Object value = map.get(property);
        if (value instanceof List) {
            List<?> list = (List<?>) value;
            if (!list.isEmpty()) {
                if (list.get(0) instanceof Map) {
                    return (String) ((Map<?, ?>) list.get(0)).get("@value");
                } else {
                    return list.get(0).toString();
                }
            }
        } else if (value instanceof String) {
            return (String) value;
        }
        return null;
    }

    /**
     * Extract next page URL from Hydra pagination.
     */
    public String getNextPageUrl(String content) {
        // Parse for hydra:next
        // Implementation omitted for brevity
        return null;
    }
}
```

### 4.4 Graph Builder Integration

```java
package org.opentripplanner.ext.linkedconnections.importer;

import org.opentripplanner.graph_builder.GraphBuilder;
import org.opentripplanner.model.*;
import org.opentripplanner.routing.graph.Graph;

/**
 * Builds OTP transit graph from Linked Connections data.
 */
public class LinkedConnectionsGraphBuilder implements GraphBuilder {

    private final LinkedConnectionsDataSource dataSource;
    private final Graph graph;
    private final ConnectionAggregator aggregator;

    public LinkedConnectionsGraphBuilder(
        LinkedConnectionsDataSource dataSource,
        Graph graph
    ) {
        this.dataSource = dataSource;
        this.graph = graph;
        this.aggregator = new ConnectionAggregator();
    }

    @Override
    public void buildGraph() {
        LOG.info("Building graph from Linked Connections...");

        // Step 1: Create stops
        Map<String, Stop> stops = createStops();

        // Step 2: Group connections into trips
        Map<String, List<LinkedConnection>> tripConnections =
            aggregator.groupByTrip(dataSource.fetchConnections());

        // Step 3: Create routes, trips, and stop times
        for (Map.Entry<String, List<LinkedConnection>> entry : tripConnections.entrySet()) {
            String tripUri = entry.getKey();
            List<LinkedConnection> connections = entry.getValue();

            createTripFromConnections(tripUri, connections, stops);
        }

        LOG.info("Linked Connections graph build complete.");
    }

    private Map<String, Stop> createStops() {
        Map<String, Stop> stops = new HashMap<>();

        for (Stop stopData : dataSource.extractStops()) {
            Stop stop = new Stop();
            stop.setId(new FeedScopedId("LC", extractStopId(stopData.getUri())));
            stop.setName(stopData.getName());
            stop.setLat(stopData.getLatitude());
            stop.setLon(stopData.getLongitude());
            stop.setUrl(stopData.getUri());

            graph.addVertex(stop);
            stops.put(stopData.getUri(), stop);
        }

        return stops;
    }

    private void createTripFromConnections(
        String tripUri,
        List<LinkedConnection> connections,
        Map<String, Stop> stops
    ) {
        // Sort connections by departure time
        connections.sort(Comparator.comparing(LinkedConnection::getDepartureTime));

        LinkedConnection first = connections.get(0);

        // Create Route
        Route route = getOrCreateRoute(first.getRoute());

        // Create Trip
        Trip trip = new Trip();
        trip.setId(new FeedScopedId("LC", extractTripId(tripUri)));
        trip.setRoute(route);
        trip.setTripHeadsign(first.getHeadsign());

        // Create StopTimes
        List<StopTime> stopTimes = new ArrayList<>();
        int sequence = 0;

        // First stop (departure only)
        StopTime firstStopTime = new StopTime();
        firstStopTime.setTrip(trip);
        firstStopTime.setStop(stops.get(first.getDepartureStop()));
        firstStopTime.setDepartureTime(toSecondsSinceMidnight(first.getDepartureTime()));
        firstStopTime.setArrivalTime(firstStopTime.getDepartureTime());
        firstStopTime.setStopSequence(sequence++);
        stopTimes.add(firstStopTime);

        // Intermediate and final stops
        for (LinkedConnection conn : connections) {
            StopTime stopTime = new StopTime();
            stopTime.setTrip(trip);
            stopTime.setStop(stops.get(conn.getArrivalStop()));
            stopTime.setArrivalTime(toSecondsSinceMidnight(conn.getArrivalTime()));
            stopTime.setDepartureTime(stopTime.getArrivalTime());
            stopTime.setStopSequence(sequence++);
            stopTimes.add(stopTime);
        }

        // Add to graph
        route.addTrip(trip);
        graph.addTripPattern(trip.getId(), new TripPattern(route, stopTimes));
    }

    private int toSecondsSinceMidnight(ZonedDateTime dateTime) {
        return dateTime.toLocalTime().toSecondOfDay();
    }

    private Route getOrCreateRoute(String routeUri) {
        // Implementation: lookup or create route
        // Dereference URI to get route details
        return new Route(); // Simplified
    }

    private String extractStopId(String uri) {
        return uri.substring(uri.lastIndexOf('/') + 1);
    }

    private String extractTripId(String uri) {
        return uri.substring(uri.lastIndexOf('/') + 1);
    }
}
```

### 4.5 Connection Aggregator

```java
package org.opentripplanner.ext.linkedconnections.importer;

/**
 * Groups Linked Connections into trips.
 * Connections with the same trip URI belong to the same journey.
 */
public class ConnectionAggregator {

    /**
     * Group connections by trip URI.
     */
    public Map<String, List<LinkedConnection>> groupByTrip(
        Stream<LinkedConnection> connections
    ) {
        return connections.collect(
            Collectors.groupingBy(
                LinkedConnection::getTrip,
                Collectors.toList()
            )
        );
    }

    /**
     * Infer trips from connection patterns (when trip URI not provided).
     * Uses heuristics: same route, sequential times, matching stops.
     */
    public Map<String, List<LinkedConnection>> inferTrips(
        Stream<LinkedConnection> connections
    ) {
        // Group by route first
        Map<String, List<LinkedConnection>> byRoute = connections
            .collect(Collectors.groupingBy(LinkedConnection::getRoute));

        Map<String, List<LinkedConnection>> trips = new HashMap<>();

        for (Map.Entry<String, List<LinkedConnection>> entry : byRoute.entrySet()) {
            String routeUri = entry.getKey();
            List<LinkedConnection> routeConnections = entry.getValue();

            // Sort by departure time
            routeConnections.sort(Comparator.comparing(LinkedConnection::getDepartureTime));

            // Infer trip boundaries (e.g., when departure stop repeats)
            int tripNumber = 0;
            List<LinkedConnection> currentTrip = new ArrayList<>();
            String lastArrivalStop = null;

            for (LinkedConnection conn : routeConnections) {
                if (lastArrivalStop != null && !conn.getDepartureStop().equals(lastArrivalStop)) {
                    // New trip started
                    String inferredTripId = routeUri + "/trip_" + tripNumber++;
                    trips.put(inferredTripId, new ArrayList<>(currentTrip));
                    currentTrip.clear();
                }

                currentTrip.add(conn);
                lastArrivalStop = conn.getArrivalStop();
            }

            // Add last trip
            if (!currentTrip.isEmpty()) {
                String inferredTripId = routeUri + "/trip_" + tripNumber;
                trips.put(inferredTripId, currentTrip);
            }
        }

        return trips;
    }
}
```

---

## 5. Implementation Approach

### 5.1 OTP Extension Architecture

Following OTP2's sandbox extension pattern:

```
src/ext/java/org/opentripplanner/ext/linkedconnections/
├── LinkedConnectionsModule.java          # Main module entry point
├── config/
│   └── LinkedConnectionsConfig.java      # Configuration
├── datasource/
│   ├── LinkedConnectionsDataSource.java
│   ├── HttpConnectionFetcher.java
│   ├── ConnectionsFragmentCache.java
│   └── RdfParser.java
├── model/
│   ├── LinkedConnection.java
│   ├── Stop.java
│   └── Route.java
├── importer/
│   ├── LinkedConnectionsGraphBuilder.java
│   ├── ConnectionAggregator.java
│   └── StopPlaceExtractor.java
├── updater/
│   └── LinkedConnectionsRealtimeUpdater.java
└── util/
    ├── UriResolver.java
    └── HydraNavigator.java
```

### 5.2 Configuration Model

**build-config.json**:

```json
{
  "transitFeeds": [
    {
      "type": "linked-connections",
      "source": "https://linkedconnections.org/data/nmbs/connections",
      "format": "jsonld",
      "caching": {
        "enabled": true,
        "ttl": 3600
      },
      "pagination": {
        "followHydra": true,
        "maxPages": 100
      },
      "validation": {
        "shacl": "https://linkedconnections.org/spec/shapes.ttl"
      },
      "uriStrategy": {
        "stopDereference": true,
        "routeDereference": true,
        "cacheUris": true
      },
      "tripInference": {
        "enabled": false,
        "groupByRoute": true
      }
    }
  ],
  "osm": [
    {
      "source": "https://download.geofabrik.de/europe/belgium-latest.osm.pbf"
    }
  ]
}
```

**router-config.json** (for real-time updates):

```json
{
  "updaters": [
    {
      "type": "linked-connections-realtime-updater",
      "url": "https://linkedconnections.org/data/nmbs/realtime",
      "frequencySec": 30,
      "format": "jsonld",
      "earlyStartSec": 300,
      "logFrequency": 2000
    }
  ]
}
```

### 5.3 Dependency Management

**pom.xml** additions:

```xml
<!-- RDF Processing -->
<dependency>
    <groupId>org.apache.jena</groupId>
    <artifactId>apache-jena-libs</artifactId>
    <version>4.10.0</version>
</dependency>

<!-- JSON-LD Processing -->
<dependency>
    <groupId>com.github.jsonld-java</groupId>
    <artifactId>jsonld-java</artifactId>
    <version>0.13.5</version>
</dependency>

<!-- HTTP Client with caching -->
<dependency>
    <groupId>com.squareup.okhttp3</groupId>
    <artifactId>okhttp</artifactId>
    <version>4.12.0</version>
</dependency>
<dependency>
    <groupId>com.squareup.okhttp3</groupId>
    <artifactId>okhttp-urlconnection</artifactId>
    <version>4.12.0</version>
</dependency>

<!-- SHACL Validation (optional) -->
<dependency>
    <groupId>org.topbraid</groupId>
    <artifactId>shacl</artifactId>
    <version>1.4.3</version>
</dependency>
```

---

## 6. Routing Algorithm Adaptation

### 6.1 RAPTOR Compatibility

**Good News**: RAPTOR works with OTP's internal transit model, not directly with GTFS/NeTEx structures. Once Linked Connections are converted to OTP's `StopTime`, `Trip`, `Route` model, RAPTOR works without modification.

**Key Insight**: The challenge is **data import**, not routing algorithm.

### 6.2 Connection Scan Algorithm (Future)

For advanced integration, implement CSA within OTP:

```java
package org.opentripplanner.ext.linkedconnections.routing;

/**
 * Connection Scan Algorithm implementation for OTP.
 * Alternative to RAPTOR for LC-native routing.
 */
public class ConnectionScanAlgorithm {

    /**
     * Find earliest arrival times using CSA.
     */
    public Map<Stop, ZonedDateTime> scan(
        Stop origin,
        ZonedDateTime departureTime,
        Stream<LinkedConnection> connections
    ) {
        Map<Stop, ZonedDateTime> earliestArrival = new HashMap<>();
        earliestArrival.put(origin, departureTime);

        // Scan connections in departure time order
        connections
            .sorted(Comparator.comparing(LinkedConnection::getDepartureTime))
            .forEach(conn -> {
                Stop depStop = conn.getDepartureStop();
                Stop arrStop = conn.getArrivalStop();

                // Can we board this connection?
                ZonedDateTime depEarliest = earliestArrival.get(depStop);
                if (depEarliest != null &&
                    !depEarliest.isAfter(conn.getDepartureTime())) {

                    // Update earliest arrival at arrival stop
                    ZonedDateTime currentBest = earliestArrival.get(arrStop);
                    if (currentBest == null ||
                        conn.getArrivalTime().isBefore(currentBest)) {
                        earliestArrival.put(arrStop, conn.getArrivalTime());
                    }
                }
            });

        return earliestArrival;
    }
}
```

**Note**: This is a simplified CSA. Full implementation requires:
- Transfer handling
- Journey reconstruction (backtracking)
- Multi-criteria optimization
- Pareto-optimal filtering

---

## 7. Real-time Updates

### 7.1 LinkedConnectionsRealtimeUpdater

```java
package org.opentripplanner.ext.linkedconnections.updater;

import org.opentripplanner.updater.PollingGraphUpdater;
import org.opentripplanner.routing.graph.Graph;

/**
 * Real-time updater for Linked Connections streams.
 * Polls LC endpoint for updated connections with delays.
 */
public class LinkedConnectionsRealtimeUpdater extends PollingGraphUpdater {

    private final String url;
    private final RdfParser parser;
    private final HttpConnectionFetcher fetcher;

    @Override
    protected void runPolling() {
        try {
            // Fetch real-time LC feed
            String content = fetcher.fetch(url);
            List<LinkedConnection> updates = parser.parse(content);

            // Apply updates to graph
            applyUpdates(updates);

        } catch (Exception e) {
            LOG.error("Failed to fetch LC real-time updates: {}", e.getMessage());
        }
    }

    private void applyUpdates(List<LinkedConnection> updates) {
        for (LinkedConnection conn : updates) {
            // Find corresponding trip in graph
            Trip trip = graph.index.getTripForId(
                new FeedScopedId("LC", conn.getTrip())
            );

            if (trip == null) {
                LOG.warn("Trip not found for connection: {}", conn.getId());
                continue;
            }

            // Update stop times with delays
            TripPattern pattern = graph.index.getPatternForTrip(trip);
            TripTimes times = pattern.getScheduledTimetable().getTripTimes(trip);

            // Apply departure delay
            int depStopSeq = findStopSequence(times, conn.getDepartureStop());
            if (depStopSeq >= 0 && conn.getDepartureDelay() != null) {
                times.updateDepartureDelay(depStopSeq, conn.getDepartureDelay());
            }

            // Apply arrival delay
            int arrStopSeq = findStopSequence(times, conn.getArrivalStop());
            if (arrStopSeq >= 0 && conn.getArrivalDelay() != null) {
                times.updateArrivalDelay(arrStopSeq, conn.getArrivalDelay());
            }

            // Handle cancellations
            if (conn.isCancelled()) {
                times.cancel();
            }
        }
    }

    private int findStopSequence(TripTimes times, String stopUri) {
        // Find stop sequence by matching stop URI
        // Implementation details omitted
        return -1;
    }
}
```

---

## 8. Configuration and Usage

### 8.1 Complete Build Configuration Example

```json
{
  "transitFeeds": [
    {
      "type": "linked-connections",
      "source": "https://graph.spitsgids.be/belgium/nmbs/connections",
      "format": "jsonld",
      "caching": {
        "enabled": true,
        "directory": "/var/otp/cache/lc",
        "ttl": 3600,
        "maxSize": "1GB"
      },
      "pagination": {
        "followHydra": true,
        "maxPages": 1000,
        "pageSize": 100
      },
      "timeRange": {
        "start": "2026-02-05T00:00:00Z",
        "end": "2026-02-12T23:59:59Z"
      },
      "validation": {
        "enabled": false,
        "shaclShapesUrl": "https://linkedconnections.org/spec/lc-shapes.ttl"
      },
      "uriStrategy": {
        "stopDereference": true,
        "routeDereference": true,
        "operatorDereference": false,
        "cacheUris": true,
        "cacheDirectory": "/var/otp/cache/uris"
      },
      "tripInference": {
        "enabled": false,
        "strategy": "sequential",
        "minConnectionsPerTrip": 2
      },
      "fallbackToGTFS": {
        "enabled": false,
        "gtfsSource": "https://gtfs.example.org/feed.zip"
      }
    },
    {
      "type": "gtfs",
      "source": "https://transitfeeds.com/p/other-agency/123/latest/download"
    }
  ],
  "osm": [
    {
      "source": "https://download.geofabrik.de/europe/belgium-latest.osm.pbf"
    }
  ],
  "dem": [
    {
      "source": "https://srtm.example.org/belgium.tif"
    }
  ],
  "buildReportDir": "/var/otp/reports"
}
```

### 8.2 Router Configuration (Real-time)

```json
{
  "routingDefaults": {
    "walkSpeed": 1.4,
    "transferSlack": 120,
    "maxTransfers": 4,
    "waitReluctance": 0.95,
    "walkReluctance": 1.75
  },
  "updaters": [
    {
      "type": "linked-connections-realtime-updater",
      "url": "https://graph.spitsgids.be/belgium/nmbs/realtime/connections",
      "format": "jsonld",
      "feedId": "LC",
      "frequencySec": 30,
      "earlyStartSec": 300,
      "backlogTimeSec": 3600,
      "logFrequency": 100,
      "maxSnapshotFrequency": 2000,
      "purgeExpiredData": true
    },
    {
      "type": "real-time-alerts",
      "url": "https://api.example.org/alerts",
      "feedId": "OTHER",
      "frequencySec": 60
    }
  ]
}
```

### 8.3 Command-Line Usage

```bash
# Build graph with Linked Connections
java -Xmx8G -jar otp-2.5.0-shaded.jar \
  --build \
  --buildDirectory /var/otp/graphs/belgium \
  --save

# Start server with real-time updates
java -Xmx4G -jar otp-2.5.0-shaded.jar \
  --load \
  --serve \
  --port 8080 \
  --graphs /var/otp/graphs
```

---

## 9. Performance Considerations

### 9.1 Optimization Strategies

#### HTTP Caching

```java
public class ConnectionsFragmentCache {
    private final Cache<String, String> cache;

    public ConnectionsFragmentCache() {
        this.cache = Caffeine.newBuilder()
            .maximumSize(10_000)
            .expireAfterWrite(Duration.ofHours(1))
            .build();
    }

    public String fetch(String url) {
        return cache.get(url, this::fetchFromNetwork);
    }

    private String fetchFromNetwork(String url) {
        // HTTP GET with ETag/If-None-Match support
        Request request = new Request.Builder()
            .url(url)
            .header("Accept", "application/ld+json")
            .build();

        Response response = httpClient.newCall(request).execute();
        return response.body().string();
    }
}
```

#### Streaming Parsing

```java
// Avoid loading entire RDF graph into memory
public Stream<LinkedConnection> streamParse(InputStream input) {
    return StreamSupport.stream(
        new JsonLdSpliterator(input),
        false
    );
}
```

#### Parallel Processing

```java
// Parallelize connection processing
connections.parallel()
    .map(this::convertToStopTime)
    .forEach(stopTimes::add);
```

### 9.2 Performance Benchmarks (Estimated)

**Test Environment**: Medium transit network (1000 stops, 50 routes, 5000 trips/day)

| Operation | GTFS | NeTEx | LC (JSON-LD) | LC (Turtle) |
|-----------|------|-------|--------------|-------------|
| **Download** | 2 MB (zip) | 15 MB (XML) | 25 MB (JSON-LD) | 18 MB (TTL) |
| **Parse Time** | 3 sec | 12 sec | 20 sec | 15 sec |
| **Memory (Peak)** | 200 MB | 500 MB | 800 MB | 600 MB |
| **Graph Build** | 15 sec | 25 sec | 35 sec | 30 sec |
| **Total Time** | 18 sec | 37 sec | 55 sec | 45 sec |

**Optimization Targets**:
- Cache parsed RDF models
- Use binary RDF formats (HDT)
- Implement incremental graph updates
- Parallelize URI dereferencing

### 9.3 Scaling Strategies

**For Large Networks** (10,000+ stops):
1. **Lazy Loading**: Fetch only time-relevant connection fragments
2. **Pre-aggregation**: Pre-compute trips from connections
3. **Binary Caching**: Cache parsed objects in binary format
4. **Distributed Build**: Split graph building across workers

---

## 10. Implementation Roadmap

### Phase 1: Foundation (Months 1-3)

**Objectives**:
- ✅ Design OTP extension architecture
- ✅ Implement RDF/JSON-LD parser
- ✅ Create LinkedConnection data model
- ✅ Build HTTP fetcher with caching

**Deliverables**:
- Core extension classes
- Unit tests
- Configuration schema
- Technical documentation

**Milestones**:
- M1.1: Extension scaffolding (Week 4)
- M1.2: Parser implementation (Week 8)
- M1.3: HTTP client with cache (Week 12)

---

### Phase 2: Graph Building (Months 4-6)

**Objectives**:
- ✅ Implement LinkedConnectionsGraphBuilder
- ✅ Connection-to-StopTime mapping
- ✅ Trip aggregation/inference
- ✅ Integration testing with sample LC data

**Deliverables**:
- Graph builder module
- Integration tests
- Sample LC datasets
- Build performance benchmarks

**Milestones**:
- M2.1: Graph builder skeleton (Week 16)
- M2.2: Trip aggregation complete (Week 20)
- M2.3: First successful graph build (Week 24)

---

### Phase 3: Real-time Updates (Months 7-9)

**Objectives**:
- ✅ Real-time updater implementation
- ✅ Delay propagation
- ✅ Cancellation handling
- ✅ Integration with RAPTOR

**Deliverables**:
- LinkedConnectionsRealtimeUpdater
- Real-time integration tests
- Performance benchmarks
- Documentation

**Milestones**:
- M3.1: Updater framework (Week 28)
- M3.2: Delay application (Week 32)
- M3.3: Real-time end-to-end test (Week 36)

---

### Phase 4: Production Hardening (Months 10-12)

**Objectives**:
- ✅ Error handling and resilience
- ✅ Performance optimization
- ✅ Documentation completion
- ✅ Community testing

**Deliverables**:
- Production-ready release
- User documentation
- Operator deployment guide
- Blog post and presentation

**Milestones**:
- M4.1: Performance optimization (Week 40)
- M4.2: Documentation complete (Week 44)
- M4.3: v1.0.0 Release (Week 48)

---

### Phase 5: Advanced Features (Year 2+)

**Objectives**:
- 🎯 Federation across multiple LC endpoints
- 🎯 Client-side CSA implementation
- 🎯 SPARQL query integration
- 🎯 Semantic reasoning capabilities

---

## 11. Benefits and Use Cases

### 11.1 For Transit Agencies

**European NAP Compliance**:
- Single OTP instance consuming NeTEx, SIRI, and LC
- Federated routing across national borders
- Semantic data integration

**Example**: **Norwegian NAP**
- Entur publishes NeTEx + SIRI
- Add LC export using netex2lc
- OTP consumes LC for experimental routing
- Compare performance with native NeTEx import

---

### 11.2 For Researchers

**Academic Applications**:
- Linked Data journey planning studies
- Federated transit network analysis
- SPARQL-based mobility queries
- Semantic web + transportation research

**Example**: **PhD Research**
- Student investigates multi-modal routing over linked data
- Uses OTP-LC to validate theoretical algorithms
- Publishes benchmark datasets
- Contributes improvements back to OTP

---

### 11.3 For Developers

**Hackathons and Innovation**:
- Build apps consuming LC-enabled OTP
- Experiment with distributed routing
- Integrate transit data with other linked datasets (e.g., events, weather)

**Example**: **Mobility Hackathon**
- Team builds "Event Transit Router"
- Queries DBpedia for concert locations
- Uses OTP-LC to find transit connections
- Wins prize for innovation

---

### 11.4 For Open Data Community

**Ecosystem Growth**:
- Demonstrates Linked Data viability for transit
- Bridges OTP and Semantic Web communities
- Encourages LC adoption by agencies
- Creates feedback loop for standards improvement

---

## 12. Future Enhancements

### 12.1 SPARQL Endpoint Integration

```java
/**
 * Query LC data via SPARQL instead of HTTP pagination.
 */
public class SparqlLinkedConnectionsDataSource {

    private final String sparqlEndpoint;

    public Stream<LinkedConnection> fetchConnections(
        ZonedDateTime start,
        ZonedDateTime end
    ) {
        String query = """
            PREFIX lc: <http://semweb.mmlab.be/ns/linkedconnections#>
            PREFIX xsd: <http://www.w3.org/2001/XMLSchema#>

            SELECT ?conn ?depStop ?depTime ?arrStop ?arrTime ?route ?trip
            WHERE {
              ?conn a lc:Connection ;
                    lc:departureStop ?depStop ;
                    lc:departureTime ?depTime ;
                    lc:arrivalStop ?arrStop ;
                    lc:arrivalTime ?arrTime ;
                    gtfs:route ?route ;
                    gtfs:trip ?trip .

              FILTER(?depTime >= "%s"^^xsd:dateTime)
              FILTER(?depTime < "%s"^^xsd:dateTime)
            }
            ORDER BY ?depTime
            """.formatted(start, end);

        // Execute SPARQL query and stream results
        return executeSparqlQuery(query);
    }
}
```

### 12.2 Federated Query Support

```java
/**
 * Route across multiple LC endpoints (different agencies/countries).
 */
public class FederatedLinkedConnectionsRouter {

    private final List<String> lcEndpoints;

    public Itinerary route(Stop origin, Stop destination, ZonedDateTime time) {
        // Discover relevant endpoints (e.g., by geographic proximity)
        List<String> relevantEndpoints = discoverEndpoints(origin, destination);

        // Fetch connections from all endpoints in parallel
        Stream<LinkedConnection> allConnections = relevantEndpoints.parallelStream()
            .flatMap(endpoint -> fetchFrom(endpoint, time));

        // Run CSA over merged connection stream
        return csa.route(origin, destination, allConnections);
    }
}
```

### 12.3 Semantic Reasoning

```java
/**
 * Use OWL reasoning to infer additional connections.
 * E.g., infer walking connections between nearby stops.
 */
public class SemanticConnectionInferencer {

    public Stream<LinkedConnection> inferConnections(
        Stream<LinkedConnection> base,
        OWLOntology ontology
    ) {
        // Load base connections into RDF model
        Model model = loadIntoModel(base);

        // Apply reasoning rules
        InfModel infModel = ModelFactory.createInfModel(
            ReasonerRegistry.getOWLReasoner(),
            model
        );

        // Extract inferred connections
        return extractConnections(infModel);
    }
}
```

### 12.4 Machine Learning Integration

```java
/**
 * Predict delays using historical LC data.
 */
public class DelayPredictionEnhancer {

    private final MLModel delayPredictor;

    public Stream<LinkedConnection> enrichWithPredictions(
        Stream<LinkedConnection> connections
    ) {
        return connections.map(conn -> {
            // Predict delay based on historical patterns
            int predictedDelay = delayPredictor.predict(
                conn.getRoute(),
                conn.getDepartureTime().getHour(),
                conn.getDepartureTime().getDayOfWeek()
            );

            // Add prediction to connection
            conn.setPredictedDelay(predictedDelay);
            return conn;
        });
    }
}
```

---

## 13. Testing Strategy

### 13.1 Unit Tests

```java
@Test
public void testParseJsonLdConnection() {
    String jsonLd = """
        {
          "@context": {
            "lc": "http://semweb.mmlab.be/ns/linkedconnections#",
            "xsd": "http://www.w3.org/2001/XMLSchema#"
          },
          "@id": "http://example.org/connections/123",
          "@type": "lc:Connection",
          "lc:departureStop": {"@id": "http://example.org/stops/A"},
          "lc:departureTime": {"@value": "2026-02-05T08:30:00Z", "@type": "xsd:dateTime"},
          "lc:arrivalStop": {"@id": "http://example.org/stops/B"},
          "lc:arrivalTime": {"@value": "2026-02-05T08:45:00Z", "@type": "xsd:dateTime"}
        }
        """;

    RdfParser parser = new RdfParser("jsonld");
    List<LinkedConnection> connections = parser.parse(jsonLd);

    assertEquals(1, connections.size());
    LinkedConnection conn = connections.get(0);
    assertEquals("http://example.org/connections/123", conn.getId());
    assertEquals("http://example.org/stops/A", conn.getDepartureStop());
    assertEquals("http://example.org/stops/B", conn.getArrivalStop());
}
```

### 13.2 Integration Tests

```java
@Test
public void testBuildGraphFromLinkedConnections() {
    // Setup: Create test LC data source
    LinkedConnectionsDataSource dataSource = createTestDataSource();
    Graph graph = new Graph();

    // Build graph
    LinkedConnectionsGraphBuilder builder =
        new LinkedConnectionsGraphBuilder(dataSource, graph);
    builder.buildGraph();

    // Verify: Check stops, routes, trips created
    assertNotNull(graph.getStop("LC:StopA"));
    assertNotNull(graph.getStop("LC:StopB"));
    assertEquals(1, graph.getRoutes().size());
    assertEquals(1, graph.getTrips().size());
}
```

### 13.3 End-to-End Tests

```java
@Test
public void testRouteUsingLinkedConnectionsData() {
    // Build graph from LC
    buildGraphFromLC();

    // Create routing request
    RoutingRequest request = new RoutingRequest();
    request.from = new GenericLocation(50.8503, 4.3517); // Brussels
    request.to = new GenericLocation(51.2194, 4.4025);   // Antwerp
    request.setDateTime("2026-02-05", "08:00:00", timezone);

    // Route
    GraphPathFinder pathFinder = new GraphPathFinder(router);
    List<GraphPath> paths = pathFinder.getPaths(request);

    // Verify results
    assertFalse(paths.isEmpty());
    GraphPath bestPath = paths.get(0);
    assertTrue(bestPath.getDuration() < 3600); // Less than 1 hour
}
```

---

## 14. Documentation Plan

### 14.1 User Documentation

**Topics**:
1. Introduction to Linked Connections in OTP
2. Configuration guide (build-config.json, router-config.json)
3. Deployment tutorial
4. Troubleshooting common issues
5. Performance tuning

**Format**: Markdown on OTP documentation site

---

### 14.2 Developer Documentation

**Topics**:
1. Architecture overview
2. Extension API reference
3. Contributing guide
4. Code examples
5. Testing guide

**Format**: JavaDoc + Developer Wiki

---

### 14.3 Operator Guide

**Topics**:
1. When to use LC vs GTFS/NeTEx
2. Production deployment checklist
3. Monitoring and logging
4. Real-time update configuration
5. Performance optimization

**Format**: PDF/GitBook

---

## 15. Community Engagement

### 15.1 Open Source Collaboration

**Repositories**:
- `opentripplanner/OpenTripPlanner` (main PR)
- `linkedconnections/otp-lc-spec` (specification)
- `linkedconnections/otp-lc-examples` (sample data)

**Communication**:
- OTP developers mailing list
- GitHub discussions
- Quarterly community calls
- Conference presentations (TRB, FOSS4G)

---

### 15.2 Pilot Projects

**Target Partners**:
1. **Entur (Norway)**: NeTEx → LC → OTP pipeline
2. **SNCF (France)**: Multi-modal LC integration
3. **Ruter (Oslo)**: Real-time LC updates
4. **delijn (Belgium)**: Regional LC deployment

---

## 16. Risk Assessment

### 16.1 Technical Risks

| Risk | Likelihood | Impact | Mitigation |
|------|------------|--------|------------|
| RDF parsing performance | Medium | High | Use binary formats (HDT), caching |
| URI dereferencing overhead | High | Medium | Aggressive caching, pre-fetching |
| Graph build time increase | Medium | Medium | Parallel processing, incremental builds |
| Real-time update latency | Low | Medium | Optimized updater, connection pooling |
| Memory consumption | Medium | High | Streaming parsing, memory tuning |

---

### 16.2 Adoption Risks

| Risk | Likelihood | Impact | Mitigation |
|------|------------|--------|------------|
| Limited LC data availability | High | High | Partner with agencies, create converters |
| OTP community resistance | Low | Medium | Clear benefits, backward compatibility |
| Maintenance burden | Medium | Medium | Strong documentation, test coverage |
| Performance concerns | Medium | High | Benchmarking, optimization, guidelines |

---

## 17. Success Metrics

### 17.1 Technical Metrics

- ✅ Graph build time < 2x GTFS equivalent
- ✅ Memory usage < 3x GTFS equivalent
- ✅ Routing performance parity with GTFS
- ✅ 90%+ LC spec compliance
- ✅ Real-time latency < 5 seconds

### 17.2 Adoption Metrics

- 🎯 3+ transit agencies using OTP-LC in production (Year 1)
- 🎯 10+ community contributors
- 🎯 5+ research papers citing OTP-LC
- 🎯 1000+ OTP instances with LC enabled

---

## 18. Conclusion

### 18.1 Summary

This proposal provides a comprehensive roadmap for integrating **Linked Connections** into **OpenTripPlanner**, positioning OTP as the first major journey planner to natively support Linked Data transit formats. The phased approach ensures:

1. **Compatibility**: Works alongside existing GTFS/NeTEx support
2. **Extensibility**: Leverages OTP2's sandbox architecture
3. **Performance**: Optimized for production use
4. **Innovation**: Opens new possibilities for federated, semantic routing

### 18.2 Strategic Value

**For OTP**:
- Expands data source ecosystem
- Positions OTP at forefront of Linked Data adoption
- Attracts new contributors and use cases

**For Transit Community**:
- Demonstrates viability of LC for production routing
- Bridges open data and semantic web communities
- Enables cross-border, federated journey planning

**For Research**:
- Creates platform for distributed routing experiments
- Enables semantic transit data studies
- Provides benchmark implementation for LC algorithms

### 18.3 Next Steps

1. **Community Discussion**: Present proposal to OTP developers
2. **Partner Engagement**: Recruit pilot agencies
3. **Funding**: Apply for research grants (EU Horizon, NSF)
4. **Development**: Begin Phase 1 implementation
5. **Publication**: Submit design paper to academic conference

---

## Appendices

### Appendix A: LC Vocabulary Reference

| Property | URI | Type | Description |
|----------|-----|------|-------------|
| Connection | lc:Connection | Class | Departure-arrival pair |
| departureStop | lc:departureStop | ObjectProperty | URI of departure stop |
| departureTime | lc:departureTime | DatatypeProperty (xsd:dateTime) | Departure time |
| arrivalStop | lc:arrivalStop | ObjectProperty | URI of arrival stop |
| arrivalTime | lc:arrivalTime | DatatypeProperty (xsd:dateTime) | Arrival time |
| departureDelay | lc:departureDelay | DatatypeProperty (xsd:integer) | Delay in seconds |
| arrivalDelay | lc:arrivalDelay | DatatypeProperty (xsd:integer) | Delay in seconds |

### Appendix B: Sample JSON-LD Context

```json
{
  "@context": {
    "lc": "http://semweb.mmlab.be/ns/linkedconnections#",
    "gtfs": "http://vocab.gtfs.org/terms#",
    "netex": "http://data.europa.eu/949/",
    "siri": "http://www.siri.org.uk/siri#",
    "geo": "http://www.w3.org/2003/01/geo/wgs84_pos#",
    "xsd": "http://www.w3.org/2001/XMLSchema#",
    "hydra": "http://www.w3.org/ns/hydra/core#",
    "Connection": "lc:Connection",
    "departureStop": {"@id": "lc:departureStop", "@type": "@id"},
    "arrivalStop": {"@id": "lc:arrivalStop", "@type": "@id"},
    "departureTime": {"@id": "lc:departureTime", "@type": "xsd:dateTime"},
    "arrivalTime": {"@id": "lc:arrivalTime", "@type": "xsd:dateTime"},
    "departureDelay": {"@id": "lc:departureDelay", "@type": "xsd:integer"},
    "arrivalDelay": {"@id": "lc:arrivalDelay", "@type": "xsd:integer"}
  }
}
```

### Appendix C: References

1. **OpenTripPlanner Documentation**: https://docs.opentripplanner.org
2. **Linked Connections Specification**: https://linkedconnections.org/specification/1-0
3. **RAPTOR Algorithm**: Delling et al., "Round-Based Public Transit Routing" (2012)
4. **Connection Scan Algorithm**: Dibbelt et al., "Connection Scan Algorithm" (2013)
5. **OTP2 Architecture**: https://github.com/opentripplanner/OpenTripPlanner
6. **Apache Jena**: https://jena.apache.org/
7. **JSON-LD**: https://json-ld.org/

---

**Document Version**: 1.0
**Date**: February 5, 2026
**Authors**: Transit Technology Working Group
**Status**: Proposal for Community Review
**License**: CC BY 4.0

---

**End of Proposal**
