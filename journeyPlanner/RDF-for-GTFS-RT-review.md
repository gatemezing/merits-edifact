# Review of RDF Work for GTFS-RT and Transit Data

## Executive Summary

This document reviews the state of the art in using RDF (Resource Description Framework) and semantic web technologies for GTFS-RT (General Transit Feed Specification - Realtime) and related transit data formats. While significant work has been done on converting static GTFS data to RDF, real-time GTFS-RT presents unique challenges that are being addressed through various projects and ontologies.

**Key Finding**: The main approach for GTFS-RT in RDF is through the **Linked Connections** framework, which converts GTFS-RT updates into RDF-based linked data using tools like `gtfsrt2lc`.

---

## 1. Linked GTFS Vocabulary

### Overview
- **Namespace**: http://vocab.gtfs.org/terms#
- **Prefix**: gtfs:
- **Repository**: https://github.com/OpenTransport/linked-gtfs
- **Status**: Active, widely referenced in research

### Purpose
The Linked GTFS vocabulary is a translation of the General Transit Feed Specification (GTFS) towards URIs. Its primary goals are:
- Creating an exchange platform for transit data using RDF
- Enabling SPARQL queries over transit data
- Providing globally unique identifiers for transit entities
- Staying as close as possible to the CSV GTFS reference

### Key Features
1. **URI Strategy**: Converts GTFS entities (stops, routes, trips, etc.) into URIs
2. **SPARQL-ready**: Allows local and remote data querying with SPARQL
3. **Interoperability**: Enables data integration using R2RML and RML mapping technologies
4. **CSV to RDF**: Provides transformation from GTFS CSV files to RDF triples

### Main Classes and Properties

```turtle
@prefix gtfs: <http://vocab.gtfs.org/terms#> .
@prefix rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#> .
@prefix rdfs: <http://www.w3.org/2000/01/rdf-schema#> .

# Core Classes
gtfs:Agency
gtfs:Stop
gtfs:Route
gtfs:Trip
gtfs:StopTime
gtfs:Service
gtfs:Shape
gtfs:FareAttribute
gtfs:FareRule
gtfs:Frequency
gtfs:Transfer

# Example Properties
gtfs:shortName
gtfs:longName
gtfs:route
gtfs:trip
gtfs:arrivalTime
gtfs:departureTime
gtfs:stopSequence
```

### Limitations for Real-time Data
The Linked GTFS vocabulary primarily addresses **static schedule data**. It does not natively handle:
- Real-time vehicle positions
- Trip updates and delays
- Service alerts and disruptions
- Dynamic scheduling changes

This gap is addressed by the **Linked Connections** framework.

---

## 2. Linked Connections Framework

### Overview
- **Website**: https://linkedconnections.org
- **Specification**: Version 1.0
- **Format**: RDF (JSON-LD, Turtle, N-Triples)
- **Status**: Active development, production use

### What is Linked Connections?
Linked Connections is a framework to publish transport data on the Web for route planning applications. A "connection" describes:
- **Departure stop** and **departure time**
- **Arrival stop** and **arrival time**
- **Route/Trip information**

Connections are published as a paged collection of RDF resources, enabling:
- Distributed route planning
- Caching at the client side
- Scalable real-time updates

### Real-time Support
Linked Connections handles real-time updates by:
1. Publishing **base connections** from static GTFS
2. Overlaying **real-time updates** from GTFS-RT
3. Maintaining **stable URIs** over time
4. Supporting **incremental updates**

### Key Advantages for Real-time Transit
- **Cacheable**: HTTP caching reduces server load
- **Client-side routing**: Route planning happens in the client
- **Linked Data**: Follows REST and hypermedia principles
- **Multi-modal**: Can combine data from different transit systems

---

## 3. gtfsrt2lc: GTFS-RT to Linked Connections Converter

### Overview
- **npm Package**: https://www.npmjs.com/package/gtfsrt2lc
- **GitHub**: https://github.com/linkedconnections/gtfsrt2lc
- **Language**: Node.js (JavaScript)
- **License**: Open Source

### Purpose
`gtfsrt2lc` converts GTFS-RT (Protocol Buffer format) updates into Linked Connections using RDF and Linked Data principles.

### Key Features

