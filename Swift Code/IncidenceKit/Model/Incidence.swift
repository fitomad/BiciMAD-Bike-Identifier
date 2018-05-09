
import Foundation
import CoreLocation

public struct Incidence
{
    /**
        Tipos de incidencias reportables
    */
    public enum Kind
    {
        case wheel
        case breaks
        case lights
        case engine
        case other
        case hook
    }

    /// Identificador de la bicicleta
    public var bikeIdentifier: Int
    /// Fecha de creación de la incidencia
    public var createdAt: Date
    /// Los fallos que ve el usuario
    public var kinds: [Kind]
    /// Donde se informa de la incidencia
    public var location: CLLocation?
    /// Dirección en base de la localización
    public var address: String?
    /// Una imagen de la incidencia.
    public var image: UIImage?

    /// Si la incidencia tiene este problema reportado
    public subscript(kind: Kind) -> Bool
    {
        return self.kinds.contains(kind)
    }

    /**
        Nueva incidencia para una bicicleta en un momento dado

        - Parameters:
            - bike: El identificador único de la bici 
            - time: Cuando se crea esta incidencia
    */
    public init(forBike bike: Int, at time: Date)
    {
        self.bikeIdentifier = bike
        self.createdAt = time

        self.kinds = [Kind]()
    }

    /**
        Activa o desactiva los problemas que tiene 
        la incidencia.

        - Parameter kind: El problema que vamos a añadir o quitar
    */
    public mutating func toogle(kind: Kind) -> Void
    {
        if self.kinds.contains(kind)
        {
            if let index = self.kinds.index(of: kind)
            {
                self.kinds.remove(at: index)
            }
        } 
        else
        {
            self.kinds.append(kind)
        }
    }
}

//
// MARK: - CustomStringConvertible Protocol
//

extension Incidence: CustomStringConvertible
{
    /// Descripción más detallada. 
    /// Útil en la depuración de la app.
    public var description: String
    {
        var incidenceDescription: String = "Incidencia con la bicicleta \(self.bikeIdentifier)."
        
        return incidenceDescription
    }
}
