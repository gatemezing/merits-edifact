# EDIFACT Message Types for Railway Timetable Exchange - Implementation Guide

## Overview

This document provides a detailed guide on specific EDIFACT message types for actual implementation in railway projects, focusing on UIC (International Union of Railways) standards for timetable information exchange.

## 1. SKDUPD (Schedule Update - Interactive Message)

### Primary Function

This message is used within the travel, tourism and leisure industry to transmit transport bulk timetable information, or to request its retransmission.

### Hierarchical Message Structure

The main segments include: UIH (Interactive message header), MSD (Message action details), ORG (Originator of request details), HDR (Header information), IFT (Interactive free text), PRD (Product identification), POP (Period of operation), POR (Location and/or related time information), ODI (Origin and destination details), and other service and facility segments.

#### Mandatory Segments (M) at Level 0:

- **UIH** - Message header (identifies the SKDUPD message type)
- **MSD** - Message action details (business function and message type)
- **ORG** - Originator details (data provider)
- **HDR** - Header information (delivery status, validity dates)
- **UIT** - Message trailer

#### Group 2 (Mandatory, up to 99999 repetitions):

- **PRD** - Product identification (identifies transport service/train)
  - Service number (e.g., train number)
  - Service characteristics (reservation status)
  - Tariff category

#### Group 4 (Conditional, up to 999 repetitions):

- **POP** - Period of operation (circulation period)
  - Start and end dates
  - Days of operation (using frequencies or specific dates)

#### Group 7 (Mandatory, up to 999 repetitions):

- **POR** - Location and/or related time information
  - Location code (station)
  - Arrival/departure times
  - Stop type (commercial, technical)

#### Group 9 (Conditional, up to 999 repetitions):

- **ODI** - Origin and destination details
  - Information on origin-destination sections
  - Fares and specific restrictions

### Practical Implementation Details

#### Temporal Data Format:

```
Delivery date/time: yyyy-mm-ddThhmm
Validity period: yyyy-mm-dd/yyyy-mm-dd
```

#### Service Identification:

The service is identified by concatenation of the party name (service provider) and product identification (service number).

#### Example of Key Segments:

```edifact
UIH+SKDUPD:D:04A::UN+3040+dialog-0'
MSD+AAR:61'
ORG+0080+++0080'
HDR+81+273:1996-09-29/1997-05-31*11:1996-07-20T1422'
PRD+12345:::::::0080'
```

### Update Management

An occurrence of the RFR segment must be present if the message contains an update to a previous delivery, allowing the recipient to check the chain of updates.

#### Update Types (code list B.4.1225):

- **61** - Timetable complete (full delivery)
- **62** - Timetable update (partial update)

## 2. TSDUPD (Timetable Static Data Update - Interactive Message)

### Primary Function

This message provides static data complementary to the timetable information conveyed by the SKDUPD message, such as information about locations related to schedules.

### Message Structure

#### Main Segments:

- **UIH** - Message header
- **MSD** - Message action details
- **ORG** - Originator details
- **HDR** - Header information
- **Location data groups** (stations, stops)

### Types of Data Included

#### For Stations/Locations:

- Location codes (UIC, national)
- Station names (with linguistic variants)
- **Geographic coordinates** (mandatory according to TAP TSI v1.1.1)
- Time zone
- Reservation codes
- Information about linked sub-locations

#### Footpaths:

- Links between nearby stations
- Minimum Connection Time (MCT)
- Calculation rules for connections

#### City Definitions:

- Station groupings
- Location hierarchies

### Usage Example:

```edifact
UIH+TSDUPD:D:04A::UN+1+dialog-0'
MSD+AAR:61'
ORG+0080+++0080'
HDR+81+11:2024-01-15T1200'
ALS+FR123456:UIC::Paris Gare du Nord'
COM+48.8808N:2.3551E'  # GPS coordinates
CNY+FR+1'  # Country/timezone information
```

## 3. Other Relevant Railway EDIFACT Messages

### Complementary Messages in the TAP TSI Ecosystem

While SKDUPD and TSDUPD are the main messages for timetables, other messages are used in the railway context:

#### For Tariffs:

- Fixed-length text files (format 108-1, evolving toward OSDM)

#### For Reservations:

- Binary and XML messages according to TAP TSI B.52
- PRM (Persons with Reduced Mobility) reservation messages in XML

## 4. Critical Implementation Points

### Specific EDIFACT Syntax

Data elements or groups of elements are separated by a plus character (+), repetitions are separated by asterisks (*), and data elements within a group are separated by double colons (::).

### Codes and Reference Lists

#### Essential Documents to Consult:

- **ERA Code lists** - "Directory of Passenger Code Lists for the ERA Technical Documents Used in TAP TSI"
- **UN/EDIFACT Directory D.04A** (reference version)
- **ISO 9735** - Parts 1 & 3 (service segments)

### Error Handling

#### Group 1 (ERI - Application Error Information):

- Allows specifying the type of application error
- Used to request retransmission in case of error

### Versioning and Compatibility

#### Version Identification in UIH:

