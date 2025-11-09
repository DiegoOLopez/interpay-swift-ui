//
//  CobrarView.swift
//  interpay
//
//  Created by Diego Obed on 08/11/25.
//

import SwiftUI
import MultipeerConnectivity

struct CobrarView: View {
    @State private var amount: String = ""
    @State private var selectedCurrency: Currency = .MXN
    @State private var showCurrencyPicker: Bool = false
    @FocusState private var isAmountFocused: Bool
    @EnvironmentObject var sendAmount: SendAmount
    
    
    enum Currency: String, CaseIterable {
        case PKR = "PKR"
        case PEB = "PEB"
        case EGG = "EGG"
        case CAD = "CAD"
        case SGD = "SGD"
        case MXN = "MXN"
        case GBP = "GBP"
        case ZAR = "ZAR"
        case EUR = "EUR"
        case USD = "USD"
        
        var symbol: String {
            switch self {
            case .PKR: return "₨"
            case .PEB: return "£"
            case .EGG: return "E£"
            case .CAD: return "$"
            case .SGD: return "$"
            case .MXN: return "$"
            case .GBP: return "£"
            case .ZAR: return "R"
            case .EUR: return "€"
            case .USD: return "$"
            }
        }
        
        var flag: String {
            switch self {
            case .PKR: return "🇵🇰"
            case .PEB: return "🇷🇺"
            case .EGG: return "🇪🇬"
            case .CAD: return "🇨🇦"
            case .SGD: return "🇸🇬"
            case .MXN: return "🇲🇽"
            case .GBP: return "🇬🇧"
            case .ZAR: return "🇿🇦"
            case .EUR: return "🇪🇺"
            case .USD: return "🇺🇸"
            }
        }
        
        var name: String {
            switch self {
            case .PKR: return "Pakistani Rupee"
            case .PEB: return "Russian Ruble"
            case .EGG: return "Egyptian Pound"
            case .CAD: return "Canadian Dollar"
            case .SGD: return "Singapore Dollar"
            case .MXN: return "Mexican Peso"
            case .GBP: return "British Pound"
            case .ZAR: return "South African Rand"
            case .EUR: return "Euro"
            case .USD: return "US Dollar"
            }
        }

    }
    
    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                // Header
                Text("Solicitar Pago")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding(.top, 40)
                    .padding(.bottom, 20)
                
                Spacer()
                
                // Área principal de input
                VStack(spacing: 24) {
                    // Selector de moneda compacto
                    Button(action: {
                        withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                            showCurrencyPicker = true
                            isAmountFocused = false
                        }
                    }) {
                        HStack(spacing: 12) {
                            Text(selectedCurrency.flag)
                                .font(.system(size: 32))
                            
                            VStack(alignment: .leading, spacing: 2) {
                                Text(selectedCurrency.rawValue)
                                    .font(.headline)
                                    .foregroundColor(.primary)
                                
                                Text(selectedCurrency.name)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            
                            Spacer()
                            
                            Image(systemName: "chevron.down")
                                .foregroundColor(.secondary)
                                .rotationEffect(.degrees(showCurrencyPicker ? 180 : 0))
                        }
                        .padding(.horizontal, 20)
                        .padding(.vertical, 16)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color(.systemGray6))
                        )
                    }
                    .padding(.horizontal, 24)
                    
                    // Input de cantidad
                    VStack(spacing: 8) {
                        HStack(alignment: .center, spacing: 4) {
                            Text(selectedCurrency.symbol)
                                .font(.system(size: 48, weight: .medium))
                                .foregroundColor(.secondary)
                            
                            TextField("0", text: $amount)
                                .font(.system(size: 72, weight: .bold))
                                .keyboardType(.decimalPad)
                                .multilineTextAlignment(.leading)
                                .focused($isAmountFocused)
                                .frame(maxWidth: .infinity)
                        }
                        .padding(.horizontal, 24)
                        
                        // Indicador de moneda seleccionada
                        Text(selectedCurrency.rawValue)
                            .font(.title3)
                            .fontWeight(.semibold)
                            .foregroundColor(.secondary)
                    }
                    .padding(.vertical, 32)
                    .background(
                        RoundedRectangle(cornerRadius: 24)
                            .fill(Color(.systemGray6))
                    )
                    .padding(.horizontal, 24)
                }
                
                Spacer()
                
                // Botón de acción
                Button(action: {
                    cobrarAction()
                }) {
                    HStack {
                        Image(systemName: "square.and.arrow.up")
                            .font(.title3)
                        Text("Generar Solicitud")
                            .font(.headline)
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 18)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(
                                amount.isEmpty ? Color.gray : Color.blue
                            )
                    )
                }
                .disabled(amount.isEmpty)
                .padding(.horizontal, 24)
                .padding(.bottom, 40)
            }
            
            // Currency Picker Overlay
            if showCurrencyPicker {
                Color.black.opacity(0.3)
                    .ignoresSafeArea()
                    .onTapGesture {
                        withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                            showCurrencyPicker = false
                        }
                    }
                
                VStack {
                    Spacer()
                    
                    VStack(spacing: 0) {
                        // Header del picker
                        HStack {
                            Text("Seleccionar Moneda")
                                .font(.headline)
                            Spacer()
                            Button(action: {
                                withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                                    showCurrencyPicker = false
                                }
                            }) {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundColor(.secondary)
                                    .font(.title2)
                            }
                        }
                        .padding()
                        .background(Color(.systemBackground))
                        
                        Divider()
                        
                        // Lista de monedas
                        ScrollView {
                            LazyVStack(spacing: 0) {
                                ForEach(Currency.allCases, id: \.self) { currency in
                                    CurrencyRow(
                                        currency: currency,
                                        isSelected: selectedCurrency == currency
                                    ) {
                                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                            selectedCurrency = currency
                                            showCurrencyPicker = false
                                        }
                                    }
                                }
                            }
                            .padding(.bottom, 80) // <-- AÑADE ESTA LÍNEA
                        }
                        .frame(maxHeight: 400)
                    }
                    .background(Color(.systemBackground))
                    .cornerRadius(20, corners: [.topLeft, .topRight])
                    .shadow(radius: 20)
                    .transition(.move(edge: .bottom))
                }
                .ignoresSafeArea(edges: .bottom)
            }
        }
        .onTapGesture {
            isAmountFocused = false
        }
    }
    
    private func cobrarAction() {
        guard let amountValue = Double(amount) else { return }
        print("Cobrando \(selectedCurrency.symbol)\(amountValue) \(selectedCurrency.rawValue)")
        // Aquí implementarás la lógica de cobro
        sendAmount.sendPaymentRequest(amount: amountValue, currency: selectedCurrency.rawValue)
    }
}

// Componente para las filas de moneda
struct CurrencyRow: View {
    let currency: CobrarView.Currency
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                Text(currency.flag)
                    .font(.system(size: 36))
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(currency.rawValue)
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    Text(currency.name)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.blue)
                        .font(.title3)
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
            .background(isSelected ? Color.blue.opacity(0.1) : Color.clear)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// Extension para redondear esquinas específicas
extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
}

struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners
    
    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(path.cgPath)
    }
}

#Preview {
    CobrarView()
        .environmentObject(SendAmount())
}
