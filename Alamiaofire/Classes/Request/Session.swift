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


public class AlamoSession {
    
    public static let shared = AlamoSession()
    
    private var appVersion: String { Bundle.main.infoDictionary?["CFBundleShortVersionString"] as! String}
    private var timestamp: String { return "\(Int64(Date().timeIntervalSince1970))" }
    private var package_name: String {  "net.huidapay.live"  }
    private var channel: String {  "iOS"  }
}

let parser = JSONDecoder()

extension AlamoSession {
    
    @discardableResult
    private func send<R>(
        _ request: R,
        completionHandler completion: @escaping ReusltHandle<Swift.Result<R.Response, SessionError>>
    ) -> DataRequest where R: Request {
        let params = request.parameters ?? [:]
        let pending = [
            "device_id" : "89C9EDD2-35EB-4CB2-A700-BA328A463804",
            "version" : "1.8.1",
            "package_name": package_name,
            "channel": channel
        ] as [String : Any?]
        let completeParams = params.merging(pending) {$1}
        let parameters = completeParams.compactMapValues(EncodeValue.init)
        let url = URL(string: request.baseURL.absoluteString + request.path)!
        

//        return AF.upload(
//            multipartFormData: { mutipartData in
//                parameters.forEach { (key, value) in
//                    let dataString = value.asString()
//                    if let data = dataString.data(using: .utf8) {
//                        mutipartData.append(data, withName: key)
//                    }
//                }
//            },
//            to: url
//        )
        
        
        return AF.request(
            url,
            method: .post,
            parameters: parameters,
            encoder: JSONParameterEncoder.default
        )
            .response { response in
                
#if DEBUG
                debugPrint(response)
#endif
                
                guard response.error == nil, let data = response.data else {
                    completion(.failure(.networkError))
                    return
                }
                
                if data.count == 0 { // 剔除data为0
                    completion(.failure(.dataMissingError(R.Response.self)))
                    return
                }
                let decodedData = data
                
                do {
                    let decoder = JSONDecoder()
                    decoder.dateDecodingStrategy = .millisecondsSince1970
                    let reponse = try parser.decode(R.Response.self, from: decodedData)
                    completion(.success(reponse))
                } catch let error {
    #if DEBUG
                    debugPrint(error)
    #endif
                    completion(.failure(.dataParsingFailed(R.Response.self, decodedData, error)))
                }
            }
    }
    
    
    @discardableResult
    private func send<T>(
        path: String,
        parameters: Parameters? = nil,
        type: T.Type,
        completionHandler completion: @escaping Hanlder<Swift.Result<T, SessionError>>
    ) -> DataRequest where T: Codable {
        let request = GeneralRequest<T>(path: path, parameters: parameters)
        return send(request, completionHandler: completion)
    }
}


extension AlamoSession {
    
    // combine
    private func send<T>(
        path: String,
        parameters: Parameters? = nil,
        type: T.Type
    ) -> AnyPublisher<T, SessionError> where T: Codable {
        var dataTask: DataRequest?
        
        let onSubscription: (Subscription) -> Void = { _ in dataTask?.resume() }
        let onCancel: () -> Void = { dataTask?.cancel() }
        
        return Future { promise in
            dataTask = self.send(path: path, parameters: parameters, type: ServerResponse<T>.self) { result in
                switch result {
                    case .success(let value):
                    if let data = value.data {
                        promise(.success(data))
                    } else {
                        promise(.failure(SessionError.dataMissingError(T.self)))
                    }
                    promise(.success(value.data!))
                    case .failure(let error):
                        promise(.failure(error))
                }
            }
        }
        .handleEvents(receiveSubscription: onSubscription, receiveCancel: onCancel)
        .eraseToAnyPublisher()
    }
    
    public func send<T>(
        path: String,
        parameters: Parameters? = nil
    ) -> AnyPublisher<T, SessionError> where T: Codable {
        return send(path: path, parameters: parameters, type: T.self)
    }
 
}


extension AlamoSession {
    
    public func request(path: String, arguments: [String: Any?]? = nil, onResult: @escaping (ResultCode, String) -> Void) {
        sendData(path: path, arguments: arguments) { (result: SendResult<NilServerResponse>) in
            switch result {
                case .success(let bean):
                    let code = ResultCode(rawValue: bean.code) ?? .ERROR
                    switch code {
                        case .SUCCESS:
                            onResult(.SUCCESS, "")
                        default:
                            self.handleResult(code: code, message: bean.msg)
                            onResult(code, bean.msg)
                    }
                case .failure(let message):
                    onResult(.EXCEPTION, message)
            }
        }
    }
    
    public func request<T: Codable>(path: String, arguments: [String: Any?]? = nil, onSuccess: @escaping (T)->Void, onFailure: @escaping (ResultCode, String) -> Void) {
        sendData(path: path, arguments: arguments) { (result: SendResult<ServerResponse<T>>) in
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
    
    private func sendData<T: Codable>(path: String, arguments: [String: Any?]?, onResult: @escaping (SendResult<T>) -> Void) {
        send(
            path: path,
            parameters: arguments,
            type: T.self,
            completionHandler: { result in
                switch result {
                    case .success( let value):
                        onResult(.success(value))
                    case .failure(let error):
                        onResult(.failure(error.localizedDescription))
                }
            }
        )
    }
    
    private func handleResult(code: ResultCode, message: String) {
        switch code {
            default:
                break
        }
    }
}


