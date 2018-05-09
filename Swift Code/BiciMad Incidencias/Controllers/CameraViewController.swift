//
//  CameraViewController.swift
//  BiciMad Incidencias
//
//  Created by Adolfo Vera Blasco on 28/4/18.
//  Copyright © 2018 desappstre {eStudio}. All rights reserved.
//

import UIKit
import Vision
import AVFoundation

internal class CameraViewController: UIViewController
{
    /**
        Estado del flash. Activado o desactivado
    */
    private enum FlashMode
    {
        case on
        case off

        /**
            Cambia el estado del flash
        */
        mutating func toogle() -> Void
        {
            switch self
            {
                case .on:
                    self = .off
                case .off:
                    self = .on
            }
        }
    }

    /// Vista donde se muestra la imagen
    @IBOutlet private weak var viewCamera: UIView!
    /// Botón para accionar el *obturador*
    @IBOutlet private weak var buttonCapture: UIButton!
    /// Activa o desactiva el flash
    @IBOutlet private weak var buttonFlash: UIButton!
    
    /// La sesión de AV
    private var cameraSession: AVCaptureSession!
    /// Salida de AV. En este caso una imagen fija
    private var photoOutput: AVCapturePhotoOutput!

    /// Estado del flash
    private var flashMode: FlashMode!
    {
        didSet
        {
            if case .on = self.flashMode!
            {
                self.selectFlashButton()
            }
            else
            {
                self.unselectedFlashButton()
            }
        }
    }

    /// Delegado donde informamos de las fotos capturadas
    internal weak var delegate: CameraViewControllerDelegate?

    //
    // MARK: - Life Cycle
    //

    /**
        Aplicamos el tema y por defecto el flash está descativado
    */
    override internal func viewDidLoad()
    {
        super.viewDidLoad()
        
        self.applyTheme()

        self.flashMode = .off
    }
    
    /**
        Justo antes de que la vista se vea en 
        pantalla arrancamos la sesión de AV
    */
    override internal func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(animated)
        
        self.startVideoSession()
    }
    
    /**
        Para que la imagen que se recibe de la cámara se vea bien
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
        Estilo visual de elementos de la vista
    */
    private func applyTheme() -> Void
    {
        self.viewCamera.layer.cornerRadius = 8.0
        self.viewCamera.layer.masksToBounds = true
    }

    //
    // MARK: - Animations
    //

    /**
        Estilo del botón flash indicando que **está** activo
    */
    private func selectFlashButton() -> Void
    {
        let animator = UIViewPropertyAnimator(duration: 0.35, curve: .easeIn)

        animator.addAnimations({ [unowned self] in
            self.buttonFlash.tintColor = UIColor(hexadecimal: "#ed6a3b")
        })

        animator.startAnimation()
    }

    /**
        Estilo del botón flash indicando que **no está** activo
    */
    private func unselectedFlashButton() -> Void
    {
        let animator = UIViewPropertyAnimator(duration: 0.35, curve: .easeIn)

        animator.addAnimations({ [unowned self] in
            self.buttonFlash.tintColor = UIColor(hexadecimal: "#e9e9e9")
        })

        animator.startAnimation()
    }
    
    //
    // MARK: - Camera
    //
    
    /**
        Configuramos la sesión de AV para la
        captura de imágenes.
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
        
        // La salida es una foto
        self.photoOutput = AVCapturePhotoOutput()
        self.cameraSession.addOutput(self.photoOutput)
        
        // Aspecto de la vista donde mostramos lo que 
        // ve la cámara del iPhone.
        let preview_layer = AVCaptureVideoPreviewLayer(session: self.cameraSession)
        
        preview_layer.frame = self.viewCamera.bounds
        preview_layer.videoGravity = .resizeAspectFill
        preview_layer.connection?.videoOrientation = .portrait
        
        self.viewCamera.layer.addSublayer(preview_layer)
        
        // Todo listo. Iniciamos la sesión
        self.cameraSession.startRunning()
    }
    
    //
    // MARK: - Actions
    //
    
    /**
        Pulsación en el botón de captura de foto.
    */
    @IBAction private func handleCaptureButtonTap(sender: UIButton) -> Void
    {
        let settings = AVCapturePhotoSettings(format: [ AVVideoCodecKey : AVVideoCodecType.jpeg ])
        settings.flashMode = self.flashMode == .on ? AVCaptureDevice.FlashMode.on : AVCaptureDevice.FlashMode.off

        self.photoOutput.capturePhoto(with: settings, delegate: self)
    }

    /**
        Activación o desactivación del flash
    */
    @IBAction private func handleFlashButtonTap(sender: UIButton) -> Void
    {
        self.flashMode.toogle()
    }

}

//
// MARK: - AVCaptureVideoDataOutputSampleBufferDelegate Protocol
//

extension CameraViewController: AVCapturePhotoCaptureDelegate
{
    /**
        Imagen procesada por AV
    */
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) -> Void
    {
        guard let unmanaged_image = photo.cgImageRepresentation() else
        {
            if let error = error
            {
                print("No podemos procesar la foto. \(error.localizedDescription)")
            }
            
            return
        }
        
        let cg_image = unmanaged_image.takeUnretainedValue()
        // No se debería poner la orientación *fija*
        let imageBike = UIImage(cgImage: cg_image, scale: 1.0, orientation: .right)
        
        // Informamos de la nueva foto al delegado
        self.delegate?.cameraViewController(self, didFinishTakePhoto: imageBike)
        // El controlador ha terminado su trabajo
        self.navigationController?.popViewController(animated: true)
    }
}
