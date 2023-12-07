# Fungal time series

If jq is not installed, install jq by:
```
conda install -c conda-forge jq
```

SigalP6.0 should be downloaded via the developer's sites following their [instructions](https://github.com/fteufel/signalp-6.0/blob/main/installation_instructions.md). 

Copy the package to cluster computer, unzip and install:
```
tar -xvf signalp-6.0h.fast.tar.gz
pip install signalp-6.0h.fast/signalp-6-package/
```
In the package there is a model file (**distilled_model_signalp6.pt**), copy the directory and make sure in the command the ```--model_dir``` option is pointing towards the directory of containing that file (should be in **signalp-6-package/models** at installation)

Before running the scripts its required to load the following modules:
```
#module load BioPerl/1.7.8-GCCcore-11.3.0
module load Biopython/1.79-foss-2022a
```


