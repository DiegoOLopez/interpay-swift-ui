//
//  MapView.swift
//  interpay
//
//  Created by macbook on 08/11/25.
//

import SwiftUI
import MapKit
import Combine

struct Place: Identifiable {
    let id = UUID()
    let name: String
    let subtitle: String?
    let coordinate: CLLocationCoordinate2D
}

@MainActor
final class MapViewModel: ObservableObject {
    @Published var region: MKCoordinateRegion
    @Published var places: [Place] = []
    @Published var selectedCategory: Category = .all
    
    enum Category: String, CaseIterable, Identifiable {
        case all = "Todo"
        case restaurants = "Restaurantes"
        case cafes = "Cafés"
        case stores = "Tiendas"
        case banks = "Bancos"
        
        var id: String { rawValue }
        
        // Sugerencia de prefijo para el nombre ficticio
        var displayPrefix: String {
            switch self {
            case .all: return "Lugar"
            case .restaurants: return "Restaurante"
            case .cafes: return "Café"
            case .stores: return "Tienda"
            case .banks: return "Banco"
            }
        }
    }
    
    // Ubicación fija: Centro Histórico, Ciudad de México
    private let baseCoordinate = CLLocationCoordinate2D(latitude: 19.432608, longitude: -99.133209)
    
    init() {
        self.region = MKCoordinateRegion(
            center: baseCoordinate,
            span: MKCoordinateSpan(latitudeDelta: 0.06, longitudeDelta: 0.06)
        )
        // Generamos lugares iniciales
        generateMockPlaces()
    }
    
    func generateMockPlaces() {
        // Generamos 15 puntos alrededor del centro con offsets pequeños
        let count = 15
        let latDeltaRange: ClosedRange<Double> = -0.02...0.02
        let lonDeltaRange: ClosedRange<Double> = -0.02...0.02
        
        var newPlaces: [Place] = []
        for i in 1...count {
            let latOffset = Double.random(in: latDeltaRange)
            let lonOffset = Double.random(in: lonDeltaRange)
            let coord = CLLocationCoordinate2D(
                latitude: baseCoordinate.latitude + latOffset,
                longitude: baseCoordinate.longitude + lonOffset
            )
            
            // Nombre según categoría seleccionada (si es "Todo", alternamos)
            let prefix: String
            if selectedCategory == .all {
                let allPrefixes: [Category] = [.restaurants, .cafes, .stores, .banks]
                prefix = allPrefixes.randomElement()?.displayPrefix ?? "Lugar"
            } else {
                prefix = selectedCategory.displayPrefix
            }
            
            let place = Place(
                name: "\(prefix) \(i)",
                subtitle: "Zona Centro, CDMX",
                coordinate: coord
            )
            newPlaces.append(place)
        }
        self.places = newPlaces
    }
}

struct MapView: View {
    @StateObject private var vm = MapViewModel()
    @State private var mapSelection: MKMapItem?
    @State private var position: MapCameraPosition = .automatic
    
    var body: some View {
        VStack(spacing: 0) {
            controlBar
            
            Map(position: $position, selection: $mapSelection) {
                ForEach(vm.places) { place in
                    Annotation(place.name, coordinate: place.coordinate) {
                        ZStack {
                            Circle()
                                .fill(Color.blue)
                                .frame(width: 10, height: 10)
                            Circle()
                                .stroke(Color.white, lineWidth: 2)
                                .frame(width: 14, height: 14)
                        }
                        .accessibilityLabel(place.name)
                    }
                }
            }
            .mapControls {
                MapCompass()
                MapPitchToggle()
                MapScaleView()
            }
            .task {
                // Posicionamos el mapa en la región fija al cargar
                position = .region(vm.region)
            }
            .onChange(of: vm.selectedCategory) { _, _ in
                // Regeneramos lugares cuando cambia la categoría
                vm.generateMockPlaces()
            }
        }
        .navigationTitle("Mapa")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private var controlBar: some View {
        HStack(spacing: 8) {
            Picker("Categoría", selection: $vm.selectedCategory) {
                ForEach(MapViewModel.Category.allCases) { category in
                    Text(category.rawValue).tag(category)
                }
            }
            .pickerStyle(.segmented)
            
            Button {
                vm.generateMockPlaces()
            } label: {
                Image(systemName: "arrow.clockwise")
                    .padding(8)
                    .background(Color(.systemGray6))
                    .clipShape(RoundedRectangle(cornerRadius: 8))
            }
            .accessibilityLabel("Actualizar lugares")
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
        .background(.ultraThinMaterial)
    }
}

#Preview {
    NavigationStack {
        MapView()
    }
}
