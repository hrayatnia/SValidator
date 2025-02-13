//
//  ValidateTests.swift
//  SValidator
//
//  Created by Sam Rayatnia on 13.02.25.
//

import Testing
@testable import SValidator

@Suite("Validation Tests")
struct ValidateTests {
    
    @Validate({
        MockPositiveIntegerValidator()
        MockOddPositiveIntegerValidator()
    }) var integer: Int = 1
    
    
    @Test(arguments: [1,3,5,7,9,11,13,15,17])
    mutating func testValidRange(input: Int) throws {
        integer = input
        #expect($integer.isValid)
    }
    
    
    
}
