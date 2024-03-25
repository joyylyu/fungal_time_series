#!/bin/bash

species=$(jq -r '.species[]' config.json)
output_path=$(jq -r '.output_path' config.json)
EFF_count_table=$"$output_path"/"$species"/eff_ortho/"$species"_EFF_count.tsv

#select putative lost effectors
awk -F'\t' 'NR==1 || /0/' "$EFF_count_table" | awk -F'\t' '{ for (i=2; i<=NF; i++) if ($i == 0) { print; next } }' > "$output_path"/"$species"/eff_ortho/selected_rows.tsv
