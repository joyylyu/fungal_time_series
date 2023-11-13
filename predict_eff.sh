#!/bin/bash

# run EffHunter and EffectorP sequentially to predict SSP and effectors from SSP
# the EffHunter workflow was slightly modified to enable looping over samples

# get path from config file
tool_path=$(jq -r '.tool_path' config.json)
proteome_path=$(jq -r '.proteome_path' config.json)
output_path=$(jq -r '.output_path' config.json)
sample=($(jq -r '.samples[]' config.json))

tool_path="${tool_path%/}"
output_path="${output_path%/}"
proteome_path="${proteome_path%/}"

cd "${tool_path}/EffHunter_v.1.0/"

# predict SSPs
for name in "${sample[@]}"; do 
   mkdir -p "${output_path}/${name}"
   ./EffHunter.sh 30 400 "${proteome_path}/${name}.proteins.fa" 2 && \
   mv EffectorHunter/effectors.fasta "${output_path}/${name}/${name}_SSP.fasta"
done 

# predict effectors
for name in "${sample[@]}"; do
    python ${tool_path}/EffectorP-3.0/EffectorP.py \
    -f -i "${output_path}/${name}/${name}_SSP.fasta" \
    -o "${output_path}/${name}/${name}_EFF.txt" \
    -E "${output_path}/${name}/${name}_EFF.fasta"
done 

