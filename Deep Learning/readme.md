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

Si ya tienes las imágenes de los números estás listo para entrenar la Red Neural Convolucional. 

Lo primero que tienes que hacer es renombrar la carpeta `preview` para que pase a llamarse `data`.

Después, dirígite a tu terminal de comando y ejecuta...

```
python cnn_bicimad_model.py
```

Este proceso tarda bastante (dependiento del números de *epochs* y *pasos* que hayamos definido) así que ármate de paciencia. 

Cuando haya acabo tendrás dos archivos en tu carpeta...

* Uno con el modelo (MLBiciMAD.h5)
* Y el archivo con los pesos (MLBiciMAD_Weights.h5)

## Exportación a CoreML

¿Ya tienes el archivo con los pesos y el modelo? ¡Estupendo! 

Supongo que querrás pobrarlo en tu app así que sólo nos queda un pequeño paso; convertir el archivo `MLBiciMAD.h5` al formato `mlmodel` definido por CoreML.

Tranquilo, que también te dejo un script Python para ya lo hace por ti. De nuevo ve al terminal de comando y ejecuta...

```
python exporte.py
```

Al terminal tendrás otro nuevo archivo en tu carpeta. En este caso se llama `MLBiciMAD.mlmodel`

## Enlaces de Interés

* [Keras](https://keras.io). La librería de Deep Learning
* [TensorFlow](https://www.tensorflow.org/). Sobre la que trabaja Keras. Desarrollada por Google
* [h5py](https://www.h5py.org/). Necesario para guardar los archivos de pesos y el modelo de Keras
* [coremltools](https://apple.github.io/coremltools/). Desarrollado por Apple, ayuda a traducir los modelos en un formato legible para Xcode.
* [CoreML](https://developer.apple.com/machine-learning/). El framework de Apple para trabajar con Machine Learning

## Contacto

Todas las dudas o sugerencias que tengas me las puedes plantear a través de twitter en mi cuenta [@fitomad](https://twitter.com/fitomad)
