//
//  ApiKeyManager.swift
//  UnSplash_sample
//
//  Created by Pedro on 24/6/23.
//

import Foundation
import CloudKit
import CommonCrypto

/**
 API Keys used by this app is fetched from CloudKit. This class manages fetching and saving it into Keychain
 */
struct ApiInfo {
    
    let ckRecordId: String
    let ckRecordType: String
    let ckField: String
    let keychainLabel: String
}

enum Api {
    case unplash
    
    func info() -> ApiInfo {
        let ckRecordId = "CLOUDKIT RECORD ID"
        let ckRecordType = "ApiKeys"
        
        switch self {
        case .unplash:
            return ApiInfo.init(ckRecordId: ckRecordId,
                                ckRecordType: ckRecordType,
                                ckField: "unplash",
                                keychainLabel: "api_key_openai")
        }
    }
}


public enum ApiKeyError: Error {
    case errorFetchingAPIKey
    case errorStoringAPIKey
}


class ApiKeyManager {
    
    // Keychain Configuration
    struct KeychainConfiguration {
        static let serviceName = "com.nscoder.UnSplash-sample"
        static let account = "unplash_sample"
        static let accessGroup: String? = nil
        static let label: String? = nil
    }

    static var instance = ApiKeyManager()
    
    // MARK - Async / Await
    @discardableResult
    func key(for api: Api) async throws -> String {
        let apiInfo = api.info()
        if let apikey = try? KeychainPasswordItem(service: KeychainConfiguration.serviceName,
                                               account: KeychainConfiguration.account,
                                                        label: apiInfo.keychainLabel).readPassword() {
            return apikey
        } else {
            do {
                let key = try await fetchApikey(for: apiInfo)
                return key
            } catch {
                throw error
            }
        }
    }
    
    /// Fetch a Record for id and concrete value
    func fetchApikey(for apiInfo: ApiInfo) async throws -> String {
        
        let apiKeyRecordID = CKRecord.ID(recordName: apiInfo.ckRecordId)
        let publicDatabase = CKContainer.default().database(with: .public)
        
        do {
            let record = try await publicDatabase.record(for: apiKeyRecordID)
            if let key = record[apiInfo.ckField] as? String {
                do {
                     try KeychainPasswordItem(service: KeychainConfiguration.serviceName,
                                                 account: KeychainConfiguration.account,
                                                 label: apiInfo.keychainLabel)
                        .savePassword(key)
                } catch {
                    debugPrint(ApiKeyError.errorStoringAPIKey)
                }
                return key
            } else {
                print("Error fetching API Key")
                throw ApiKeyError.errorFetchingAPIKey
            }
        } catch {
            print("Error fetching API Key")
            throw ApiKeyError.errorFetchingAPIKey
        }
    }
    
    /// Fetch all records for a record type
    func fetchApikeys(for apiInfo: ApiInfo) async throws -> String {
        
        let publicDatabase = CKContainer.default().database(with: .public)
        
        let query = CKQuery(recordType: apiInfo.ckRecordType,
                            predicate: NSPredicate(value: true))
        
        do {
            let (matchResults, cursor) = try await publicDatabase.records(matching: query)
            if cursor != nil {
                debugPrint("""
                           maximum number of results.  Results of a query exceed the maximum number of results.
                           Need to launch a new query with this cursor
                           """ )
            }
            if let result = matchResults.last {
                debugPrint("Id\(result.0)")
                switch result.1 {
                case .failure(let error):
                    debugPrint(error.localizedDescription)
                    throw ApiKeyError.errorStoringAPIKey
                case .success(let item):
                    debugPrint(item.value(forKey: apiInfo.ckField) ?? "No value for api key")
                    if let key = item.value(forKey: apiInfo.ckField) as? String {
                        do {
                            try KeychainPasswordItem(service: KeychainConfiguration.serviceName,
                                                     account: KeychainConfiguration.account,
                                                     label: apiInfo.keychainLabel)
                            .savePassword(key)
                            return key
                        } catch {
                            print("Error storing API API Key into Keychain: \(error.localizedDescription)")
                            throw ApiKeyError.errorStoringAPIKey
                        }
                    } else {
                        print("Error fetching API Key")
                        throw ApiKeyError.errorFetchingAPIKey
                    }
                }
            }
            throw ApiKeyError.errorStoringAPIKey
        } catch {
            print("Error fetching API Key")
            throw ApiKeyError.errorFetchingAPIKey
        }
    }
}
