//
//  PhotoDetailView.swift
//  UnSplash_sample
//
//  Created by Pedro on 24/6/23.
//

import SwiftUI

struct PhotoDetailView: View {
    @Environment(\.dismiss) var dismiss
    @State private var maskEnabled = false
    private var unplashPhoto: UnplashPhoto
    
    init(unplashPhoto: UnplashPhoto) {
        self.unplashPhoto = unplashPhoto
    }
    var body: some View {
        GeometryReader { geometryProxy in
            ZStack() {
                loadPicture(geometryProxy)
                    .if(maskEnabled) { view in
                        view.mask { Image("LogoCircular")}
                            .background(.black)
                    }
                VStack{
                    actions
                    Spacer()
                    author
                }
            }
        }
    }
}

struct PhotoDetailView_Previews: PreviewProvider {
    static var previews: some View {
        PhotoDetailView(unplashPhoto: dev.photos().first!)
    }
}

extension PhotoDetailView {
    func loadPicture(_ geometryProxy: GeometryProxy) -> some View{
        AsyncImage(
            url: URL.init(string: unplashPhoto.urls?.full ?? ""),
            content: { image in
                image.resizable()
                    .aspectRatio(contentMode: .fill)
                    .ignoresSafeArea(.all)
            },
            placeholder: {
                ProgressView()
            }
        )
        .frame(width: geometryProxy.size.width, height:geometryProxy.size.height)
    }
    
    private var actions: some View {
        HStack {
            Button("Close") {
                dismiss()
            }
            .tint(.indigo)
            .buttonStyle(.borderedProminent)
            .clipShape(Capsule())
            Spacer()
            Button("Mask") {
                maskEnabled.toggle()
            }
            .tint(.indigo)
            .buttonStyle(.borderedProminent)
            .clipShape(Capsule())
        }
        #if os(macOS)
        .padding([.leading, .trailing, .top])
        #else
        .padding([.leading, .trailing])
        #endif
    }
    
    private var author: some View {
        HStack {
            Spacer()
            Text("\(self.unplashPhoto.author())\n\(self.unplashPhoto.datePhoto())")
                .font(.caption)
                .multilineTextAlignment(.center)
                .padding(4)
                .background(.black)
                .foregroundColor(.white)
                .cornerRadius(4)
                .offset(x: -10, y: -5)
        }
    }
}


extension View {
    @ViewBuilder func `if`<Content: View>(_ condition: Bool, transform: (Self) -> Content) -> some View {
        if condition {
            transform(self)
        } else {
            self
        }
    }
}

