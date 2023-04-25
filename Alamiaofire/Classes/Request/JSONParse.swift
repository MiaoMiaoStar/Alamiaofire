//
//  JSONParse.swift
//  Alamiaofire
//
//  Created by 热心市民小龚 on 2023/3/31.
//

import Foundation



let parser = JSONDecoder()

extension AlamoSession {
    
    func parseAndDecrypt<T>(data: Data, type: T.Type) throws -> ServerResponse<T> {
        let response = try parser.decode(EncryptResponse.self, from: data)
        if response.isEncrypt {
            let decryptResponse = try parser.decode(DecryptResponse.self, from: data)
            if let decryptResponseData = decryptResponse.data {
                let decryptData = try decrpty(resonseBase64String: decryptResponseData)
                let  resposeDataModel = try parser.decode(T.self, from: decryptData)
                let result = ServerResponse(code: response.code, msg: response.msg, data: resposeDataModel)
                return result
            } else {
                return ServerResponse(code: response.code, msg: response.msg, data: nil)
            }
        } else {
            let  result = try parser.decode(ServerResponse<T>.self, from: data)
            return result
        }
    }
    
    func parse<T: Codable>(data: Data, type: T.Type) throws -> T {
        let response = try parser.decode(T.self, from: data)
        return response
    }
}


extension AlamoSession {
    func parseAndDecrypt(data: Data) throws -> HandyResponse {
        let response = try parser.decode(EncryptResponse.self, from: data)
        if response.isEncrypt {
            let decryptResponse = try parser.decode(DecryptResponse.self, from: data)
            if let decryptResponseData = decryptResponse.data {
                let decryptData = try AlamoSession.shared.decrpty(resonseBase64String: decryptResponseData)
                let jsonString = String(data: decryptData, encoding: .utf8)
                let result = HandyResponse(code: response.code, msg: response.msg, data: jsonString)
                return result
            } else {
                return HandyResponse(code: response.code, msg: response.msg, data: nil)
            }
        } else {
            let jsonString = String(data: data, encoding: .utf8)
            let result = HandyResponse(code: response.code, msg: response.msg, data: jsonString)
            return result
        }
    }
}