#### 1. Multiple Output Formats
Supports serialization in:
- **JSON** (plain JSON objects)
- **CSV** (tabular format)
- **RDF**:
  - Turtle (TTL)
  - N-Triples (NT)
  - JSON-LD

#### 2. URI Template Strategy (RFC 6570)
Uses configurable URI templates to generate stable, persistent identifiers for:
- Connections
- Stops
- Routes
- Trips
- Agencies

Example URI template configuration:
```json
{
  "stop": "http://example.org/stops/{stop_id}",
  "route": "http://example.org/routes/{route_id}",
  "trip": "http://example.org/trips/{trip_id}",
  "connection": "http://example.org/connections/{connection.departureTime(yyyyMMdd)}/{trip.trip_id}"
}
```

#### 3. Streaming Architecture
- Uses Node.js streams for efficient processing
- Handles large GTFS-RT feeds without loading everything into memory
- Streams JSON-LD `@context` first, then connection objects

#### 4. Integration with Static GTFS
- Requires both GTFS-RT feed and corresponding static GTFS data
- Enriches real-time updates with static schedule information
- Resolves references between real-time and static entities

### Command-Line Usage

```bash
# Install globally
npm install -g gtfsrt2lc

# Convert GTFS-RT to JSON
gtfsrt2json -r http://gtfsrt.feed/ -H '{"api-key":"your_key"}'

# Convert to Linked Connections (JSON-LD)
gtfsrt2lc \
  --real-time http://gtfsrt.feed/ \
  --static /path/to/gtfs.zip \
  --uris /path/to/uri-templates.json \
  --format jsonld
```

### Programmatic Usage

```javascript
const { Gtfsrt2LC } = require('gtfsrt2lc');

const converter = new Gtfsrt2LC({
  realtimeFeed: 'http://example.org/gtfs-rt',
  staticGtfs: '/path/to/gtfs.zip',
  uriTemplates: '/path/to/templates.json',
  format: 'jsonld'
});

converter.stream()
  .on('data', (connection) => {
    console.log(connection);
  })
  .on('error', (error) => {
    console.error(error);
  })
  .on('end', () => {
    console.log('Conversion complete');
  });
```

### Sample Output (JSON-LD)

```json
{
  "@context": {
    "lc": "http://semweb.mmlab.be/ns/linkedconnections#",
    "gtfs": "http://vocab.gtfs.org/terms#",
    "xsd": "http://www.w3.org/2001/XMLSchema#"
  },
  "@id": "http://example.org/connections/20260205/trip_123",
  "@type": "lc:Connection",
  "lc:departureStop": {
    "@id": "http://example.org/stops/STOP001",
    "@type": "gtfs:Stop"
  },
  "lc:departureTime": {
    "@value": "2026-02-05T08:30:00Z",
    "@type": "xsd:dateTime"
  },
  "lc:arrivalStop": {
    "@id": "http://example.org/stops/STOP002",
    "@type": "gtfs:Stop"
  },
  "lc:arrivalTime": {
    "@value": "2026-02-05T08:47:00Z",
    "@type": "xsd:dateTime"
  },
  "lc:departureDelay": {
    "@value": "120",
    "@type": "xsd:integer"
  },
  "lc:arrivalDelay": {
    "@value": "120",
    "@type": "xsd:integer"
  },
  "gtfs:trip": {
    "@id": "http://example.org/trips/trip_123",
    "@type": "gtfs:Trip"
  },
  "gtfs:route": {
    "@id": "http://example.org/routes/route_1",
    "@type": "gtfs:Route"
  }
}
```

### Related Tools

#### gtfs2lc
- **Purpose**: Converts static GTFS to Linked Connections
- **Repository**: https://github.com/linkedconnections/gtfs2lc
- **Use**: Creates base connections from GTFS schedules

#### lc-client
- **Purpose**: Client-side route planning with Linked Connections
- **Repository**: https://github.com/linkedconnections
- **Use**: Demonstrates client-side routing applications

---

## 4. Transmodel Ontology

### Overview
- **Namespace**: https://w3id.org/transmodel/terms#
- **Repository**: https://github.com/oeg-upm/transmodel-ontology
- **Developer**: Ontology Engineering Group (OEG), Universidad Politécnica de Madrid
- **Status**: Official EU-aligned ontology

