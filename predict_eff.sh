#!/bin/bash

# run EffHunter and EffectorP sequentially to predict SSP and effectors from SSP
# *the EffHunter workflow was slightly modified to enable looping over samples

# load modules
module load BioPerl/1.7.8-GCCcore-11.3.0
module load Biopython/1.79-foss-2022a

# get path from config file
tool_path=$(jq -r '.tool_path' config.json)
proteome_path=$(jq -r '.proteome_path' config.json)
output_path=$(jq -r '.output_path' config.json)
sample=($(jq -r '.samples' config.json))

# predict SSPs
for sample in $sample[@]; do 
    name=$(echo "$sample")
    mkdir -p ${output_path}/${name}
    ./${tool_path}/EffHunter_v.1.0/EffHunter.sh 30 400 ${proteome_path}/${name}. 2
    mv ${tool_path}/EffHunter_v.1.0/EffectorHunter/effectors.fasta ${output_path}/${name}/${name}_SSP.fasta
done 

# predict effectors
for sample in $sample[@]; do
    name=$(echo "$sample")
    python ${tool_path}/EffectorP-3.0/EffectorP.py \
    -f -i ${output_path}/${name}/${name}_SSP.fasta \
    -o ${output_path}/${name}/${name}_EFF.txt \
    -E ${output_path}/${name}/${name}_EFF.fasta
done 

