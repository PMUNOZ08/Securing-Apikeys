//
//  HTTPDataDownloader.swift
//  UnSplash_sample
//
//  Created by Pedro on 30/4/23.
//  Copyright © 2023 Apple. All rights reserved.
//

import Foundation

let validStatus = 200...299

protocol HTTPDataDownloader {
    
    func httpData(for: URLRequest, delegate: URLSessionTaskDelegate?) async throws -> Data
    
}

extension URLSession: HTTPDataDownloader {
    
    func httpData(for urlRequest: URLRequest, delegate: URLSessionTaskDelegate?) async throws -> Data {
        guard let (data, response) = try await self.data(for: urlRequest, delegate: delegate) as? (Data, HTTPURLResponse),
              validStatus.contains(response.statusCode) else {
            throw UnplashError.networkError
        }
        return data
    }
}


enum UnplashError: Error {
    case missingData
    case networkError
    case unexpectedError(error: Error)
}
