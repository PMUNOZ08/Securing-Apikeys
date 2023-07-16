//
//  File.swift
//  UnSplash_sample
//
//  Created by Pedro on 22/6/23.
//

import Foundation

class DataModel: ObservableObject {
    
    @Published var photos: [UnplashPhoto] = []
    let client: UnplashClient
    private var page = 1
    
    init(client: UnplashClient = UnplashClient()) {
        self.client = client
        Task {
            try? await self.fetchPhotos()
        }
    }

    @MainActor
    func fetchPhotos() async throws {
        self.photos = try await client.fechtPhotos()
    }
    
    func loadMorePhotos(_ photo: UnplashPhoto) {
        if let index = self.photos.firstIndex(where: {$0.id == photo.id}),
           index == photos.count - 2 {
            page += 1
            Task {
                let newPhotos = try await client.fechtPhotos(page: page)
                await MainActor.run {
                    self.photos.append(contentsOf: newPhotos)
                }
            }
        }
           
        
        
    }
}
