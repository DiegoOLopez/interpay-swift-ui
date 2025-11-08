//
//  decodificador_json.swift
//  interpay
//
//  Created by Diego Obed on 08/11/25.
//
/**
import Foundation

import MultipeerConnectivity

// Tu clase debe conformarse a MCSessionDelegate
class MiControladorDeConexion: NSObject, MCSessionDelegate {

    var session: MCSession!
    
    // ... otros métodos del delegado (session:peer:didChange:) ...

    // Este es el método clave para recibir
    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
        
        do {
            // 1. Intenta decodificar el Data como si fuera tu struct
            let datosRecibidos = try JSONDecoder().decode(MiDato.self, from: data)
            
            // 2. ¡Éxito! Ahora puedes usar el objeto
            print("Datos JSON recibidos de \(peerID.displayName):")
            print("Mensaje: \(datosRecibidos.mensaje)")
            print("Valor: \(datosRecibidos.valor)")

            // Asegúrate de actualizar la UI en el hilo principal si es necesario
            DispatchQueue.main.async {
                // self.actualizarLabel(con: datosRecibidos.mensaje)
            }
            
        } catch let error {
            print("Error al decodificar JSON de \(peerID.displayName): \(error.localizedDescription)")
        }
    }
    
    // --- Métodos obligatorios del delegado (puedes dejarlos así por ahora) ---
    
    func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
        // Maneja cambios de estado (conectado, desconectado)
        switch state {
        case .connected:
            print("Conectado: \(peerID.displayName)")
        case .connecting:
            print("Conectando: \(peerID.displayName)")
        case .notConnected:
            print("No conectado: \(peerID.displayName)")
        @unknown default:
            fatalError("Estado desconocido")
        }
    }
    
    func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID) {
        // No usado para JSON
    }
    
    func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with progress: Progress) {
        // No usado para JSON
    }
    
    func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL?, withError error: Error?) {
        // No usado para JSON
    }
}

 */
