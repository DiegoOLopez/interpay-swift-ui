import SwiftUI

struct ProfileView: View {
    // Para permitir cerrar sesión desde aquí
    @Binding var isAuthenticated: Bool
    
    // Datos mock de usuario
    @State private var name: String = "Diego Obed"
    @State private var email: String = "diego@example.com"
    @State private var preferredCurrency: String = "MXN"
    @State private var enableBiometrics: Bool = true
    @State private var useDarkMode: Bool = false
    
    // Estados UI
    @State private var showChangePassword = false
    @State private var showCurrencyPicker = false
    @State private var showLogoutConfirm = false
    @State private var showHelp = false
    
    let currencies = ["MXN", "USD", "EUR", "GBP"]
    
    var body: some View {
        NavigationStack {
            List {
                Section("Tu cuenta") {
                    HStack(spacing: 14) {
                        ZStack {
                            Circle()
                                .fill(LinearGradient(colors: [Color.green.opacity(0.7), Color.green],
                                                     startPoint: .topLeading, endPoint: .bottomTrailing))
                                .frame(width: 56, height: 56)
                                .shadow(color: Color.green.opacity(0.3), radius: 6, x: 0, y: 3)
                            Image(systemName: "person.fill")
                                .foregroundColor(.white)
                                .font(.system(size: 24, weight: .semibold))
                        }
                        VStack(alignment: .leading, spacing: 4) {
                            Text(name)
                                .font(.headline)
                            Text(email)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        Spacer()
                        Image(systemName: "chevron.right")
                            .foregroundColor(.secondary)
                    }
                    .contentShape(Rectangle())
                    .onTapGesture {
                        // Aquí podrías abrir edición de perfil (nombre, foto)
                    }
                }
                
                Section("Seguridad") {
                    Button {
                        showChangePassword = true
                    } label: {
                        Label("Cambiar contraseña", systemImage: "key.fill")
                    }
                    
                    Toggle(isOn: $enableBiometrics) {
                        Label("Usar Face ID / Touch ID", systemImage: "faceid")
                    }
                }
                
                Section("Preferencias") {
                    HStack {
                        Label("Divisa preferida", systemImage: "coloncurrencysign.circle")
                        Spacer()
                        Button(preferredCurrency) {
                            showCurrencyPicker = true
                        }
                        .buttonStyle(.borderless)
                    }
                    
                    Toggle(isOn: $useDarkMode) {
                        Label("Tema oscuro", systemImage: "moon.fill")
                    }
                }
                
                Section("Ayuda") {
                    Button {
                        showHelp = true
                    } label: {
                        Label("Cómo funcionan los pagos y divisas", systemImage: "questionmark.circle")
                    }
                }
                
                Section {
                    Button(role: .destructive) {
                        showLogoutConfirm = true
                    } label: {
                        Label("Cerrar sesión", systemImage: "rectangle.portrait.and.arrow.right")
                    }
                }
            }
            .navigationTitle("Perfil")
            .sheet(isPresented: $showChangePassword) {
                ChangePasswordView()
            }
            .sheet(isPresented: $showCurrencyPicker) {
                CurrencyPickerView(selected: $preferredCurrency, options: currencies)
            }
            .sheet(isPresented: $showHelp) {
                HelpView()
            }
            .confirmationDialog("¿Deseas cerrar tu sesión?", isPresented: $showLogoutConfirm, titleVisibility: .visible) {
                Button("Cerrar sesión", role: .destructive) {
                    withAnimation(.spring(response: 0.5, dampingFraction: 0.9)) {
                        isAuthenticated = false
                    }
                }
                Button("Cancelar", role: .cancel) { }
            } message: {
                Text("Podrás volver a entrar con tu correo, contraseña o biometría.")
            }
        }
    }
}

// MARK: - Subvistas

private struct ChangePasswordView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var current: String = ""
    @State private var newPass: String = ""
    @State private var confirm: String = ""
    @State private var showMismatch: Bool = false
    @State private var isLoading: Bool = false
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Contraseña actual") {
                    SecureField("••••••••", text: $current)
                        .textContentType(.password)
                }
                Section("Nueva contraseña") {
                    SecureField("Nueva contraseña", text: $newPass)
                    SecureField("Confirmar contraseña", text: $confirm)
                    if showMismatch {
                        Text("Las contraseñas no coinciden.")
                            .font(.footnote)
                            .foregroundColor(.red)
                    }
                }
            }
            .navigationTitle("Cambiar contraseña")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancelar") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button(isLoading ? "Guardando..." : "Guardar") {
                        guard !newPass.isEmpty, newPass == confirm else {
                            withAnimation { showMismatch = true }
                            return
                        }
                        showMismatch = false
                        isLoading = true
                        // Simula guardado
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                            isLoading = false
                            dismiss()
                        }
                    }
                    .disabled(isLoading)
                }
            }
        }
    }
}

private struct CurrencyPickerView: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var selected: String
    let options: [String]
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(options, id: \.self) { code in
                    HStack {
                        Text(code)
                        Spacer()
                        if selected == code {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.green)
                        }
                    }
                    .contentShape(Rectangle())
                    .onTapGesture {
                        selected = code
                        dismiss()
                    }
                }
            }
            .navigationTitle("Divisa preferida")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cerrar") { dismiss() }
                }
            }
        }
    }
}

private struct HelpView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    Text("Ayuda sobre pagos y divisas")
                        .font(.title2).bold()
                    
                    Group {
                        Text("• Realizar pagos")
                            .font(.headline)
                        Text("Desde la pestaña Pagar puedes seleccionar el monto en tu divisa preferida y confirmar el pago. Si ambos dispositivos están cercanos, InterPay intentará conectar usando Multipeer Connectivity para enviar la solicitud de pago de forma segura.")
                        
                        Text("• Cobrar a otros")
                            .font(.headline)
                            .padding(.top, 8)
                        Text("En Cobrar puedes generar una solicitud por el monto deseado y compartirla con dispositivos cercanos. El receptor verá el detalle y podrá aceptar el pago.")
                        
                        Text("• Divisas soportadas")
                            .font(.headline)
                            .padding(.top, 8)
                        Text("Actualmente manejamos MXN, USD, EUR y GBP en la configuración. Puedes cambiar tu divisa preferida en Perfil > Preferencias > Divisa preferida.")
                        
                        Text("• Consejos de seguridad")
                            .font(.headline)
                            .padding(.top, 8)
                        Text("Activa Face ID/Touch ID y usa contraseñas seguras. Verifica siempre los montos antes de confirmar un pago.")
                    }
                    .foregroundColor(.secondary)
                }
                .padding()
            }
            .navigationTitle("Ayuda")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cerrar") { dismiss() }
                }
            }
        }
    }
}
