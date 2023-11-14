#!/bin/bash

# run EffHunter and EffectorP sequentially to predict SSP and effectors from SSP
# the EffHunter workflow was slightly modified to enable looping over samples

# get path from config file
tool_path=$(jq -r '.tool_path' config.json)
proteome_path="/data/zool-barralab/scro4523/fungal_effector/orthofinder/fcul/proteome/fcul113133_core_noannot_seq_clean.fasta"
output_path=$(jq -r '.output_path' config.json)
name="fcul113133"
species=$(jq -r '.species' config.json)
sample_no=("${name[@]//[^0-9]/}")


# predict SSPs
   mkdir -p "${output_path}/${species}/${name}"
   biolib run DTU/SignalP_6 --fastafile "${proteome_path}/fusarium_lateritium_${sample_no}.proteins.fa" \
                            --output_dir "${output_path}/${species}/${name}"

secreted_pro=($(awk '!/^#/ {print $1}' "${output_path}/${species}/${name}/biolib_results/output.gff3"))
secreted_seq=($(grep -Fwf <(printf "%s\n" "${secreted_pro[@]}") -A 1 "${proteome_path}/fusarium_lateritium_${name}.proteins.fa"))
secreted_sample=($(grep '>' "$secreted_seq[@]"))

# predict effectors
for name in "${secreted_sample[@]}"; do
    python ${tool_path}/EffectorP-3.0/EffectorP.py \
    -f -i "${output_path}/${name}/${name}_SSP.fasta" \
    -o "${output_path}/${name}/${name}_EFF.txt" \
    -E "${output_path}/${name}/${name}_EFF.fasta"
done 

