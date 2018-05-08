"""
Generamos los juegos de datos de entrenamiento y validacion
a partir de las imagenes que hayamos recopilado.

Con este procedimiento podemos ampliar de manera significativa
el numero de elementos que usaremos para validar la CNN.

Adolfo Vera - 2018
"""

import os
from keras.preprocessing.image import ImageDataGenerator, img_to_array, load_img

# Cantidad de imagenes que se van a generar
# para el entrenamientro del modelo.
TRAINING_SET_COUNT = 7000
# Cantidad de imagenes que se generaran
# para la validacion del modelo.
VALIDATION_SET_COUNT = 400

# Generador de imagenes
datagen = ImageDataGenerator(
	rotation_range=10,
	width_shift_range=0.3,
	height_shift_range=0.3,
	shear_range=0.3,
	zoom_range=0.15,
	horizontal_flip=False,
	fill_mode='nearest')

"""
Comprueba la existencia de un directorio en concreto.
El script genera los directorio basandose en la siguiente 
estructura:

preview/
	training/
		0
		...
	validation/
		0
		...
"""
def check_root_directory():
	if not os.path.exists('preview'):
		os.makedirs('preview')

		if not os.path.exists('preview/training'):
			os.makedirs('preview/training')

		if not os.path.exists('preview/validation'):
			os.makedirs('preview/validation')

"""
Comprueba que existan los directorio de 
training y validation para una categoria (numero)
que se pasa como parametro
"""
def check_data_directory(number):
	train_dir = str.format('preview/training/{0}', number)
	valid_dir = str.format('preview/validation/{0}', number)

	if not os.path.exists(train_dir):
		os.makedirs(train_dir)

	if not os.path.exists(valid_dir):
		os.makedirs(valid_dir)

"""
Generamos las imagenes para el entrenamiento
o validacion del modelo
"""
def process_images_from(directory_name, is_training = False):
	data_path = str.format('assets/{0}', directory_name)

	for image_file in os.listdir(data_path):
		# Evitamos los archivo ocultos
		if not image_file.startswith('.'):
			image_path = str.format('assets/{0}/{1}', directory_name, image_file)
			img = load_img(image_path) 

			kind_dir = "training" if is_training else "validation"
			save_dir = str.format('preview/{0}/{1}', kind_dir, directory_name)

			# Convertimos una imagen de pillow en un array 3D de numpy
			x = img_to_array(img)  
			# Hacemos un reshape del array para adecuarlo a lo que 
			# # espera la CNN de Keras
			x = x.reshape((1,) + x.shape)  

			# Ahora transformamos y guardamos las imagenes
			image_counter = 0
			atomic_counter = 0
			image_limit = TRAINING_SET_COUNT if is_training else VALIDATION_SET_COUNT

			while image_counter < image_limit:
				for batch in datagen.flow(x, batch_size=1, save_to_dir=save_dir, save_prefix=directory_name, save_format='png'):
					atomic_counter += 1
					if atomic_counter > 1:
						atomic_counter = 0
						break

				image_counter += 1

#
# WORKFLOW
#

# Si no existe el directorio preview lo creamos
check_root_directory()

# Preparamos los directorios de imagenes
# para cada digito.
for number in range(10):
	check_data_directory(number)

	process_images_from(number, True)
	process_images_from(number, False)
