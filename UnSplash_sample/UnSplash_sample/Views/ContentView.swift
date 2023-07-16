//
//  ContentView.swift
//  UnSplash_sample
//
//  Created by Pedro on 22/6/23.
//

import SwiftUI

struct ContentView: View {

    @StateObject private var dataModel = DataModel()
    @State private var selectedPhoto: UnplashPhoto?
    #if os(tvOS)
    private let spacing = 20.0
    #else
    private let spacing = 3.0
    #endif
    var body: some View {
        GeometryReader { geometryProxy in
            ScrollView {
                LazyVGrid(columns: [.init(.adaptive(minimum: 150, maximum: .infinity), spacing: spacing)], spacing: spacing) {
                    ForEach(dataModel.photos) { photo in
                        PhotoView(unplashPhoto: photo)
                            .onTapGesture {
                                selectedPhoto = photo
                            }
                            .onAppear{
                                dataModel.loadMorePhotos(photo)
                            }
                    }
                }
            }
            #if os(macOS)
            .sheet(item: $selectedPhoto) { photo in
                PhotoDetailView(unplashPhoto: photo)
                    .frame(minWidth: 750, maxWidth: geometryProxy.size.width, minHeight: 450, maxHeight: geometryProxy.size.height)
            }
            #else
            .fullScreenCover(item: $selectedPhoto) { photo in
                PhotoDetailView(unplashPhoto: photo)
            }
            #endif
        }

    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().preferredColorScheme(.dark)
    }
}
