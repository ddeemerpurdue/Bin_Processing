# 3 Step Bin Processing

### Based on:
1. Taxonomy
2. Average nucleotide identity
3. Reference assembly

## Introduction
This 3-phase processing pipeline is designed to both add and remove contigs from bins based on different reference annotations. Three main programs are utilized during this pipeline and correspond to a step: i.) CatBat ii.) fastANI and iii.) MetaErg. Step 1 both removes and add contigs, whereas steps 2 and 3 are limited to only adding contigs into bins for now. The end results are bin identification files and fasta files. The purpose of this is to be able to automatically run the processing steps with various combinations of parameters to see how the final bin product compares the to original results.

### Initial Setup
A specific directory structure is required to make sure the pipeline runs correctly.
Clone this Git repository in order to establish the skeleton for the analysis:

$ git clone https://github.com/ddeemerpurdue/Bin_Processing.git  

$ cd Bin_Processing
Note: From now on, reference to '~' corresponds to the /Bin_Processing/ folder.
Three main folders are required at the top level:
1. config
- This contains a config.yaml file, which is specifies the project-specific variables.
2. input
- All files required for this analysis.
3. workflow
- This is where all results will be saved for the project.

The initial tree structure should look as follows:

./MyProject
+-- config
+-- input
+-- workflow

#### Configuration directory:  
Inside this directory there should be 2 files:  
---
### 1. config.yaml  
This contains multiple variables needed for the pipeline.  
---

---
### 2. cluster.json  
This file contains information for submitting the snakemake pipeline to a SLURM manager.  
---

#### Input directory:
./input  
+-- Assembly/  
    +-- sample1.assembly.fasta  
    +-- sample2.assembly.fasta  
+-- OriginalBins/  
    +-- {sample1}  
        +-- Bin.{number}.fasta  
        +-- Bin.{number}.fasta  
        +-- etc.
    +-- {sample2) 
        +-- Bin.{number}.fasta  
        +-- Bin.{number}.fasta  
        +-- etc. 
+-- Cat/  
    +-- {sample1}/{sample1}.C2C.names.txt  
    +-- {sample2}/{sample1}.C2C.names.txt  
+-- Bat/  
    +-- {sample1}/{sample1}.Bin2C.names.txt  
    +-- {sample2}/{sample1}.Bin2C.names.txt  
+-- GFF/  
    +-- {sample1}/{sample1}.All.gff  
    +-- {sample2}/{sample1}.All.gff  

**Note:** The Cat and Bat directories correspond to output files from the program CatBat. When copying into these folders, most likely the names will need to change to comply with this pipelines rules.  
For the GFF file, this file must contain an attribute with the name *genomedb_acc* in order for this to work. MetaErg provides a gff file with this annotation.  

#### workflow directory:
./workflow  
+-- envs/  
+-- logs/
+-- scripts/
    +-- aniContigRecycler.py  
    +-- appendBinsToANI.py  
    +-- blastContigRecycler.py  
    +-- download_acc_ncbi.bash  
    +-- filterContigsSm.py  
    +-- filterSeqLength.py  
    +-- findNonBinners.py  
    +-- getContigBinIdentifier.py  
    +-- gffMine.py  
    +-- makelist.py  
    +-- splitList.py  
    +-- split_mfa.sh  
    +-- split.py  
    +-- taxonFilter.py  
    +-- taxonRemovedBinIDFromLogFile.py  
    +-- writeFastaFromBinID.py  
    +-- writeModeGffFeaturePerBin.py
+-- snake.smk
**Note**: All other files will be automatically generated throughout the pipeline.
***