### Purpose
The Transmodel ontology provides RDF/OWL representation of the Transmodel conceptual model, which is the basis for:
- **NeTEx** (Network Timetable Exchange) - static data
- **SIRI** (Service Interface for Real-time Information) - real-time data

### Relationship to European Standards
- **EU Regulation 2017/1926**: Requires NeTEx and SIRI for EU member states
- **Transmodel**: CEN European Reference Data Model for Public Transport
- **Ontology Role**: Enables semantic interoperability between GTFS and NeTEx/SIRI

### Key Components

The Transmodel ontology is divided into modular vocabularies:

1. **tm-commons**: Common concepts (organizations, versions, validity)
2. **tm-journeys**: Journey patterns, service journeys, calls
3. **tm-facilities**: Stop facilities, equipment
4. **tm-organisations**: Operators, authorities
5. **tm-fares**: Fare structures, pricing

### GTFS to Transmodel Mapping

The ontology enables mapping between GTFS concepts and Transmodel:

| GTFS Concept | Transmodel/NeTEx Concept |
|--------------|--------------------------|
| Agency | Operator |
| Stop | StopPlace / Quay |
| Route | Line |
| Trip | ServiceJourney |
| StopTime | TimetabledPassingTime / Call |
| Frequency | JourneyFrequency |
| Fare | FareFrame |

### Real-time Extensions
For real-time data, Transmodel aligns with **SIRI XML**, which provides:
- Vehicle Monitoring (SIRI-VM)
- Stop Monitoring (SIRI-SM)
- Estimated Timetable (SIRI-ET)
- Situation Exchange (SIRI-SX)

Work is ongoing to provide RDF representations of SIRI messages.

---

## 5. ONETT Project: Systematic Knowledge Graph Generation

### Overview
- **Project**: ONETT (Ontology-based Network for European Transport Transformation)
- **Focus**: Automatic Knowledge Graph generation for National Access Points (NAPs)
- **Paper**: https://osoc-es.github.io/onett-paper/output/

### Key Innovations

#### 1. GTFS to Transmodel Mapping with RML
ONETT generates RML (RDF Mapping Language) mappings to transform GTFS CSV data into Transmodel-based RDF:

```yaml
# YARRRML example (RML serialization)
mappings:
  stops:
    sources:
      - ['stops.txt~csv']
    s: http://transport.linkeddata.es/madrid/metro/stops/$(stop_id)
    po:
      - [a, gtfs:Stop]
      - [a, tm:StopPlace]
      - [gtfs:name, $(stop_name)]
      - [geo:lat, $(stop_lat)]
      - [geo:long, $(stop_lon)]
      - [tm:publicCode, $(stop_code)]
```

#### 2. Automatic RDF Generation
- Uses **SDM-RDFizer** engine for materialization
- Processes GTFS feeds automatically
- Generates RDF conforming to Transmodel ontology
- Updates National Access Points

#### 3. Multi-source Integration
Integrates data from:
- GTFS feeds
- NeTEx XML files
- TransXChange (UK)
- Other regional formats

### Relevance to Real-time Data
While ONETT focuses primarily on static data, the framework is designed to:
- Support SIRI real-time extensions
- Enable federated SPARQL queries across static and real-time data
- Provide consistent URIs for entities referenced in real-time updates

---

## 6. GTFS-Madrid-Bench: Benchmark for Virtual Knowledge Graphs

### Overview
- **Repository**: https://github.com/oeg-upm/gtfs-bench
- **Purpose**: Benchmark for evaluating Knowledge Graph Construction engines
- **Data**: Madrid Metro GTFS data
- **Queries**: 18 complex + 11 simple SPARQL queries

### Features

#### 1. Query Set
The benchmark includes SPARQL queries covering:
- Basic triple patterns
- FILTER operations
- OPTIONAL patterns
- Aggregations (COUNT, AVG, etc.)
- UNION queries
- Property paths
- DISTINCT and ORDER BY

