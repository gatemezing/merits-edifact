# Comparative Review of Real-Time Transport Data Formats

## Executive Summary

This document provides a comprehensive comparison of the major data formats used for aggregating and exchanging real-time transport data. The analysis covers five primary formats: GTFS-RT, SIRI, NeTEx (with SIRI), TransXChange, and SIRI Lite.

---

## 1. GTFS-RT (General Transit Feed Specification - Realtime)

### Overview
- **Developer**: Google (2011)
- **Format**: Protocol Buffers (binary)
- **Geographic Adoption**: Worldwide, particularly strong in North America
- **Status**: De facto global standard

### Key Characteristics

**Strengths:**
- Highly compact binary format (Protocol Buffers)
- Efficient data transmission
- Wide adoption and tool support
- Direct integration with Google Maps and major journey planners
- Well-documented with extensive developer community
- Three focused feed types: Trip Updates, Vehicle Positions, Service Alerts

**Limitations:**
- Limited compared to European standards in terms of functionality scope
- Less detailed than SIRI for complex operational scenarios
- Not mandated by EU regulations

**Use Cases:**
- Real-time arrival/departure predictions
- Service alerts and disruptions
- Vehicle tracking and positioning
- Integration with consumer apps

### Technical Details
- **Protocol**: Protocol Buffers (protobuf)
- **Transport**: HTTP/HTTPS
- **Update Frequency**: Typically 30 seconds to 2 minutes
- **File Size**: Very compact (binary)

### Sample Data: GTFS-RT Trip Updates (Protocol Buffer Text Format)

```protobuf
# GTFS-RT Trip Update Feed Example
header {
  gtfs_realtime_version: "2.0"
  incrementality: FULL_DATASET
  timestamp: 1643723400
}

entity {
  id: "trip_update_1"
  trip_update {
    trip {
      trip_id: "route_1_north_weekday"
      route_id: "route_1"
      direction_id: 0
      start_time: "08:30:00"
      start_date: "20260205"
      schedule_relationship: SCHEDULED
    }
    vehicle {
      id: "vehicle_1001"
      label: "Bus 1001"
    }
    stop_time_update {
      stop_sequence: 1
      stop_id: "stop_main_st_1"
      arrival {
        delay: 120
        time: 1643723520
        uncertainty: 0
      }
      departure {
        delay: 120
        time: 1643723580
        uncertainty: 0
      }
      schedule_relationship: SCHEDULED
    }
    stop_time_update {
      stop_sequence: 2
      stop_id: "stop_elm_st_2"
      arrival {
        delay: 180
        time: 1643724120
      }
      departure {
        delay: 180
        time: 1643724180
      }
      schedule_relationship: SCHEDULED
    }
    timestamp: 1643723400
  }
}

entity {
  id: "trip_update_2"
  trip_update {
    trip {
      trip_id: "route_2_south_weekday"
      route_id: "route_2"
      direction_id: 1
      start_date: "20260205"
      schedule_relationship: CANCELED
    }
    timestamp: 1643723400
  }
}
```

### Sample Data: GTFS-RT Vehicle Positions

```protobuf
# GTFS-RT Vehicle Positions Feed Example
header {
  gtfs_realtime_version: "2.0"
  incrementality: FULL_DATASET
  timestamp: 1643723400
}

entity {
  id: "vehicle_position_1"
  vehicle {
    trip {
      trip_id: "route_1_north_weekday"
      route_id: "route_1"
      direction_id: 0
      start_date: "20260205"
    }
    vehicle {
      id: "vehicle_1001"
      label: "Bus 1001"
      license_plate: "ABC123"
    }
    position {
      latitude: 37.7749
      longitude: -122.4194
      bearing: 45.0
      speed: 12.5
    }
    current_stop_sequence: 5
    stop_id: "stop_market_st_5"
    current_status: IN_TRANSIT_TO
    timestamp: 1643723398
    congestion_level: CONGESTION
    occupancy_status: MANY_SEATS_AVAILABLE
  }
}

entity {
  id: "vehicle_position_2"
  vehicle {
    trip {
      trip_id: "route_3_east_weekday"
      route_id: "route_3"
    }
    vehicle {
      id: "vehicle_2005"
    }
    position {
      latitude: 37.8044
      longitude: -122.2712
    }
    current_status: STOPPED_AT
    stop_id: "stop_broadway_8"
    timestamp: 1643723395
    occupancy_status: FULL
  }
}
```

### Sample Data: GTFS-RT Service Alerts

```protobuf
# GTFS-RT Service Alerts Feed Example
header {
  gtfs_realtime_version: "2.0"
  incrementality: FULL_DATASET
  timestamp: 1643723400
}

entity {
  id: "alert_1"
  alert {
    active_period {
      start: 1643720000
      end: 1643806800
    }
    informed_entity {
      route_id: "route_1"
    }
    informed_entity {
      route_id: "route_2"
    }
    cause: CONSTRUCTION
    effect: DETOUR
    url {
      translation {
        text: "https://transit.example.com/alerts/construction-detour"
        language: "en"
      }
    }
    header_text {
      translation {
        text: "Route 1 and 2 Detour Due to Construction"
        language: "en"
      }
    }
    description_text {
      translation {
        text: "Routes 1 and 2 are temporarily detoured due to road construction on Main Street. Expect delays of 10-15 minutes. Alternative stops are located on Elm Street."
        language: "en"
      }
      translation {
        text: "Les lignes 1 et 2 sont temporairement déviées en raison de travaux routiers sur Main Street. Attendez-vous à des retards de 10 à 15 minutes."
        language: "fr"
      }
    }
    severity_level: MODERATE_SEVERITY
  }
}
```

