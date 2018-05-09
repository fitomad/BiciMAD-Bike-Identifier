//
//  LocationerDelegate.swift
//  IncidenceKit
//
//  Created by Adolfo Vera Blasco on 2/5/18.
//  Copyright © 2018 desappstre {eStudio}. All rights reserved.
//

import Foundation
import CoreLocation

public protocol LocationerDelegate: AnyObject
{
    /**
        Cambio en la posición 

        - Parameters:
            - locationer: Objeto que informa del cambio
            - location: La nueva posición
    */
    func locationer(_ locationer: Locationer, didUpdateLocation location: CLLocation) -> Void
    
    /**
        Informa de errores en la obtención de la posición

        - Parameters:
            - locationer: El objeto que informa del error
            - error: Información del error
    */
    func locationer(_ locationer: Locationer, failsWithError error: Error) -> Void
}
