//
//  Encrypt.swift
//  Alamiaofire
//
//  Created by 热心市民小龚 on 2023/4/24.
//

import Foundation
import CommonCrypto

let REP_KEY = "dc642fb319e8969c"
let APP_IV = "00b2dd1120b120ba"
let PARAM_REP_KEY = "70f454cb6e96819a"
let PARAM_APP_IV = "6ba6c583615c11a6"

extension AlamoSession {
    
    
    func encrypt(_ parameters: [String: Any]) throws -> [String: Any] {
        let data = try JSONSerialization.data(withJSONObject: parameters)
        let encrptyData = try aes_encrypt.encrrypt(data)
        return ["params": encrptyData.base64EncodedString(options: Data.Base64EncodingOptions(rawValue: UInt(0)))]
    }
}


extension AlamoSession {
    func decrpty(responseBase64String: String) throws -> Data {
//        if let encrptyData = NSData.init(base64EncodedString: resonseBase64String) {
//            let decrptyData = try aes_decrypt.decrrypt(encrptyData)
//            return decrptyData
//        } else {
//            throw SessionError.responseFailed(detail: "数据解密错误")
//        }
        if let encrptyData = Data(base64Encoded: responseBase64String) {
            let decrptyData = try aes_decrypt.decrrypt(encrptyData)
            return decrptyData
        } else {
            throw SessionError.responseFailed(detail: "数据解密错误")
        }
    }

}

struct AES256 {

    private var key: Data
    private var iv: Data

    public init(key: Data, iv: Data) {
        self.key = key
        self.iv = iv
    }
    
    func encrrypt(_ data: Data) throws -> Data {
//        if let encrptyData = NSData(data: data).aes256Encrypt(withKey: key, iv: iv) {
//            return encrptyData
//        } else {
//            throw SessionError.requestEcrptyFailed(data)
//        }
        return try encryptAES256(data, key: key, iv: iv)
    }

    func decrrypt(_ data: Data) throws -> Data {
//        if let decrptyData = data.aes256DecryptWithkey(key, iv: iv) {
//            return decrptyData
//        } else {
//            throw SessionError.responseFailed(detail: "数据解密错误")
//        }
        return try decryptAES256(data, key: key, iv: iv)
    }
    
    // 加密函数
    func encryptAES256(_ data: Data, key: Data, iv: Data) throws -> Data {
        let keyData = key as NSData
        let ivData = iv as NSData
        let dataLength = data.count
        let dataBytes = (data as NSData).bytes
        let keyBytes = keyData.bytes
        let ivBytes = ivData.bytes
        let cryptLength = size_t(dataLength + kCCBlockSizeAES128)
        var cryptBytes = [UInt8](repeating: 0, count: cryptLength)
        var numBytesEncrypted: size_t = 0
        let cryptStatus = CCCrypt(CCOperation(kCCEncrypt),
                                  CCAlgorithm(kCCAlgorithmAES),
                                  CCOptions(kCCOptionPKCS7Padding),
                                  keyBytes, keyData.length,
                                  ivBytes,
                                  dataBytes, dataLength,
                                  &cryptBytes, cryptLength,
                                  &numBytesEncrypted)
        guard cryptStatus == kCCSuccess else {
            throw NSError(domain: "com.example.AES256", code: Int(cryptStatus), userInfo: nil)
        }
        return Data(bytes: cryptBytes, count: numBytesEncrypted)
    }

    // 解密函数
    func decryptAES256(_ encryptedData: Data, key: Data, iv: Data) throws -> Data {
        let keyData = key as NSData
        let ivData = iv as NSData
        let dataLength = encryptedData.count
        let dataBytes = (encryptedData as NSData).bytes
        let keyBytes = keyData.bytes
        let ivBytes = ivData.bytes
        let cryptLength = size_t(dataLength + kCCBlockSizeAES128)
        var cryptBytes = [UInt8](repeating: 0, count: cryptLength)
        var numBytesDecrypted: size_t = 0
        let cryptStatus = CCCrypt(CCOperation(kCCDecrypt),
                                  CCAlgorithm(kCCAlgorithmAES),
                                  CCOptions(kCCOptionPKCS7Padding),
                                  keyBytes, keyData.length,
                                  ivBytes,
                                  dataBytes, dataLength,
                                  &cryptBytes, cryptLength,
                                  &numBytesDecrypted)
        guard cryptStatus == kCCSuccess else {
            throw NSError(domain: "com.example.AES256", code: Int(cryptStatus), userInfo: nil)
        }
        return Data(bytes: cryptBytes, count: numBytesDecrypted)
    }

    
}










