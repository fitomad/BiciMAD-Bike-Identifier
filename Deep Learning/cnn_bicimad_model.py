"""
Convolutional Neural Network para el reconocimiento de los
numeros de identificacion de las bicicletas del servicio BiciMAD
de la ciudad de Madrid.

Adolfo Vera - 2018
"""
from keras.preprocessing.image import ImageDataGenerator
from keras.models import Sequential
from keras.layers import Conv2D, MaxPooling2D
from keras.layers import Dropout, Flatten, Dense
from keras import optimizers
from keras import backend as K

# Dimension de las imagenes
img_width, img_height = 28, 28

# Rutas a los directorio con las imagenes
# de entrenamiento y validacion
train_data_dir = 'data/training'
validation_data_dir = 'data/validation'

epochs = 15
batch_size = 256

if K.image_data_format() == 'channels_first':
    input_shape = (3, img_width, img_height)
else:
    input_shape = (img_width, img_height, 3)

#
# CNN. Basada en la aproximacion de Francois Chollet
#

model = Sequential()

model.add(Conv2D(32, kernel_size=(3,3), activation='relu', input_shape=input_shape))
model.add(Conv2D(64, kernel_size=(3,3), activation='relu'))

model.add(MaxPooling2D(pool_size=(2,2)))
model.add(Dropout(0.25))
model.add(Flatten())

model.add(Dense(128, activation='relu'))
model.add(Dropout(0.5))
model.add(Dense(10, activation='softmax'))

#
# Configuramos la forma en la que vamos
#  a entrenar el modelo...
#

model.compile(loss="categorical_crossentropy",
              optimizer=optimizers.Adadelta(),
              metrics=['accuracy'])

#
# ...y lo entrenamos
#

train_generator = ImageDataGenerator().flow_from_directory(
    train_data_dir,
    target_size=(img_width, img_height))

validation_generator = ImageDataGenerator().flow_from_directory(
    validation_data_dir,
    target_size=(img_width, img_height))

model.fit_generator(
    train_generator,
    steps_per_epoch=batch_size,
    epochs=epochs,
    validation_data=validation_generator)

# 
# Guardamos en formato .h5
#

model.save('MLBiciMAD.h5')
model.save_weights('MLBiciMAD_Weights.h5')
