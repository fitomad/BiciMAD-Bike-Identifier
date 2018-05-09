//
//  CameraViewControllerDelegate.swift
//  BiciMad Incidencias
//
//  Created by Adolfo Vera Blasco on 30/4/18.
//  Copyright © 2018 desappstre {eStudio}. All rights reserved.
//

import UIKit
import Vision
import AVFoundation

internal protocol CameraViewControllerDelegate: AnyObject
{
    /**
        El usuario ha tomado una foto

        - Parameters:
            - controller: El `UIViewController` responsable de la toma de la foto
            - photo: La imagen de la foto capturada
    */
    func cameraViewController(_ controller: CameraViewController, didFinishTakePhoto photo: UIImage) -> Void

    /**
        El usuario cierra la *sesión de foto*

        - Parameter controller: El `UIViewController` responsable de la cámara
    */
    func cameraViewControllerDidCancel(_ controller: CameraViewController) -> Void
}
