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
    // Estructura para ENVIAR el JSON de login
    struct LoginRequest: Codable {
        let email: String
        let password: String
    }

    // Estructura para RECIBIR el JSON de respuesta
    // 1. Esta es la respuesta COMPLETA de la API
    struct LoginResponse: Codable {
        let message: String
        let user: User
    }

    // 2. Este es el objeto 'user' anidado
    struct User: Codable, Equatable {
        let id_user: Int
        let name: String
        let email: String
        let password: String // (Nota: es una mala práctica que tu API devuelva la contraseña)
        let created_at: String
        let updated_at: String
        let lenguaje: String
        let type_money: String
        let rol: String
        let key_url: String
    }

    // Un enum de error personalizado para manejar fallos de login
    enum AuthError: Error {
        case invalidCredentials
        case serverError
        case networkError(Error)
        case unknown
    }
    
    // Binding para notificar autenticación exitosa
    @Binding var isAuthenticated: Bool
    
    var body: some View {
        ZStack {
            animatedBackground
            
            VStack(spacing: 24) {
                // Logo / Título
                VStack(spacing: 8) {
                    // Un isotipo simple con glow verde
                    ZStack {
                        Circle()
                            .fill(Color.green.opacity(0.15))
                            .frame(width: 120, height: 120)
                            .blur(radius: 2)
                        Image(systemName: "link.circle.fill")
                            .font(.system(size: 72, weight: .semibold))
                            .foregroundStyle(.green)
                            .shadow(color: .green.opacity(0.5), radius: 12, x: 0, y: 0)
                    }
                    Text("InterPay")
                        .font(.system(size: 36, weight: .bold))
                        .foregroundStyle(.white)
                    Text("Pagos simples, interoperables.")
                        .font(.subheadline)
                        .foregroundStyle(.white.opacity(0.8))
                }
                .padding(.top, 40)
                
                // Formulario
                VStack(spacing: 16) {
                    inputField(
                        title: "Correo electrónico",
                        text: $email,
                        icon: "envelope.fill",
                        isSecure: false,
                        keyboard: .emailAddress
                    )
                    
                    inputField(
                        title: "Contraseña",
                        text: $password,
                        icon: "lock.fill",
                        isSecure: isSecure,
                        keyboard: .default
                    ) {
                        isSecure.toggle()
                    }
                    
                    if showError {
                        Text(errorMessage)
                            .font(.footnote)
                            .foregroundColor(.red)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .transition(.opacity)
                    }
                    
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
                        .padding(.vertical, 14)
                        .background(
                            LinearGradient(colors: [.green, Color.green.opacity(0.7)],
                                           startPoint: .topLeading, endPoint: .bottomTrailing)
                        )
                        .foregroundColor(.black)
                        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                        .shadow(color: .green.opacity(0.4), radius: 10, x: 0, y: 6)
                    }
                    .disabled(isLoading || !isValidForm)
                    .opacity(isValidForm ? 1 : 0.6)
                    
                    // Opcional: FaceID/TouchID
                    if canUseBiometrics {
                        Button(action: authenticateWithBiometrics) {
                            HStack(spacing: 8) {
                                Image(systemName: biometricIconName)
                                Text("Continuar con \(biometricLabel)")
                            }
                            .font(.subheadline.weight(.semibold))
                            .foregroundColor(.white)
                            .padding(.vertical, 10)
                            .frame(maxWidth: .infinity)
                            .background(Color.white.opacity(0.08))
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                        }
                    }
                    
                    HStack {
                        Button("Crear cuenta") {
                            showRegister = true        // <-- usar el booleano
                        }
                        .foregroundColor(.white.opacity(0.9))
                        .sheet(isPresented: $showRegister) { // <-- presentar el sheet
                            RegisterView {
                                // Autenticar al completar registro (opcional)
                                withAnimation(.spring(response: 0.6, dampingFraction: 0.9)) {
                                    isAuthenticated = true
                                }
                            }
                        }
                        
                        Spacer()
                        
                        Button("Olvidé mi contraseña") {
                            // Aquí podrías abrir recuperación
                        }
                        .foregroundColor(.white.opacity(0.9))
                    }
                    .font(.footnote.weight(.semibold))
                    .padding(.top, 6)
                }
                .padding(20)
                .background(
                    RoundedRectangle(cornerRadius: 24, style: .continuous)
                        .fill(Color.white.opacity(0.06))
                        .overlay(
                            RoundedRectangle(cornerRadius: 24, style: .continuous)
                                .stroke(Color.white.opacity(0.12), lineWidth: 1)
                        )
                        .shadow(color: .black.opacity(0.25), radius: 20, x: 0, y: 10)
                )
                .padding(.horizontal)
                
                Spacer()
                
                Text("© \(Calendar.current.component(.year, from: Date())) InterPay")
                    .font(.caption2)
                    .foregroundColor(.white.opacity(0.6))
                    .padding(.bottom, 16)
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
                // 3. Prepara la solicitud
                let urlString = "http://192.168.1.109:3001/api/auth/login" 
                guard let url = URL(string: urlString) else {
                    throw AuthError.unknown
                }
                
                // 4. Prepara el cuerpo (Body) de la solicitud
                let loginData = LoginRequest(email: email, password: password)
                let bodyData = try JSONEncoder().encode(loginData)
                
                // 5. Configura la petición (Request)
                var request = URLRequest(url: url)
                request.httpMethod = "POST"
                request.httpBody = bodyData
                request.setValue("application/json", forHTTPHeaderField: "Content-Type")

                // 6. Ejecuta la llamada de red
                let (data, response) = try await URLSession.shared.data(for: request)
                
                // 7. Valida la respuesta del servidor
                guard let httpResponse = response as? HTTPURLResponse else {
                    throw AuthError.unknown
                }
                
                if httpResponse.statusCode == 401 {
                    throw AuthError.invalidCredentials
                } else if httpResponse.statusCode != 200 {
                    throw AuthError.serverError
                }
                
                // --- 8. Decodifica la NUEVA respuesta exitosa ---
                let loginResponse = try JSONDecoder().decode(LoginResponse.self, from: data)
                
                // --- 9. ¡ÉXITO! Guardar solo el OBJETO USUARIO ---
                // (Ya no guardamos el token)
                let userData = try JSONEncoder().encode(loginResponse.user)
                try KeychainHelper.save(
                    data: userData,
                    service: "com.tu-app.interpay.user", // <-- Servicio para el USUARIO
                    account: email // Usamos el email como "llave"
                )
                
                // 10. Actualiza la UI en el Hilo Principal
                await MainActor.run {
                    withAnimation(.spring(response: 0.6, dampingFraction: 0.9)) {
                        isLoading = false
                        isAuthenticated = true
                    }
                }
                
            } catch let authError as AuthError {
                // Maneja errores de login específicos
                await MainActor.run {
                    isLoading = false
                    showError = true
                    switch authError {
                    case .invalidCredentials:
                        errorMessage = "Usuario o contraseña incorrectos."
                    default:
                        errorMessage = "Error del servidor. Intenta de nuevo."
                    }
                }
            } catch {
                // Maneja errores de red genéricos (ej. sin internet)
                await MainActor.run {
                    isLoading = false
                    showError = true
                    errorMessage = "Error de red. Revisa tu conexión."
                    print("Error de login: \(error.localizedDescription)") // Para depurar
                }
            }
        }
    }
    
    // MARK: - Biométricos
    private var canUseBiometrics: Bool {
        let context = LAContext()
        var error: NSError?
        return context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error)
    }
    
    private var biometricLabel: String {
        let context = LAContext()
        var error: NSError?
        _ = context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error)
        switch context.biometryType {
        case .faceID: return "Face ID"
        case .touchID: return "Touch ID"
        default: return "Biometría"
        }
    }
    
    private var biometricIconName: String {
        let context = LAContext()
        var error: NSError?
        _ = context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error)
        switch context.biometryType {
        case .faceID: return "faceid"
        case .touchID: return "touchid"
        default: return "lock.circle"
        }
    }
    
    private func authenticateWithBiometrics() {
        let context = LAContext()
        let reason = "Autentícate para acceder a InterPay."
        context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) { success, _ in
            DispatchQueue.main.async {
                if success {
                    withAnimation(.spring(response: 0.6, dampingFraction: 0.9)) {
                        isAuthenticated = true
                    }
                }
            }
        }
    }
    
    // MARK: - Componentes UI
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
            // ondas verdes suaves
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
