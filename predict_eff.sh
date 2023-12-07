#!/bin/bash

# run EffHunter and EffectorP sequentially to predict SSP and effectors from SSP
# the original EffHunter workflow was slightly modified to enable looping over samples

#SBATCH --job-name=predict_effectors
#SBATCH --time=1-12:00:00
#SBATCH --nodes=2
#SBATCH --ntasks-per-node=8
#SBATCH --mem=8g

# get path from config file
tool_path=$(jq -r '.tool_path' config.json)
proteome_path=$(jq -r '.proteome_path' config.json)
output_path=$(jq -r '.output_path' config.json)
sample=($(jq -r '.samples[]' config.json))
species=$(jq -r '.species[]' config.json)
full_sp_name=$(jq -r '.full_species_name[]' config.json)


# predict SSPs
for name in "${sample[@]}"; do 
    output_gff="${output_path}/${species}/${name}/SignalP6/output.gff3"
    sample_no=("${name[@]//[^0-9]/}")
    proteome=$(echo "${proteome_path}/${full_sp_name}_${sample_no}.proteins.fa")s
    
    # Check if output.gff3 file exists
    if [ ! -e "$output_gff" ]; then
        mkdir -p "${output_path}/${species}/${name}"
        mkdir -p "${output_path}/${species}/${name}/SignalP6"
        
        signalp6 --fastafile "$proteome" \
                 --output_dir "${output_path}/${species}/${name}/SignalP6"  \
                 --model_dir "${tool_path}/signalp-6-package/models" \
                 --format none 
        
        secreted_pro=$(awk '!/^#/ {print $1}' "${output_path}/${species}/${name}/SignalP6/output.gff3")
        
        grep -Fwf <(printf "%s\n" "${secreted_pro[@]}") -A 1 "$proteome" > "${output_path}/${species}/${name}/SignalP6/${name}_SSP.fasta"
        
        sed -i 's/--//g' "${output_path}/${species}/${name}/SignalP6/${name}_SSP.fasta" 
    else
        echo "Output file $output_gff exists. Skipping SignalP command."
    fi
done


#predict transmembrane domain
for name in "${sample[@]}"; do
    mkdir -p "${output_path}/${species}/${name}/TMHMM"
    
    cat ${output_path}/${species}/${name}/SignalP6/${name}_SSP.fasta  | \
    ${tool_path}/tmhmm/decodeanhmm.Linux_x86_64 -f ${tool_path}/tmhmm/TMHMM2.0.options \
    -modelfile ${tool_path}/tmhmm/TMHMM2.0c.model > ${output_path}/${species}/${name}/TMHMM/tmhmm.gff3
    
    perl ${tool_path}/tmhmm/tmhmmformat.pl \
    ${output_path}/${species}/${name}/TMHMM/tmhmm.gff3 > ${output_path}/${species}/${name}/TMHMM/res.gff3
    
    grep -E "Number of predicted TMHs:  0" ${output_path}/${species}/${name}/TMHMM/res.gff3| sed 's/# />/g' > ${output_path}/${species}/${name}/TMHMM/IDtmhmm.txt
    
    cut -d ' ' -f1 ${output_path}/${species}/${name}/TMHMM/IDtmhmm.txt > ${output_path}/${species}/${name}/TMHMM/id.wotransmembrandomains.fastaxs
    
    grep -Fwf ${output_path}/${species}/${name}/TMHMM/id.wotransmembrandomains.fastaxs -A 1 "${output_path}/${species}/${name}/SignalP6/${name}_SSP.fasta" > "${output_path}/${species}/${name}/TMHMM/${name}_NOTM.fasta"
done


# predict effectors
for name in "${sample[@]}"; do
    python ${tool_path}/EffectorP-3.0/EffectorP.py \
    -f -i "${output_path}/${species}/${name}/TMHMM/${name}_NOTM.fasta" \
    -o "${output_path}/${species}/${name}/${name}_EFF.txt" \
    -E "${output_path}/${species}/${name}/${name}_EFF.fasta"
done 

