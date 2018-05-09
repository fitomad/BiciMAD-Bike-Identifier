//
//  Locationer.swift
//  BiciMad Incidencias
//
//  Created by Adolfo Vera Blasco on 29/4/18.
//  Copyright © 2018 desappstre {eStudio}. All rights reserved.
//

import Foundation
import CoreLocation

/**
    Closure donde devolvemos la dirección basada
    en unas coordenadas
*/
public typealias AddressCompletionHandler = (_ address: String?) -> Void

public class Locationer: NSObject
{
    /// Singleton
    public static let shared: Locationer = Locationer()
    
    /// Manager
    private var locationManager: CLLocationManager
    /// Última posición obtenida
    public private(set) var myPosition: CLLocation?
    /// Dirección a partir de la última dirección
    public private(set) var myAddress: String?
    
    /// Delegado para avisar de las actualizaciones
    public weak var delegate: LocationerDelegate?
    
    /**
        Preparamos el manager y gestionamos la
        autorización a la localización
    */
    override private init()
    {
        self.locationManager = CLLocationManager()
        
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
        self.locationManager.distanceFilter = 10
        
        super.init()
        
        self.locationManager.delegate = self
        self.manageAuthoritation()
    }
    
    //
    // MARK: - Authoritation status
    //
    
    /**
        Comprobamos que la app tiene permiso para acceder
        a la localización.

        Si no tiene permisos los solicitamos 
    */
    private func manageAuthoritation() -> Void
    {
        if case .authorizedWhenInUse != CLLocationManager.authorizationStatus()
        {
            self.locationManager.requestWhenInUseAuthorization()
        }
    }
    
    //
    // MARK: - Location Service
    //
    
    /**
        Arranca una sesión de localización
    */
    public func startLocationer() -> Void
    {
        self.locationManager.startUpdatingLocation()
    }
    
    /**
        Detiene una sesión de localización
    */
    public func stopLocationer() -> Void
    {
        self.locationManager.stopUpdatingLocation()
    }
    
    //
    // MARK: - Helper
    //
    
    /**
        Crea una dirección a partir de unas coordenadas

        - Parameters:
            - location: Las coordenadas de las que vamos a 
                obtener una dirección
            - handler: Closure donde devolvemos el resultado
    */
    public func makeAddress(from location: CLLocation, handler: AddressCompletionHandler? = nil) -> Void
    {
        let geocoder = CLGeocoder()
        
        geocoder.reverseGeocodeLocation(location) { (placemarks: [CLPlacemark]?, error: Error?) -> Void in
            guard let placemarks = placemarks, let placemark = placemarks.first else
            {
                return
            }
            
            if let handler = handler
            {
                handler(placemark.name)
            }
            else
            {
                self.myAddress = placemark.name
            }
        }
    }
}

//
// MARK: - CLLocationManagerDelegate Protocol
//

extension Locationer: CLLocationManagerDelegate
{
    /**
        Actualizaciones en la localización
    */
    public func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) -> Void
    {
        guard let location = locations.last else
        {
            return
        }
        
        // Las coordenadas
        self.myPosition = location
        // La posición de una forma más legible
        self.makeAddress(from: location)
        
        self.delegate?.locationer(self, didUpdateLocation: location)
    }
    
    /**
        Cambios en los permisos
    */
    public func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) -> Void
    {
        if case .denied = status
        {
            manager.stopUpdatingLocation()
        }
        else
        {
            manager.startUpdatingLocation()
        }
    }
    
    /**
        Error en la localización
    */
    public func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) -> Void
    {
        print("No podemos procesar la ubicación. \(error.localizedDescription)")
        
        self.delegate?.locationer(self, failsWithError: error)
    }
}
