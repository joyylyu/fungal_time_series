import json
import pandas as pd
import glob

with open ('config.json') as json_file:
    config = json.load(json_file)

data_path = config['data_path']
output_path = config['output_path']
species = config['species']

ortho_table=f"{data_path}/{species}_ortho/Results_*/Orthogroups/Orthogroups.tsv"
eff_count_table = f"{output_path}/{species}/eff_ortho/{species}_EFF_count.tsv"

#select effectors whose gene count=0
df = pd.read_csv(eff_count_table, sep = '\t')
eff_loss = df[df.eq(0).any(axis=1)]
eff_loss.to_csv(f"{output_path}/{species}/eff_ortho/{species}_EFF_loss.tsv", sep='\t', index=False)

#select orthogroup for 'lost' genes into a csv 
eff_ortho = pd.concat([pd.read_csv(file, sep='\t') for file in glob.glob(ortho_table)], ignore_index=True)
loss_ortho = eff_ortho[eff_ortho.iloc[:, 0].isin(eff_loss.iloc[:, 0])]
loss_ortho.to_csv(f"{output_path}/{species}/eff_ortho/{species}_EFF_loss_ortho.tsv", sep='\t', index=False)



