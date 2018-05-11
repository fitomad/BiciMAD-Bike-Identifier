# Deep Learning para BiciMAD. App para iOS

 ![Swift 4.1](https://img.shields.io/badge/Swift-4.1-orange.svg) ![Xcode](https://img.shields.io/badge/Xcode-9.3-orange.svg) ![macOS](https://img.shields.io/badge/macOS-10.13-yellow.svg)

Ya tengo el modelo entrenado y lo único que queda es usarlo en una app para iOS y comprobar que funciona tal y como se espera.

## Entorno

Para compilar el proyecto necesitas Xcode en su versión 9.3, y para llevar a cabo las pruebas debes tener un iPhone con iOS actualizado a la versión 11.0

## Estructura del proyecto

He organizado el código en dos targets.

1. El principal donde está el interfaz de usuario y la llamada a [CoreML](https://developer.apple.com/documentation/coreml)  y [Vision](https://developer.apple.com/documentation/vision)
2. Un framework llamado `IncidenceKit` que tiene el modelo importado de Keras y se encarga de la clasificación de las imágenes y otras cosas

Todo lo relacionado con CoreML y el modelo está programado en dos archivos

1. `CaptureViewController` (target principal)
2. `Visionary` (framework IncidenceKit)

Este es el código donde *capturo* un número del identificador y los transformo para crear una imagen como las que espera el modelo.

```swift
// El rectángulo del número
let box_rect = box.boundingBox.scaled(to: ciBikeImage.extent.size)

// Calculamos los vértices del rectangulo...
let topLeft = box.topLeft.scaled(to: imageSize)
let topRight = box.topRight.scaled(to: imageSize)
let bottomLeft = box.bottomLeft.scaled(to: imageSize)
let bottomRight = box.bottomRight.scaled(to: imageSize)

// ...y cortamos la imagen, la ponemos en blanco y negro
// y por último invertimos los colores. De esta manera
// la nueva imagen es como las del modelo de predicción 
let correctedImage = ciBikeImage
    .cropped(to: box_rect)
    .applyingFilter("CIColorInvert")
    .applyingFilter("CIPerspectiveCorrection", parameters: [
        "inputTopLeft": CIVector(cgPoint: topLeft),
        "inputTopRight": CIVector(cgPoint: topRight),
        "inputBottomLeft": CIVector(cgPoint: bottomLeft),
        "inputBottomRight": CIVector(cgPoint: bottomRight)
    ])
    .applyingFilter("CIColorControls", parameters: [
        kCIInputSaturationKey: 0,
        kCIInputContrastKey: 32
    ])
             
```
