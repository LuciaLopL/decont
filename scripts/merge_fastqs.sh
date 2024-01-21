# This script should merge all files from a given sample (the sample id is
# provided in the third argument ($3)) into a single file, which should be
# stored in the output directory specified by the second argument ($2).
#
# The directory containing the samples is indicated by the first argument ($1).
directorio_origen=$1
directorio_output=$2
sampleid=$3

mkdir -p "$directorio_output"
cat "$directorio_origen"/"$sampleid"*.*.1s*.fastq.gz "$directorio_origen"/"$sampleid"*.*.2s*.fastq.gz > "$directorio_output"/"$sampleid".fastq.gz


