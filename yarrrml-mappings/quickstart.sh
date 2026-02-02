#!/bin/bash

# YARRRML to RDF - Quick Start Script
# This script automates the conversion of MERITS CSV data to RDF using YARRRML mappings

set -e  # Exit on error

echo "================================================"
echo "MERITS YARRRML to RDF Conversion"
echo "================================================"
echo ""

# Check if required tools are installed
check_dependencies() {
    echo "Checking dependencies..."

    if ! command -v yarrrml-parser &> /dev/null; then
        echo "ERROR: yarrrml-parser is not installed."
        echo "Install with: npm install -g @rmlio/yarrrml-parser"
        exit 1
    fi

    if ! command -v java &> /dev/null; then
        echo "ERROR: Java is not installed (required for RMLMapper)."
        exit 1
    fi

    # Get Java version
    JAVA_VERSION=$(java -version 2>&1 | head -1 | cut -d'"' -f2 | cut -d'.' -f1)
    echo "Java version: $JAVA_VERSION"

    # Minimum Java version for any RMLMapper
    if [ "$JAVA_VERSION" -lt 11 ] 2>/dev/null; then
        echo "ERROR: Java 11 or higher is required (you have Java $JAVA_VERSION)."
        exit 1
    fi

    if [ ! -f "rmlmapper.jar" ]; then
        echo "WARNING: rmlmapper.jar not found in current directory."
        echo "Download from: https://github.com/RMLio/rmlmapper-java/releases"
        echo ""

        # Check Java version to recommend appropriate RMLMapper version
        if [ "$JAVA_VERSION" -lt 21 ] 2>/dev/null; then
            echo "NOTE: Your Java version ($JAVA_VERSION) requires RMLMapper v7.x or older."
            echo "      RMLMapper v8.x requires Java 21+."
            echo ""
            read -p "Download RMLMapper v7.0.0 (compatible with Java $JAVA_VERSION)? (y/n) " -n 1 -r
            echo
            if [[ $REPLY =~ ^[Yy]$ ]]; then
                DOWNLOAD_URL="https://github.com/RMLio/rmlmapper-java/releases/download/v7.0.0/rmlmapper-7.0.0-r374-all.jar"
                echo "Downloading from: $DOWNLOAD_URL"
                curl -L -o rmlmapper.jar "$DOWNLOAD_URL"
            else
                exit 1
            fi
        else
            read -p "Download latest RMLMapper? (y/n) " -n 1 -r
            echo
            if [[ $REPLY =~ ^[Yy]$ ]]; then
                echo "Fetching latest release URL from GitHub..."
                DOWNLOAD_URL=$(curl -s https://api.github.com/repos/RMLio/rmlmapper-java/releases/latest | grep "browser_download_url.*\.jar" | head -1 | cut -d '"' -f 4)
                if [ -z "$DOWNLOAD_URL" ]; then
                    echo "ERROR: Could not determine download URL. Please download manually from:"
                    echo "https://github.com/RMLio/rmlmapper-java/releases"
                    exit 1
                fi
                echo "Downloading from: $DOWNLOAD_URL"
                curl -L -o rmlmapper.jar "$DOWNLOAD_URL"
            else
                exit 1
            fi
        fi
    fi

    echo "All dependencies found!"
    echo ""
}

# Convert YARRRML to RML
convert_yarrrml_to_rml() {
    local input=$1
    local output=$2

    echo "Converting YARRRML to RML..."
    echo "  Input:  $input"
    echo "  Output: $output"

    yarrrml-parser -i "$input" -o "$output"

    if [ $? -eq 0 ]; then
        echo "✓ Conversion successful"
    else
        echo "✗ Conversion failed"
        exit 1
    fi
    echo ""
}

# Execute RML mapping
execute_rml_mapping() {
    local rml_file=$1
    local output_file=$2
    local format=${3:-turtle}

    echo "Executing RML mapping..."
    echo "  RML file:    $rml_file"
    echo "  Output file: $output_file"
    echo "  Format:      $format"

    java -jar rmlmapper.jar -m "$rml_file" -o "$output_file" -s "$format"

    if [ $? -eq 0 ]; then
        echo "✓ RDF generation successful"
        local line_count=$(wc -l < "$output_file")
        echo "  Generated $line_count triples"
    else
        echo "✗ RDF generation failed"
        exit 1
    fi
    echo ""
}

# Display usage
usage() {
    echo "Usage: $0 [OPTIONS]"
    echo ""
    echo "Options:"
    echo "  -t, --type TYPE       Type of mapping: skdupd or tsdupd (default: both)"
    echo "  -f, --format FORMAT   Output format: turtle, ntriples, nquads (default: turtle)"
    echo "  -o, --output DIR      Output directory (default: ./output)"
    echo "  -h, --help            Show this help message"
    echo ""
    echo "Examples:"
    echo "  $0                           # Process both SKDUPD and TSDUPD"
    echo "  $0 --type skdupd             # Process only SKDUPD"
    echo "  $0 --type tsdupd --format ntriples  # TSDUPD with N-Triples format"
    echo ""
}

# Parse command line arguments
TYPE="both"
FORMAT="turtle"
OUTPUT_DIR="./output"

while [[ $# -gt 0 ]]; do
    case $1 in
        -t|--type)
            TYPE="$2"
            shift 2
            ;;
        -f|--format)
            FORMAT="$2"
            shift 2
            ;;
        -o|--output)
            OUTPUT_DIR="$2"
            shift 2
            ;;
        -h|--help)
            usage
            exit 0
            ;;
        *)
            echo "Unknown option: $1"
            usage
            exit 1
            ;;
    esac