---

## 2. SIRI (Service Interface for Real-time Information)

### Overview
- **Developer**: CEN (European Committee for Standardization), 2006
- **Format**: XML (SOAP protocol)
- **Geographic Adoption**: European standard, mandatory for EU member states
- **Status**: De jure European standard

### Key Characteristics

**Strengths:**
- Comprehensive European standard
- Eight specialized service profiles for different needs
- Detailed operational data exchange
- Officially mandated by EU regulations
- Complementary to NeTEx for static data
- Rich metadata and contextual information

**Limitations:**
- XML format is verbose and larger in size
- SOAP protocol can be complex to implement
- Less adoption outside Europe
- More complex than GTFS-RT

**Service Profiles (8 types):**
1. **SIRI-SM** - Stop Monitoring (real-time arrivals at stops)
2. **SIRI-VM** - Vehicle Monitoring (vehicle locations and progress)
3. **SIRI-ET** - Estimated Timetable (predictions for entire journeys)
4. **SIRI-SX** - Situation Exchange (service alerts and disruptions)
5. **SIRI-PT** - Production Timetable (actual operations vs planned)
6. **SIRI-FM** - Facility Monitoring (station/stop facilities status)
7. **SIRI-CM** - Connection Monitoring (guaranteed connections)
8. **SIRI-GM** - General Message (general information messages)

### Technical Details
- **Protocol**: SOAP (XML)
- **Transport**: HTTP/HTTPS
- **Format Size**: Verbose (XML text)
- **Update Frequency**: Variable, typically 30 seconds to 2 minutes

### Sample Data: SIRI Vehicle Monitoring (SIRI-VM)

```xml
<?xml version="1.0" encoding="UTF-8"?>
<Siri version="2.0" xmlns="http://www.siri.org.uk/siri"
      xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
  <ServiceDelivery>
    <ResponseTimestamp>2026-02-05T14:30:00Z</ResponseTimestamp>
    <ProducerRef>TransitAgency123</ProducerRef>
    <ResponseMessageIdentifier>VM-20260205-143000-001</ResponseMessageIdentifier>

    <VehicleMonitoringDelivery version="2.0">
      <ResponseTimestamp>2026-02-05T14:30:00Z</ResponseTimestamp>
      <RequestMessageRef>VM-REQ-001</RequestMessageRef>
      <ValidUntil>2026-02-05T14:31:00Z</ValidUntil>
      <ShortestPossibleCycle>PT30S</ShortestPossibleCycle>

      <VehicleActivity>
        <RecordedAtTime>2026-02-05T14:29:55Z</RecordedAtTime>
        <ItemIdentifier>VA-1001-20260205</ItemIdentifier>
        <ValidUntilTime>2026-02-05T14:31:00Z</ValidUntilTime>

        <MonitoredVehicleJourney>
          <LineRef>Line_1</LineRef>
          <DirectionRef>Northbound</DirectionRef>
          <FramedVehicleJourneyRef>
            <DataFrameRef>2026-02-05</DataFrameRef>
            <DatedVehicleJourneyRef>Trip_1_20260205_0830</DatedVehicleJourneyRef>
          </FramedVehicleJourneyRef>

          <PublishedLineName>Route 1 - City Center</PublishedLineName>
          <OperatorRef>Operator_ABC</OperatorRef>
          <ProductCategoryRef>Bus</ProductCategoryRef>

          <VehicleRef>Vehicle_1001</VehicleRef>
          <VehicleLocation>
            <Longitude>-122.419400</Longitude>
            <Latitude>37.774900</Latitude>
          </VehicleLocation>
          <Bearing>45.0</Bearing>
          <Velocity>12.5</Velocity>

          <Occupancy>seatsAvailable</Occupancy>

          <OriginRef>Stop_Start</OriginRef>
          <OriginName>Main Terminal</OriginName>
          <OriginAimedDepartureTime>2026-02-05T08:30:00Z</OriginAimedDepartureTime>

          <DestinationRef>Stop_End</DestinationRef>
          <DestinationName>North Station</DestinationName>
          <DestinationAimedArrivalTime>2026-02-05T09:30:00Z</DestinationAimedArrivalTime>

          <Monitored>true</Monitored>
          <InCongestion>true</InCongestion>
          <InPanic>false</InPanic>

          <MonitoredCall>
            <StopPointRef>Stop_Market_St_5</StopPointRef>
            <StopPointName>Market Street at 5th Avenue</StopPointName>
            <VehicleAtStop>false</VehicleAtStop>
            <AimedArrivalTime>2026-02-05T08:45:00Z</AimedArrivalTime>
            <ExpectedArrivalTime>2026-02-05T08:47:00Z</ExpectedArrivalTime>
            <ArrivalStatus>delayed</ArrivalStatus>
            <AimedDepartureTime>2026-02-05T08:46:00Z</AimedDepartureTime>
            <ExpectedDepartureTime>2026-02-05T08:48:00Z</ExpectedDepartureTime>
            <DepartureStatus>delayed</DepartureStatus>
          </MonitoredCall>

          <VehicleJourneyInfoGroup>
            <VehicleJourneyName>Morning Express</VehicleJourneyName>
          </VehicleJourneyInfoGroup>

        </MonitoredVehicleJourney>

        <Extensions>
          <VehicleFeatures>
            <WheelchairAccessible>true</WheelchairAccessible>
            <LowFloor>true</LowFloor>
            <AirConditioned>true</AirConditioned>
          </VehicleFeatures>
        </Extensions>
      </VehicleActivity>

      <VehicleActivity>
        <RecordedAtTime>2026-02-05T14:29:58Z</RecordedAtTime>
        <ItemIdentifier>VA-2005-20260205</ItemIdentifier>
        <ValidUntilTime>2026-02-05T14:31:00Z</ValidUntilTime>

        <MonitoredVehicleJourney>
          <LineRef>Line_3</LineRef>
          <DirectionRef>Eastbound</DirectionRef>
          <FramedVehicleJourneyRef>
            <DataFrameRef>2026-02-05</DataFrameRef>
            <DatedVehicleJourneyRef>Trip_3_20260205_0900</DatedVehicleJourneyRef>
          </FramedVehicleJourneyRef>

          <PublishedLineName>Route 3 - Crosstown</PublishedLineName>
          <VehicleRef>Vehicle_2005</VehicleRef>
          <VehicleLocation>
            <Longitude>-122.271200</Longitude>
            <Latitude>37.804400</Latitude>
          </VehicleLocation>

          <Occupancy>full</Occupancy>
          <Monitored>true</Monitored>

          <MonitoredCall>
            <StopPointRef>Stop_Broadway_8</StopPointRef>
            <StopPointName>Broadway at 8th Street</StopPointName>
            <VehicleAtStop>true</VehicleAtStop>
            <AimedArrivalTime>2026-02-05T14:29:00Z</AimedArrivalTime>
            <ExpectedArrivalTime>2026-02-05T14:29:00Z</ExpectedArrivalTime>
            <ArrivalStatus>onTime</ArrivalStatus>
          </MonitoredCall>
        </MonitoredVehicleJourney>
      </VehicleActivity>

    </VehicleMonitoringDelivery>
  </ServiceDelivery>
</Siri>
```

