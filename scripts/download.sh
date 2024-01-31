# This script should download the file specified in the first argument ($1),
# place it in the directory specified in the second argument ($2),
# and *optionally*:
# - uncompress the downloaded file with gunzip if the third
#   argument ($3) contains the word "yes"
# - filter the sequences based on a word contained in their header lines:
#   sequences containing the specified word in their header should be **excluded**
#
# Example of the desired filtering:
#
#   > this is my sequence
#   CACTATGGGAGGACATTATAC
#   > this is my second sequence
#   CACTATGGGAGGGAGAGGAGA
#   > this is another sequence
#   CCAGGATTTACAGACTTTAAA
#
#   If $4 == "another" only the **first two sequence** should be output

url=$1
directorio=$2
uncompress_opcion=$3
palabra_filtrar=$4

nombre_archivo=$(basename "$url")

mkdir -p "$directorio"

#Para descargar los archivos
wget -P "$directorio" "$url"
#Para descomprimir en caso necesario 

if [ "$uncompress_opcion" == "yes" ] 
then
	nombre_archivo=$(basename "$url")
	echo "$nombre_archivo"
	gzip -dk "$directorio/$nombre_archivo"
	echo "El archivo se ha descomprimido"
fi

if [ -n "$palabra_filtrar" ]
then
	nombre_filtrado=$(basename "$nombre_archivo" .fasta.gz)
        echo "$nombre_filtrado"
	seqkit grep -v -n -r -p "$palabra_filtrar" "$directorio/$nombre_archivo" > "$directorio/$nombre_filtrado.fasta"
fi 

