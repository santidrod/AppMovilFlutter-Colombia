# Guía de Instalación


## Requisitos

Previamente se deben instalar las siguientes herramientas y librerías:

```
$ sudo apt install -y curl wget unzip zip xz-utils libglu1-mesa
```

## Instalando Flutter

1. Descargar la última versión estable de flutter

```
$ wget https://storage.googleapis.com/flutter_infra/releases/stable/linux/flutter_linux_1.20.3-stable.tar.xz
```

2. Extraer el archivo en la ruta deseada, p.e. carpeta 'development'

```
$ cd ~/development
$ tar xf <ruta_de_descarga>/flutter_linux_1.20.3-stable.tar.xz
```

3. Agregar Flutter al PATH del sistema

```
$ export PATH="$PATH:`pwd`/flutter/bin"
```

4. Verificar dependencias faltantes
```
$ flutter doctor
```

## Instalando Android Studio (opcional)

1. Descargar la versión más reciente según el tipo de sistema operativo. [Descargar Android Studio](https://developer.android.com/studio#downloads)

2. Descomprimir el archivo en la ruta deseada, p.e. carpeta 'development'

```
$ unzip -q <ultima_version_android_studio>.zip -d ./development
```

**SI SE UTILIZA UN SO 64 BITS**: Si el SO es una versión Debian/Ubuntu de 64 bits, se debe instalar las siguientes librerías:

```
$ sudo apt install libc6:i386 libncurses5:i386 libstdc++6:i386 lib32z1 libbz2-1.0:i386
```

3. Iniciar Android Studio

```
$ cd ./development/android-studio/bin
$ ./studio.sh
```

4. En la primera ejecución se iniciará el asistente de configuración, siga los pasos para configurar el SDK y las herramientas de compilación (se recomienda usar la versión 29 o superior).


## Configurar el proyecto

En el directorio "lib/utilidades" renombrar o copiar el archivo **Constantes.example.dart** a **Constantes.dart** y configurar las rutas necesarias para los diferentes ambientes disponibles.