### Sample Data: SIRI Situation Exchange (SIRI-SX)

```xml
<?xml version="1.0" encoding="UTF-8"?>
<Siri version="2.0" xmlns="http://www.siri.org.uk/siri">
  <ServiceDelivery>
    <ResponseTimestamp>2026-02-05T14:30:00Z</ResponseTimestamp>
    <ProducerRef>TransitAgency123</ProducerRef>
    <ResponseMessageIdentifier>SX-20260205-143000-001</ResponseMessageIdentifier>

    <SituationExchangeDelivery version="2.0">
      <ResponseTimestamp>2026-02-05T14:30:00Z</ResponseTimestamp>

      <Situations>
        <PtSituationElement>
          <CreationTime>2026-02-05T06:00:00Z</CreationTime>
          <ParticipantRef>TransitAgency123</ParticipantRef>
          <SituationNumber>ALERT-2026-001</SituationNumber>
          <Version>1</Version>

          <Source>
            <SourceType>directReport</SourceType>
          </Source>

          <Progress>open</Progress>
          <ValidityPeriod>
            <StartTime>2026-02-05T08:00:00Z</StartTime>
            <EndTime>2026-02-05T18:00:00Z</EndTime>
          </ValidityPeriod>

          <Severity>normal</Severity>
          <Priority>3</Priority>

          <ReportType>incident</ReportType>
          <Planned>true</Planned>

          <Summary xml:lang="en">Route 1 and 2 Detour Due to Construction</Summary>
          <Description xml:lang="en">
            Routes 1 and 2 are temporarily detoured due to road construction
            on Main Street between 5th and 10th Avenues. Expect delays of
            10-15 minutes. Alternative stops are located on Elm Street.
          </Description>
          <Description xml:lang="fr">
            Les lignes 1 et 2 sont temporairement déviées en raison de travaux
            routiers sur Main Street. Attendez-vous à des retards de 10 à 15 minutes.
          </Description>

          <Affects>
            <Networks>
              <AffectedNetwork>
                <AffectedLine>
                  <LineRef>Line_1</LineRef>
                  <PublishedLineName>Route 1</PublishedLineName>
                </AffectedLine>
              </AffectedNetwork>
              <AffectedNetwork>
                <AffectedLine>
                  <LineRef>Line_2</LineRef>
                  <PublishedLineName>Route 2</PublishedLineName>
                </AffectedLine>
              </AffectedNetwork>
            </Networks>
          </Affects>

          <Consequences>
            <Consequence>
              <Condition>altered</Condition>
              <Severity>normal</Severity>
              <Affects>
                <Networks>
                  <AffectedNetwork>
                    <AffectedLine>
                      <LineRef>Line_1</LineRef>
                    </AffectedLine>
                  </AffectedNetwork>
                </Networks>
              </Affects>
              <Advice>
                <Details xml:lang="en">
                  Please allow extra travel time. Use stops on Elm Street
                  as alternatives to Main Street stops.
                </Details>
              </Advice>
              <Delays>
                <Delay>PT15M</Delay>
              </Delays>
            </Consequence>
          </Consequences>

        </PtSituationElement>
      </Situations>

    </SituationExchangeDelivery>
  </ServiceDelivery>
</Siri>
```

---

