# Open data journey planners in Europe - landscape review

Reviewed: 2026-02-04

## Scope
This review covers open data journey planners and APIs that aggregate multi-operator transport data in Europe. It also includes the data access layer and standards that enable cross-operator and cross-border routing.

## Executive takeaways
- National Access Points (NAPs) are the policy-backed data access layer: EU member states set up NAPs to facilitate access, exchange, and reuse of transport data, and NAPs can take multiple forms (portal, repository, marketplace, etc.).
- NAPCORE coordinates interoperability across Europe, but NAPs still differ in setup, interfaces, and data formats, which adds integration friction.
- OJP (Open Journey Planner) is the European standard for distributed journey planning and aligns with the EU MMTIS Delegated Regulation (EU) 2017/1926, amended by 2024/490.
- OJP is a CEN/TS 17118 standard and part of the Transmodel family alongside NeTEx and SIRI.
- Open-source engines (OpenTripPlanner and MOTIS) power many national and cross-border planners and enable data aggregation at scale.
- Notable open data planner APIs include Entur (Norway), Digitransit (Finland and Estonia), Trafiklab SL Journey Planner (Sweden), TfL Journey Planner (UK, London), iRail (Belgium), Navitia (France), transport.opendata.ch (Switzerland), and Transitous (pan-European).

## Ecosystem layers

### 1) Data access and policy (NAPs)
- EU member states are setting up NAPs to facilitate access, exchange, and reuse of transport data for EU-wide interoperable travel and traffic services.
- NAPs can be databases, data warehouses, marketplaces, repositories, or portals and provide discovery services.
- NAPCORE aims to improve interoperability and harmonization across NAPs, but NAPs remain heterogeneous in interfaces and data formats.

### 2) Standards and formats
- OJP is a standardized framework for multimodal, distributed journey planning and for combining real-time and scheduled data.
- OJP is a CEN/TS 17118 standard and part of the Transmodel family with NeTEx and SIRI.
- Many platforms still publish GTFS and GTFS-RT; engines like MOTIS support GTFS, GTFS-RT, and GBFS and are working on NeTEx and SIRI.

### 3) Open-source engines
- OpenTripPlanner (OTP) is widely deployed; official deployments include Norway (Entur) and Finland (Digitransit).
- MOTIS is an open-source multimodal routing platform with a REST API and is used by Transitous to provide a cross-border routing service.

### 4) Notable open-data planner APIs (examples)
- Entur Journey Planner v3 (Norway): GraphQL API for nationwide public transport journey planning with real-time info; OTP-based.
- Digitransit (Finland and Estonia): Routing API (OTP) plus routing data sets for Finland and Estonia, and geocoding/map/real-time APIs.
- HSL Journey Planner APIs (Helsinki region): Routing, geocoding, map, and real-time APIs via Digitransit.
- Trafiklab SL Journey Planner v2 (Stockholm County): travel proposals via API; no API key required.
- TfL Journey Planner API (London): XML responses; registration required; open licence listed in DfT catalogue.
- iRail API (Belgium): trains, stations, liveboards, connections.
- Navitia (France): journeys endpoint provides computed itineraries.
- transport.opendata.ch (Switzerland): unofficial API for Swiss public transport, based on search.ch data.
- Transitous (pan-European): community-run, provider-neutral routing using open data and FOSS, with a free API.

## Gaps and friction (observations)
- NAPs differ in setup and access interfaces; this implies extra normalization work for cross-border aggregation.
- API openness varies by country; many countries have NAPs or open data portals but limited open journey-planning APIs.

## Sources
1. EU Commission - National Access Points: https://transport.ec.europa.eu/transport-themes/smart-mobility/road/its-directive-and-action-plan/national-access-points_en
2. NAPCORE - National Access Point list and description: https://napcore.eu/description-naps/national-access-point/
3. UITP - NAPCORE overview (differences across NAPs): https://www.uitp.org/projects/napcore/
4. Transmodel (OJP overview and alignment with EU regulation): https://transmodel-cen.eu/index.php/ojp/
5. OJP GitHub (CEN/TS 17118, Transmodel family with NeTEx/SIRI): https://github.com/VDVde/OJP
6. OpenTripPlanner deployments (Entur, Digitransit, Plannerstack): https://opentripplanner.readthedocs.io/en/latest/Deployments/
7. MOTIS GitHub (platform description, supported formats, REST API): https://github.com/motis-project/motis
8. Entur Journey Planner v3 docs: https://developer.entur.org/pages-journeyplanner-journeyplanner/
9. Digitransit APIs: https://digitransit.fi/en/developers/apis/
10. Digitransit routing data API (Finland and Estonia datasets): https://digitransit.fi/en/developers/apis/2-routing-data-api/
11. HSL open data (Journey Planner APIs): https://www.hsl.fi/en/hsl/open-data
12. Trafiklab SL Journey-planner v2: https://www.trafiklab.se/api/sl-journey-planner-2
13. TfL Journey Planner API (DfT catalogue entry): https://findtransportdata.dft.gov.uk/dataset/tfl-journey-planner-api
14. iRail API docs: https://docs.irail.be/
15. Navitia docs (journeys endpoint): https://doc.navitia.io/
16. Transport API (Switzerland): https://transport.opendata.ch/
17. Transitous: https://transitous.org/
