//
//  UnplashPhoto.swift
//  UnSplash_sample
//
//  Created by Pedro on 22/6/23.
//

import Foundation


struct UnplashPhoto: Codable, Identifiable {

    let id, slug: String
    let createdAt, updatedAt, promotedAt: String?
    let width, height: Int?
    let color, blurHash, description, altDescription: String?
    let urls: Urls?
    let links: Links?
    let user: User?
    
    enum CodingKeys: String, CodingKey {
        case id, slug
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case promotedAt = "promoted_at"
        case width, height, color
        case blurHash = "blur_hash"
        case description
        case altDescription = "alt_description"
        case urls, links
        case user
    }
    
    
    func datePhoto() -> String {
        guard let createdAt = self.createdAt else {
            return ""
        }
        return Date.init(string: createdAt).asShortDateString()
    }
    
    func author() -> String {
        if let twitterUsername = self.user?.twitterUsername {
            return  "@\(twitterUsername)"
        }
        return  self.user?.name ?? ""
    }
}

// MARK: - Links
struct Links: Codable {
    let linksSelf, html, download, downloadLocation: String?
    
    enum CodingKeys: String, CodingKey {
        case linksSelf = "self"
        case html, download
        case downloadLocation = "download_location"
    }
}

// MARK: - Urls
struct Urls: Codable {
    let raw, full, regular, small: String?
    let thumb, smallS3: String?
    
    enum CodingKeys: String, CodingKey {
        case raw, full, regular, small, thumb
        case smallS3 = "small_s3"
    }
}

struct User: Codable {
    let id, name, twitterUsername: String?
    
    enum CodingKeys: String, CodingKey {
        case id, name
        case twitterUsername = "twitter_username"
    }
}

