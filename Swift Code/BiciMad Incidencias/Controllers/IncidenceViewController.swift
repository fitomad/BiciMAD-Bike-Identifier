// Icon made by Freepik from www.flaticon.com
import UIKit
import Foundation
import CoreLocation

import IncidenceKit

internal class IncidenceViewController: UIViewController
{
    /**
        Estado de los problemas detectados
        en esta incidencia.
    */
    private enum State
    {
        case selected
        case unselected
    }

    /// Para hacer una foto
    @IBOutlet private weak var buttonPhoto: UIBarButtonItem!
    /// Muestra la imagen asociada la incidencia, si la hubiera
    @IBOutlet private weak var imagePhoto: UIImageView!
    /// La dirección donde se crea la incidencia
    @IBOutlet private weak var labelAddress: UILabel!
    /// La hora a la que se ha creado la incidencia
    @IBOutlet private weak var labelTime: UILabel!

    /// Para marcar indidencias con las ruedas
    @IBOutlet private weak var buttonIncidenceWheel: UIButton!
    /// Para marcar indidencias con los frenos
    @IBOutlet private weak var buttonIncidenceBreaks: UIButton!
    /// Para marcar indidencias con las luces
    @IBOutlet private weak var buttonIncidenciaLights: UIButton!
    /// Para marcar indidencias con el motor
    @IBOutlet private weak var buttonIncidenciaEngine: UIButton!
    /// Para marcar indidencias con otro tipo de problema
    @IBOutlet private weak var buttonIncidenceOther: UIButton!
    /// Para marcar indidencias con el gancho
    @IBOutlet private weak var buttonIncidenciaHook: UIButton!

    /// Envía la incidencia a... 
    @IBOutlet private weak var buttonSend: UIButton!

    /// El identificar capturado
    internal var bikeSerialNumber: Int?
    /// Estructura donde guardamos la información
    /// de la incidencia
    private var incidence: Incidence?

    //
    // MARK: - Life Cycle
    //

    /**
        Aplicamos el tema y le decimos al
        `Locationer` que nos avise de los cambios
        en la localización del usuario
    */
    override internal func viewDidLoad() -> Void
    {
        super.viewDidLoad()

        self.applyTheme()
        
        Locationer.shared.delegate = self
    }
    
    /**
        Antes de aparecer en pantalla establecemos
        el título del formulario y recuperamos la
        dirección del `Locationer`
    */
    override internal func viewWillAppear(_ animated: Bool) -> Void
    {
        super.viewWillAppear(animated)
        
        if let bikeSerialNumber = self.bikeSerialNumber
        {
            self.title = "Bicicleta \(bikeSerialNumber)"
            
            self.incidence = Incidence(forBike: bikeSerialNumber, at: Date())
        }
        else
        {
            self.title = "Bicicleta"
        }
        
        if let myAddress = Locationer.shared.myAddress
        {
            self.labelAddress.text = myAddress
        }
    }

    //
    // MARK: - Prepare UI
    //

    /**
        Estilo para algunos elementos de la vista
    */ 
    private func applyTheme() -> Void
    {
        self.view.backgroundColor = UIColor.white

        self.labelAddress.textColor = UIColor(hexadecimal: "#212121")
        self.labelTime.textColor = UIColor(hexadecimal: "#212121")

        self.buttonSend.backgroundColor = UIColor(hexadecimal: "#ed6a3b")
        self.buttonSend.layer.cornerRadius = self.buttonSend.bounds.height / 2.0
        self.buttonSend.layer.masksToBounds = true
        self.buttonSend.tintColor = UIColor.white

        self.imagePhoto.layer.cornerRadius = 8.0
        self.imagePhoto.layer.borderWidth = 2.0
        self.imagePhoto.layer.borderColor = UIColor(hexadecimal: "#e9e9e9").cgColor
        self.imagePhoto.layer.masksToBounds = true

        self.applyUnselectedTheme(to: self.buttonIncidenceBreaks)
        self.applyUnselectedTheme(to: self.buttonIncidenceOther)
        self.applyUnselectedTheme(to: self.buttonIncidenceWheel)
        self.applyUnselectedTheme(to: self.buttonIncidenciaEngine)
        self.applyUnselectedTheme(to: self.buttonIncidenciaHook)
        self.applyUnselectedTheme(to: self.buttonIncidenciaLights)
    }

    //
    // MARK: - Animations
    //

    /**
        Estilo para un botón de problema que ha
        sido deseleccionado

        - Parameter button: El botón que ya no está seleccionado
    */
    private func applyUnselectedTheme(to button: UIButton) -> Void
    {
        let animator = UIViewPropertyAnimator(duration: 0.35, curve: .easeIn)

        animator.addAnimations({
            button.backgroundColor = UIColor.white
            button.tintColor = UIColor(hexadecimal: "#E55812")
            button.layer.borderColor = UIColor(hexadecimal: "#F5EBDD").cgColor
            button.layer.borderWidth = 1.0
            button.layer.cornerRadius = button.bounds.height / 2.0
            button.layer.masksToBounds = true
        })

        animator.startAnimation()
    }

