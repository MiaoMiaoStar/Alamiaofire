//
//  SessionError.swift
//  Alamiaofire
//
//  Created by 热心市民小龚 on 2023/3/31.
//

import Foundation


public enum ResultCode: Int {
    /** 成功 */
    case SUCCESS = 2000
    /** 失败 */
    case ERROR = -1
    
    case EXCEPTION = -2
}


public typealias ReusltHandle<T> = (_ result: T) -> Void

public enum SendResult<T: Decodable> {
    case success(T)
    case failure(String)
}

struct ServerResponse<T: Codable>: Codable {
    let code: Int
    let msg: String
    let data: T?
}

struct EncryptResponse: Codable {
    let code: Int
    let msg: String
    let encrypt: Int?
    
    var isEncrypt: Bool { encrypt != 0 }
}


struct DecryptResponse: Codable {
    let code: Int
    let msg: String
    let encrypt: Int?
    let data: String?
    
    var isEncrypt: Bool { encrypt != 0 }
}


struct HandyResponse {
    let code: Int
    let msg: String
    let data: String?
}



struct NilServerResponse: Codable {
}




public enum SessionError: Swift.Error  {
    
    
    /// messages returned by the  App server.
    public struct APIErrorDetail {
        
        public let code: ResultCode
        
        public let msg: String
        
    }
    
    /// The associated value `APIErrorDetail` contains error details.
    case APIError(detail: APIErrorDetail)

    case dataMissingError(Any.Type)
    
    case dataParsingFailed(Any.Type, Data, Error)
    
    case requestEcrptyFailed(Any)
    
    /// An error not defined in the  response occurred.
    case untypedError(error: Error)
    
    case responseFailed(detail: String)
    
    case networkError
}


#if DEBUG
extension SessionError: LocalizedError {
    public var localizedDescription: String {
        switch self {
        case .APIError(let detail):
            return detail.msg
        case .dataMissingError:
            return "数据缺失"
        case .dataParsingFailed:
            return "数据解析出错"
        case .requestEcrptyFailed:
            return "参数加密错误"
        case .untypedError:
            return "未知错误"
        case .responseFailed(let detail):
            return detail
        case .networkError:
            return "网络错误"
        }
    }
}

#else

extension SessionError: LocalizedError {
    public var localizedDescription: String {
        switch self {
        case .APIError(let detail):
            return detail.msg
        case .dataMissingError:
            return "数据缺失"
        case .dataParsingFailed:
            return "数据解析出错"
        case .requestEcrptyFailed:
            return "参数加密错误"
        case .untypedError:
            return "未知错误"
        case .responseFailed(let detail):
            return detail
        case .networkError:
            return "网络错误"
        }
    }
}
#endif
