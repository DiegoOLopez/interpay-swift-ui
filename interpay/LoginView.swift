import SwiftUI
import LocalAuthentication

struct LoginView: View {
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var isSecure: Bool = true
    @State private var isLoading: Bool = false
    @State private var showError: Bool = false
    @State private var errorMessage: String = ""
    @State private var animateBG: Bool = false
    @State private var showRegister: Bool = false
    
    // --- 1. CAMBIO CLAVE: Reemplaza el @Binding ---
    
    // BORRA esta línea:
    // @Binding var isAuthenticated: Bool
    
    // AÑADE esta línea:
    @EnvironmentObject var authManager: AuthManager
    
    // ----------------------------------------------

    // (¡Asegúrate de haber BORRADO las 'structs' LoginRequest,
    // LoginResponse, User, y el 'enum' AuthError de aquí!
    // Ya deben estar en tu archivo 'UserModels.swift')
    
    var body: some View {
        ZStack {
            animatedBackground
            
            VStack(spacing: 24) {
                // ... (Logo / Título no cambia) ...
                
                // Formulario
                VStack(spacing: 16) {
                    // ... (inputField no cambia) ...
                    
                    // Botón de Login (la acción cambia)
                    Button(action: loginAction) {
                        HStack {
                            if isLoading {
                                ProgressView()
                                    .tint(.black)
                            } else {
                                Image(systemName: "arrow.right.circle.fill")
                                    .font(.title3)
                            }
                            Text(isLoading ? "Ingresando..." : "Ingresar")
                                .font(.headline)
                        }
                        .frame(maxWidth: .infinity)
                        // ... (el resto del botón no cambia)
                    }
                    .disabled(isLoading || !isValidForm)
                    .opacity(isValidForm ? 1 : 0.6)
                    
                    // Botón de Biométricos (la acción cambia)
                    if canUseBiometrics {
                        Button(action: authenticateWithBiometrics) {
                            // ... (El Hstack de tu botón no cambia) ...
                        }
                    }
                    
                    HStack {
                        Button("Crear cuenta") {
                            showRegister = true
                        }
                        .foregroundColor(.white.opacity(0.9))
                        .sheet(isPresented: $showRegister) {
                            
                            // --- 2. CAMBIO: Pasa el manager a RegisterView ---
                            // Asumimos que RegisterView también usará
                            // el AuthManager para loguear al usuario
                            // cuando el registro sea exitoso.
                            RegisterView()
                                .environmentObject(authManager)
                            // (Borramos el 'onComplete' closure que
                            //  solo cambiaba el @Binding 'isAuthenticated')
                            // ----------------------------------------------
                        }
                        
                        Spacer()
                        
                        Button("Olvidé mi contraseña") {
                            // ...
                        }
                        .foregroundColor(.white.opacity(0.9))
                    }
                    .font(.footnote.weight(.semibold))
                    .padding(.top, 6)
                }
                .padding(20)
                // ... (El resto de tu UI (backgrounds, shadows) no cambia) ...
            }
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 6).repeatForever(autoreverses: true)) {
                animateBG = true
            }
        }
    }
    
    private var isValidForm: Bool {
        email.contains("@") && email.contains(".") && password.count >= 4
    }
    
    // --- 3. CAMBIO CLAVE: 'loginAction' ahora delega ---
    private func loginAction() {
        guard isValidForm else {
            withAnimation {
                showError = true
                errorMessage = "Verifica tu correo y contraseña."
            }
            return
        }
        
        withAnimation {
            showError = false
            isLoading = true
        }
        
        Task {
            do {
                // (3. Prepara la solicitud - Sin cambios)
                let urlString = "http://192.168.1.109:3001/api/auth/login"
                guard let url = URL(string: urlString) else { throw AuthError.unknown }
                
                // (4. Prepara el cuerpo - Sin cambios)
                let loginData = LoginRequest(email: email, password: password)
                let bodyData = try JSONEncoder().encode(loginData)
                
                // (5. Configura la petición - Sin cambios)
                var request = URLRequest(url: url)
                request.httpMethod = "POST"
                request.httpBody = bodyData
                request.setValue("application/json", forHTTPHeaderField: "Content-Type")

                // (6. Ejecuta la llamada - Sin cambios)
                let (data, response) = try await URLSession.shared.data(for: request)
                
                // (7. Valida la respuesta - Sin cambios)
                guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                    if ((response as? HTTPURLResponse)?.statusCode == 401) {
                        throw AuthError.invalidCredentials
                    } else {
                        throw AuthError.serverError
                    }
                }
                
                // (8. Decodifica la respuesta - Sin cambios)
                let loginResponse = try JSONDecoder().decode(LoginResponse.self, from: data)
                
                
                // --- ¡AQUÍ ESTÁ LA NUEVA LÓGICA! ---
                
                // (BORRA ESTO, el AuthManager lo hará:)
                // let userData = try JSONEncoder().encode(loginResponse.user)
                // try KeychainHelper.save(...)
                
                // (10. Actualiza la UI llamando al manager)
                await MainActor.run {
                    isLoading = false
                    
                    // Esta única línea reemplaza a 'isAuthenticated = true'
                    // y al guardado en Keychain.
                    authManager.login(user: loginResponse.user)
                }
                
            } catch {
                // (El manejo de errores no cambia)
                await MainActor.run {
                    isLoading = false
                    showError = true
                    errorMessage = "Error de red o credenciales."
                    print("Error de login: \(error.localizedDescription)")
                }
            }
        }
    }
    
    // ... (Definiciones de Biométricos (canUse, label, icon) no cambian) ...
    private var canUseBiometrics: Bool { /* ... */ return LAContext().canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: nil) }
    private var biometricLabel: String { /* ... */ return "Face ID" }
    private var biometricIconName: String { /* ... */ return "faceid" }
    
    // --- 4. CAMBIO CLAVE: Biométricos ahora carga la sesión ---
    private func authenticateWithBiometrics() {
        let context = LAContext()
        let reason = "Autentícate para acceder a InterPay."
        
        context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) { success, _ in
            DispatchQueue.main.async {
                if success {
                    // En lugar de solo cambiar el Bool,
                    // le pedimos al AuthManager que intente
                    // cargar la sesión guardada desde el Keychain.
                    authManager.loadUserFromKeychain()
                }
            }
        }
    }
    
    // ... (Tu 'inputField' y 'animatedBackground' no cambian) ...
    
    @ViewBuilder
    private func inputField(title: String,
                            text: Binding<String>,
                            icon: String,
                            isSecure: Bool,
                            keyboard: UIKeyboardType,
                            trailingAction: (() -> Void)? = nil) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.caption)
                .foregroundColor(.white.opacity(0.8))
            HStack(spacing: 10) {
                Image(systemName: icon)
                    .foregroundColor(.green)
                if isSecure {
                    SecureField("••••••••", text: text)
                        .textContentType(.password)
                        .keyboardType(keyboard)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                        .foregroundColor(.white)
                } else {
                    TextField(title, text: text)
                        .textContentType(.emailAddress)
                        .keyboardType(keyboard)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                        .foregroundColor(.white)
                }
                if let action = trailingAction {
                    Button(action: action) {
                        Image(systemName: isSecure ? "eye.slash.fill" : "eye.fill")
                            .foregroundColor(.white.opacity(0.8))
                    }
                }
            }
            .padding(14)
            .background(Color.white.opacity(0.06))
            .overlay(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .stroke(Color.white.opacity(0.12), lineWidth: 1)
            )
            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        }
    }
    
    private var animatedBackground: some View {
        ZStack {
            LinearGradient(
                colors: [Color.black, Color.black.opacity(0.9)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            Circle()
                .fill(Color.green.opacity(animateBG ? 0.18 : 0.10))
                .frame(width: animateBG ? 380 : 320, height: animateBG ? 380 : 320)
                .blur(radius: 60)
                .offset(x: -120, y: -180)
                .animation(.easeInOut(duration: 6).repeatForever(autoreverses: true), value: animateBG)
            Circle()
                .fill(Color.green.opacity(animateBG ? 0.14 : 0.08))
                .frame(width: animateBG ? 420 : 360, height: animateBG ? 420 : 360)
                .blur(radius: 80)
                .offset(x: 140, y: 160)
                .animation(.easeInOut(duration: 6).repeatForever(autoreverses: true), value: animateBG)
        }
        .ignoresSafeArea()
    }
}
