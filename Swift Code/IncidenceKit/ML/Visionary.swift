//
//  Visionary.swift
//  IncidenceKit
//
//  Created by Adolfo Vera Blasco on 2/5/18.
//  Copyright © 2018 desappstre {eStudio}. All rights reserved.
//

import Vision
import CoreML
import Foundation

public struct Visionary
{
    /// La red convolucional exportado a formato CoreML
    private let model: MLBiciMAD

    /**
        Inicializa el modelo
    */
    public init()
    {
        self.model = MLBiciMAD()
    }
    
    /**
        Aplica el modelo a una serie de imagenes, donde 
        cada imagen es un dígito del número de identificación
        de la bicicletas de BiciMAD.

        - Parameter images: El array de imagenes a validar
        - Return: El identificador si es que las imagenes dan 
            lugar a uno.
    */
    public func prediction(images: [CIImage]) -> Int?
    {
        guard images.count == 4 else
        {
            return nil
        }
        
        var serial: (thousands: Int?, hundreds: Int?, tens: Int?, units: Int?)
        
        
        for (index, image) in images.enumerated()
        {
            if let a_number = self.prediction(image: image)
            {
                switch index
                {
                    case 0:
                        serial.thousands = a_number
                    case 1:
                        serial.hundreds = a_number
                    case 2:
                        serial.tens = a_number
                    default:
                        serial.units = a_number
                }
            }
        }
        
        if let thousands = serial.thousands,
           let hundreds = serial.hundreds,
           let tens = serial.tens,
           let units = serial.units
        {
            let serial_number = Int("\(thousands)\(hundreds)\(tens)\(units)")
            
            return serial_number
        }
        
        return nil
    }
    
    /**
        Pasamos la imagen por el modelo de clasificación.

        Al ser una clasificación en lugar de una predicción
        obtenemos la probalidad de **todos** los números en 
        lugar de que el número más probable. 

        Por eso aplico mi propio *filtro*:
        ```
        let digit = output.numero.enumerated()
            .filter({ $0.element.value > 0.90 && $0.element.value <= 1.0 })
            .map({ $0.element })
            .sorted(by: { $0.value < $1.value })
            .first
        ```
        Filtramos aquellas clasificaciones con menos de un 90% y
        de ellas, cogemos la mayor.

        - Parameter image: La imagen de Vision. Es un único dígito
        - Returns: Un número si es que se ha podido clasificar

    */
    public func prediction(image: CIImage) -> Int?
    {
        guard let buffer = self.pixelBuffer(from: image),
              let output = try? self.model.prediction(image: buffer)
        else
        {
            return nil
        }
        
        let digit = output.numero.enumerated()
            .filter({ $0.element.value > 0.90 && $0.element.value <= 1.0 })
            .map({ $0.element })
            .sorted(by: { $0.value < $1.value })
            .first
        
        if let digit = digit, let number = Int(digit.key)
        {
            return number
        }
        
        return nil
    }
    
    /**
        El modelo de `CoreML` espera como parámetro de entrada 
        un array de datos que representen a la imagen.

        Este array de datos se encapsula dentro de un `CVPixelBuffer`
        así que esta función convirte la imagen de tipo `CIImage` que 
        nos llega desde Vision al array de datos.

        Todo esto nos lo podemos ahorrar si usamos `VNCoreMLRequest` que 
        permite pasar como parámetro del modelo un `CIImage`.
    */
    private func pixelBuffer(from ciImage: CIImage) -> CVPixelBuffer?
    {
        guard let image = self.scaledImage(ciImage) else
        {
            return nil
        }
        
        let width = 28
        let height = 28
        
        let pixelFormatType = kCVPixelFormatType_32ARGB
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let alphaInfo = CGImageAlphaInfo.noneSkipFirst
        
        
        var maybePixelBuffer: CVPixelBuffer?
        let attrs = [
            kCVPixelBufferCGImageCompatibilityKey: kCFBooleanTrue,
            kCVPixelBufferCGBitmapContextCompatibilityKey: kCFBooleanTrue
        ]
        
        let status = CVPixelBufferCreate(kCFAllocatorDefault,
                                         width,
                                         height,
                                         pixelFormatType,
                                         attrs as CFDictionary,
                                         &maybePixelBuffer)
        
        guard let pixelBuffer = maybePixelBuffer, status == kCVReturnSuccess else
        {
            return nil
        }
        
        CVPixelBufferLockBaseAddress(pixelBuffer, CVPixelBufferLockFlags(rawValue: 0))
        let pixelData = CVPixelBufferGetBaseAddress(pixelBuffer)
        
        guard let context = CGContext(data: pixelData,
                                      width: width,
                                      height: height,
                                      bitsPerComponent: 8,
                                      bytesPerRow: CVPixelBufferGetBytesPerRow(pixelBuffer),
                                      space: colorSpace,
                                      bitmapInfo: alphaInfo.rawValue)
        else
        {
            return nil
        }
        
        UIGraphicsPushContext(context)
        context.translateBy(x: 0, y: CGFloat(height))
        context.scaleBy(x: 1, y: -1)
        image.draw(in: CGRect(x: 0, y: 0, width: width, height: height))
        UIGraphicsPopContext()
        
        CVPixelBufferUnlockBaseAddress(pixelBuffer, CVPixelBufferLockFlags(rawValue: 0))
        
        return pixelBuffer
    }
    
    /**
        Escala la imagen que nos llega desde `Vision` a
        un tamaño de `28 x 28` pixels.

        Si no hicieramos esto la imagen que pasaríamos al
        modelo de predicción estaría *deformada*

        - Parameter ciImage: La imagen que nos llega desde Vision
        - Returns: Una imagen escalada al tamaño esperado por el modelo
    */
    private func scaledImage(_ ciImage: CIImage) -> UIImage?
    {
        let image = UIImage(ciImage: ciImage)
        var scaledImageRect = CGRect.zero
        
        let aspectWidth = 28.0 / image.size.width;
        let aspectHeight = 28.0 / image.size.height;
        // Obtenemos el ratio de escalado
        let aspectRatio = min(aspectWidth, aspectHeight)
        
        scaledImageRect.size.width = image.size.width * aspectRatio
        scaledImageRect.size.height = image.size.height * aspectRatio
        scaledImageRect.origin.x = (28.0 - scaledImageRect.size.width) / 2.0
        scaledImageRect.origin.y = (28.0 - scaledImageRect.size.height) / 2.0
        
        let newSize = CGSize(width: 28.0, height: 28.0)
        
        UIGraphicsBeginImageContextWithOptions(newSize, false, 0)
        image.draw(in: scaledImageRect)
        let scaledImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return scaledImage
    }
}
