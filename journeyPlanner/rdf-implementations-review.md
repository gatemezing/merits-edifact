# RDF implementations of journey-planner APIs (Europe)

Reviewed: 2026-02-05

## Overview
This review summarizes known efforts to expose journey-planning data via RDF/Linked Data in Europe, and contrasts them with the dominant non-RDF planner APIs identified in the landscape review.

## RDF-native efforts

### Linked Connections (spec + publishing model)
- Defines a publishing server for journey-planning clients, representing timetable “connections” as a paged Linked Data graph.
- Requires RDF 1.1 with at least one RDF serialization (JSON-LD, TriG, or N-Quads).
- Uses stable HTTP URIs and Linked Data navigation patterns (hypermedia, pagination, time-based access).
- Reuses a Linked GTFS vocabulary to map GTFS-style properties into RDF.

### Research and reference architecture
- Peer-reviewed work describes a Linked Connections framework for publishing planned, live, and historical transport data as Linked Data.
- The work evaluates performance and proposes an RDF-native architecture that can be compared against traditional planner engines.

## Mainstream planner APIs: non-RDF formats
Based on the planner APIs identified in the previous review, the dominant public-facing interfaces are JSON/GraphQL or XML, not RDF/JSON-LD. Examples:

- Entur Journey Planner v3 (GraphQL/JSON)
- Digitransit Routing API (GraphQL/JSON; GTFS/GTFS-RT under the hood)
- Trafiklab SL Journey Planner v2 (JSON)
- TfL Journey Planner API (XML)
- iRail (JSON/XML)
- Navitia (JSON)
- transport.opendata.ch (JSON)
- Transitous (MOTIS 2 API; GTFS/GTFS-RT/NeTEx ingestion)

## Assessment
RDF-native planner APIs appear rare among widely used open-data planners. Linked Connections stands out as the most explicit RDF implementation effort with a published specification and architecture. This assessment is based on the contrast between Linked Connections’ RDF requirements and the non-RDF formats documented by mainstream planner APIs.

## Sources
1. Linked Connections specification (RDF requirements, JSON-LD/TriG/N-Quads): https://linkedconnections.org/specification/1-0
2. Linked Connections research paper (architecture, evaluation): https://ruben.verborgh.org/publications/rojas_swj_2023/
3. Entur Journey Planner v3 docs: https://developer.entur.org/pages-journeyplanner-journeyplanner/
4. Digitransit APIs: https://digitransit.fi/en/developers/apis/
5. Trafiklab SL Journey Planner v2: https://www.trafiklab.se/api/sl-journey-planner-2
6. TfL Journey Planner dataset listing: https://findtransportdata.dft.gov.uk/dataset/tfl-journey-planner-api
7. iRail API docs: https://docs.irail.be/
8. Navitia docs: https://doc.navitia.io/
9. transport.opendata.ch docs: https://transport.opendata.ch/docs.html
10. Transitous API usage policy: https://transitous.org/api/
11. Transitous docs (formats/feeds): https://transitous.org/doc/
