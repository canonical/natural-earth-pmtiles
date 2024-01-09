# Natural Earth PMTiles Generator

This project generates a small PMTiles file (~18MB) with a selection of Natural Earth layers.

## Prerequisites

- Docker installed on your machine.

## Generating Tiles

To generate the tiles, you need to run the Docker image. The command below will run the image and mount your current directory's `out` subdirectory to the `/output_directory` in the Docker container:

```bash
chmod +x ./run.sh && ./run.sh
```

## Acknowledgements

Thanks to [@dgtlntv](https://github.com/dgtlntv) for his [initial research](https://github.com/dgtlntv/natural-earth-tiles-test) on this.