#### Sample SPARQL Query
```sparql
# Query: Find all stops for a specific route
PREFIX gtfs: <http://vocab.gtfs.org/terms#>
PREFIX geo: <http://www.w3.org/2003/01/geo/wgs84_pos#>

SELECT ?stop ?stopName ?lat ?lon ?stopSequence
WHERE {
  ?trip a gtfs:Trip ;
        gtfs:route <http://transport.linkeddata.es/madrid/metro/routes/1> ;
        gtfs:service ?service .

  ?stopTime gtfs:trip ?trip ;
            gtfs:stop ?stop ;
            gtfs:departureTime ?depTime ;
            gtfs:stopSequence ?stopSequence .

  ?stop gtfs:name ?stopName ;
        geo:lat ?lat ;
        geo:long ?lon .
}
ORDER BY ?stopSequence
```

#### 2. Scalability Testing
- Multiple data scales (1x, 10x, 100x, 500x)
- Different formats (CSV, JSON, SQL, XML)
- Virtual Knowledge Graph vs Materialized RDF

#### 3. Performance Metrics
Evaluates:
- Query execution time
- Memory usage
- Mapping generation time
- RDF materialization efficiency

### Research Findings (2024)
Recent research published in Semantic Web Journal shows:
- **Storage reduction**: Up to 315.83x reduction using virtual KG approaches
- **CPU time reduction**: Up to 4.59x improvement in processing
- **Scalability**: Successful evaluation with datasets scaled to 500x original size

---

## 7. Related Ontologies and Vocabularies

### 7.1 Transport Disruption Ontology

**Purpose**: Describes events causing disruption on transport services

**Key Classes**:
- `td:Disruption` - Base class for disruptions
- `td:Delay` - Delays affecting services
- `td:Cancellation` - Cancelled services
- `td:Detour` - Route changes

**Relevance to GTFS-RT**: Provides semantic model for GTFS-RT Service Alerts

### 7.2 Linked Connections Vocabulary

**Namespace**: http://semweb.mmlab.be/ns/linkedconnections#

**Key Classes**:
- `lc:Connection` - A single connection between stops
- `lc:CancelledConnection` - Cancelled connection
- `lc:DelayedConnection` - Delayed connection

**Properties**:
- `lc:departureStop` - Departure stop URI
- `lc:departureTime` - Actual/predicted departure time
- `lc:departureDelay` - Delay in seconds
- `lc:arrivalStop` - Arrival stop URI
- `lc:arrivalTime` - Actual/predicted arrival time
- `lc:arrivalDelay` - Delay in seconds

### 7.3 GeoSPARQL and WGS84 Geo Positioning

**Purpose**: Represent geographic locations in RDF

**Usage in Transit**:
```sparql
PREFIX geo: <http://www.w3.org/2003/01/geo/wgs84_pos#>
PREFIX geof: <http://www.opengis.net/def/function/geosparql/>

SELECT ?stop ?distance
WHERE {
  ?stop a gtfs:Stop ;
        geo:lat ?lat ;
        geo:long ?lon .

  BIND(geof:distance(
    "POINT(-122.4194 37.7749)"^^geo:wktLiteral,
    CONCAT("POINT(", STR(?lon), " ", STR(?lat), ")")^^geo:wktLiteral,
    uom:metre
  ) AS ?distance)

  FILTER(?distance < 500)
}
```

---

## 8. Mapping Technologies: R2RML and RML

### R2RML (RDB to RDF Mapping Language)

**Purpose**: W3C Recommendation for mapping relational databases to RDF

**Use Case**: GTFS data loaded into SQL databases can be mapped to RDF

**Example**:
```turtle
@prefix rr: <http://www.w3.org/ns/r2rml#> .
@prefix gtfs: <http://vocab.gtfs.org/terms#> .

<#StopsMapping>
  rr:logicalTable [ rr:tableName "stops" ];
  rr:subjectMap [
    rr:template "http://example.org/stops/{stop_id}";
    rr:class gtfs:Stop
  ];
  rr:predicateObjectMap [
    rr:predicate gtfs:name;
    rr:objectMap [ rr:column "stop_name" ]
  ];
  rr:predicateObjectMap [
    rr:predicate geo:lat;
    rr:objectMap [
      rr:column "stop_lat";
      rr:datatype xsd:double
    ]
  ].
```

### RML (RDF Mapping Language)

**Purpose**: Extension of R2RML for heterogeneous data sources (CSV, JSON, XML)

**Advantages for Transit**:
- Handles GTFS CSV files directly
- Processes GTFS-RT JSON/Protocol Buffers
- Supports NeTEx XML
- Enables multi-format integration

