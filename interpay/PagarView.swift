//
//  PagarView.swift
//  interpay
//
//  Created by Diego Obed on 08/11/25.
//

import SwiftUI

public struct PayInformation {
    var localType: String
    var businessType: String
    var localAmount: Double
    var businessAmount: Double
}


struct PagarView: View {
    // Estados para los montos
    @State private var payInfo = PayInformation(
        localType: "-",
        businessType: "-",
        localAmount: 0.0,
        businessAmount: 0.0
    )
    @EnvironmentObject var sendAmount: SendAmount

    
    var body: some View {
        VStack(spacing: 20) {
            Text("Payment Summary")
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding(.top, 40)
            
            Spacer()
            
            // Card para MXN
            VStack(alignment: .leading, spacing: 8) {
                Text("Total to pay in \(payInfo.localType):")
                    .font(.headline)
                    .foregroundColor(.secondary)
                
                Text("$\(payInfo.localAmount, specifier: "%.2f") \(payInfo.localType)")
                    .font(.system(size: 36, weight: .bold))
                    .foregroundColor(.primary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(12)
            .padding(.horizontal)
            
            // Card para USD
            VStack(alignment: .leading, spacing: 8) {
                Text("Total to pay in \(payInfo.businessType):")
                    .font(.headline)
                    .foregroundColor(.secondary)
                
                Text("$\(payInfo.businessAmount, specifier: "%.2f") \(payInfo.businessType)")
                    .font(.system(size: 36, weight: .bold))
                    .foregroundColor(.primary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(12)
            .padding(.horizontal)
            
            Spacer()
            
            // Botón de pago (opcional)
            Button(action: {
                // Acción del botón de pago
            }) {
                Text("Proceed to Payment")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(12)
            }
            .padding(.horizontal)
            .padding(.bottom, 40)
        }
        .onChange(of: sendAmount.solicitudRecibida) { _, nuevaSolicitud in
            
            guard let solicitud = nuevaSolicitud else { return }
            payInfo.businessAmount = solicitud.amount
            payInfo.businessType = solicitud.currency
            
        }
        
    }
}

#Preview {
    PagarView()
        .environmentObject(SendAmount())
}
