# SwiftUI_Ultimate_SearchView

# Search Navigation View

```swift

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


```

# Font Selection View

```swift
import SwiftUI

struct ContentView: View {

    @Binding var filteredFonts: [String]
    private var data: [String: [String]] = [:]
    let alphabet: String = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"

    init(fonts: Binding<[String]>) {
        _filteredFonts = fonts
        UIFont.familyNames.forEach { fontName in
            for character in alphabet {
                if fontName == "Bodoni Ornaments" {
                    continue
                }
                if fontName.first == character {
                    if data.keys.contains(String(character)) {
                        data[String(character)]?.append(fontName)
                    } else {
                        data[String(character)] = [fontName]
                    }
                }
            }
        }
    }


    var body: some View {
        ScrollViewReader { proxy in
            ScrollView(showsIndicators: false) {

                if filteredFonts.count > 0 {
                    LazyVStack {
                        ForEach(filteredFonts.sorted(by: <), id: \.self) { font in
                            Text(font)
                                .font(.custom(font, size: 16))
                                .padding()
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                    }
                } else {
                    LazyVStack {
                        ForEach(data.sorted(by: { (lhs, rhs) -> Bool in
                            lhs.key < rhs.key
                        }), id: \.key) { categoryName, fontArray in
                            Section(
                                header: Text(categoryName)
                                    .font(.title)
                                    .fontWeight(.bold)
                                    .padding()
                                    .frame(maxWidth: .infinity, alignment: .leading)
                            ) {
                                ForEach(fontArray, id: \.self) { font in
                                    Text(font)
                                        .font(.custom(font, size: 16))
                                        .padding()
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                }
                            }
                        }
                    }
                }

            }
            .overlay(
                SectionIndexTitles(proxy: proxy, titles: data.keys.sorted())
                    .frame(maxWidth: .infinity, alignment: .trailing)
                    .font(.system(size: 12))
                    .padding()
            )
        }
    }



}

struct SectionIndexTitles: View {
    let proxy: ScrollViewProxy
    let titles: [String]
    @GestureState private var dragLocation: CGPoint = .zero

    var body: some View {
        VStack {
            ForEach(titles, id: \.self) { title in
                Text(title)
                    .background(dragObserver(title: title))
            }
        }
        .gesture(
            DragGesture(minimumDistance: 0, coordinateSpace: .global)
                .updating($dragLocation) { value, state, _ in
                    state = value.location
                }
        )
    }

    func dragObserver(title: String) -> some View {
        GeometryReader { geometry in
            dragObserver(geometry: geometry, title: title)
        }
    }

    func dragObserver(geometry: GeometryProxy, title: String) -> some View {
        if geometry.frame(in: .global).contains(dragLocation) {
            DispatchQueue.main.async {
                proxy.scrollTo(title, anchor: .center)
            }
        }
        return Rectangle().fill(Color.clear)
    }

}

```

# Main

```swift
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

```
