#!/bin/bash

#SBATCH --job-name=predict_effectors
#SBATCH --time=1-12:00:00
#SBATCH --nodes=2
#SBATCH --ntasks-per-node=8
#SBATCH --mem=8g

# run effector prediction workflow
./predict_eff.sh

# select effectors from orthogroup.genecount table 
./prep_gene_count.sh