**Example (YARRRML syntax)**:
```yaml
prefixes:
  gtfs: "http://vocab.gtfs.org/terms#"
  ex: "http://example.org/"

mappings:
  trips:
    sources:
      - ['trips.txt~csv']
    s: ex:trips/$(trip_id)
    po:
      - [a, gtfs:Trip]
      - [gtfs:route, ex:routes/$(route_id)~iri]
      - [gtfs:service, ex:services/$(service_id)~iri]
      - [gtfs:headsign, $(trip_headsign)]
```

### Tools for RML Processing

1. **SDM-RDFizer** (Python)
   - High-performance RDF generation
   - Used in ONETT project
   - Handles large GTFS datasets

2. **RMLMapper** (Java)
   - Reference RML implementation
   - Supports multiple serializations
   - Active development

3. **Morph-KGC** (Python)
   - Virtual Knowledge Graph engine
   - SPARQL queries over CSV/JSON without materialization
   - Excellent for real-time scenarios

---

## 9. Practical Implementations and Use Cases

### 9.1 Belgian Railways (NMBS/SNCB)

**Implementation**:
- Publishes GTFS and GTFS-RT feeds
- Converts to Linked Connections using gtfsrt2lc
- Provides public SPARQL endpoint

**Benefits**:
- Third-party app development
- Multi-modal journey planning
- Real-time delay information

### 9.2 Madrid Metro

**Implementation**:
- GTFS data converted to RDF using R2RML
- Used in GTFS-Madrid-Bench
- Academic research platform

**Applications**:
- Route planning algorithms research
- Query optimization studies
- Benchmark for KG tools

### 9.3 European National Access Points (NAPs)

**Requirement**: EU Regulation 2017/1926 mandates data publication

**Current State**:
- Most NAPs publish NeTEx/SIRI (XML)
- Some also publish GTFS/GTFS-RT
- ONETT project working on RDF conversion

**Future Direction**:
- Unified RDF endpoints across EU
- Federated SPARQL queries
- Cross-border journey planning

### 9.4 Routable Tiles / Linked Connections

**Implementation**:
- Transit data as HTTP-cacheable fragments
- Client-side route planning
- Reduces server load

**Real-time Updates**:
- Base tiles from static GTFS
- Delta updates from GTFS-RT
- Efficient cache invalidation

---

## 10. Challenges and Limitations

### 10.1 Real-time Data Volume

**Challenge**: GTFS-RT feeds update every 30 seconds
- High-frequency RDF generation
- Large triple stores
- Query performance degradation

**Solutions**:
- Virtual Knowledge Graphs (no materialization)
- Selective materialization
- Time-windowed queries
- Stream processing

### 10.2 URI Stability

**Challenge**: Real-time updates reference entities that may change
- Trip IDs may be reused
- Vehicle assignments change
- Route modifications

**Solutions**:
- Versioned URIs with timestamps
- Canonical identifiers
- Hash-based URIs
- RFC 6570 URI templates

### 10.3 Protocol Buffer to RDF

**Challenge**: GTFS-RT uses binary Protocol Buffers
- Not directly RDF-compatible
- Nested message structures
- Extensions and custom fields

**Solutions**:
- gtfsrt2lc handles conversion
- JSON intermediate format
- Custom RML mappings
- Protocol Buffer to JSON converters

### 10.4 Ontology Alignment

**Challenge**: Multiple ontologies for transit
- Linked GTFS
- Transmodel
- Local/regional ontologies
- Application-specific vocabularies

**Solutions**:
- OWL equivalence axioms
- SKOS mappings
- RML multi-target mappings
- Upper ontology (e.g., Schema.org)

### 10.5 Query Performance

**Challenge**: SPARQL queries over large transit networks
- Millions of triples
- Complex join patterns
- Real-time constraints

**Solutions**:
- Geospatial indexing
- Temporal indexing
- Query rewriting
- Caching strategies
- Approximate query answering

---

## 11. Current State and Future Directions (2025-2026)

### Current State

✅ **Mature Technologies**:
- Linked GTFS vocabulary (static data)
- R2RML/RML mapping tools
- GTFS to RDF converters

🔄 **Active Development**:
- gtfsrt2lc (real-time conversion)
- Linked Connections framework
- Transmodel ontology
- ONETT NAP integration