## 3. NeTEx (Network Timetable Exchange) with SIRI

### Overview
- **Developer**: CEN (European Committee for Standardization)
- **Format**: XML
- **Geographic Adoption**: European standard, mandatory for EU member states
- **Status**: De jure European standard for static data

### Key Characteristics

**Strengths:**
- Comprehensive data model based on Transmodel
- Extremely wide functional scope (broader than GTFS)
- Handles complex fare structures
- Detailed network topology
- European mandate through EU regulations
- Integrated with SIRI for real-time data

**Limitations:**
- Very complex specification
- Steep learning curve
- XML format is verbose
- Less adoption outside Europe
- Limited tool support compared to GTFS

**Use Cases:**
- Static timetable data
- Complex fare structures
- Network topology and infrastructure
- Multi-modal journey planning
- Used with SIRI for complete static + real-time solution

### Technical Details
- **Protocol**: XML files
- **Data Type**: Primarily static/scheduled data
- **Complementary**: SIRI for real-time, NeTEx for static
- **Scope**: Extremely comprehensive

### Sample Data: NeTEx Timetable Data (Simplified)

```xml
<?xml version="1.0" encoding="UTF-8"?>
<PublicationDelivery version="1.1"
  xmlns="http://www.netex.org.uk/netex"
  xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">

  <PublicationTimestamp>2026-02-05T00:00:00Z</PublicationTimestamp>
  <ParticipantRef>TransitAgency123</ParticipantRef>
  <PublicationRequest version="1.0">
    <RequestTimestamp>2026-02-04T12:00:00Z</RequestTimestamp>
  </PublicationRequest>

  <dataObjects>
    <CompositeFrame version="1" id="TA123:CompositeFrame:Winter2026">
      <ValidityConditions>
        <ValidBetween>
          <FromDate>2026-02-01T00:00:00Z</FromDate>
          <ToDate>2026-04-30T23:59:59Z</ToDate>
        </ValidBetween>
      </ValidityConditions>

      <frames>
        <!-- RESOURCE FRAME: Network, Lines, Routes -->
        <ResourceFrame version="1" id="TA123:ResourceFrame:Network">
          <organisations>
            <Operator version="1" id="TA123:Operator:ABC">
              <Name>ABC Transit Company</Name>
              <ContactDetails>
                <Phone>+1-555-0100</Phone>
                <Url>https://www.abctransit.example.com</Url>
              </ContactDetails>
            </Operator>
          </organisations>
        </ResourceFrame>

        <!-- SERVICE FRAME: Lines and Routes -->
        <ServiceFrame version="1" id="TA123:ServiceFrame:Lines">
          <Network version="1" id="TA123:Network:MainNetwork">
            <Name>ABC Transit Network</Name>
            <TransportOrganisationRef ref="TA123:Operator:ABC"/>
          </Network>

          <lines>
            <Line version="1" id="TA123:Line:1">
              <Name>Route 1</Name>
              <PublicCode>1</PublicCode>
              <TransportMode>bus</TransportMode>
              <OperatorRef ref="TA123:Operator:ABC"/>
              <routes>
                <Route version="1" id="TA123:Route:1_North">
                  <Name>Route 1 Northbound</Name>
                  <DirectionType>inbound</DirectionType>
                  <PointsInSequence>
                    <PointOnRoute order="1" version="1" id="TA123:PointOnRoute:1N_P1">
                      <RoutePointRef ref="TA123:RoutePoint:MainTerminal"/>
                    </PointOnRoute>
                    <PointOnRoute order="2" version="1" id="TA123:PointOnRoute:1N_P2">
                      <RoutePointRef ref="TA123:RoutePoint:MarketSt5"/>
                    </PointOnRoute>
                    <PointOnRoute order="3" version="1" id="TA123:PointOnRoute:1N_P3">
                      <RoutePointRef ref="TA123:RoutePoint:NorthStation"/>
                    </PointOnRoute>
                  </PointsInSequence>
                </Route>
              </routes>
            </Line>
          </lines>
        </ServiceFrame>

        <!-- TIMETABLE FRAME: Service Patterns and Journey Patterns -->
        <TimetableFrame version="1" id="TA123:TimetableFrame:Winter2026">
          <vehicleJourneys>
            <ServiceJourney version="1" id="TA123:ServiceJourney:1_North_0830">
              <Name>Route 1 North - 08:30 Departure</Name>
              <DepartureTime>08:30:00</DepartureTime>
              <dayTypes>
                <DayTypeRef ref="TA123:DayType:Weekday"/>
              </dayTypes>
              <JourneyPatternRef ref="TA123:JourneyPattern:1_North"/>
              <OperatorRef ref="TA123:Operator:ABC"/>
              <LineRef ref="TA123:Line:1"/>

              <passingTimes>
                <TimetabledPassingTime version="1" id="TA123:TPT:1N_0830_1">
                  <StopPointInJourneyPatternRef ref="TA123:SPIJP:1N_1"/>
                  <DepartureTime>08:30:00</DepartureTime>
                </TimetabledPassingTime>
                <TimetabledPassingTime version="1" id="TA123:TPT:1N_0830_2">
                  <StopPointInJourneyPatternRef ref="TA123:SPIJP:1N_2"/>
                  <ArrivalTime>08:45:00</ArrivalTime>
                  <DepartureTime>08:46:00</DepartureTime>
                </TimetabledPassingTime>
                <TimetabledPassingTime version="1" id="TA123:TPT:1N_0830_3">
                  <StopPointInJourneyPatternRef ref="TA123:SPIJP:1N_3"/>
                  <ArrivalTime>09:30:00</ArrivalTime>
                </TimetabledPassingTime>
              </passingTimes>
            </ServiceJourney>
          </vehicleJourneys>
        </TimetableFrame>

        <!-- SITE FRAME: Stops and Infrastructure -->
        <SiteFrame version="1" id="TA123:SiteFrame:Stops">
          <stopPlaces>
            <StopPlace version="1" id="TA123:StopPlace:MainTerminal">
              <Name>Main Terminal</Name>
              <Centroid>
                <Location>
                  <Longitude>-122.419500</Longitude>
                  <Latitude>37.774800</Latitude>
                </Location>
              </Centroid>
              <TransportMode>bus</TransportMode>
              <StopPlaceType>onstreetBus</StopPlaceType>
              <quays>
                <Quay version="1" id="TA123:Quay:MainTerminal_1">
                  <Name>Platform 1</Name>
                  <PublicCode>1</PublicCode>
                  <Centroid>
                    <Location>
                      <Longitude>-122.419500</Longitude>
                      <Latitude>37.774800</Latitude>
                    </Location>
                  </Centroid>
                </Quay>
              </quays>
            </StopPlace>

            <StopPlace version="1" id="TA123:StopPlace:MarketSt5">
              <Name>Market Street at 5th Avenue</Name>
              <Centroid>
                <Location>
                  <Longitude>-122.419400</Longitude>
                  <Latitude>37.774900</Latitude>
                </Location>
              </Centroid>
              <TransportMode>bus</TransportMode>
            </StopPlace>
          </stopPlaces>
        </SiteFrame>

      </frames>
    </CompositeFrame>
  </dataObjects>

</PublicationDelivery>
```

