//
//  Data+ hashPublicKeyInfoFromCertificate.swift
//  UnSplash_sample
//
//  Created by Pedro on 9/7/23.
//

import Foundation
import CommonCrypto

extension Data {
    
    private var rsa2048Asn1Header: [UInt8] {[
        0x30, 0x82, 0x01, 0x22, 0x30, 0x0d, 0x06, 0x09, 0x2a, 0x86, 0x48, 0x86,
        0xf7, 0x0d, 0x01, 0x01, 0x01, 0x05, 0x00, 0x03, 0x82, 0x01, 0x0f, 0x00
        ]}


    public func hashPublicKeyInfoFromCertificate() -> String {
        var keyWithHeader = Data(rsa2048Asn1Header)
        keyWithHeader.append(self)
        var hash = [UInt8](repeating: 0, count: Int(CC_SHA256_DIGEST_LENGTH))
        
        keyWithHeader.withUnsafeBytes { buffer in
            _ = CC_SHA256(buffer.baseAddress!, CC_LONG(buffer.count), &hash)
        }
        return Data(hash).base64EncodedString()
    }
}