🔬 **Research Phase**:
- SIRI to RDF conversion
- Federated SPARQL across NAPs
- Stream reasoning for real-time data
- Semantic service alerts

### Future Directions

#### 1. SIRI RDF Representation
**Need**: Native RDF representation of SIRI messages
**Status**: Limited work, primarily XML-based
**Opportunity**: Define SIRI ontology aligned with Transmodel

#### 2. Unified European Knowledge Graph
**Vision**: Single federated RDF endpoint for all EU transit data
**Challenges**:
- NAP heterogeneity
- URI coordination
- Real-time synchronization
**Benefit**: Cross-border journey planning

#### 3. Stream Reasoning and CEP
**Application**: Complex Event Processing over GTFS-RT streams
**Technologies**:
- RSP-QL (RDF Stream Processing Query Language)
- C-SPARQL
- CQELS
**Use Cases**:
- Delay pattern detection
- Predictive analytics
- Automated alerts

#### 4. Integration with MaaS Platforms
**Trend**: Mobility-as-a-Service requires multi-modal data
**RDF Role**:
- Unified data model
- Cross-operator queries
- Linked pricing/ticketing
**Standards**: Combine GTFS, GBFS (bike-share), MDS (micro-mobility)

#### 5. AI/ML over Knowledge Graphs
**Applications**:
- Delay prediction
- Demand forecasting
- Route optimization
- Anomaly detection
**Approach**: Graph Neural Networks over transit KG

---

## 12. Tools and Resources Summary

### Conversion Tools

| Tool | Input | Output | Language | Repository |
|------|-------|--------|----------|------------|
| gtfs2lc | GTFS (CSV) | Linked Connections (RDF) | Node.js | https://github.com/linkedconnections/gtfs2lc |
| gtfsrt2lc | GTFS-RT (protobuf) | Linked Connections (RDF) | Node.js | https://github.com/linkedconnections/gtfsrt2lc |
| SDM-RDFizer | CSV/JSON/XML + RML | RDF | Python | https://github.com/SDM-TIB/SDM-RDFizer |
| RMLMapper | Any + RML | RDF | Java | https://github.com/RMLio/rmlmapper-java |
| Morph-KGC | Any + RML | Virtual KG | Python | https://github.com/oeg-upm/morph-kgc |

### Ontologies and Vocabularies

| Ontology | Namespace | Purpose | Repository |
|----------|-----------|---------|------------|
| Linked GTFS | http://vocab.gtfs.org/terms# | GTFS in RDF | https://github.com/OpenTransport/linked-gtfs |
| Transmodel | https://w3id.org/transmodel/terms# | European transit model | https://github.com/oeg-upm/transmodel-ontology |
| Linked Connections | http://semweb.mmlab.be/ns/linkedconnections# | Connection-based transit | Spec at linkedconnections.org |

### Benchmarks

| Benchmark | Focus | Repository |
|-----------|-------|------------|
| GTFS-Madrid-Bench | KG Construction, SPARQL | https://github.com/oeg-upm/gtfs-bench |

### Research Projects

| Project | Focus | Link |
|---------|-------|------|
| ONETT | NAP Knowledge Graphs | https://osoc-es.github.io/onett-paper/ |
| Linked Connections | Distributed routing | https://linkedconnections.org |
| SNAP | Transmodel ontology | https://oeg-upm.github.io/snap-docs/ |

---

## 13. Sample Implementation: Complete Workflow

### Scenario
A transit agency wants to publish both static and real-time data as RDF.

### Step 1: Publish Static GTFS as RDF

```bash
# Install gtfs2lc
npm install -g gtfs2lc

# Create URI templates (uris.json)
cat > uris.json <<EOF
{
  "stop": "http://example.org/stops/{stop_id}",
  "route": "http://example.org/routes/{route_id}",
  "trip": "http://example.org/trips/{trip_id}",
  "connection": "http://example.org/connections/{departureTime}/{trip.trip_id}"
}
EOF

# Convert GTFS to Linked Connections
gtfs2lc \
  --static gtfs.zip \
  --uris uris.json \
  --format jsonld \
  --store output/static-connections.jsonld
```

### Step 2: Publish Real-time GTFS-RT as RDF

