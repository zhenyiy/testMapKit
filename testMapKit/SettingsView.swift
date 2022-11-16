//
//  SettingsView.swift
//  testMapKit
//
//  Created by Zhenyi Yang on 7/27/22.
//

import SwiftUI

struct SettingsView: View {
    
    @AppStorage("Locations") private var locations = ""
    @State private var showingLastLocationAlert = false

    var body: some View {
        let locs = locations.components(separatedBy: "|")
        NavigationView {
            Form {
                Section {
                    List {
                        ForEach(locs, id: \.self){ele in
                            Text("\(ele)")
                        }
                        .onDelete(perform: removeItems)
                        .alert("At least one location should be selected", isPresented: $showingLastLocationAlert){
                        }
                    }
                    
                }
                Section {
                    let test = locations.numberOfOccurrencesOf(string: "|")
                    if(locations.numberOfOccurrencesOf(string: "|") < 2){
                        NavigationLink(destination: ContentView()
                        ){
                            Text("Add Location")
                        }
                    }
                }
            }

        }
    }
    func removeItems(at offsets: IndexSet){
        var locs = locations.components(separatedBy: "|")
        if locs.count > 1 {
            locs.remove(atOffsets: offsets)
            locations = locs.joined(separator: "|")
        } else {
            showingLastLocationAlert.toggle()
        }
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
