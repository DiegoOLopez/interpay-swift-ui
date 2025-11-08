import MultipeerConnectivity
import Foundation

// Un ejemplo de datos que podríamos querer enviar
struct MiDato: Codable {
    var id: UUID
    var mensaje: String
    var valor: Double
}
// Asumiendo que tienes una variable 'session' de tipo MCSession
var session: MCSession!

func enviarDatosJSON() {
    // 1. Crea el objeto que quieres enviar
    let misDatos = MiDato(id: UUID(), mensaje: "¡Hola desde MPC!", valor: 123.45)

    do {
        // 2. Codifica el objeto a Data (JSON)
        let data = try JSONEncoder().encode(misDatos)
        
        // 3. Envía el Data a todos los peers conectados
        if !session.connectedPeers.isEmpty {
            try session.send(data, toPeers: session.connectedPeers, with: .reliable)
        }
        
    } catch let error {
        print("Error al codificar o enviar JSON: \(error.localizedDescription)")
    }
}
