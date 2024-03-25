import pandas as pd 
import glob
import json
import re

with open ('config.json') as json_file:
    config = json.load(json_file)

data_path = config['data_path']
output_path = config['output_path']
species = config['species']

loss_ortho = pd.read_csv(f"{output_path}/{species}/eff_ortho/{species}_EFF_loss_ortho.tsv",sep = )
loss_ortho = loss_ortho.drop(loss_ortho.columns[0], axis = 1) #deleting the first column (orthogroup name)

#for each 'lost' gene, select the gene name from anther sample to get the sequence
#for each sample, the output are saved in a txt file
def extract_numbers(column_name):
    numbers = re.findall(r'\d+', column_name)
    return ''.join(numbers)

def process_column(col_name):
    non_null_values = []
    sample_num = extract_numbers(col_name)
    #print(sample_num)
    for index, value in enumerate(loss_ortho[col_name]):
        if pd.isnull(value):
            for col in loss_ortho.columns:
                if col != col_name and not pd.isnull(loss_ortho.at[index, col]):
                    non_null_values.append(loss_ortho.at[index, col])
        else:
            continue
    with open(f'{output_path}/{species}/eff_ortho/{species}{numbers}_lost_names.txt', 'w') as file:
        file.write('\n'.join(non_null_values)) 

for cols in loss_ortho.columns:
    process_column(cols)
