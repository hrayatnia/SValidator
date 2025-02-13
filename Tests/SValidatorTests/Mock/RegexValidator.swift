//
//  ValidationError.swift
//  SValidator
//
//  Created by Sam Rayatnia on 13.02.25.
//


import Foundation
@testable import SValidator

public enum ValidationError: Error {
    case invalidLength
    case invalidPattern
}

public struct RegexValidator: Validator {
    private let pattern: String

    public init(pattern: String) {
        self.pattern = pattern
    }
    
    public init() {
        pattern = ""
    }

    public func validate(_ value: String) throws {
        let regex = try NSRegularExpression(pattern: pattern)
        let range = NSRange(location: 0, length: value.count)
        if regex.firstMatch(in: value, options: [], range: range) == nil {
            throw ValidationError.invalidPattern
        }
    }
}
