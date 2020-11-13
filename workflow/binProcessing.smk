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


# ~~~~~~~~~~ STEP 2: ANI-Based Processing ~~~~~~~~~~ #


# Filter the assembly to contain only contigs >= n
# This is prep for fastANI
rule filter_contigs:
    input:
        assembly = "../input/Assembly/{sample}.fasta"
    params:
        length = "{length}"
    log:
        "logs/FastANI/filtering{sample}Assembly{length}.log"
    wildcard_constraints:
        length = "\d+"
    output:
        outputs = "../input/Assembly/Filtered/{sample}.Assembly{length}.fasta"
    shell:
        "python scripts/filterSeqLength.py -a {input.assembly} -l {params.length} -o {output.outputs} -g {log}"

# Prep for fastANI by splitting the assembly into multiple subsetted files
# Output consists of a .fasta file for EVERY entry in the assembly, a list
# of all the locations to said files, and n splits of that list file.
rule split_filtered_contigs:
    input:
        assembly = "../input/Assembly/Filtered/{sample}.Assembly{length}.fasta"
    params:
        parts = config['ANIAssemblySplitSize']
    log:
        "logs/generalProcessing/{sample}.{length}.FastaEntrySplitting.log"
    output:
        files = directory(
            "../input/Assembly/Filtered/Split-Files-{length}/{sample}/"),
        filelist = "../input/Assembly/Filtered/Split-Files-{length}/{sample}.AllContigsList{length}.txt",
        splitlist = expand("../input/Assembly/Filtered/Split-Files-{{length}}/{{sample}}.AllContigsList{{length}}_{split}.txt", split=range(
            1, int(config['ANIAssemblySplitSize']) + 1))
    shell:
        """
        python scripts/splitFastaByEntry.py -a {input.assembly} -o {output.files} -l {output.filelist} -n {params.parts} -g {log}
        """