done

# Validate type
if [[ ! "$TYPE" =~ ^(skdupd|tsdupd|both)$ ]]; then
    echo "ERROR: Invalid type '$TYPE'. Must be 'skdupd', 'tsdupd', or 'both'"
    exit 1
fi

# Create output directory
mkdir -p "$OUTPUT_DIR"

# Check dependencies
check_dependencies

# Process SKDUPD
if [[ "$TYPE" == "skdupd" || "$TYPE" == "both" ]]; then
    echo "Processing SKDUPD (Timetable Data)..."
    echo "========================================"

    convert_yarrrml_to_rml \
        "skdupd/skdupd-mapping.yarrrml.yml" \
        "$OUTPUT_DIR/skdupd-mapping.rml.ttl"

    execute_rml_mapping \
        "$OUTPUT_DIR/skdupd-mapping.rml.ttl" \
        "$OUTPUT_DIR/skdupd-output.ttl" \
        "$FORMAT"
fi

# Process TSDUPD
if [[ "$TYPE" == "tsdupd" || "$TYPE" == "both" ]]; then
    echo "Processing TSDUPD (Location Data)..."
    echo "========================================"

    convert_yarrrml_to_rml \
        "tsdupd/tsdupd-mapping.yarrrml.yml" \
        "$OUTPUT_DIR/tsdupd-mapping.rml.ttl"

    execute_rml_mapping \
        "$OUTPUT_DIR/tsdupd-mapping.rml.ttl" \
        "$OUTPUT_DIR/tsdupd-output.ttl" \
        "$FORMAT"
fi

echo "================================================"
echo "All processing complete!"
echo "================================================"
echo ""
echo "Output files in: $OUTPUT_DIR"
echo ""
echo "Next steps:"
echo "  1. Validate RDF: rapper -i turtle -c $OUTPUT_DIR/*.ttl"
echo "  2. Load into triple store"
echo "  3. Query with SPARQL"
echo ""
echo "Example SPARQL query:"
echo "  PREFIX merits: <http://example.org/merits/ontology#>"
echo "  SELECT * WHERE { ?s a era:Train } LIMIT 10"
echo ""
