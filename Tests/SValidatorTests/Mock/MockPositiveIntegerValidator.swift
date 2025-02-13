//
//  MockPositiveIntegerValidator.swift
//  SValidator
//
//  Created by Sam Rayatnia on 13.02.25.
//


@testable import SValidator

struct MockPositiveIntegerValidator: Validator {
   
    func validate(_ value: Int) throws {
        guard value > 0 else {
            throw ValidationError.valueMustBeAPositiveInteger
        }
    }
    
    private enum ValidationError: Error {
        case valueMustBeAPositiveInteger
        
        var errorDescription: String? {
            switch self {
            case .valueMustBeAPositiveInteger:
                return "Value must be a positive integer"
            }
        }
    }
}

struct MockOddPositiveIntegerValidator: Validator {
    
    func validate(_ value: Int) throws {
        guard value.isMultiple(of: 2) == false else {
            throw ValidationError.valueMustBeAOddNumber
        }
    }
    
    private enum ValidationError: Error {
        case valueMustBeAOddNumber
    }
}
