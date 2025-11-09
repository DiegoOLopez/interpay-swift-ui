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
        localType: "MXN",
        businessType: "-",
        localAmount: 0.0,
        businessAmount: 0.0
    )
    @EnvironmentObject var sendAmount: SendAmount
    private let currencyConverter = CurrencyConverter()
    @State private var isLoading = false
    
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
        .task(id: sendAmount.solicitudRecibida) {
            guard let solicitud = sendAmount.solicitudRecibida else { return }
            await actualizarMontos(from: solicitud)
            
        }
        
    }
    func actualizarMontos(from solicitud: SolicitudPago) async {
            isLoading = true
            
            payInfo.businessType = solicitud.currency
            payInfo.businessAmount = solicitud.amount
            
            do {
                if payInfo.businessType == payInfo.localType {
                    // --- CASO 1: Recibimos un pago en nuestra moneda local (ej. MXN) ---
                    
                    // Caja local (MXN) muestra el monto recibido
                    payInfo.localType = payInfo.businessType
                    payInfo.localAmount = payInfo.businessAmount
                    
                } else {
                    // --- CASO 2: Recibimos un pago en moneda externa (ej. CAD, USD, EUR) ---

                    let montoConvertido = try await currencyConverter.convert(
                        amount: payInfo.businessAmount,
                        from: payInfo.businessType,
                        to: payInfo.localType
                    )
                    payInfo.localAmount = montoConvertido
                }
            } catch {
                print("Error al convertir moneda: \(error.localizedDescription)")
                payInfo.localType = "Error"
                payInfo.businessType = "Error"
            }
            
            isLoading = false
        }
}

#Preview {
    PagarView()
        .environmentObject(SendAmount())
}
