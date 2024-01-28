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
for sid in $(ls data/*.fastq.gz|cut -d "." -f1|xargs -n 1 basename| sort | uniq )
do
    bash scripts/merge_fastqs.sh data out/merged $sid
    echo $sid
done

#run cutadapt for all merged files

mkdir -p out/trimmed
mkdir -p log/cutadapt

touch log/pipeline.log

for merged in $(ls out/merged/*.fastq.gz|xargs -n 1 basename)
do
cutadapt -m 18 -a TGGAATTCTCGGGTGCCAAGG --discard-untrimmed \
     -o out/trimmed/"$merged".trimmed.fastq.gz out/merged/"$merged" > log/cutadapt/"$merged".log >log/cutadapt.log 2>&1
nombre_sample=$(basename "$merged" .fastq.gz | cut -d "." -f1 | cut -d "-" -f1)
echo "$nombre_sample" >>log/pipeline.log
grep -E "^Reads with adapters:*" log/cutadapt.log >> log/pipeline.log
grep -E "^Total basepairs processed:*" log/cutadapt.log >> log/pipeline.log
echo " " >> log/pipeline.log
done

# run STAR for all trimmed files
mkdir -p out/star

for fname in out/trimmed/*.fastq.gz
do
    # you will need to obtain the sample ID from the filename
    sample_id=$(basename $fname .trimmed.fastq.gz|cut -d "." -f1|cut -d "-" -f1)
    echo $fname
    echo "$sample_id"
    mkdir -p out/star/"$sample_id"
    STAR --runThreadN 4 --genomeDir res/contaminants_idx \
        --outReadsUnmapped Fastx --readFilesIn $fname \
        --readFilesCommand gunzip -c --outFileNamePrefix out/star/"$sample_id"/ 
done 

# create a log file containing information from cutadapt and star logs
# (this should be a single log file, and information should be *appended* to it on each run)
# - cutadapt: Reads with adapters and total basepairs
# - star: Percentages of uniquely mapped reads, reads mapped to multiple loci, and to too many loci
# tip: use grep to filter the lines you're interested in
#touch log/pipeline.log

#grep -E "^Reads with adapters:*" log/cutadapt.log >> log/pipeline.log
#grep -E "^Total basepairs processed:*" log/cutadapt.log >> log/pipeline.log

for sample in $(ls log/cutadapt/*.fastq.gz.log)
do
	nombre_sample=$(basename "$sample" .fastq.gz.log | cut -d "." -f1 | cut -d "-" -f1 |sort| uniq)
	echo -E "$nombre_sample" >> log/pipeline.log
	grep -E "*Uniquely mapped reads %:*" out/star/"$nombre_sample"/Log.final.out >> log/pipeline.log
	grep -E "*% of reads mapped to multiple loci:*" out/star/"$nombre_sample"/Log.final.out >> log/pipeline.log
	grep -E "*% of reads mapped to too many loci:*" out/star/"$nombre_sample"/Log.final.out >> log/pipeline.log
done
