//
//  ContentView.swift
//  FontSearchScreen
//
//  Created by paige on 2022/01/31.
//

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