```bash
# Install gtfsrt2lc
npm install -g gtfsrt2lc

# Convert GTFS-RT feed to Linked Connections (real-time updates)
gtfsrt2lc \
  --real-time https://api.example.org/gtfs-rt/trip-updates \
  --static gtfs.zip \
  --uris uris.json \
  --format jsonld \
  > output/realtime-updates.jsonld
```

### Step 3: Load into Triple Store

```bash
# Using Apache Jena Fuseki
# Start Fuseki server
fuseki-server --update --mem /transit

# Load static connections
curl -X POST \
  -H "Content-Type: application/ld+json" \
  --data-binary @output/static-connections.jsonld \
  http://localhost:3030/transit/data

# Load real-time updates
curl -X POST \
  -H "Content-Type: application/ld+json" \
  --data-binary @output/realtime-updates.jsonld \
  http://localhost:3030/transit/data
```

### Step 4: Query with SPARQL

```sparql
PREFIX lc: <http://semweb.mmlab.be/ns/linkedconnections#>
PREFIX gtfs: <http://vocab.gtfs.org/terms#>
PREFIX xsd: <http://www.w3.org/2001/XMLSchema#>

# Find all delayed connections in the next hour
SELECT ?connection ?route ?departureStop ?arrivalStop
       ?scheduledDeparture ?actualDeparture ?delay
WHERE {
  ?connection a lc:Connection ;
              lc:departureStop ?departureStop ;
              lc:arrivalStop ?arrivalStop ;
              lc:departureTime ?actualDeparture ;
              lc:departureDelay ?delay ;
              gtfs:route ?route .

  FILTER(?actualDeparture >= NOW() &&
         ?actualDeparture < NOW() + "PT1H"^^xsd:duration)
  FILTER(?delay > 60)

  BIND(?actualDeparture - ?delay AS ?scheduledDeparture)
}
ORDER BY ?actualDeparture
```

### Step 5: Publish as Linked Data Fragments

```javascript
// Server setup with Linked Data Fragments
const ldf = require('ldf-server');

const config = {
  title: "Transit Data",
  datasources: {
    transit: {
      title: "Real-time Transit Connections",
      type: "SparqlDatasource",
      settings: {
        endpoint: "http://localhost:3030/transit/sparql"
      }
    }
  },
  prefixes: {
    lc: "http://semweb.mmlab.be/ns/linkedconnections#",
    gtfs: "http://vocab.gtfs.org/terms#"
  }
};

ldf.start(config);
```

### Step 6: Continuous Updates

