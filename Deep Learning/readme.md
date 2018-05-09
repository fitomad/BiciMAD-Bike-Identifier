# Deep Learning. El modelo para BiciMAD

La generación del modelo se realiza en tres pasos

1. Generación de los datos para los conjuntos de **entrenamiento** y **validación**
2. Desarrollo de la Red Neural Convolucional usando la librería [Keras](http://keras.io)
3. Exportar el modelo al formato `mlmodel` para importarlo posteriormente en Xcode.

## Requisitos Previos

Necesitarás tener instalada una versión de Python 2.7 o 3.6. Puedes descargarlas desde la web de Python. Tras instalarlo necesitarás además una serie de librería que detallamos a continuacion

* Keras
* TensorFlow 
* numpy
* scipy
* h5py
* Pillow
* coremltools

La instalación se hace mediante el gestor de paquetes **pip**

```
sudo pip install keras
sudo pip install tensorflow
sudo pip install h5py
sudo pip install pillow
sudo pip install coremltools
```

Comprueba que la instalación de las librerías se he realizado correctamente con el comando

```
pip list
```

Deberías ver esas librerías en el listado que aparecer en tu terminal del sistema.

## Generación de Imágenes para Entrenamiento y Validación

Necesitarás las imágenes contenidas en la carpeta `assets` de este repositorio. Dentro hay 10 carpetas, cada uno correspondiente a un números del 0 al 9, que contiene 3 imágenes base que usaremos para crear los conjuntos de entrenamiento y validación.

En la misma carpeta `assets` encontrarás el archivo `bicimad_assets_keras.afdesign` que tiene los diseños de todas las imágenes de los números. Puedes abrirlo con [Affinity Designer](https://affinity.serif.com/en-gb/designer/)

En cuanto tengas la carpeta `assets` y el script `image_generator.py` en la misma carpeta sólo tienes que abrir tu terminal y ejecutar el comando

```
python image_generator.py
```

Tras unos minutos tendrás una nueva carpeta llamada `preview` con los conjuntos de imágenes para cada uno de los números.

## Desarrollo de la Red Neural Convolucional

## Exportación a CoreML
