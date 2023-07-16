//
//  KeychainPasswordItem.swift
//  UnSplash_sample
//
//  Created by Pedro on 7/5/23.
//
// Inspired in:
// https://github.com/janlionly/KeychainPasswordItem

import Foundation
import CommonCrypto

class KeychainPasswordItem {
    // MARK: Types
    enum KeychainError: Error {
        case noPassword
        case unexpectedPasswordData
        case unexpectedItemData
        case unhandledError(status: OSStatus)
    }

    // MARK: Properties
    let service: String

    private(set) var account: String

    let accessGroup: String?

    let label: String?
    
    var key: SecKey?

    // MARK: Intialization
    init(service: String, account: String, accessGroup: String? = nil, label: String? = nil) {
        self.service = service
        self.account = account
        self.accessGroup = accessGroup
        self.label = label
    }

    // MARK: Keychain access
   func readPassword() throws -> String {
        // Parse the password string from the query result.
        let passwordData = try self.readPasswordData()
        guard let password = self.decryptApiKey(cipherTextData: passwordData)  else {
                throw KeychainError.unexpectedPasswordData
        }
        return password
    }
    
    func readPasswordData() throws -> Data {
        
        /*
         Build a query to find the item that matches the service, account and
         access group.
         */
        var query = KeychainPasswordItem.keychainQuery(withService: service, account: account, accessGroup: accessGroup, label: label)
        query[kSecMatchLimit as String] = kSecMatchLimitOne
        query[kSecReturnAttributes as String] = kCFBooleanTrue
        query[kSecReturnData as String] = kCFBooleanTrue

        // Try to fetch the existing keychain item that matches the query.
        var queryResult: AnyObject?
        let status = withUnsafeMutablePointer(to: &queryResult) {
            SecItemCopyMatching(query as CFDictionary, UnsafeMutablePointer($0))
        }

        // Check the return status and throw an error if appropriate.
        guard status != errSecItemNotFound else { throw KeychainError.noPassword }
        guard status == noErr else { throw KeychainError.unhandledError(status: status) }

        // Parse the password data from the query result.
        guard let existingItem = queryResult as? [String: AnyObject],
            let passwordData = existingItem[kSecValueData as String] as? Data
            else {
                throw KeychainError.unexpectedPasswordData
        }

        return passwordData
    }

    func savePassword(_ password: String) throws {
        // Encode the password into an Data object.
        if let encodedPassword = self.encryptAndSaveApiKey(password) {
            try self.savePassword(encodedPassword)
        }
    }
    
    
    func savePassword(_ encodedPassword: Data) throws {
        
        do {
            // Check for an existing item in the keychain.
            try _ = readPassword()

            // Update the existing item with the new password.
            var attributesToUpdate = [String: AnyObject]()
            attributesToUpdate[kSecValueData as String] = encodedPassword as AnyObject?

            let query = KeychainPasswordItem.keychainQuery(withService: service, account: account, accessGroup: accessGroup, label: label)
            let status = SecItemUpdate(query as CFDictionary, attributesToUpdate as CFDictionary)

            // Throw an error if an unexpected status was returned.
            guard status == noErr else {
                throw KeychainError.unhandledError(status: status)
            }
        } catch {
            /*
             No password was found in the keychain. Create a dictionary to save
             as a new keychain item.
             */
            var newItem = KeychainPasswordItem.keychainQuery(withService: service, account: account, accessGroup: accessGroup, label: label)
            newItem[kSecValueData as String] = encodedPassword as AnyObject?

            // Add a the new item to the keychain.
            let status = SecItemAdd(newItem as CFDictionary, nil)

            // Throw an error if an unexpected status was returned.
            guard status == noErr else {
                throw KeychainError.unhandledError(status: status)
            }
        }
    }

