//
//  VNTextObservation+BiciMad.swift
//  BiciMad Incidencias
//
//  Created by Adolfo Vera Blasco on 29/4/18.
//  Copyright © 2018 desappstre {eStudio}. All rights reserved.
//

import UIKit
import Vision
import Foundation

public extension VNTextObservation
{
    /// Si la observación un identificador de una
    /// bicicleta del servicio BiciMAD
    public var isBikeIdentifier: Bool
    {
        guard let boxes = self.characterBoxes else
        {
            return false
        }
        
        return boxes.count == 4
    }
    
    
    /**
        El `CGRect` de la observación en base a la 
        vista en pantalla.

        - Parameters view: La vista en la que se ha detectado la observación
        - Returns: El rectángulo que ocupa le observación  en la vista
    */
    public func rectangleRelative(to view: UIView) -> CGRect
    {
        var rect: CGRect = CGRect()
        
        rect.size.width = self.boundingBox.size.width * view.frame.size.width
        rect.size.height = self.boundingBox.size.height * view.frame.size.height
        rect.origin.y =  (view.frame.height) - (view.frame.height * self.boundingBox.origin.y)
        rect.origin.y  = rect.origin.y - rect.size.height
        rect.origin.x =  self.boundingBox.origin.x * view.frame.size.width
        
        return rect
    }
}
