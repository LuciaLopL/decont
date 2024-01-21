#Download all the files specified in data/filenames

for url in $(cat data/urls)
do
    bash scripts/download.sh $url data
done

# Download the contaminants fasta file, uncompress it, and
# filter to remove all small nuclear RNAs
contaminant_url="https://bioinformatics.cnio.es/data/courses/decont/contaminants.fasta.gz"

palabra_filtrar="small\ nuclear"
bash scripts/download.sh "$contaminant_url" res yes "$palabra_filtrar"

# Index the contaminants file
bash scripts/index.sh res/contaminants.fasta res/contaminants_idx

# Merge the samples into a single file
for sid in $(ls data/*.fastq.gz|cut -d "." -f1|xargs -n 1 basename|sort|uniq)
do
    bash scripts/merge_fastqs.sh data out/merged $sid
    echo $sid
done

#run cutadapt for all merged files
mkdir -p out/trimmed
mkdir -p log/cutadapt

for merged in $(ls out/merged/*.fastq.gz|xargs -n 1 basename)
do
cutadapt -m 18 -a TGGAATTCTCGGGTGCCAAGG --discard-untrimmed \
     -o out/trimmed/"$merged".trimmed.fasq.gz out/merged/"$merged".fastq.gz > log/cutadapt/"$merged".log
done

# run STAR for all trimmed files
for fname in out/trimmed/*.fastq.gz
do
    # you will need to obtain the sample ID from the filename
    sid=#TODO
    # mkdir -p out/star/$sid
    # STAR --runThreadN 4 --genomeDir res/contaminants_idx \
    #    --outReadsUnmapped Fastx --readFilesIn <input_file> \
    #    --readFilesCommand gunzip -c --outFileNamePrefix <output_directory>
done 

# TODO: create a log file containing information from cutadapt and star logs
# (this should be a single log file, and information should be *appended* to it on each run)
# - cutadapt: Reads with adapters and total basepairs
# - star: Percentages of uniquely mapped reads, reads mapped to multiple loci, and to too many loci
# tip: use grep to filter the lines you're interested in