    func renameAccount(_ newAccountName: String) throws {
        // Try to update an existing item with the new account name.
        var attributesToUpdate = [String: AnyObject]()
        attributesToUpdate[kSecAttrAccount as String] = newAccountName as AnyObject?

        let query = KeychainPasswordItem.keychainQuery(withService: service, account: self.account, accessGroup: accessGroup, label: label)
        let status = SecItemUpdate(query as CFDictionary, attributesToUpdate as CFDictionary)

        // Throw an error if an unexpected status was returned.
        guard status == noErr || status == errSecItemNotFound else {
            throw KeychainError.unhandledError(status: status)
        }

        self.account = newAccountName
    }

    func deleteItem() throws {
        // Delete the existing item from the keychain.
        let query = KeychainPasswordItem.keychainQuery(withService: service, account: account, accessGroup: accessGroup, label: label)
        let status = SecItemDelete(query as CFDictionary)

        // Throw an error if an unexpected status was returned.
        guard status == noErr || status == errSecItemNotFound else {
            throw KeychainError.unhandledError(status: status)
        }
    }

    static func passwordItems(forService service: String, accessGroup: String? = nil) throws -> [KeychainPasswordItem] {
        // Build a query for all items that match the service and access group.
        var query = KeychainPasswordItem.keychainQuery(withService: service, accessGroup: accessGroup)
        query[kSecMatchLimit as String] = kSecMatchLimitAll
        query[kSecReturnAttributes as String] = kCFBooleanTrue
        query[kSecReturnData as String] = kCFBooleanFalse

        // Fetch matching items from the keychain.
        var queryResult: AnyObject?
        let status = withUnsafeMutablePointer(to: &queryResult) {
            SecItemCopyMatching(query as CFDictionary, UnsafeMutablePointer($0))
        }

        // If no items were found, return an empty array.
        guard status != errSecItemNotFound else {
            return []
        }

        // Throw an error if an unexpected status was returned.
        guard status == noErr else {
            throw KeychainError.unhandledError(status: status)
        }

        // Cast the query result to an array of dictionaries.
        guard let resultData = queryResult as? [[String: AnyObject]] else {
            throw KeychainError.unexpectedItemData
        }

        // Create a `KeychainPasswordItem` for each dictionary in the query result.
        var passwordItems = [KeychainPasswordItem]()
        for result in resultData {
            guard let account = result[kSecAttrAccount as String] as? String else {
                throw KeychainError.unexpectedItemData
            }

            let passwordItem = KeychainPasswordItem(service: service, account: account, accessGroup: accessGroup)
            passwordItems.append(passwordItem)
        }

        return passwordItems
    }

    // MARK: Convenience
    private static func keychainQuery(withService service: String, account: String? = nil, accessGroup: String? = nil, label: String? = nil) -> [String: AnyObject] {
        var query = [String: AnyObject]()
        query[kSecClass as String] = kSecClassGenericPassword
        query[kSecAttrService as String] = service as AnyObject?

        if let account = account {
            query[kSecAttrAccount as String] = account as AnyObject?
        }

        if let accessGroup = accessGroup {
            query[kSecAttrAccessGroup as String] = accessGroup as AnyObject?
        }

        if let label = label {
            query[kSecAttrLabel as String] = label as AnyObject?
        }

        return query
    }
    
    private func encryptAndSaveApiKey(_ apiKey: String) -> Data? {
        guard prepareKey() else {
            return nil
        }
        
        guard let publicKey = SecKeyCopyPublicKey(key!) else {
            debugPrint("Can't get public key")
            return nil
        }
        let algorithm: SecKeyAlgorithm = .eciesEncryptionCofactorVariableIVX963SHA256AESGCM
        guard SecKeyIsAlgorithmSupported(publicKey, .encrypt, algorithm) else {
            debugPrint("Algorith not supported")
            return nil
        }
        var error: Unmanaged<CFError>?
        let clearTextData = apiKey.data(using: .utf8)!
        let apiKeyEncripted =  SecKeyCreateEncryptedData(publicKey, algorithm,
                                                   clearTextData as CFData,
                                                   &error) as? Data
        if error != nil {
            debugPrint((error!.takeRetainedValue() as Error).localizedDescription)
        }
        return apiKeyEncripted
    }
    
