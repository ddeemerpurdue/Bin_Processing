import os
import argparse
from Bio import SeqIO
import time


def return_deflines(file):
    """ Open up a .fasta file and return the defline values in a list """
    assert file.lower().endswith(('fasta', 'fa')), "File does not end in .fasta or .fa"
    seq_dict = {rec.id: rec.seq for rec in SeqIO.parse(file, "fasta")}
    return list(seq_dict.keys())


def read_multiple_fasta(files):
    """ Increase functionality of 'read_fasta' by allowing a list of multiple
    .fasta files to be read in, returning a master dictionary.
    Note: this will not work if multiple .fasta files contain same identifier
    """
    master_dict = {}
    for file in files:
        '''
        The line below may need to be changed depending on how
        the bin files are named!
        '''
        bin_id = os.path.basename(file)
        bin_id = str(bin_id).split('.')[1]
        deflines = return_deflines(file)
        master_dict[bin_id] = deflines
    return master_dict


def write_fa_dict(files, savename, log):
    """ A function to write .txt values of .fasta output """
    now = time.localtime(time.time())  # Track the time it takes.
    master = read_multiple_fasta(files)
    with open(savename, 'w') as o:
        if log:
            with open(log, 'a') as lg:
                lg.write(f"Time started: {time.asctime(now)}\n")
        for bin_id, deflines in master.items():
            if log:
                with open(log, 'a') as lg:
                    lg.write(f"{bin_id} contains {len(deflines)} contigs\n")
            for defline in deflines:
                if defline.startswith('super'):
                    line = f"{bin_id}\t{defline.split('super_max_')[1]}\n"
                else:
                    line = f"{bin_id}\t{defline}\n"
                o.write(line)
        if log:
            now = time.localtime(time.time())  # Track the time it takes.
            with open(log, 'a') as lg:
                lg.write(f"Time ended: {time.asctime(now)}\n")


if __name__ == "__main__":
    ''' Initialize the arguments to be entered '''
    parser = argparse.ArgumentParser(description="Parser")
    parser.add_argument("-f", "--Files", help="Fasta files",
                        required=True, nargs='*')
    parser.add_argument("-o", "--Output", help="Output file name",
                        required=True)
    parser.add_argument("-l", "--Log", help="Verbose output for logging",
                        default=False)
    argument = parser.parse_args()
    log = str(argument.Log)
    write_fa_dict(argument.Files, argument.Output, log)
