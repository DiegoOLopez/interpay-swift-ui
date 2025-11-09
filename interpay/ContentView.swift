import SwiftUI

struct ContentView: View {
    @State private var selectedTab: Tab = .cobrar
    
    enum Tab {
        case cobrar
        case pagar
        case mapa
    }
    
    var body: some View {
        TabView(selection: $selectedTab) {
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
    }
}
