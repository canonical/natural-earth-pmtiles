#!/bin/bash

docker build -t natural-earth-pmtiles .

mkdir -p ./output

docker run -v $(pwd)/output:/output_directory natural-earth-pmtiles
