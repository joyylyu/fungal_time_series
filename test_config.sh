#!/bin/bash

# get path from config file
tool_path=$(jq -r '.tool_path' config.json)
proteome_path=$(jq -r '.proteome_path' config.json)
output_path=$(jq -r '.output_path' config.json)
sample=($(jq -r '.samples' config.json))

tool_path="${tool_path%/}"
output_path="${output_path%/}"
proteome_path="${proteome_path%/}"

echo ${proteom_path}
for sample in $sample[@]; do 
    name=$(echo "$sample")
    echo $name
done 