//
//  PhotoView.swift
//  UnSplash_sample
//
//  Created by Pedro on 22/6/23.
//

import SwiftUI

struct PhotoView: View {
    #if os(tvOS)
    @FocusState private var stateFocused: Bool
    #endif
    private var unplashPhoto: UnplashPhoto
    @State private var image: Image?
    init(unplashPhoto: UnplashPhoto) {
        self.unplashPhoto = unplashPhoto
    }
    var body: some View {
        VStack {
            image?.resizable()
                .aspectRatio(contentMode: .fill)
                .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
                .clipped()
                .aspectRatio(1, contentMode: .fit)
        }
        .onAppear{
            Task {
                guard image == nil, let url = URL.init(string: unplashPhoto.urls?.thumb ?? "") else {
                    return
                }
                let (data, _) = try await URLSession.shared.data(from: url)
                await MainActor.run{
                    #if os(macOS)
                    if let nsImage = NSImage.init(data: data) {
                        image = Image.init(nsImage: nsImage)
                    }
                    #else
                    if let uiImage = UIImage.init(data: data) {
                        image = Image.init(uiImage: uiImage)
                    }
                    #endif
                }
            }
        }
        #if os(tvOS)
        .focusable()
        .focused($stateFocused)
        .scaleEffect(stateFocused ? 1.1 : 1, anchor: .center)
        #endif
    }
}

struct PhotoView_Previews: PreviewProvider {
    static var previews: some View {
        PhotoView(unplashPhoto: dev.photos().first!)
    }
}
