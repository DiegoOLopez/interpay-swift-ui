//
//  ContentView.swift
//  interpay
//
//  Created by Diego Obed on 08/11/25.
//

import SwiftUI

struct ContentView: View {
    @State private var selectedTab: Tab = .cobrar
    
    enum Tab {
        case cobrar
        case pagar
    }
    
    var body: some View {
        TabView(selection: $selectedTab) {
            CobrarView()
                .tag(Tab.cobrar)
                .tabItem {
                    Label("Cobrar", systemImage: "arrow.down.circle")
                }
            
            PagarView()
                .tag(Tab.pagar)
                .tabItem {
                    Label("Pagar", systemImage: "arrow.up.circle")
                }
        }
    }
}

#Preview {
    ContentView()
}
