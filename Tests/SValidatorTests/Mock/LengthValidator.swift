//
//  LengthValidator.swift
//  SValidator
//
//  Created by Sam Rayatnia on 13.02.25.
//

@testable import SValidator

public struct LengthValidator: Validator {
    public init() {
        min = 0
        max = 0
    }
    
    private let min: Int
    private let max: Int

    public init(min: Int, max: Int) {
        self.min = min
        self.max = max
    }

    public func validate(_ value: String) throws {
        if value.count < min || value.count > max {
            throw MockValidationError.invalidLength
        }
    }
}
