//
//  ContentView.swift
//  testMapKit
//
//  Created by Zhenyi Yang on 7/27/22.
//
import SwiftUI
import Combine
import MapKit

struct ContentView: View {
    @StateObject private var mapSearch = MapSearch()
    
    var body: some View {
            Form {
                Section {
                    TextField("Address", text: $mapSearch.searchTerm)
                }
                Section {
                    ForEach(mapSearch.locationResults, id: \.self) { location in
                        if((location.title.numberOfOccurrencesOf(string: ",") <= 1) && (location.subtitle != "")  && (!location.subtitle.contains(",")) && (!location.subtitle.contains("Nearby"))){
                                NavigationLink(destination: Detail(locationResult: location)) {
                                VStack(alignment: .leading) {
                                    Text(location.title)
                                    Text(location.subtitle)
                                        .font(.system(.caption).bold())
                                }
                            }
                        }
                    }
                }
            }.navigationTitle(Text("Address search"))
    }
}

class DetailViewModel : ObservableObject {
    @Published var isLoading = true
    @Published private var coordinate : CLLocationCoordinate2D?
    @Published var region: MKCoordinateRegion = MKCoordinateRegion()
    
    var coordinateForMap : CLLocationCoordinate2D {
        coordinate ?? CLLocationCoordinate2D()
    }
    
    func reconcileLocation(location: MKLocalSearchCompletion) {
        let searchRequest = MKLocalSearch.Request(completion: location)
        let search = MKLocalSearch(request: searchRequest)
        search.start { (response, error) in
            if error == nil, let coordinate = response?.mapItems.first?.placemark.coordinate {
                self.coordinate = coordinate
                self.region = MKCoordinateRegion(center: coordinate, span: MKCoordinateSpan(latitudeDelta: 0.03, longitudeDelta: 0.03))
                self.isLoading = false
            }
        }
    }
    
    func clear() {
        isLoading = true
    }
}

struct Detail : View {
    var locationResult : MKLocalSearchCompletion
    @State private var loc_selected = false
    @State private var saved_alert = false
    @StateObject private var viewModel = DetailViewModel()
    @AppStorage("Locations") private var locations = "Fairfax,VA,USA|Shanghai,China"
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>

    struct Marker: Identifiable {
        let id = UUID()
        var location: MapMarker
    }
    
    var body: some View {
        Group {
            if viewModel.isLoading {
                Text("Loading...")
            } else {
                    VStack {
                        Map(coordinateRegion: $viewModel.region,
                            annotationItems: [Marker(location: MapMarker(coordinate: viewModel.coordinateForMap))]) { (marker) in
                            marker.location
                        }
                        Button(action: {
                            loc_selected = true
                            saved_alert = true
                        }) {
                            Text("Add Address")
                        }
                    }
            }
        }.alert("The location has been added", isPresented: $saved_alert){
            Button("OK", role: .cancel) {
                if loc_selected {
                    let marker = Marker(location: MapMarker(coordinate: viewModel.coordinateForMap))
                    print(marker)
                    let addr = locationResult.title + "," + locationResult.subtitle
                    let extract_addr = addr.split(separator: ",")
                        .map { $0.trimmingCharacters(in: .whitespaces) }
                        .suffix(3).joined(separator: ", ")
                    locations = locations + "|" + extract_addr
                }

                self.presentationMode.wrappedValue.dismiss()
            }
        }.onAppear {
            viewModel.reconcileLocation(location: locationResult)
        }
        .onDisappear {
        }
        .navigationTitle(Text(locationResult.title))
    }
}

extension String {
    func trimmingLeadingAndTrailingSpaces(using characterSet: CharacterSet = .whitespacesAndNewlines) -> String {
        return trimmingCharacters(in: characterSet)
    }
    func numberOfOccurrencesOf(string: String) -> Int {
        return self.components(separatedBy:string).count - 1
    }

}