```javascript
// Scheduled real-time updates (every 30 seconds)
const cron = require('node-cron');
const { exec } = require('child_process');

cron.schedule('*/30 * * * * *', () => {
  exec(`gtfsrt2lc \
    --real-time https://api.example.org/gtfs-rt/trip-updates \
    --static gtfs.zip \
    --uris uris.json \
    --format jsonld | \
    curl -X POST -H "Content-Type: application/ld+json" \
      --data-binary @- \
      http://localhost:3030/transit/data`,
    (error, stdout, stderr) => {
      if (error) {
        console.error(`Error: ${error}`);
        return;
      }
      console.log(`Updated at ${new Date()}`);
    }
  );
});
```

---

## 14. Comparison: GTFS-RT Native vs RDF Representation

### GTFS-RT (Protocol Buffer)

**Advantages**:
- ✅ Compact binary format
- ✅ Fast parsing
- ✅ Wide tool support
- ✅ Direct integration with apps
- ✅ Low bandwidth

**Disadvantages**:
- ❌ No semantic linking
- ❌ Proprietary tooling required
- ❌ Limited queryability
- ❌ Single data source
- ❌ No reasoning capabilities

### GTFS-RT in RDF (Linked Connections)

**Advantages**:
- ✅ Semantic interoperability
- ✅ SPARQL queries
- ✅ Linkable to other datasets
- ✅ Standard web technologies
- ✅ Reasoning and inference
- ✅ Multi-source federation

**Disadvantages**:
- ❌ Larger file size
- ❌ More complex processing
- ❌ Fewer consumer apps
- ❌ Higher technical barrier
- ❌ Slower parsing (JSON-LD)

### Hybrid Approach (Recommended)

**Strategy**: Publish both formats
- GTFS-RT for consumer apps (Google Maps, etc.)
- RDF for data integration, research, advanced analytics

**Implementation**:
1. Generate GTFS-RT as primary format
2. Convert to RDF using gtfsrt2lc
3. Publish both via HTTP
4. Use content negotiation for RDF variants

---

## 15. Conclusion and Recommendations

### Key Findings

1. **Linked GTFS vocabulary** is well-established for static transit data in RDF
2. **Linked Connections framework** addresses real-time GTFS-RT via RDF
3. **gtfsrt2lc** is the primary tool for GTFS-RT to RDF conversion
4. **Transmodel ontology** provides European standard alignment
5. **Active research** continues in Knowledge Graph construction and querying

### Recommendations for Transit Agencies

#### Short-term (2025-2026)
- ✅ Continue publishing GTFS and GTFS-RT in native formats
- ✅ Experiment with gtfsrt2lc for RDF conversion
- ✅ Set up SPARQL endpoints for research/developer access
- ✅ Adopt stable URI strategies (RFC 6570 templates)

#### Medium-term (2026-2027)
- 🔄 Integrate RDF publishing into data pipelines
- 🔄 Participate in federated query initiatives
- 🔄 Align with Transmodel for EU compliance
- 🔄 Support Linked Data Fragments for scalability

#### Long-term (2027+)
- 🎯 Contribute to SIRI RDF standardization
- 🎯 Implement stream reasoning for predictive analytics
- 🎯 Join European Knowledge Graph federation
- 🎯 Leverage AI/ML over transit Knowledge Graphs

### Recommendations for Developers

- **Use gtfsrt2lc** for production GTFS-RT to RDF conversion
- **Adopt Linked Connections** for distributed routing applications
- **Leverage SPARQL** for multi-agency, multi-modal queries
- **Contribute to open-source** tools and ontologies
- **Follow W3C standards** (RDF, OWL, SPARQL, JSON-LD)

### Recommendations for Researchers

- **Build on GTFS-Madrid-Bench** for reproducible experiments
- **Extend Transmodel ontology** for new use cases
- **Develop stream reasoning** approaches for real-time data
- **Investigate federated queries** across European NAPs
- **Apply Graph ML** techniques to transit Knowledge Graphs

---

## 16. References and Further Reading

### Specifications and Standards
- GTFS Specification: https://gtfs.org
- GTFS Realtime Reference: https://gtfs.org/documentation/realtime/
- Linked Connections Specification: https://linkedconnections.org/specification/1-0
- R2RML W3C Recommendation: https://www.w3.org/TR/r2rml/
- RML Specification: https://rml.io/specs/rml/

### Ontologies
- Linked GTFS Vocabulary: http://vocab.gtfs.org/terms#
- Transmodel Ontology: https://w3id.org/transmodel/terms#
- GeoSPARQL: http://www.opengis.net/ont/geosparql

### Academic Papers
- Colpaert et al. (2015): "Intermodal public transit routing using Linked Connections"
- Chaves-Fraga et al. (2021): "Applying the LOT Methodology to a Public Bus Transport Ontology aligned with Transmodel"
- Dimou et al. (2014): "RML: A Generic Language for Integrated RDF Mappings of Heterogeneous Data"

### Tools and Code
- gtfsrt2lc: https://github.com/linkedconnections/gtfsrt2lc
- Linked GTFS: https://github.com/OpenTransport/linked-gtfs
- GTFS-Madrid-Bench: https://github.com/oeg-upm/gtfs-bench
- Transmodel Ontology: https://github.com/oeg-upm/transmodel-ontology
- SDM-RDFizer: https://github.com/SDM-TIB/SDM-RDFizer

### European Initiatives
- EU Regulation 2017/1926: Delegated Regulation on Multimodal Travel Information Services
- SNAP Project: https://oeg-upm.github.io/snap-docs/
- ONETT Paper: https://osoc-es.github.io/onett-paper/output/

---

## Document Information

**Version**: 1.0
**Date**: February 5, 2026
**Author**: Comparative Analysis of Real-time Transport Data Formats
**Status**: Comprehensive Review

**Updates**:
- Reflects state of art as of early 2025
- Includes latest research from Semantic Web Journal
- References active GitHub repositories
- Based on production implementations
