//
//  Encrypt.swift
//  Alamiaofire
//
//  Created by 热心市民小龚 on 2023/4/24.
//

import Foundation
import CommonCrypto
import YYKit

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
    func decrpty(resonseBase64String: String) throws -> Data {
        if let encrptyData = NSData.init(base64EncodedString: resonseBase64String) {
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
        if let encrptyData = NSData(data: data).aes256Encrypt(withKey: key, iv: iv) {
            return encrptyData
        } else {
            throw SessionError.requestEcrptyFailed(data)
        }
    }
    
    func decrrypt(_ data: NSData) throws -> Data {
        if let decrptyData = data.aes256DecryptWithkey(key, iv: iv) {
            return decrptyData
        } else {
            throw SessionError.responseFailed(detail: "数据解密错误")
        }
    }
    
}