---

## 4. TransXChange

### Overview
- **Developer**: UK Department for Transport
- **Format**: XML
- **Geographic Adoption**: United Kingdom national standard
- **Status**: UK national standard for bus data

### Key Characteristics

**Strengths:**
- UK-specific standard with government backing
- Comprehensive for bus services
- Integrated with UK National Access Points
- Detailed operational information
- Part of coherent UK transport data family

**Limitations:**
- UK-specific, limited international adoption
- XML format verbosity
- Primarily focused on buses
- Complex specification
- Less suitable for multi-modal systems

**Use Cases:**
- UK bus timetables and routes
- Integration with UK journey planners
- Compliance with UK regulations
- Bus operator reporting

### Technical Details
- **Protocol**: XML files
- **Transport Mode**: Primarily buses
- **Data Type**: Static/scheduled data
- **Geographic**: UK-specific

### Sample Data: TransXChange Bus Timetable

```xml
<?xml version="1.0" encoding="UTF-8"?>
<TransXChange
  xmlns="http://www.transxchange.org.uk/"
  xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
  CreationDateTime="2026-02-05T00:00:00"
  ModificationDateTime="2026-02-05T00:00:00"
  Modification="new"
  RevisionNumber="1"
  SchemaVersion="2.5">

  <ServicedOrganisations>
    <ServicedOrganisation>
      <OrganisationCode>ABC</OrganisationCode>
      <Name>ABC Bus Company</Name>
      <WorkingDays>
        <DateRange>
          <StartDate>2026-02-01</StartDate>
          <EndDate>2026-04-30</EndDate>
        </DateRange>
      </WorkingDays>
    </ServicedOrganisation>
  </ServicedOrganisations>

  <Operators>
    <Operator id="OP001">
      <OperatorCode>ABC</OperatorCode>
      <OperatorShortName>ABC Buses</OperatorShortName>
      <OperatorNameOnLicence>ABC Bus Company Limited</OperatorNameOnLicence>
      <TradingName>ABC Buses</TradingName>
    </Operator>
  </Operators>

  <Services>
    <Service>
      <ServiceCode>SVC001</ServiceCode>
      <PrivateCode>Route1</PrivateCode>
      <Lines>
        <Line id="LINE001">
          <LineName>1</LineName>
        </Line>
      </Lines>

      <OperatingPeriod>
        <StartDate>2026-02-01</StartDate>
        <EndDate>2026-04-30</EndDate>
      </OperatingPeriod>

      <OperatingProfile>
        <RegularDayType>
          <DaysOfWeek>
            <Monday/>
            <Tuesday/>
            <Wednesday/>
            <Thursday/>
            <Friday/>
          </DaysOfWeek>
        </RegularDayType>
      </OperatingProfile>

      <RegisteredOperatorRef>OP001</RegisteredOperatorRef>
      <Mode>bus</Mode>
      <Description>City Centre to North Station via Market Street</Description>

      <StandardService>
        <Origin>Main Terminal</Origin>
        <Destination>North Station</Destination>

        <JourneyPattern id="JP001">
          <Direction>outbound</Direction>
          <RouteRef>ROUTE001</RouteRef>
          <JourneyPatternSectionRefs>JPS001</JourneyPatternSectionRefs>
        </JourneyPattern>

        <JourneyPatternSection id="JPS001">
          <JourneyPatternTimingLink id="JPTL001">
            <From>
              <StopPointRef>STOP001</StopPointRef>
              <TimingStatus>PTP</TimingStatus>
            </From>
            <To>
              <StopPointRef>STOP002</StopPointRef>
              <TimingStatus>TIP</TimingStatus>
            </To>
            <RouteLinkRef>RL001</RouteLinkRef>
            <RunTime>PT15M</RunTime>
            <WaitTime>PT1M</WaitTime>
          </JourneyPatternTimingLink>

          <JourneyPatternTimingLink id="JPTL002">
            <From>
              <StopPointRef>STOP002</StopPointRef>
              <TimingStatus>TIP</TimingStatus>
            </From>
            <To>
              <StopPointRef>STOP003</StopPointRef>
              <TimingStatus>PTP</TimingStatus>
            </To>
            <RouteLinkRef>RL002</RouteLinkRef>
            <RunTime>PT44M</RunTime>
          </JourneyPatternTimingLink>
        </JourneyPatternSection>
      </StandardService>

      <VehicleJourney>
        <VehicleJourneyCode>VJ001</VehicleJourneyCode>
        <ServiceRef>SVC001</ServiceRef>
        <LineRef>LINE001</LineRef>
        <JourneyPatternRef>JP001</JourneyPatternRef>
        <DepartureTime>08:30:00</DepartureTime>
        <Operational>
          <TicketMachine>
            <JourneyCode>0830</JourneyCode>
          </TicketMachine>
        </Operational>
      </VehicleJourney>

      <VehicleJourney>
        <VehicleJourneyCode>VJ002</VehicleJourneyCode>
        <ServiceRef>SVC001</ServiceRef>
        <LineRef>LINE001</LineRef>
        <JourneyPatternRef>JP001</JourneyPatternRef>
        <DepartureTime>09:00:00</DepartureTime>
      </VehicleJourney>

    </Service>
  </Services>

  <StopPoints>
    <AnnotatedStopPointRef>
      <StopPointRef>STOP001</StopPointRef>
      <CommonName>Main Terminal</CommonName>
      <LocalityName>City Centre</LocalityName>
      <Location>
        <Longitude>-122.419500</Longitude>
        <Latitude>37.774800</Latitude>
      </Location>
    </AnnotatedStopPointRef>

    <AnnotatedStopPointRef>
      <StopPointRef>STOP002</StopPointRef>
      <CommonName>Market Street at 5th Avenue</CommonName>
      <LocalityName>Downtown</LocalityName>
      <Location>
        <Longitude>-122.419400</Longitude>
        <Latitude>37.774900</Latitude>
      </Location>
    </AnnotatedStopPointRef>

    <AnnotatedStopPointRef>
      <StopPointRef>STOP003</StopPointRef>
      <CommonName>North Station</CommonName>
      <LocalityName>North District</LocalityName>
      <Location>
        <Longitude>-122.420000</Longitude>
        <Latitude>37.780000</Latitude>
      </Location>
    </AnnotatedStopPointRef>
  </StopPoints>

  <RouteSections>
    <RouteSection id="RS001">
      <RouteLink id="RL001">
        <From>
          <StopPointRef>STOP001</StopPointRef>
        </From>
        <To>
          <StopPointRef>STOP002</StopPointRef>
        </To>
        <Direction>outbound</Direction>
        <Distance>2500</Distance>
      </RouteLink>

      <RouteLink id="RL002">
        <From>
          <StopPointRef>STOP002</StopPointRef>
        </From>
        <To>
          <StopPointRef>STOP003</StopPointRef>
        </To>
        <Direction>outbound</Direction>
        <Distance>8500</Distance>
      </RouteLink>
    </RouteSection>
  </RouteSections>

  <Routes>
    <Route id="ROUTE001">
      <PrivateCode>R1</PrivateCode>
      <Description>City Centre to North via Market St</Description>
      <RouteSectionRef>RS001</RouteSectionRef>
    </Route>
  </Routes>

</TransXChange>
```

