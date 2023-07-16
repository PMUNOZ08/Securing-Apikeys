//
//  Preview_Provider.swift
//  UnSplash_sample
//
//  Created by Pedro on 22/6/23.
//

import Foundation
import SwiftUI

extension PreviewProvider {
    
    static var dev: PhotosPreview {
        return PhotosPreview.instance
    }
    
}

class PhotosPreview {
    
    static let instance = PhotosPreview()
    private init() { }
    
    func photos() -> [UnplashPhoto] {
        guard let path = Bundle.main.path(forResource: "photos", ofType: "json"),
              let data = try? Data.init(contentsOf: URL.init(filePath: path)),
              let photos = try? JSONDecoder().decode([UnplashPhoto].self, from: data) else {
            return []
        }
        return photos
    }
}


