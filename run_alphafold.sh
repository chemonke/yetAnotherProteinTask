#!/usr/bin/env bash

set -euo pipefail

ROOT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

INPUT_DIR="$ROOT_DIR/filtered_fastas"
OUTPUT_DIR="$ROOT_DIR/outputs"
DOWNLOAD_DIR="$ROOT_DIR/alphafold_database"

mkdir -p "$OUTPUT_DIR"

for fasta in "$INPUT_DIR"/*.fasta; do
  basename=$(basename "$fasta" .fasta)
  outdir="$OUTPUT_DIR/$basename"
  
  if [ ! -d "$outdir" ]; then
    echo "Processing $basename"
    python3 "$ROOT_DIR/alphafold/docker/run_docker.py" \
      --fasta_paths="$fasta" \
      --max_template_date=2022-01-01 \
      --data_dir="$DOWNLOAD_DIR" \
      --output_dir="$outdir"
  else
    echo "Skipping $basename (already done)"
  fi
done