    private func decryptApiKey(cipherTextData: Data) -> String? {
        guard prepareKey() else {
            return nil
        }
        
        let algorithm: SecKeyAlgorithm = .eciesEncryptionCofactorVariableIVX963SHA256AESGCM
        guard SecKeyIsAlgorithmSupported(self.key!, .decrypt, algorithm) else {
            debugPrint("Algorith not supported")
            return nil
        }
        
        var error: Unmanaged<CFError>?
        let clearTextData = SecKeyCreateDecryptedData(self.key!,
                                                      algorithm,
                                                      cipherTextData as CFData,
                                                      &error) as Data?
        
        guard clearTextData != nil else {
            debugPrint((error!.takeRetainedValue() as Error).localizedDescription)
            return nil
        }
        let clearText = String(decoding: clearTextData!, as: UTF8.self)
        return clearText
    }
    
    private func prepareKey() -> Bool {
        guard key == nil else {
            return true
        }
        key = KeychainPasswordItem.loadKey(name: service)
        guard key == nil else {
            return true
        }
        do {
            key = try KeychainPasswordItem.makeAndStoreKey(name: service)
            return true
        } catch let error {
            debugPrint(error.localizedDescription)
        }
        return false
    }
}


// MARK: - Secure Enclave

extension KeychainPasswordItem {
    
    static func getPwSecAccessControl() -> SecAccessControl {
        var access: SecAccessControl?
        var error: Unmanaged<CFError>?
        
        access = SecAccessControlCreateWithFlags(nil,  // Use the default allocator.
                                                 kSecAttrAccessibleWhenUnlockedThisDeviceOnly,
                                                 .applicationPassword,
                                                 &error)
        precondition(access != nil, "SecAccessControlCreateWithFlags failed")
        return access!
    }
    
    // MARK: Storing keys in the keychain
    static func makeAndStoreKey(name: String) throws -> SecKey {
        removeKey(name: name)
        
        let flags: SecAccessControlCreateFlags = .privateKeyUsage
        let access =
        SecAccessControlCreateWithFlags(kCFAllocatorDefault,
                                        kSecAttrAccessibleWhenUnlockedThisDeviceOnly,
                                        flags,
                                        nil)!
        let tag = name.data(using: .utf8)!
        let attributes: [String: Any] = [
            kSecAttrKeyType as String           : kSecAttrKeyTypeEC,
            kSecAttrKeySizeInBits as String     : 256,
            kSecAttrTokenID as String           : kSecAttrTokenIDSecureEnclave,
            kSecPrivateKeyAttrs as String : [
                kSecAttrIsPermanent as String       : true,
                kSecAttrApplicationTag as String    : tag,
                kSecAttrAccessControl as String     : access
            ] as [String : Any]
        ]
        
        var error: Unmanaged<CFError>?
        guard let privateKey = SecKeyCreateRandomKey(attributes as CFDictionary, &error) else {
            throw error!.takeRetainedValue() as Error
        }
        return privateKey
    }
    
    static func loadKey(name: String) -> SecKey? {
        let tag = name.data(using: .utf8)!
        let query: [String: Any] = [
            kSecClass as String                 : kSecClassKey,
            kSecAttrApplicationTag as String    : tag,
            kSecAttrKeyType as String           : kSecAttrKeyTypeEC,
            kSecReturnRef as String             : true
        ]
        
        var item: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &item)
        guard status == errSecSuccess else {
            return nil
        }
        return (item as! SecKey)
    }
    
    static func removeKey(name: String) {
        let tag = name.data(using: .utf8)!
        let query: [String: Any] = [
            kSecClass as String                 : kSecClassKey,
            kSecAttrApplicationTag as String    : tag
        ]
        SecItemDelete(query as CFDictionary)
    }
}
