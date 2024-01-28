opcion_borrar=$1

borrar_data() {
    for archivo in $(find data/ -name '*fastq.gz'); do
        if [ -f "$archivo" ]; then
            rm "$archivo"
        fi
    done
}

borrar_res() {
    for elemento in $(find res/ -mindepth 1 -maxdepth 1); do
        if [ -f "$elemento" ]; then
            rm "$elemento"
        elif [ -d "$elemento" ]; then
            rm -r "$elemento"
        fi
    done
}

borrar_out() {
    for directorio in $(find out/ -mindepth 1 -maxdepth 1 -type d); do
        rm -r "$directorio"
    done
}

borrar_log() {
    for elemento in $(find log/ -mindepth 1 -maxdepth 1); do
        if [ -f "$elemento" ]; then
            rm "$elemento"
        elif [ -d "$elemento" ]; then
            rm -r "$elemento"
        fi
    done
}

if [ -z "$opcion_borrar" ]; then
    borrar_data
    borrar_log
    borrar_res
    borrar_out
elif [ "$opcion_borrar" == "data" ]; then
    borrar_data
elif [ "$opcion_borrar" == "logs" ]; then
    borrar_log
elif [ "$opcion_borrar" == "output" ]; then
    borrar_out
elif [ "$opcion_borrar" == "resources" ]; then
    borrar_res
else
    echo "No es un argumento válido"
fi
