//
//  Request.swift
//  Alamiaofire
//
//  Created by 热心市民小龚 on 2023/3/31.
//

import Foundation



/// Parameter types for `Request` objects.
public typealias Parameters = [String: Any?]

public struct Request {

    public var url: String
    public var parameters: Parameters?
    
    public init(url: String, parameters: Parameters?) {
        self.url = url
        self.parameters = parameters
    }
    
}
