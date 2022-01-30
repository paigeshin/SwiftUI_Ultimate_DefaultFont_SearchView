//
//  SearchNavigationView.swift
//  FontSearchScreen
//
//  Created by paige on 2022/01/31.
//

import SwiftUI

struct SearchNavigationView: UIViewControllerRepresentable {
    
    var view: AnyView
    
    // Ease Of Use...
    var largeTitle: Bool
    var title: String
    var placeholder: String
    
    // onSearch and OnCancel Closures...
    var onSearch: (String) -> Void
    var onSearchCancel: () -> Void
    var onSearchDismiss: () -> Void
    
    // require clousre on call...
    init(view: AnyView,
         placeholder: String = "Search",
         largeTitle: Bool = true,
         title: String,
         onSearch: @escaping(String) -> Void,
         onSearchCancel: @escaping() -> Void,
         onSearchDismiss: @escaping() -> Void) {
        self.view = view
        self.placeholder = placeholder
        self.largeTitle = largeTitle
        self.title = title
        self.onSearch = onSearch
        self.onSearchCancel = onSearchCancel
        self.onSearchDismiss = onSearchDismiss
    }
    
    // Integrating UIKit Navigation Controller with SwiftUI View...
    func makeUIViewController(context: Context) -> UINavigationController {
        // requires SwiftUI View...
        let childView: UIHostingController = UIHostingController(rootView: view)
        let controller: UINavigationController = UINavigationController(rootViewController: childView)
        
        // Nav Bar Data...
        controller.navigationBar.topItem?.title = title
        controller.navigationBar.prefersLargeTitles = largeTitle
        
        // search bar...
        let searchController: UISearchController = UISearchController()
        searchController.searchBar.placeholder = placeholder
        
        // setting delegate...
        searchController.searchBar.delegate = context.coordinator
        
        // setting Search Bar In NavBar...
        // disabling hide on scroll...
        // disabling dim bg...
        searchController.obscuresBackgroundDuringPresentation = false
        
        controller.navigationBar.topItem?.hidesSearchBarWhenScrolling = false
        controller.navigationBar.topItem?.searchController = searchController
        
        return controller
    }
    
    
    func updateUIViewController(_ uiViewController: UINavigationController, context: Context) {
        
        // Updaring Real Time..
        uiViewController.navigationBar.topItem?.title = title
        uiViewController.navigationBar.topItem?.searchController?.searchBar.placeholder = placeholder
        uiViewController.navigationBar.prefersLargeTitles = largeTitle
        uiViewController.navigationBar.topItem?.rightBarButtonItem = UIBarButtonItem(title: "Cancel", style: .done, target: context.coordinator, action: #selector(context.coordinator.dismiss(_:)))
        
    }
    
    func makeCoordinator() -> Coordinator {
        return SearchNavigationView.Coordinator(parent: self)
    }
    
    
    // search bar delegate...
    class Coordinator: NSObject, UISearchBarDelegate {
        
        var parent: SearchNavigationView
        
        init(parent: SearchNavigationView) {
            self.parent = parent
        }
        
        func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
            // when text changes...
            self.parent.onSearch(searchText)
        }
        
        func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
            // when cancel button is clicked...
            self.parent.onSearchCancel()
        }
        
        @objc
        func dismiss(_ sender: Any) {
            // when dismiss button is clicked...
            self.parent.onSearchDismiss()
        }
        
    }
    
    
}
