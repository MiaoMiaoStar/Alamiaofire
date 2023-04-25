//
//  Session.swift
//  Alamiaofire
//
//  Created by 热心市民小龚 on 2023/3/31.
//

import Foundation
import Alamofire
import Combine


public typealias OnResult = (_ code: ResultCode, _ message: String) -> Void
public typealias OnCompletion = (_ success: Bool, _ message: String) -> Void
public typealias Completion = (_ code: ResultCode, _ message: String) -> Void
public typealias Success<T> = (_ data: T) -> Void
public typealias Failure = (_ code: ResultCode, _ message: String) -> Void
public typealias Hanlder<T> = (_ result: T) -> Void
public typealias ResponseHanlder = (AFDataResponse<Data?>) -> Void


public enum ReuestEncrypt{
    case all
    case some([String])
    case none
}

public class  SessionConfiguration {
    
    public var baseUrl: String
    public var headers: [String : String]
    public var parameters: [String : Any] // 默认参数
    public var reqEncrypt: ReuestEncrypt = .all

    init(baseUrl: String, headers: [String : String], parameters: [String : Any]) {
        self.baseUrl = baseUrl
        self.headers = headers
        self.parameters = parameters
    }
    
    static let `default` = SessionConfiguration(baseUrl: "http://m.huida.vip", headers: ["Accept-Version" : "1.0"], parameters: [:])
    
    // 返回结果是否加密了
    var isResponseEncrypt: Bool { Float(headers["Accept-Version"] ?? "") == 1.0 }
}


public class AlamoSession {
    
    public static let shared = AlamoSession()
    
    public var config = SessionConfiguration.default
    
    let aes_encrypt: AES256 = .init(key: PARAM_REP_KEY.data(using: .utf8)!, iv: PARAM_APP_IV.data(using: .utf8)!)
    let aes_decrypt: AES256 = .init(key: REP_KEY.data(using: .utf8)!, iv: APP_IV.data(using: .utf8)!)
}



extension AlamoSession {
    
    // 最终的请求
    @discardableResult
    private func send(
        req: Request,
        parameters: Parameters,
        completionHandler completion: @escaping ResponseHanlder
    ) -> DataRequest {
        let url = URL(string: req.url)!
        let requestParameters = parameters.compactMapValues(EncodeValue.init)
        let headers = config.headers.map{ HTTPHeader(name: $0.key, value: $0.value)}
        return AF.request(
            url,
            method: .post,
            parameters: requestParameters,
            encoder: JSONParameterEncoder.default,
            headers: HTTPHeaders(headers)
        )
        .response(completionHandler: completion)
    }
    
    // 未加密参数
    @discardableResult
    private func send(
        _ request: Request,
        completionHandler completion: @escaping ResponseHanlder
    ) -> DataRequest {
        let params = request.parameters ?? [:]
        let pending = config.parameters
        let completeParams = params.merging(pending) {$1}
        return send(req:request, parameters: completeParams, completionHandler: completion)
    }
    
    
    // 参数加密
    @discardableResult
    private func sendVerify(
        _ request: Request,
        completionHandler completion: @escaping ResponseHanlder
    ) -> DataRequest {
        let params = request.parameters ?? [:]
        let pending = config.parameters
        let completeParams = params.merging(pending) {$1}
        let nonNilParams = completeParams.compactMapValues{$0}
    
        if let encrptyParams = try? encrypt(nonNilParams) {
            return send(req:request, parameters: encrptyParams, completionHandler: completion)
        } else {
            debugPrint("参数加密失败")
            return send(req:request, parameters: nonNilParams, completionHandler: completion)
        }
    }
    
    
    
    
    // 请求 判断是否需要加密
    @discardableResult
    func sendEncryptOrNot(
        path: String,
        parameters: Parameters? = nil,
        completionHandler completion: @escaping ResponseHanlder
    ) -> DataRequest {
        let request = Request(url: config.baseUrl + path, parameters: parameters)
        switch config.reqEncrypt {
        case .none:
            return send(request, completionHandler: completion)
        case .some(let apiNeedsEncrpty):
            if apiNeedsEncrpty.contains(path) {
                return sendVerify(request, completionHandler: completion)
            } else {
                return send(request, completionHandler: completion)
            }
        case .all:
            return sendVerify(request, completionHandler: completion)
        }
    }
    
    //
    @discardableResult
    private func send<T>(
        path: String,
        type: T.Type,
        parameters: Parameters? = nil,
        completionHandler completion: @escaping ReusltHandle<Swift.Result<ServerResponse<T>, SessionError>>
    ) -> DataRequest where T: Codable {
        
        return sendEncryptOrNot(path: path, parameters: parameters) { response in
#if DEBUG
                debugPrint(response)
#endif
                guard response.error == nil, let data = response.data else {
                    completion(.failure(.networkError))
                    return
                }
                if data.count == 0 { // 剔除data为0
                    completion(.failure(.dataMissingError(T.self)))
                    return
                }
            
                do {
                    let decryptResponse = try self.parseAndDecrypt(data: data, type: T.self)
                    completion(.success(decryptResponse))
                } catch let error {
    #if DEBUG
                    debugPrint(error)
    #endif
                    completion(.failure(.dataParsingFailed(T.self, data, error)))
                }
        }
    }
}


extension AlamoSession {
    
    // RxSwift
 
}


extension AlamoSession {
    
    // 只需要 状态码 和 描述
    @discardableResult
    public func request(path: String, params: [String: Any?]? = nil, onResult: @escaping (ResultCode, String) -> Void) -> DataRequest {
        return sendData(path: path, params: params) { (result: SendResult<ServerResponse<NilServerResponse>>)  in
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
    public func request<T: Codable>(path: String, params: [String: Any?]? = nil, onSuccess: @escaping (T)->Void, onFailure: @escaping (ResultCode, String) -> Void) -> DataRequest {
        
        return sendData(path: path, params: params) { (result: SendResult<ServerResponse<T>>) in
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
    private func sendData<T: Codable>(path: String, params: [String: Any?]?, onResult: @escaping (SendResult<ServerResponse<T>>) -> Void) -> DataRequest {

        return send(path: path, type: T.self, parameters: params) { result in
            switch result {
            case .success( let value):
                onResult(.success(value))
            case .failure(let error):
                onResult(.failure(error.localizedDescription))
            }
        }
    }
    
    func handleResult(code: ResultCode, message: String) {
        switch code {
            default:
                break
        }
    }
}




//return AF.upload(
//    multipartFormData: { mutipartData in
//        requestParameters.forEach { (key, value) in
//            let dataString = value.asString()
//            if let data = dataString.data(using: .utf8) {
//                mutipartData.append(data, withName: key)
//            }
//        }
//    },
//    to: url,
//    headers: HTTPHeaders(headers)
//)
