import SwiftUI

struct ContentView: View {
    @State private var selectedTab: Tab = .home
    // Si tu clase es 'sendAmount' (minúscula), usa:
    // @StateObject private var sendAmount = sendAmount()
    @StateObject private var sendAmount = SendAmount()
    
    enum Tab {
        case home
        case cobrar
        case pagar
        case mapa
    }
    
    var body: some View {
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
        }
        .environmentObject(sendAmount)
    }
}
