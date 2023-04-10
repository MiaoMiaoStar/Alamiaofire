//
//  JSONParse.swift
//  Alamiaofire
//
//  Created by 热心市民小龚 on 2023/3/31.
//

import Foundation


/// Represents a terminator pipeline with a JSON decoder to parse data.
public class JSONParse: ResponseDataParser {
    /// An underlying JSON parser of the pipeline.
    public let parser: JSONDecoder
    
    /// Initializes a `JSONParsePipeline` object.
    ///
    /// - Parameter parser: The JSON parser for input data.
    public init(_ parser: JSONDecoder) {
        self.parser = parser
    }
    
    /// Parses `data` that holds input values to a `Response` object.
    ///
    /// - Parameters:
    ///   - request: The original request.
    ///   - data: The `Data` object received from a `Session` object.
    /// - Returns: The `Response` object.
    /// - Throws: An error that occurs during the parsing process.
    public func parse<T: Request>(request: T, data: Data) throws -> T.Response {
        return try parser.decode(T.Response.self, from: data)
    }
}
