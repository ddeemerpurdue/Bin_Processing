'''
Author: Dane
Purpose: Snakemake pipeline that processes multiple samples bin files
automatically. Various parameters can be specified in the config/config.yaml
file and metadata will automatically be logged to compare various parameters
effects on bin processing.
Starting input requires:
1. Bin files in 1+ directories (.fasta)
2. MetaErg annotation - {sample}.gff file
3. CatBat annotation files {sample}.C2C.names.txt & {sample}.Bin2C.names.txt
'''

configfile: "../config/config.yaml"

# ~~~~~~~~~~ STEP 0: General Processing ~~~~~~~~~~ #


# Create a BinID file from list of .FASTA files
rule create_bin_id_file:
    input:
        bins = "../input/{sample}/bins.001.fasta"
    params:
        bins = directory("../input/{sample}")
    log:
        "logs/generalProcessing/{sample}.BinIDCreation.log"
    output:
        protected("BinIdentification/{sample}.Original.txt")
    shell:
        """
        python scripts/getContigBinIdentifier.py -f {params.bins}/*.fasta -o {output} -l {log}
        """


# ~~~~~~~~~~ STEP 1: Taxonomic Processing ~~~~~~~~~~ #


# Add and remove contigs based on taxonomies of contigs and respective bins
rule filter_taxonomy:
    input:
        bin_id = "BinIdentification/{sample}.{processing}.txt",
        cat = "../input/Cat/{sample}.C2C.names.txt",
        bat = "../input/Bat/{sample}.Bin2C.names.txt"
    params:
        addThresh = "{add}",
        removeThresh = "{remove}"
    wildcard_constraints:
        add = "\d+",
        remove = "\d+"
    output:
        new_bin_id = "BinIdentification/{sample}.{processing}TaxonRemovedA{add}R{remove}.txt"
    log:
        readme = "logs/taxonFiltering/{sample}.{processing}TaxonRemovedA{add}R{remove}.log"
    shell:
        """
        python scripts/taxonFilter.py -i {input.bin_id} -c {input.cat} -b {input.bat} \
        -m {params.removeThresh} -a {params.addThresh} -o {output.new_bin_id} -r {log.readme}
        """