---

## 5. SIRI Lite

### Overview
- **Developer**: Derived from SIRI standard
- **Format**: JSON (REST API)
- **Geographic Adoption**: Emerging, particularly in Europe
- **Status**: Modern simplification of SIRI

### Key Characteristics

**Strengths:**
- Modern REST architecture
- JSON format (lightweight, developer-friendly)
- Easier integration than SOAP-based SIRI
- Maintains SIRI functionality
- Better suited for web and mobile apps
- Lower barrier to entry

**Limitations:**
- Newer standard with less mature tooling
- Less comprehensive than full SIRI
- Still primarily European-focused
- Smaller ecosystem compared to GTFS-RT

**Use Cases:**
- Modern web and mobile applications
- Simplified real-time transit apps
- RESTful API integrations
- Lightweight real-time data exchange

### Technical Details
- **Protocol**: REST (HTTP/HTTPS)
- **Format**: JSON
- **Transport**: HTTP/HTTPS GET/POST
- **Update Frequency**: Similar to SIRI (30s - 2min)

### Sample Data: SIRI Lite Stop Monitoring (JSON)

```json
{
  "Siri": {
    "ServiceDelivery": {
      "ResponseTimestamp": "2026-02-05T14:30:00Z",
      "ProducerRef": "TransitAgency123",
      "ResponseMessageIdentifier": "SM-20260205-143000-001",
      "StopMonitoringDelivery": [
        {
          "version": "2.0",
          "ResponseTimestamp": "2026-02-05T14:30:00Z",
          "RequestMessageRef": "SM-REQ-001",
          "ValidUntil": "2026-02-05T14:31:00Z",
          "MonitoredStopVisit": [
            {
              "RecordedAtTime": "2026-02-05T14:29:55Z",
              "ItemIdentifier": "MSV-STOP002-001",
              "MonitoringRef": "STOP002",
              "MonitoredVehicleJourney": {
                "LineRef": "Line_1",
                "DirectionRef": "Northbound",
                "FramedVehicleJourneyRef": {
                  "DataFrameRef": "2026-02-05",
                  "DatedVehicleJourneyRef": "Trip_1_20260205_0830"
                },
                "PublishedLineName": "Route 1 - City Center",
                "OperatorRef": "Operator_ABC",
                "OriginRef": "STOP001",
                "OriginName": "Main Terminal",
                "DestinationRef": "STOP003",
                "DestinationName": "North Station",
                "OriginAimedDepartureTime": "2026-02-05T08:30:00Z",
                "Monitored": true,
                "VehicleLocation": {
                  "Longitude": -122.419200,
                  "Latitude": 37.774850
                },
                "Bearing": 45.0,
                "Velocity": 10.5,
                "VehicleRef": "Vehicle_1001",
                "MonitoredCall": {
                  "StopPointRef": "STOP002",
                  "StopPointName": "Market Street at 5th Avenue",
                  "VehicleAtStop": false,
                  "AimedArrivalTime": "2026-02-05T08:45:00Z",
                  "ExpectedArrivalTime": "2026-02-05T08:47:00Z",
                  "ArrivalStatus": "delayed",
                  "AimedDepartureTime": "2026-02-05T08:46:00Z",
                  "ExpectedDepartureTime": "2026-02-05T08:48:00Z",
                  "DepartureStatus": "delayed"
                }
              }
            },
            {
              "RecordedAtTime": "2026-02-05T14:29:58Z",
              "ItemIdentifier": "MSV-STOP002-002",
              "MonitoringRef": "STOP002",
              "MonitoredVehicleJourney": {
                "LineRef": "Line_1",
                "DirectionRef": "Northbound",
                "FramedVehicleJourneyRef": {
                  "DataFrameRef": "2026-02-05",
                  "DatedVehicleJourneyRef": "Trip_1_20260205_0900"
                },
                "PublishedLineName": "Route 1 - City Center",
                "OperatorRef": "Operator_ABC",
                "OriginName": "Main Terminal",
                "DestinationName": "North Station",
                "OriginAimedDepartureTime": "2026-02-05T09:00:00Z",
                "Monitored": true,
                "VehicleRef": "Vehicle_1002",
                "MonitoredCall": {
                  "StopPointRef": "STOP002",
                  "StopPointName": "Market Street at 5th Avenue",
                  "VehicleAtStop": false,
                  "AimedArrivalTime": "2026-02-05T09:15:00Z",
                  "ExpectedArrivalTime": "2026-02-05T09:15:00Z",
                  "ArrivalStatus": "onTime",
                  "AimedDepartureTime": "2026-02-05T09:16:00Z",
                  "ExpectedDepartureTime": "2026-02-05T09:16:00Z",
                  "DepartureStatus": "onTime"
                }
              }
            }
          ]
        }
      ]
    }
  }
}
```

