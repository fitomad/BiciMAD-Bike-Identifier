# BiciMAD-Bike-Identifier
![Keras](https://img.shields.io/badge/Keras-2.1.6-yellow.svg) ![TensorFlow](https://img.shields.io/badge/TensorFlow-1.8.0-yellow.svg) ![Python 2.7](https://img.shields.io/badge/python-2.7-blue.svg) ![Python 3.6](https://img.shields.io/badge/python-3.6-blue.svg) ![Swift 4.1](https://img.shields.io/badge/Swift-4.1-orange.svg) ![Xcode](https://img.shields.io/badge/Xcode-9.3-red.svg) ![macOS](https://img.shields.io/badge/macOS-10.13-brightgreen.svg) ![License MIT](https://img.shields.io/badge/license-MIT-green.svg)

Keras, Vision y CoreML para crear una app que **identifica los números de serie** de las bicicletas del servicio [BiciMAD](https://www.bicimad.com/)

La idea de este proyecto era la de desarrollar un modelo con [Keras](https://keras.io) desde cero, empezando por generar los datos con los que entrenar y validar hasta exportarlo a un proyecto [Xcode](https://developer.apple.com/xcode/) y comprobar que funciona sobre un iPhone.

## Estructura del repositorio

El proyecto está dividio en dos partes, una dedicada a la parte de Deep Learning y otra que contiene el desarrollo de la app para iPhone que incluye el modelo.

Cada carpeta contiene su propio fichero *readme.md* con información específica a la parte del proyecto a la que pertenece.

### Deep Learning

El desarrollo se centra en el uso de Keras, el framework de Deep Learning para Python, y en mi caso como backend empleo [TensorFlow](https://www.tensorflow.org/).

Esta parte del proyecto se divide a su vez en tres partes.

1. Cómo generar desde cero los datos de entrenamiento para el modelo
2. Diseñar una [Red Neuronal Convolucional](https://es.wikipedia.org/wiki/Redes_neuronales_convolucionales) y entrenarla con los datos del paso anterior
3. Exportar el modelo a [CoreML](https://developer.apple.com/machine-learning/)

Es necesario disponer de una instalación de [Python](https://www.python.org/) en su versión **2.7** (por defecto en macOS) o **3.6** (para Windows)

### Swift Code

Contiene el proyecto Xcode en su versión final. Incorpora el modelo Keras creado en la sección anterior y es totalmente funcional.

Para poder compilar el proyecto necesitarás...

1. Un Mac con [macOS](https://www.apple.com/es/macos/high-sierra/) 11.13
2. Xcode 9.3
3. Para probar necesitarás un iPhone con [iOS](https://www.apple.com/es/ios/ios-11/) 11.0 u 11.3

En esta última versión he añadido las siguientes características

1. Ahora se muestra un controlador que simula el alta de una incidencia en el servicio BiciMAD
2. Una vista de *Cámara* personalizara para adjuntar imágenes a la inicidencia
3. Mejoras en el sistema de localización geográfica.

Este último punto deja de ser relevante que ya la EMT, empresa operadora del servicio BiciMAD, ha mejorado el GPS que incorporan las bicicletas y ahora su localización es en tiempo real.

## Vídeos

He grabado tres vídeos con explicaciones más detalladas de cada paso que incluyen información adicional y alguna que otra aclaración sobre el código

1. [Deep Learning Parte I](https://www.youtube.com/watch?v=w_T030MtnBs&t=1s). Generación de los datos de entrenamiento y validación a partir de sólo 30 imágenes.
2. [Deep Learning Parte II](https://www.youtube.com/watch?v=jhuLToYuiiQ&t=1s). Desarrollo de una Red Convolucional y explicación de cada uno de los filtros que empleo en ella. Exportación a CoreML.
3. [App para iPhone con Swift](https://www.youtube.com/watch?v=_yBr-n7cdTo&t=1s). Importamos el modelo y vemos cada uno de los pasos necesarios para poder llevar el númnero de una bicicleta con la cámara del iPhone al modelo y clasificarlo.

## Contacto

¿Alguna duda o comentario? No os cortéis y mandame lo que queráis a mi cuenta de twitter [@fitomad](https://twitter.com/fitomad)

## ¿Pero esto funciona de verdad?

Juzgad por vosotros mismo ;-)

[![IMAGE ALT TEXT](http://img.youtube.com/vi/DwYoWG4OEZc/0.jpg)](https://www.youtube.com/watch?v=DwYoWG4OEZc)