```edifact
UIH+SKDUPD:D:04A::UN+...
       ^    ^ ^    ^
       |    | |    Controlling agency (UN)
       |    | Release (04A)
       |    Version (D)
       Message type
```

### Update Frequency

Annual timetables must be published at least 2 months in advance, and timetable changes must be published at least 7 days in advance.

## 5. Implementation Tools and Resources

### Available Parsers and Converters

UIC provides open-source tools on GitHub to convert MERITS EDIFACT files (SKDUPD and TSDUPD) to CSV and vice-versa.

#### Technical Resources:

- **GitHub UIC**: UnionInternationalCheminsdeFer/MERITS-open-source-tools
- **Converters**: Python-based for SKDUPD/TSDUPD
- **Validation**: Quality control tools for messages

### Deployment Considerations

#### For Successful Implementation:

1. **Internal Data Mapping**: Convert your internal data model to EDIFACT
2. **Strict Validation**: Implement rigorous quality controls
3. **Version Management**: Maintain delivery history with references
4. **Integration Testing**: Validate with MERITS systems or partners
5. **Documentation**: Maintain traceability of codes and mappings used

#### Recommended Architecture:

- Bidirectional transformation layer (internal ↔ EDIFACT)
- Syntactic and semantic validation module
- Version and reference management system
- Exchange monitoring interface

## 6. EDIFACT Syntax Details

### Character Separators

- **Segment separator**: ' (apostrophe)
- **Data element separator**: + (plus)
- **Component data element separator**: : (colon)
- **Repetition separator**: * (asterisk)
- **Decimal mark**: . (period)

### Service Segments

#### UIB - Interactive Interchange Header

Function: To head and identify an interchange.

Key data elements:
- Syntax identifier (UNOB:4)
- Initiator control reference
- Dialogue identification
- Interchange sender/recipient identification
- Date and time of initiation

#### UIZ - Interactive Interchange Trailer

Function: To end and check the integrity of an interchange.

Key data elements:
- Dialogue reference (must match UIB)
- Interchange control count (number of messages)

## 7. Comparison with Modern Standards

### EDIFACT vs. GTFS

| Aspect | EDIFACT | GTFS |
|--------|---------|------|
| **Structure** | Text format with 1980s complex syntax | Simple CSV files in a ZIP archive |
| **Readability** | Difficult for humans to read | Easily readable and editable |
| **Adoption** | Established European railway standard | Global public transport standard |
| **Available Tools** | Specialized tools required | Large open-source tool ecosystem |
| **Updates** | Established process via TAP TSI | Flexible updates, rapidly adopted |

### Current Industry Position

- MERITS now offers data in GTFS format in addition to EDIFACT format
- EDIFACT remains the regulatory standard for railway timetable exchange in Europe (TAP TSI)
- GTFS is increasingly adopted to facilitate integration with modern journey planning systems
- The industry is evolving toward coexistence of multiple formats depending on use cases

### Future Trends

The railway industry is gradually evolving toward:
- More modern formats like GTFS for public distribution
- XML standards for interoperability (e.g., RailML)
- Maintenance of EDIFACT for TAP TSI regulatory compliance in Europe
- Format coexistence depending on use cases

## 8. Practical Implementation Example

### Workflow for Sending Timetable Data

1. **Prepare internal data** in your system's format
2. **Map to EDIFACT structure** using appropriate segments
3. **Generate UIB header** with sender/recipient information
4. **Create SKDUPD message(s)** with:
   - MSD segment defining complete or partial update
   - ORG segment identifying data provider
   - HDR segment with validity dates
   - PRD groups for each service
   - POP groups for operating periods
   - POR groups for timing points
5. **Create TSDUPD message(s)** with station data if needed
6. **Add UIZ trailer** with message count
7. **Validate** against EDIFACT syntax rules
8. **Transmit** via agreed protocol (sFTP, etc.)

### Data Quality Considerations

- Ensure geographical coordinates are mandatory for stations (TAP TSI requirement)
- Indicate border stations and significant stations for fare calculation with passing times
- Provide minimum connection times for station pairs
- Include all service facilities explicitly in messages
- Validate all code list values against ERA reference documents

## 9. Integration with MERITS System

### MERITS Database Overview

MERITS (Multiple East-West Railways Integrated Timetable Storage) is a database owned by UIC containing integrated timetable data from 32 railway companies, with approximately 350,000 different timetables.

### Data Exchange Process

1. Railway undertakings submit data in EDIFACT format (SKDUPD/TSDUPD)
2. Data is quality checked by MERITS
3. Data is integrated with existing information
4. Cross-border train timetables are reconstructed through integration
5. Data is made available to authorized users in EDIFACT or GTFS format
6. Updates published 3-4 times weekly

### Interface Software

An interface software program is available for converting proprietary formats to EDIFACT and back, facilitating adoption for railway companies with legacy systems.

## Conclusion

This robust structure enables TAP TSI-compliant implementation for railway timetable data exchange. Success requires careful attention to:

- Proper segment structure and data element usage
- Strict adherence to code lists and formats
- Comprehensive validation processes
- Effective version and reference management
- Integration with both legacy EDIFACT systems and modern GTFS-based tools
