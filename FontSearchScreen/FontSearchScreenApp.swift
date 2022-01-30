//
//  FontSearchScreenApp.swift
//  FontSearchScreen
//
//  Created by paige on 2022/01/31.
//

import SwiftUI

@main
struct FontSearchScreenApp: App {
    
    @State var filteredFonts: [String] = []
    
    var body: some Scene {
        WindowGroup {
            SearchNavigationView(view: AnyView(ContentView(fonts: $filteredFonts)), placeholder: "Search", largeTitle: true, title: "Choose Font") { searchString in
                
                if searchString != "" {
                    self.filteredFonts = UIFont.familyNames.filter { $0.lowercased().contains(searchString.lowercased()) }
                } else {
                    self.filteredFonts = []
                }
                
            } onSearchCancel: {
                self.filteredFonts = []
            } onSearchDismiss: {
                
            }
            .ignoresSafeArea()

        }
    }
}
