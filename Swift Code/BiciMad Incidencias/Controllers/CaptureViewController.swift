//
//  CaptureViewController.swift
//  BiciMad Incidencias
//
//  Created by Adolfo Vera Blasco on 28/4/18.
//  Copyright © 2018 desappstre {eStudio}. All rights reserved.
//

import UIKit
import Vision
import ImageIO
import AVFoundation
import AudioToolbox

import IncidenceKit

internal class CaptureViewController: UIViewController
{
    /// La vista de la imagen 
    @IBOutlet private weak var viewCamera: UIView!
    /// Una imagen de ayuda para saber donde 
    // está el código de la bici
    @IBOutlet private weak var imageHelp: UIImageView!
    /// Muestra el código capturado por la cámara
    @IBOutlet private weak var labelHelp: UILabel!
    
    /// Sesión de AV
    private var cameraSession: AVCaptureSession!
    /// La salida de AV. En este caso es vídeo
    private var videoOutput: AVCaptureVideoDataOutput!
    
    /// La petición para `Vision`. Cualquier texto que 
    /// aparezca en la imagen
    private var requestText: VNDetectTextRectanglesRequest!
    
    /// La imagen que contiene el código
    private var ciBikeImage: CIImage?

    /// Nos sirve para validar lo más fiablemente 
    /// posible el código capturado.
    private var validation: [Int]!

    //
    // MARK: - Life Cycle
    //

    /**
        Aplicamos los estilo visuales y empezamos
        a pedir la localización del usuario.
    */
    override internal func viewDidLoad()
    {
        super.viewDidLoad()
        
        self.applyTheme()
        
        self.labelHelp.text = ""
        self.validation = [Int]()
        
        // En esta vista no necesitamos las coordenadas, pero la  
        // obtención de la localización tarda unos segundos, de  
        // esta manera nos aseguramos que cuando el usuario haya
        // terminado de escanear el código y pase al siguiente 
        // controlador ya estará disponible, o casi
        Locationer.shared.startLocationer()
    }
    
    /**
        Justo antes de que la vista aparezca en pantalla
        inciamos la sesión de AV y preparamos la petición
        de `Vision`
    */
    override internal func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(animated)
        
        self.startVideoSession()
        self.startTextDetection()
    }
    
    /**
        Para que la imagen de AV se vea bien en la `UIView`
    */
    override internal func viewDidLayoutSubviews() -> Void
    {
        if let layers = self.viewCamera.layer.sublayers, let layer = layers.first
        {
            layer.frame = self.viewCamera.bounds
        }
    }
    
    //
    // MARK: - Prepare UI
    //
    
    /**
        Estilos para algunos elementos de la vista
    */
    private func applyTheme() -> Void
    {
        self.viewCamera.layer.cornerRadius = 8.0
        self.viewCamera.layer.masksToBounds = true
        
        self.labelHelp.textColor = UIColor(hexadecimal: "#e9e9e9")
    }

    //
    // MARK: - Navigation
    //
    
    /**
        Si tenemos un código válido se lo pasamos el 
        `UIViewController` que gestiona la incidencia.

        - Parameter bike: Identificador de la bici.
    */
    private func presentIncidenceView(forBike bike: Int) -> Void
    {
        guard let storyboard = self.storyboard else
        {
            return
        }
        
        let controller = storyboard.instantiateViewController(withIdentifier: "IncidenceViewController") as! IncidenceViewController
        controller.bikeSerialNumber = bike
        
        self.navigationController?.pushViewController(controller, animated: true)
    }

    //
    // MARK: - Camera
    //
    
    /**
        Arrancamos una sesión de AV
    */
    private func startVideoSession() -> Void
    {
        self.cameraSession = AVCaptureSession()
        self.cameraSession.sessionPreset = AVCaptureSession.Preset.photo
        
        guard let captureDevice = AVCaptureDevice.default(for: AVMediaType.video),
              let deviceInput = try? AVCaptureDeviceInput(device: captureDevice)
        else
        {
            return
        }
        
        self.cameraSession.addInput(deviceInput)
        
        // Preparamos la salida de vídeo
        self.videoOutput = AVCaptureVideoDataOutput()
        self.videoOutput.alwaysDiscardsLateVideoFrames = true
        self.videoOutput.videoSettings = [
            kCVPixelBufferPixelFormatTypeKey as String: Int(kCVPixelFormatType_420YpCbCr8BiPlanarFullRange)
        ]
        
        let video_queue = DispatchQueue(label: "com.desappstre.BiciMAD.incidencias./bike_identifier")
        self.videoOutput.setSampleBufferDelegate(self, queue: video_queue)
        
        self.cameraSession.addOutput(self.videoOutput)
        
        // Y ahora la capa de presentación de imagen
        let preview_layer = AVCaptureVideoPreviewLayer(session: self.cameraSession)
        
        preview_layer.frame = self.viewCamera.bounds
        preview_layer.videoGravity = .resizeAspectFill
        preview_layer.connection?.videoOrientation = .portrait
        
        self.viewCamera.layer.addSublayer(preview_layer)
        
        self.cameraSession.commitConfiguration()

        // Todos listo. Empezamos a recuperar imagen
        self.cameraSession.startRunning()
    }
    
    //
    // MARK: - Vision
    //
    
    /**
        Configuramos la petición de detección de texto.

        Estamos muy interesados en que nos diga cuántas letras
        tiene la palabra detectada.
    */
    private func startTextDetection() -> Void
    {
        self.requestText = VNDetectTextRectanglesRequest(completionHandler: self.handleTextDetection)
        self.requestText.reportCharacterBoxes = true
    }
    
    /**
        Resuelve una petición de detección de texto de `Vision`

        Aquí vamos a hacer...
        1. Comprobar que el texto detectado tiene el formato de un identificador de BiciMAD
        2. Recortar cada número y...
            * Escalar su imagen 
            * Poner la imagen en blanco y negro
            * Invertir los colores
        3. Comprobar que el modelo dice si es un número y que número es.
        4. ¿Tenemos ya un identificador completo? ¿Está verificado? Hemos terminado

        - Parameters:
            - request: Datos con la observación detectada por Vision
            - error: Información del error en caso que se produzca
    */
    private func handleTextDetection(request: VNRequest, error: Error?) -> Void
    {
        guard let results = request.results, let ciBikeImage = self.ciBikeImage, !results.isEmpty else
        {
            return
        }
        
        DispatchQueue.main.async() 
        {
            guard let result = results.first,
                  let observation = result as? VNTextObservation,
                  observation.isBikeIdentifier
            else
            {
                return
            }
            /*
            self.viewCamera.subviews.forEach({ $0.removeFromSuperview() })
            let identifier_area: CGRect = observation.rectangleRelative(to: self.viewCamera)
            
            let mark = UIView(frame: identifier_area)
            mark.layer.borderColor = UIColor(hexadecimal: "#ed6a3b").cgColor
            mark.layer.borderWidth = 2.0
            self.viewCamera.addSubview(mark)
            */
            let visionary = Visionary()
            
            let imageSize = ciBikeImage.extent.size
            var boxes = [CIImage]()
            
            for box in observation.characterBoxes!
            {
                // El rectángulo del número
                let box_rect = box.boundingBox.scaled(to: imageSize)
                
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
                
                boxes.append(correctedImage)
            }
            
            // Vamos a ver qué nos dice nuestro modelo...
            if let serial_number = visionary.prediction(images: boxes)
            {
                // Es un identificador válido, lo mostramos
                self.labelHelp.text = "\(serial_number)"

                // ¿El modelo ha devuelto varias veces el mismo código
                // para la misma imagen? 
                if self.validadBikeIdentification(forBikeSerial: serial_number)
                {
                    // Feedback
                    AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
                    // Detenemos la captura de imagen
                    self.cameraSession.stopRunning()
                    // Vamos a trabajar con la incidencia
                    self.presentIncidenceView(forBike: serial_number)
                }
            }
        }
    }
}

