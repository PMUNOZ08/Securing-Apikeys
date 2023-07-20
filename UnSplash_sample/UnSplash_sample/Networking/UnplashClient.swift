//
//  UnSplash_sample.swift
//  UnSplash_sample
//
//  Created by Pedro on 30/4/23.
//  Copyright © 2023 Apple. All rights reserved.
//

import Foundation

enum UnSplashEndpoints: String {
    case generalPhotos = "/photos"
    case techPhotos = "/collections/4887749/photos"
}

class UnplashClient: NSObject  {

    private let host = "https://api.unsplash.com"
    private let hashPubKey = "xYGlcA+pIzAH9M7nNK5YelX5qcAryQ+tbkKmBL+o4X0="
    
    ///Toggle SSL Piinin mode
    ///true -> User hash of public key for SSL pinning
    ///false -> Use certificate for SSL pinning
    private let usePubKeyForSSLPinning = true
    
    private let pinnedCertificates = {
        let url = Bundle.main.url(forResource: "api.unsplash.com", withExtension: "cer")!
        let data = try! Data(contentsOf: url)
        return Set([data])
    }()

    private let downloader: any HTTPDataDownloader
    private let apikeyMAnager: ApiKeyManager
    private var page: Int = 1
    init(downloader: any HTTPDataDownloader = URLSession.shared, apikeyManager: ApiKeyManager = ApiKeyManager()) {
        self.downloader = downloader
        self.apikeyMAnager = apikeyManager
    }
    
    func fechtPhotos(page: Int = 1) async throws -> [UnplashPhoto] {
        self.page = page
        guard var urlRequest = urlRequest() else { return [] }
        if let apiKeyUnplash = try? await apikeyMAnager.key(for: .unplash) {
            urlRequest.setValue("Client-ID \(apiKeyUnplash)", forHTTPHeaderField: "Authorization")
            
            let data = try await downloader.httpData(for: urlRequest, delegate: self)
            do {
                return try JSONDecoder().decode([UnplashPhoto].self, from: data)
            } catch {
                debugPrint(error.localizedDescription)
                throw error
            }
        } else {
            throw ApiKeyError.errorFetchingAPIKey
        }
    }
    
    private func urlRequest() -> URLRequest? {
        guard var url = URL.init(string: host) else { return  nil }
        url.append(path: UnSplashEndpoints.techPhotos.rawValue)
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

extension UnplashClient: URLSessionTaskDelegate, @unchecked Sendable {

    func urlSession(_ session: URLSession, task: URLSessionTask, didReceive challenge: URLAuthenticationChallenge) async -> (URLSession.AuthChallengeDisposition, URLCredential?) {
#if DEBUG
        return (.useCredential, URLCredential(trust: challenge.protectionSpace.serverTrust!))
#else
        if let trust = challenge.protectionSpace.serverTrust,
           SecTrustGetCertificateCount(trust) > 0 {
            if let certificates = SecTrustCopyCertificateChain(trust) as? [SecCertificate] {
                if usePubKeyForSSLPinning {
                    let pubKeys = certificates.map({SecCertificateCopyKey($0)})
                    let serverPublicKeysData = pubKeys.map({SecKeyCopyExternalRepresentation($0!, nil )})
                    let serverHashKeys = serverPublicKeysData.map{ ($0 as? Data)?.hashPublicKeyInfoFromCertificate()}
                    if serverHashKeys.contains([hashPubKey]) {
                        return (.useCredential, URLCredential(trust: challenge.protectionSpace.serverTrust!))
                    }
                } else {
                    let serverCertificatesData = Set(
                        certificates.map { SecCertificateCopyData($0) as Data }
                    )
                    if pinnedCertificates.intersection(serverCertificatesData).count > 0 {
                        return (.useCredential, URLCredential(trust: challenge.protectionSpace.serverTrust!))
                    }
                }
            }
        }
        debugPrint("SSL pinning failed")
        return (.cancelAuthenticationChallenge, nil)
#endif
    }
}
