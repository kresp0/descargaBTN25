#!/bin/bash
# 
# Descarga hojas BTN25 del IGN y las clasifica por husos a partir de un listado de urls en un txt.
# Este script es una alternativa al cliente java del IGN.
# Para generar el txt:
# 1.- Seguir los pasos para descargar la zona de interés (hace falta java)
# http://centrodedescargas.cnig.es/CentroDescargas/buscadorCatalogo.do?codFamilia=02101
# 2.- Cuando se abra el cliente java, selecciona todas las urls y cópialas (Ctrl-C)
# 3.- En un editor de texto, pega el contenido y guarda en un txt con el nombre de la zona.
# 
# Santiago Crespo 2016 WTFL http://www.wtfpl.net/txt/copying/

######## CONFIGURACIÓN ####################
# ¿Dónde quieres guardar el BTN25?
DIRECTORIO_BTN25=/home/`whoami`/BTN25
######## FIN DE LA CONFIGURACIÓN ##########

if [ $# -eq 0 ] || [ ! -f $1 ] ; then
    echo "Uso: $0 zona.txt"
    head -n9 $0 | grep t
    exit 1
fi

NOMBRE_ZONA=`echo $1 | awk -F '.' '{print $1}'`

echo "## Vamos a extraer las urls y descargar lo que haya en $1"
echo "## Se crearán los directorios $DIRECTORIO_BTN25/$NOMBRE_ZONA/ si no existen"
read -p "## Pulsa intro para continuar o Ctrl-C para cancelar."

awk '{print $1}' $1 > /tmp/listado-urls

mkdir -p $DIRECTORIO_BTN25/$NOMBRE_ZONA/
cd $DIRECTORIO_BTN25/$NOMBRE_ZONA/

echo "## Descargando los zips por husos... (Toda la BTN25 son aprox. 11GB comprimido)"
while IFS='' read -r line || [[ -n "$line" ]]; do
    URL=`echo $line`
    HUSO=`echo $line | awk -F '/' '{print $6}'`
    mkdir -p $HUSO
    cd $HUSO
    wget $URL
    cd ..
done < /tmp/listado-urls

echo "## Descomprimiendo... (Toda la BTN25 son 40 GB descomprimida)"
for d in HUSO*; do cd $d ; unzip \*zip ; cd ..; done;

echo "## Borrando zips..."
rm HUSO*/*zip && echo "OK, FIN" && exit 0
