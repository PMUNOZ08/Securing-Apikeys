//
//  UnSplash_sample.swift
//  UnSplash_sample
//
//  Created by Pedro on 30/4/23.
//  Copyright © 2023 Apple. All rights reserved.
//

import Foundation

class UnplashClient: NSObject  {

    private let apikey_unsplash = "UNSPLASH ACCESS KEY"
    private let host = "https://api.unsplash.com"

    private let downloader: any HTTPDataDownloader
    private var page: Int = 1
    init(downloader: any HTTPDataDownloader = URLSession.shared) {
        self.downloader = downloader
    }
    
    func fechtPhotos(page: Int = 1) async throws -> [UnplashPhoto] {
        self.page = page
        guard var urlRequest = urlRequest() else { return [] }
        
        urlRequest.setValue("Client-ID \(apikey_unsplash)", forHTTPHeaderField: "Authorization")
        
        let data = try await downloader.httpData(for: urlRequest, delegate: nil)
        do {
            return try JSONDecoder().decode([UnplashPhoto].self, from: data)
        } catch {
            debugPrint(error.localizedDescription)
            throw error
        }
    }
    
    private func urlRequest() -> URLRequest? {
        guard var url = URL.init(string: host) else { return  nil }
        url.append(path: "photos")
        url.append(queryItems: self.queryParamas())
        return  URLRequest.init(url: url)
    }
    
    private func queryParamas() -> [URLQueryItem] {
        
        let queryItems = [URLQueryItem(name: "page", value: "\(page)"),
                          URLQueryItem(name: "per_page", value: "30"),
                          URLQueryItem(name: "utm_source", value: "Poster_Maker"),
                          URLQueryItem(name: "utm_medium", value: "referral"),
                          URLQueryItem(name: "utm_campaign", value: "api-credit")]
        return queryItems
    }
}
