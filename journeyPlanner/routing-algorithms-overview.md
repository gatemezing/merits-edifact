# Routing algorithms overview (identified planners)

Reviewed: 2026-02-05

## Confidence legend
- **Documented**: explicitly stated by the provider in their public docs.
- **Inferred**: derived from the documented underlying engine used by the provider.
- **Not disclosed**: algorithm is not stated in public docs (as of the review date).

## Overview table

| Planner/API | Routing algorithms (documented) | Evidence type | Confidence | Notes |
| --- | --- | --- | --- | --- |
| Entur Journey Planner v3 | RAPTOR (OTP transit routing) | Inferred | Medium | Entur states it uses OpenTripPlanner; OTP router config documents RAPTOR for transit searches. |
| Digitransit Routing API | RAPTOR (OTP transit routing) | Inferred | Medium | Digitransit states its Routing API is implemented using OpenTripPlanner; OTP router config documents RAPTOR for transit searches. |
| Navitia | RAPTOR (multi-objective, Pareto) | Documented | High | Navitia docs explicitly describe RAPTOR as the algorithm used for journeys. |
| Transitous (MOTIS 2 API) | Modified RAPTOR (MOTIS “nigiri” core) | Inferred | Medium | Transitous provides the MOTIS 2 API; MOTIS v0.9 describes a modified RAPTOR in the new core. |
| Trafiklab SL Journey Planner v2 | Not disclosed | Not disclosed | High | Public API docs describe “best match” results but do not name a routing algorithm. |
| TfL Journey Planner API | Not disclosed | Not disclosed | High | Dataset/API listing does not document routing algorithm. |
| iRail API | Not disclosed | Not disclosed | High | API docs list endpoints and parameters but do not specify routing algorithm. |
| transport.opendata.ch | Not disclosed | Not disclosed | High | API docs describe endpoints and data structures but do not specify routing algorithm. |

## Sources
1. Entur Journey Planner v3 (uses OpenTripPlanner): https://developer.entur.org/pages-journeyplanner-journeyplanner/
2. Digitransit Routing API (implemented using OpenTripPlanner): https://www.digitransit.fi/en/developers/architecture/x-apis/1-routing-api/
3. OpenTripPlanner router config (transit searches with RAPTOR): https://docs.opentripplanner.org/en/dev-2.x/RouterConfiguration/
4. Navitia docs (RAPTOR algorithm described): https://doc.navitia.io/index.html
5. Transitous API (provides MOTIS 2 API): https://transitous.org/api/
6. MOTIS v0.9 (modified RAPTOR in new core): https://motis-project.de/release/2023/05/16/new-motis-core.html
7. Trafiklab SL Journey Planner v2 docs: https://www.trafiklab.se/api/sl-journey-planner-2
8. TfL Journey Planner API listing: https://findtransportdata.dft.gov.uk/dataset/tfl-journey-planner-api
9. iRail API docs: https://docs.irail.be/
10. transport.opendata.ch docs: https://transport.opendata.ch/docs.html