    /**
        Estilo para un botón de problema que ha
        sido seleccionado

        - Parameter button: El botón que está seleccionado
    */
    private func applySelectedTheme(to button: UIButton) -> Void
    {
        let animator = UIViewPropertyAnimator(duration: 0.35, curve: .easeIn)

        animator.addAnimations({
            button.backgroundColor = UIColor(hexadecimal: "#675948")
            button.tintColor = UIColor(hexadecimal: "#ffffff")
            button.layer.borderColor = UIColor(hexadecimal: "#675948").cgColor
            button.layer.borderWidth = 1.0
            button.layer.cornerRadius = button.bounds.height / 2.0
            button.layer.masksToBounds = true
        })

        animator.startAnimation()
    }

    /**
        Gestiona los cambios de estado de los botones
        de problemas.

        - Parameters:
            - button: El botón que se ha pulsado
            - state: Su nuevo estado
    */
    private func button(_ button: UIButton, changesToState state: State) -> Void
    {
        switch state
        {
            case .selected:
                self.applySelectedTheme(to: button)
                button.selectedFeedback()

            case .unselected:
                self.applyUnselectedTheme(to: button)
                button.unselectedFeedback()
        }
    }

    //
    // MARK: - Private Methods
    //

    /**
        Maneja el resultado de pulsar el botón de problemas.

        - Parameters:
            - kind: El problema al que se refiere el usuario
            - button: El botón asignado al problema
    */
    private func manageIncidence(ofKind kind: Incidence.Kind, forButton button: UIButton) -> Void
    {
        self.incidence!.toogle(kind: kind)

        let new_state: State = self.incidence![kind] ? .selected : .unselected

        self.button(button, changesToState: new_state)
    }

    //
    // MARK: - Actions
    //
    
    /**
        Presentamos el controllador de la cámara de fotos
    */
    @IBAction private func handlePhotoButtonTap(sender: UIBarButtonItem) -> Void
    {
        guard let storyboard = self.storyboard,
              let controller = storyboard.instantiateViewController(withIdentifier: "CameraViewController") as? CameraViewController
        else
        {
            return
        }
        
        controller.delegate = self
        self.navigationController?.pushViewController(controller, animated: true)
    }

    /**
        Pulsado el botón del problema con las ruedas
    */
    @IBAction private func handleIncidenceWheelButtonTap(sender: UIButton) -> Void
    {
        self.manageIncidence(ofKind: .wheel, forButton: sender)
    }

    /**
        Pulsado el botón del otro problema
    */
    @IBAction private func handleIncidenceOtherButtonTap(sender: UIButton) -> Void
    {
        self.manageIncidence(ofKind: .other, forButton: sender)
    }

    /**
        Pulsado el botón del problema con el motor
    */
    @IBAction private func handleIncidenceEngineButtonTap(sender: UIButton) -> Void
    {
        self.manageIncidence(ofKind: .engine, forButton: sender)
    }

    /**
        Pulsado el botón del problema con las luces
    */
    @IBAction private func handleIncidenceLightsButtonTap(sender: UIButton) -> Void
    {
        self.manageIncidence(ofKind: .lights, forButton: sender)
    }

    /**
        Pulsado el botón del problema con el enganche
    */
    @IBAction private func handleIncidenceHookButtonTap(sender: UIButton) -> Void
    {
        self.manageIncidence(ofKind: .hook, forButton: sender)
    }

    /**
        Pulsado el botón del problema con los frenos
    */
    @IBAction private func handleIncidenceBreaksButtonTap(sender: UIButton) -> Void
    {
        self.manageIncidence(ofKind: .breaks, forButton: sender)
    }

    /**
        Envía la incidencia
    */
    @IBAction private func handleSendButtonTap(sender: UIButton) -> Void
    {
        
    }
}

//
// MARK: - CameraViewControllerDelegate Protocol
//

extension IncidenceViewController: CameraViewControllerDelegate
{
    /**
        La foto tomada por el usuario
    */
    func cameraViewController(_ controller: CameraViewController, didFinishTakePhoto photo: UIImage) -> Void
    {
        self.imagePhoto.image = photo
        self.incidence?.image = photo
    }

    /**
        El usuario no ha querido hacer la foto
    */
    func cameraViewControllerDidCancel(_ controller: CameraViewController) -> Void
    {
        print("No ha querido hacer la foto...")
    }
}

extension IncidenceViewController: LocationerDelegate
{
    /**
        Cambio en la localización del usuario
    */
    func locationer(_ locationer: Locationer, didUpdateLocation location: CLLocation) -> Void
    {
        self.incidence?.location = location
        
        Locationer.shared.makeAddress(from: location) { (address: String?) -> Void in
            if let address = address
            {
                self.labelAddress.text = address
                self.incidence?.address = address
            }
        }
    }
    
    /**
        Error al recuperar la posición del usuario
    */
    func locationer(_ locationer: Locationer, failsWithError error: Error) -> Void
    {
        print("No se puede situar la incidencia")
    }
}
