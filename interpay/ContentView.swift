import SwiftUI

struct ContentView: View {
    @State private var isAuthenticated = false
    @State private var selectedTab: Tab = .home
    @StateObject private var sendAmount = SendAmount() // usa la clase existente en tu proyecto
    
    enum Tab {
        case home
        case cobrar
        case pagar
        case mapa
        case perfil
        case sales
    }
    
    var body: some View {
        Group {
            if isAuthenticated {
                TabView(selection: $selectedTab) {
                    HomeView()
                        .tag(Tab.home)
                        .tabItem { Label("Inicio", systemImage: "house.fill") }
                    
                    CobrarView()
                        .tag(Tab.cobrar)
                        .tabItem { Label("Cobrar", systemImage: "arrow.down.circle") }
                    
                    PagarView()
                        .tag(Tab.pagar)
                        .tabItem { Label("Pagar", systemImage: "arrow.up.circle") }
                    
                    NavigationStack {
                        MapView()
                    }
                    .tag(Tab.mapa)
                    .tabItem { Label("Mapa", systemImage: "map") }
                    
                    SalesView()
                        .tag(Tab.sales)
                        .tabItem { Label("Analytics", systemImage: "chart.bar.xaxis") }
                    
                    ProfileView(isAuthenticated: $isAuthenticated)
                        .tag(Tab.perfil)
                        .tabItem { Label("Perfil", systemImage: "person.crop.circle") }
                }
                .environmentObject(sendAmount)
            } else {
                LoginView(isAuthenticated: $isAuthenticated)
            }
        }
    }
}
