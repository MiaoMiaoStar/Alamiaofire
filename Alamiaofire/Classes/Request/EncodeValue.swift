//
//  EncodeValue.swift
//  Alamiaofire
//
//  Created by 热心市民小龚 on 2023/4/3.
//

import Foundation

internal struct EncodeValue: Encodable {
    init?(_ value: Any?) {
        if(value == nil) {
            return nil
        }
        self.value = value
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch(value) {
            case let i as Int:
                try container.encode(i)
            case let i as Int64:
                try container.encode(i)
            case let i as Int32:
                try container.encode(i)
            case let i as String:
                try container.encode(i)
            case let i as [String]:
                try container.encode(i)
            case let i as [Int]:
                try container.encode(i)
            case let i as [Int64]:
                try container.encode(i)
            case let i as [String]:
                try container.encode(i)
            case nil:
                try container.encodeNil()
            default:
                try container.encode(value as! Int)
        }
    }
    
    func asString() -> String {
        switch value {
            case let i as [Int]:
                return "\(i)".replacingOccurrences(of: " ", with: "")
            case let i as [Int64]:
                return "\(i)".replacingOccurrences(of: " ", with: "")
            case let i as [String]:
                return "\(i)".replacingOccurrences(of: "\", \"", with: "\",\"")
            case nil:
                return ""
            default:
                return "\(value!)"
        }
    }
    let value: Any?
}
