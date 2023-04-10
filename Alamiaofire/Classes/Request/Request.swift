//
//  Request.swift
//  Alamiaofire
//
//  Created by 热心市民小龚 on 2023/3/31.
//

import Foundation


public protocol ResponseDataParser: AnyObject {
    
    func parse<R: Request>(request: R, data: Data) throws -> R.Response
}

/// Parameter types for `Request` objects.
public typealias Parameters = [String: Any?]

public protocol Request {
    
    associatedtype Response: Codable
    
    var baseURL: URL { get }
    
    var path: String { get }
    
    var parameters: Parameters? { get }
    
    var dataParser: ResponseDataParser { get }
    
}

public var baseURL = URL(string: "http://m.huida.vip")!

let defaultJSONParser = JSONDecoder()

public extension Request {
    
    var baseURL: URL {
        return Alamiaofire.baseURL
    }
    
    var parameters: Parameters? {
        return nil
    }
    
    var dataParser: ResponseDataParser {
        return JSONParse(defaultJSONParser)
    }
}


public struct GeneralRequest<D>: Request where D: Codable {
    
    public typealias Response = D
    public var path: String
    public var parameters: Parameters?
    
    public init(path: String, parameters: Parameters?) {
        self.path = path
        self.parameters = parameters
    }
    
}
