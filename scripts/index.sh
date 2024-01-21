# This script should index the genome file specified in the first argument ($1),
# creating the index in a directory specified by the second argument ($2).

# The STAR command is provided for you. You should replace the parts surrounded
# by "<>" and uncomment it.

archivo_genoma=$1
directorio_index=$2

mkdir -p "$directorio_index"

STAR --runThreadN 4 --runMode genomeGenerate --genomeDir "$directorio_index" \
 --genomeFastaFiles "$archivo_genoma" --genomeSAindexNbases 9
