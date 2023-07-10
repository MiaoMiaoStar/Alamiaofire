//
//  Service.swift
//  Alamiaofire
//
//  Created by 热心市民小龚 on 2023/4/25.
//

import Foundation
import HandyJSON
import Alamofire


struct HandyNilResponse: HandyJSON {
}

public enum HandySendResult<T> {
    case success(T)
    case failure(String)
}


public class AlamoService {
    
    public static let shared = AlamoService()
}

struct HandyServerResponse<T: HandyJSON> {
    let code: Int
    let msg: String
    let data: T?
}

struct HandyServerList<T: HandyJSON> {
    let code: Int
    let msg: String
    let data: [T?]?
}

extension AlamoService {
    
    @discardableResult
    func send(
        path: String,
        parameters: Parameters? = nil,
        completionHandler completion: @escaping ReusltHandle<Swift.Result<HandyResponse, SessionError>>
    ) -> DataRequest {

        return AlamoSession.shared.sendEncryptOrNot(path: path, parameters: parameters) { response in
#if DEBUG
                debugPrint(response)
#endif
                guard response.error == nil, let data = response.data else {
                    completion(.failure(.networkError))
                    return
                }
                do {
                    let handyResponse = try AlamoSession.shared.parseAndDecrypt(data: data)
                    completion(.success(handyResponse))
                } catch let error {
    #if DEBUG
                    debugPrint(error)
    #endif
                    completion(.failure(.dataParsingFailed(HandyResponse.self, data, error)))
                }
        }
    }
    
    
    @discardableResult
    func send<T>(
        path: String,
        type: T.Type,
        parameters: Parameters? = nil,
        completionHandler completion: @escaping ReusltHandle<Swift.Result<HandyServerResponse<T>, SessionError>>
    ) -> DataRequest where T: HandyJSON {

        return send(path: path, parameters: parameters) { result in
            switch result {
            case .success( let handyResponse):
                let obj = JSONDeserializer<T>.deserializeFrom(json: handyResponse.data)
                let decryptResponse = HandyServerResponse(code: handyResponse.code, msg: handyResponse.msg, data: obj)
                completion(.success(decryptResponse))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    @discardableResult
    func sendList<T>(
        path: String,
        type: T.Type,
        parameters: Parameters? = nil,
        completionHandler completion: @escaping ReusltHandle<Swift.Result<HandyServerList<T>, SessionError>>
    ) -> DataRequest where T: HandyJSON {

        return send(path: path, parameters: parameters) { result in
            switch result {
            case .success( let handyResponse):
                let obj = JSONDeserializer<T>.deserializeModelArrayFrom(json: handyResponse.data)
                let decryptResponse = HandyServerList(code: handyResponse.code, msg: handyResponse.msg, data: obj)
                completion(.success(decryptResponse))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}

extension AlamoService {
    
    // 只需要 状态码 和 描述
    @discardableResult
    public func request(path: String, params: [String: Any?]? = nil, onResult: @escaping (ResultCode, String) -> Void) -> DataRequest {
        return sendData(path: path, params: params) { (result: HandySendResult<HandyServerResponse<HandyNilResponse>>)  in
            switch result {
            case .success(let res):
                let code = ResultCode(rawValue: res.code) ?? .ERROR
                switch code {
                case .SUCCESS:
                    onResult(.SUCCESS, "")
                default:
                    self.handleResult(code: code, message: res.msg)
                    onResult(code, res.msg)
                }
            case .failure(let message):
                onResult(.EXCEPTION, message)
            }
        }
    }
    @discardableResult
    public func request<T: HandyJSON>(path: String, params: [String: Any?]? = nil, onSuccess: @escaping (T)->Void, onFailure: @escaping (ResultCode, String) -> Void) -> DataRequest {
        
        return sendData(path: path, params: params) { (result: HandySendResult<HandyServerResponse<T>>) in
            switch result {
                case .success(let bean):
                    let code = ResultCode(rawValue: bean.code) ?? .ERROR
                    switch code {
                        case .SUCCESS:
                            if bean.data != nil {
                                onSuccess(bean.data!)
                            } else {
                                onFailure(.EXCEPTION, "data为nil")
                            }
                        default:
                            self.handleResult(code: code, message: bean.msg)
                            onFailure(code, bean.msg)
                    }
                case .failure(let message):
                    onFailure(.EXCEPTION, message)
            }
        }
    }
    
    @discardableResult
    public func requestList<T: HandyJSON>(path: String, params: [String: Any?]? = nil, onSuccess: @escaping ([T])->Void, onFailure: @escaping (ResultCode, String) -> Void) -> DataRequest {
        
        return sendDataList(path: path, params: params) { (result: HandySendResult<HandyServerList<T>>) in
            switch result {
                case .success(let bean):
                    let code = ResultCode(rawValue: bean.code) ?? .ERROR
                    switch code {
                        case .SUCCESS:
                        if let dataList = bean.data {
                            onSuccess(dataList.compactMap{ $0 })
                            } else {
                                onFailure(.EXCEPTION, "data为nil")
                            }
                        default:
                            self.handleResult(code: code, message: bean.msg)
                            onFailure(code, bean.msg)
                    }
                case .failure(let message):
                    onFailure(.EXCEPTION, message)
            }
        }
    }
    
    @discardableResult
    private func sendData<T: HandyJSON>(path: String, params: [String: Any?]?, onResult: @escaping (HandySendResult<HandyServerResponse<T>>) -> Void) -> DataRequest {

        return send(path: path, type: T.self, parameters: params) { result in
            switch result {
            case .success( let value):
                onResult(.success(value))
            case .failure(let error):
                onResult(.failure(error.localizedDescription))
            }
        }
    }
    
    @discardableResult
    private func sendDataList<T: HandyJSON>(path: String, params: [String: Any?]?, onResult: @escaping (HandySendResult<HandyServerList<T>>) -> Void) -> DataRequest {

        return sendList(path: path, type: T.self, parameters: params) { result in
            switch result {
            case .success( let value):
                onResult(.success(value))
            case .failure(let error):
                onResult(.failure(error.localizedDescription))
            }
        }
    }
    
    private func handleResult(code: ResultCode, message: String) {
        AlamoSession.shared.handleResult(code: code, message: message)
    }
}
