"""
Convertimos el modelo de Keras en uno valido para CoreML.

Adolfo Vera - 2018
"""

import os
# Si usas Python 3.6 en Windows... 
# pip install git+https://github.com/apple/coremltools.git
import coremltools 

#
# WORKFLOW. 
#

# Archivo con el modelo de Keras.
model_file = str('MLBiciMAD.h5')

if not os.path.exists(model_file):
    error_message = str.format("No encontramos nada en {0}. Comprueba la ruta", model_file)
    print(error_message)
    exit()

# Exportacion a CoreML

coreml_model = coremltools.converters.keras.convert(model_file, 
    input_names = 'image',
    image_input_names = 'image',
    output_names='numero',
    class_labels=['0', '1', '2', '3', '4', '5', '6', '7', '8', '9'])

# Metadatos
coreml_model.author = 'Adolfo Vera'
coreml_model.license = 'MIT'
coreml_model.short_description = 'Identifica los digitos del numero de serie de una bicicleta de BiciMAD'

# Descripcion de la entrada
coreml_model.input_description['image'] = 'Imagen de una bicicleta de BiciMAD'

# Descripcion de la salida
coreml_model.output_description['numero'] = 'Un digito del identificador de bicicleta'

# Guardamos el modelo CoreML
coreml_model.save('MLBiciMAD.mlmodel')