#!/bin/bash

# Script to generate UML diagrams from PlantUML files
# Requires plantuml to be installed: sudo apt install plantuml

echo "Generating OpenVINS UML Diagrams..."

UML_DIR="docs/uml"
OUTPUT_DIR="docs/images"

# Create output directory if it doesn't exist
mkdir -p $OUTPUT_DIR

# Check if plantuml is available
if ! command -v plantuml &> /dev/null; then
    echo "PlantUML not found. Installing..."
    sudo apt update
    sudo apt install plantuml -y
fi

# Generate PNG images from PlantUML files
echo "Converting PlantUML files to PNG..."

plantuml -tpng $UML_DIR/system_overview.puml -o ../../$OUTPUT_DIR/
plantuml -tpng $UML_DIR/sensor_fusion_flow.puml -o ../../$OUTPUT_DIR/
plantuml -tpng $UML_DIR/feature_tracking_pipeline.puml -o ../../$OUTPUT_DIR/
plantuml -tpng $UML_DIR/ekf_state_structure.puml -o ../../$OUTPUT_DIR/
plantuml -tpng $UML_DIR/gps_integration_flow.puml -o ../../$OUTPUT_DIR/
plantuml -tpng $UML_DIR/ros_node_interactions.puml -o ../../$OUTPUT_DIR/

echo "UML diagrams generated in $OUTPUT_DIR/"
echo "Available diagrams:"
echo "  - system_overview.png"
echo "  - sensor_fusion_flow.png" 
echo "  - feature_tracking_pipeline.png"
echo "  - ekf_state_structure.png"
echo "  - gps_integration_flow.png"
echo "  - ros_node_interactions.png"

echo "Done!"
