import Foundation
import Combine
// Estructura de datos que realmente enviaremos
struct SolicitudPago: Codable {
    var id: UUID
    var amount: Double
    var currency: String // Usaremos el 'rawValue' de tu enum, ej: "MXN"
}

import MultipeerConnectivity
import SwiftUI

// Este manager manejará toda la lógica de MPC
class SendAmount: NSObject, ObservableObject, MCSessionDelegate, MCNearbyServiceAdvertiserDelegate, MCNearbyServiceBrowserDelegate {
    
    private let serviceType = "interpay-mpc" // Un identificador único para tu app
    private let myPeerID: MCPeerID
    let session: MCSession
    private let serviceAdvertiser: MCNearbyServiceAdvertiser
    private let serviceBrowser: MCNearbyServiceBrowser

    // Publica los peers conectados para que la vista pueda verlos si es necesario
    @Published var connectedPeers: [MCPeerID] = []

    override init() {
        // 1. Inicializa el PeerID con el nombre del dispositivo
        self.myPeerID = MCPeerID(displayName: UIDevice.current.name)
        
        // 2. Crea la sesión
        self.session = MCSession(peer: myPeerID, securityIdentity: nil, encryptionPreference: .required)
        
        // 3. Crea el Advertiser (para que otros te vean)
        self.serviceAdvertiser = MCNearbyServiceAdvertiser(peer: myPeerID, discoveryInfo: nil, serviceType: serviceType)
        
        // 4. Crea el Browser (para ver a otros)
        self.serviceBrowser = MCNearbyServiceBrowser(peer: myPeerID, serviceType: serviceType)

        super.init()

        // 5. Asigna los delegados
        self.session.delegate = self
        self.serviceAdvertiser.delegate = self
        self.serviceBrowser.delegate = self

        // 6. Empieza a anunciar y buscar
        self.serviceAdvertiser.startAdvertisingPeer()
        self.serviceBrowser.startBrowsingForPeers()
    }
    
    deinit {
        // Detener al salir
        self.serviceAdvertiser.stopAdvertisingPeer()
        self.serviceBrowser.stopBrowsingForPeers()
    }

    // --- FUNCIÓN DE ENVÍO ---
    // Esta es la función clave que llamará tu vista
    func sendPaymentRequest(amount: Double, currency: String) {
        guard !session.connectedPeers.isEmpty else {
            print("No hay peers conectados a los que enviar la solicitud.")
            return
        }

        // 1. Crea el objeto que quieres enviar
        let solicitud = SolicitudPago(id: UUID(), amount: amount, currency: currency)

        do {
            // 2. Codifica el objeto a Data (JSON)
            let data = try JSONEncoder().encode(solicitud)
            
            // 3. Envía el Data a todos los peers conectados
            try session.send(data, toPeers: session.connectedPeers, with: .reliable)
            print("Solicitud de pago enviada correctamente.")
            
        } catch let error {
            print("Error al codificar o enviar SolicitudPago: \(error.localizedDescription)")
        }
    }

    // --- Métodos Requeridos del Delegado MCSession ---

    func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
        DispatchQueue.main.async {
            switch state {
            case .connected:
                print("Conectado a: \(peerID.displayName)")
                if !self.connectedPeers.contains(peerID) {
                    self.connectedPeers.append(peerID)
                }
            case .notConnected:
                print("Desconectado de: \(peerID.displayName)")
                self.connectedPeers.removeAll(where: { $0 == peerID })
            case .connecting:
                print("Conectando a: \(peerID.displayName)")
            @unknown default:
                fatalError("Estado desconocido de MCSession")
            }
        }
    }

    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
        // Aquí es donde RECIBIRÍAS datos (ej. una confirmación de pago)
        print("Datos recibidos de \(peerID.displayName)")
        // Intenta decodificar los datos recibidos...
    }
    
    // (Otros métodos de delegado obligatorios pero que puedes dejar vacíos por ahora)
    func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID) { }
    func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with progress: Progress) { }
    func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL?, withError error: Error?) { }

    // --- Métodos del Delegado MCNearbyServiceAdvertiser ---
    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didReceiveInvitationFromPeer peerID: MCPeerID, withContext context: Data?, invitationHandler: @escaping (Bool, MCSession?) -> Void) {
        // Aceptar automáticamente las invitaciones por simplicidad
        print("Invitación recibida de \(peerID.displayName)")
        invitationHandler(true, self.session)
    }

    // --- Métodos del Delegado MCNearbyServiceBrowser ---
    func browser(_ browser: MCNearbyServiceBrowser, foundPeer peerID: MCPeerID, withDiscoveryInfo info: [String : String]?) {
        // Invitar automáticamente a los peers encontrados por simplicidad
        print("Peer encontrado: \(peerID.displayName). Invitando...")
        browser.invitePeer(peerID, to: self.session, withContext: nil, timeout: 10)
    }

    func browser(_ browser: MCNearbyServiceBrowser, lostPeer peerID: MCPeerID) {
        print("Peer perdido: \(peerID.displayName)")
    }
}
