# DIAGRAMA DE CLASES

## Requisitos

1. Instalar la herramienta **dcdg** (Dart Class Diagram Generator)
```
$ flutter pub global activate dcdg
```

2. Descargar el visor grafico PlantUML. [Archivo JAR plantuml.jar](http://sourceforge.net/projects/plantuml/files/plantuml.jar/download)

3. Instalar java. [Link de descarga](https://www.java.com/en/download/)

4. Instalar Graphviz
```
$ sudo apt install graphviz
```
[Link de descarga](https://graphviz.org/download/source/) en caso de no poder instalar mediante gestionador de paquetes apt.


## Generación de código

Desde la raiz del proyecto ejecutar:
```
$ flutter pub global run dcdg -o ./documentacion/diagrama_clases.puml
```
Se exportará en la ruta indicada un archivo de tipo PlantUML.

## Generación del diagrama de clases

Para generar la imagen PNG del codigo fuente en PlantUML, ejecutar el siguiente comando:
```
java -jar ./plantuml.jar -DPLANTUML_LIMIT_SIZE=32768 -tpng ./documentacion/diagrama_clases.puml
```
La imagen resultante se encuenta en el mismo directorio 'documentacion'.

   ![imagen generada](documentacion/images/diagrama_clases_app.png).