### Sample Data: SIRI Lite Vehicle Monitoring (JSON)

```json
{
  "Siri": {
    "ServiceDelivery": {
      "ResponseTimestamp": "2026-02-05T14:30:00Z",
      "ProducerRef": "TransitAgency123",
      "VehicleMonitoringDelivery": [
        {
          "version": "2.0",
          "ResponseTimestamp": "2026-02-05T14:30:00Z",
          "VehicleActivity": [
            {
              "RecordedAtTime": "2026-02-05T14:29:55Z",
              "ItemIdentifier": "VA-1001-20260205",
              "ValidUntilTime": "2026-02-05T14:31:00Z",
              "MonitoredVehicleJourney": {
                "LineRef": "Line_1",
                "DirectionRef": "Northbound",
                "FramedVehicleJourneyRef": {
                  "DataFrameRef": "2026-02-05",
                  "DatedVehicleJourneyRef": "Trip_1_20260205_0830"
                },
                "PublishedLineName": "Route 1 - City Center",
                "OperatorRef": "Operator_ABC",
                "ProductCategoryRef": "Bus",
                "VehicleRef": "Vehicle_1001",
                "VehicleLocation": {
                  "Longitude": -122.419400,
                  "Latitude": 37.774900
                },
                "Bearing": 45.0,
                "Velocity": 12.5,
                "Occupancy": "seatsAvailable",
                "OriginRef": "STOP001",
                "OriginName": "Main Terminal",
                "OriginAimedDepartureTime": "2026-02-05T08:30:00Z",
                "DestinationRef": "STOP003",
                "DestinationName": "North Station",
                "DestinationAimedArrivalTime": "2026-02-05T09:30:00Z",
                "Monitored": true,
                "InCongestion": true,
                "MonitoredCall": {
                  "StopPointRef": "STOP002",
                  "StopPointName": "Market Street at 5th Avenue",
                  "VehicleAtStop": false,
                  "AimedArrivalTime": "2026-02-05T08:45:00Z",
                  "ExpectedArrivalTime": "2026-02-05T08:47:00Z",
                  "ArrivalStatus": "delayed",
                  "AimedDepartureTime": "2026-02-05T08:46:00Z",
                  "ExpectedDepartureTime": "2026-02-05T08:48:00Z",
                  "DepartureStatus": "delayed"
                },
                "Extensions": {
                  "VehicleFeatures": {
                    "WheelchairAccessible": true,
                    "LowFloor": true,
                    "AirConditioned": true
                  }
                }
              }
            },
            {
              "RecordedAtTime": "2026-02-05T14:29:58Z",
              "ItemIdentifier": "VA-2005-20260205",
              "MonitoredVehicleJourney": {
                "LineRef": "Line_3",
                "DirectionRef": "Eastbound",
                "PublishedLineName": "Route 3 - Crosstown",
                "VehicleRef": "Vehicle_2005",
                "VehicleLocation": {
                  "Longitude": -122.271200,
                  "Latitude": 37.804400
                },
                "Occupancy": "full",
                "Monitored": true,
                "MonitoredCall": {
                  "StopPointRef": "STOP008",
                  "StopPointName": "Broadway at 8th Street",
                  "VehicleAtStop": true,
                  "AimedArrivalTime": "2026-02-05T14:29:00Z",
                  "ExpectedArrivalTime": "2026-02-05T14:29:00Z",
                  "ArrivalStatus": "onTime"
                }
              }
            }
          ]
        }
      ]
    }
  }
}
```

