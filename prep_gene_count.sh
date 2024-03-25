#!/bin/bash

output_path=$(jq -r '.output_path' config.json)
sample=($(jq -r '.samples[]' config.json))
species=$(jq -r '.species[]' config.json)
full_sp_name=$(jq -r '.full_species_name[]' config.json)
data_path=$(jq -r '.data_path' config.json)
ortho_table=$(find "$data_path"/"$species"_ortho -type d -name "Results_*" -exec echo {}/Orthogroups/Orthogroups.tsv \;)
ortho_count=$(find "$data_path"/"$species"_ortho -type d -name "Results_*" -exec echo {}/Orthogroups/Orthogroups.GeneCount.tsv \;)

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

for item in "${orthogroup[@]}"; do
    echo "$item"
done | awk '!seen[$0]++' > "${output_path}/${species}/unique_orthogroups.txt"

# find out gene count for these orthogroups from each sample
mkdir -p "$output_path"/"$species"/eff_ortho
head -n 1 "$ortho_count" >"$output_path"/"$species"/eff_ortho/"$species"_EFF_count.tsv 
awk 'FNR==NR{a[$1]; next} $1 in a' "${output_path}/${species}/unique_orthogroups.txt" "$ortho_count" >> "$output_path"/"$species"/eff_ortho/"$species"_EFF_count.tsv



