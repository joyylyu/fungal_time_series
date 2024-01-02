#!/bin/bash

output_path=$(jq -r '.output_path' config.json)
sample=($(jq -r '.samples[]' config.json))
species=$(jq -r '.species[]' config.json)
full_sp_name=$(jq -r '.full_species_name[]' config.json)
data_path=$(jq -r '.data_path' config.json)
ortho_table=$(find "$data_path"/"$species"_ortho -type d -name "Results_*" -exec echo {}/Orthogroups/Orthogroups.tsv \;)

# select putative effectors from orthogroup count table
orthogroup=()
for name in "${sample[@]}"; do
    effectors=$(awk '{print $1}' "${output_path}/${species}/${name}/${name}_EFF.txt")
    for eff in ${effectors[@]}; do 
        og=$(grep -w $eff "$ortho_table" | cut -f1 )
        if  [[ ! " ${orthogroup[@]} " =~ " ${og} " ]]; then
            orthogroup+=("$og")
        fi
    done
done

# find out gene count for these orthogroups from each sample
ortho_count=$(find "$data_path"/"$species"_ortho -type d -name "Results_*" -exec echo {}/Orthogroups/Orthogroups.GeneCount.tsv \;)
mkdir -p "$output_path"/"$species"/eff_ortho 
for pattern in "${orthogroup[@]}"; do
    grep -F "$pattern" "$ortho_count"
done > "$output_path"/"$species"/eff_ortho/"$species"_EFF_count.tsv