//
// MARK: - AVCaptureVideoDataOutputSampleBufferDelegate Protocol
//

extension CaptureViewController: AVCaptureVideoDataOutputSampleBufferDelegate 
{
    /**
        Procesamos cada fotograma devuelto para la cámara
    */
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) -> Void
    {
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else 
        {
            return
        }
    
        self.ciBikeImage = CIImage(cvImageBuffer: pixelBuffer)
        self.ciBikeImage = self.ciBikeImage?.oriented(forExifOrientation: 6)
        
        if let ciBikeImage = self.ciBikeImage
        {
            // Creamos la petición de procesamiento de la imagen por parte de Vision.
            let imageRequestHandler = VNImageRequestHandler(ciImage: ciBikeImage)
            
            do
            {
                try imageRequestHandler.perform([ self.requestText ])
            }
            catch
            {
                print(error)
            }
        }
        
    }
}

//
// MARK: - Bike Identifier Validation
//

extension CaptureViewController
{
    /**
        Validar un stream de vídeo no como hacerlo de una 
        única imagen.

        En el caso del vídeo el resultado de la clasificación 
        por parte del modelo puede cambiar con el solo hecho
        de girar un poco la cámara.

        Así que lo que hago es comprobar si el modelo me devuelve
        el mismo código N veces seguida.

        Seguro que se puede hacer de otro manera más eficiente, pero 
        ahora mismo es lo que se me ha ocurrido.

        - Parameter serial: El últiimo identificador de la bici 
            devuelto por nuestro modelo
        - Returns: Sí es el mismo código que las veces anteriores
    */
    private func validadBikeIdentification(forBikeSerial serial: Int) -> Bool
    {
        // Ponemos el nuevo código el primero de todos
        self.validation.insert(serial, at: 0)
        
        // ¿No hay el mínimo de código para validar?
        guard self.validation.count > 4 else
        {
            return false
        }

        // Quitamos el código más antiguo
        self.validation.removeLast()

        // Número de identificador diferentes al 
        // último capturado
        let diferent_count = self.validation.filter({ $0 != serial }).count

        // ¿Hay alguno? Entonces no hay concordancia
        // Tenemos que seguir capturando
        if diferent_count > 0
        {
            return false
        }
        
        // Son todo iguales. Tenemos un ganador ;)
        return true
    }
}