---

## Comparative Matrix

| **Criterion** | **GTFS-RT** | **SIRI** | **NeTEx + SIRI** | **TransXChange** | **SIRI Lite** |
|--------------|-------------|----------|------------------|------------------|---------------|
| **Format** | Protocol Buffers (binary) | XML (SOAP) | XML | XML | JSON (REST) |
| **Data Size** | Very compact | Verbose | Verbose | Verbose | Compact |
| **Ease of Implementation** | Easy | Complex | Very complex | Complex | Easy |
| **Geographic Focus** | Global | Europe | Europe | UK only | Europe/emerging |
| **Regulatory Status** | De facto standard | EU de jure standard | EU de jure standard | UK national standard | Emerging |
| **Real-time Capabilities** | Strong | Comprehensive | Comprehensive (via SIRI) | Limited | Strong |
| **Static Data** | GTFS (separate) | Limited | Comprehensive (NeTEx) | Comprehensive | Limited |
| **Tool Support** | Excellent | Good | Moderate | Moderate | Growing |
| **Learning Curve** | Low | Moderate-High | High | Moderate-High | Low |
| **Update Frequency** | 30s - 2min | 30s - 2min | 30s - 2min | N/A (static) | 30s - 2min |
| **Multi-modal Support** | Yes | Yes | Excellent | Bus-focused | Yes |
| **Fare Information** | Limited | Basic | Comprehensive | Moderate | Basic |
| **API Style** | File-based | SOAP/Web Service | File-based/SOAP | File-based | REST |
| **Developer Adoption** | Very high | Moderate | Low-Moderate | Low (UK) | Growing |
| **Mobile App Friendly** | Excellent | Moderate | Moderate | Moderate | Excellent |
| **Industry Momentum** | Strong globally | Strong in EU | Mandated in EU | Declining | Growing |

---

## Recommendations by Use Case

### For Global Applications
**Choose: GTFS + GTFS-RT**
- Best tool support and ecosystem
- Widest adoption
- Easy integration with major platforms
- Compact and efficient

### For European Union Compliance
**Choose: NeTEx + SIRI**
- Mandatory for EU National Access Points
- Comprehensive data model
- Future-proof for EU regulations
- Consider offering GTFS-RT as well for app compatibility

### For Modern Web/Mobile Apps (Europe)
**Choose: SIRI Lite**
- JSON format, REST APIs
- Easy integration
- Modern architecture
- Growing ecosystem

### For UK Bus Services
**Choose: TransXChange (static) + SIRI or GTFS-RT (real-time)**
- UK regulatory compliance
- Established infrastructure
- Consider GTFS conversion for wider app support

### For Maximum Compatibility
**Choose: Dual format approach**
- Publish both GTFS-RT and SIRI
- Bridges de facto vs de jure divide
- Maximizes app integration opportunities

---

## Future Trends (2025-2026)

1. **Convergence Tools**: Increasing number of tools to convert between GTFS/GTFS-RT and NeTEx/SIRI (e.g., OpenTripPlanner developments)

2. **SIRI Lite Growth**: Expect continued growth in SIRI Lite adoption as REST/JSON becomes the standard for modern APIs

3. **EU Mandate Impact**: EU member states increasingly required to provide NeTEx/SIRI data, but many will maintain GTFS-RT for practical compatibility

4. **Multi-format Publishing**: Leading transit agencies publish in multiple formats to serve different audiences

5. **MaaS (Mobility-as-a-Service)**: Driving need for comprehensive, standardized data exchange across modes

---

## Conclusion

The choice of real-time transport data format depends on:
- **Geographic location** (global vs EU vs UK)
- **Regulatory requirements** (EU mandates NeTEx/SIRI)
- **Target applications** (consumer apps favor GTFS-RT, government systems favor EU standards)
- **Implementation resources** (GTFS-RT easier, NeTEx/SIRI more complex)
- **Data complexity** (simple schedules vs complex fare structures)

For maximum reach and compatibility in 2026, many transit agencies are adopting a **dual-format strategy**, publishing both GTFS-RT (for wide app compatibility) and SIRI/NeTEx (for regulatory compliance), bridging the gap between de facto and de jure standards.
