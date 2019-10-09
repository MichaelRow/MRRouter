//
//  RegexReplaceHandler.swift
//  URLRouter
//
//  Created by Michael Row on 2019/9/8.
//

import Foundation

public struct RegexReplaceHandler {
    
    public var replacement: String
    
    public private(set) var pattern: String
    
    private var regex: NSRegularExpression
    
    public init?(pattern: String, replacement: String) {
        guard let regex = try? NSRegularExpression(pattern: pattern) else { return nil }
        self.regex = regex
        self.pattern = pattern
        self.replacement = replacement
    }
    
    public func replace(_ input: URLConvertible) -> URLConvertible {
        let inputStr = input.urlStringValue
        return regex.stringByReplacingMatches(in: inputStr, range: NSMakeRange(0, inputStr.count), withTemplate: replacement)
    }
}
