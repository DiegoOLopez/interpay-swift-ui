//
//  PagarView.swift
//  interpay
//
//  Created by Diego Obed on 08/11/25.
//

import SwiftUI

struct PagarView: View {
    // Estados para los montos
    @State private var totalMXN: Double = 0.0
    @State private var totalUSD: Double = 0.0
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Resumen de Pago")
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding(.top, 40)
            
            Spacer()
            
            // Card para MXN
            VStack(alignment: .leading, spacing: 8) {
                Text("Total a pagar en MXN:")
                    .font(.headline)
                    .foregroundColor(.secondary)
                
                Text("$\(totalMXN, specifier: "%.2f") MXN")
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
                Text("Total a pagar en USD:")
                    .font(.headline)
                    .foregroundColor(.secondary)
                
                Text("$\(totalUSD, specifier: "%.2f") USD")
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
                Text("Proceder al Pago")
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
    }
}

#Preview {
    PagarView()
}
