#!/bin/bash

# This script processes geospatial data layers and generates the PMTiles file.

set -euo pipefail

# Parse config file
CONFIG_FILE="config.yml"

# Extract base URL from the config file.
SOURCE_BASE_URL=$(yq e '.source_base_url' "$CONFIG_FILE")

# Declare an array to store all the generated PMTiles filenames.
declare -a pmtiles_files

# Function to process each layer.
process_layer() {
    local layer=$1
    local type output_name start_zoom end_zoom params tile_join_params url

    # Extract layer-specific configuration from the config file.
    type=$(yq e ".layers[] | select(.name == \"$layer\") | .type" "$CONFIG_FILE")
    output_name=$(yq e ".layers[] | select(.name == \"$layer\") | .output_name" "$CONFIG_FILE")
    start_zoom=$(yq e ".layers[] | select(.name == \"$layer\") | .start_zoom" "$CONFIG_FILE")
    end_zoom=$(yq e ".layers[] | select(.name == \"$layer\") | .end_zoom" "$CONFIG_FILE")
    params=$(yq e ".layers[] | select(.name == \"$layer\") | .params" "$CONFIG_FILE")
    tile_join_params=$(yq e ".layers[] | select(.name == \"$layer\") | .tile_join_params" "$CONFIG_FILE" || echo "")

    # Construct the download URL.
    url="${SOURCE_BASE_URL}${type}/${layer}.zip"

    # Download the layer archive.
    curl --retry 5 --retry-delay 10 -L -O "$url"

    # Unzip the layer archive.
    unzip -o "${layer}.zip"

    # Transform the shapefile to GeoJSON.
    ogr2ogr -f GeoJSON "${layer}.geojson" "${layer}.shp"

    # Generate tiles for the layer.
    local output_pmtiles="${layer}-Z${end_zoom}.pmtiles"
    tippecanoe -z"${end_zoom}" -Z"${start_zoom}" -o "${output_pmtiles}" -l "${output_name}" ${params} "${layer}.geojson"

    # Append the generated PMTiles filename to the array.
    pmtiles_files+=("${output_pmtiles}")
}

# Process each layer defined in the config file.
while IFS= read -r layer; do
    echo "Processing layer: $layer"
    process_layer "$layer"
done < <(yq e '.layers[].name' "$CONFIG_FILE")

echo "PMTiles files to join: ${pmtiles_files[*]}"

# Join tiles using the array of PMTiles filenames.
tile-join --no-tile-size-limit --overzoom -f -o world.pmtiles "${pmtiles_files[@]}"

# Export the final PMTiles file.
cp world.pmtiles /output_directory

echo "Processing complete. PMTiles file is available at /output_directory/world.pmtiles."
