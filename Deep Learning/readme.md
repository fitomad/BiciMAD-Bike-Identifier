#Deep Learning. El modelo para BiciMAD

La generación del modelo se realiza en tres pasos

1. Generación de los datos para los conjuntos de **entrenamiento** y **validación**
2. Desarrollo de la Red Neural Convolucional usando la librería [Keras](http://keras.io)
3. Exportar el modelo al formato `mlmodel` para importarlo posteriormente en Xcode.

##Requisitos Previos

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

##Generación de Imágenes para Entrenamiento y Validación


##Desarrollo de la Red Neural Convolucional

##Exportación a CoreML