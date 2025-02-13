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

    // Test case for validating positive odd integers.
    @Validate({
        MockPositiveIntegerValidator()
        MockOddPositiveIntegerValidator()
    }) var integer: Int = 1
    
    // Test case for valid range
    @Test(arguments: [1, 3, 5, 7, 9, 11, 13, 15, 17])
    mutating func testValidRange(input: Int) throws {
        integer = input
        #expect($integer.isValid)  // Check if the integer is valid
    }

    // Test case for invalid range: should trigger validation errors for even numbers.
    @Test(arguments: [2, 4, 6, 8, 10, 12, 14, 16])
    mutating func testInvalidRange(input: Int) throws {
        integer = input
        #expect(!$integer.isValid)  // Expect validation to fail
    }

    // Test case for validation error retrieval
    @Test
    mutating func testValidationError() throws {
        integer = 2  // Even number, fails OddPositiveIntegerValidator
        if let error = $integer.validationError {
            #expect(error != nil)  // Should throw an error due to the validation failure
        }
    }

    // Test case to verify if validation works on set
    @Test
    mutating func testValidationOnSet() throws {
        integer = 2  // This should fail validation on set because of the odd number check
        #expect(!$integer.isValid)  // Expect validation to fail on set
    }

    // Test case to verify validation works on get (validation logic should trigger when accessed)
    @Test
    mutating func testValidationOnGet() throws {
        // Set an invalid value
        integer = 2
        // Accessing it should trigger the validation on get
        _ = integer
        #expect(!$integer.isValid)
    }

    // Test case to verify validation always happens (on both get and set)
    @Test
    mutating func testValidationAlways() throws {
        @Validate(wrappedValue: 2, {
            MockPositiveIntegerValidator()
            MockOddPositiveIntegerValidator()
        }, option: .always) var alwaysValidatedInteger: Int

        // Set an invalid value (even number)
        alwaysValidatedInteger = 2
        #expect(!$alwaysValidatedInteger.isValid)  // Validation should fail immediately
        
        // Get the value, should still fail validation
        _ = alwaysValidatedInteger
        #expect(!$alwaysValidatedInteger.isValid)  // Validation should still fail on get
    }

    // Test case for valid value on get and set
    @Test
    mutating func testValidValueOnGetSet() throws {
        @Validate(wrappedValue: 15, {
            MockPositiveIntegerValidator()
            MockOddPositiveIntegerValidator()
        }, option: .always) var alwaysValidatedInteger: Int

        // Set a valid value (odd positive integer)
        alwaysValidatedInteger = 15
        #expect($alwaysValidatedInteger.isValid)  // Validation should pass
        
        // Get the value, should still be valid
        _ = alwaysValidatedInteger
        #expect($alwaysValidatedInteger.isValid)  // Validation should still pass
    }

    // Test case for checking the initialization with validation
    @Test
    mutating func testInitialValueValidation() throws {
        // Initialize with an invalid value (even number)
        @Validate(wrappedValue: 2, {
            MockPositiveIntegerValidator()
            MockOddPositiveIntegerValidator()
        }) var validatedInteger: Int
        
        // Check that validation failed upon initialization
        #expect(!$validatedInteger.isValid) // Expect validation to fail
    }

    // Test case for an empty or invalid input in a string scenario
    @Validate({
        LengthValidator(min: 3, max: 10)
        RegexValidator(pattern: "^[a-zA-Z]+$")
    }) var username: String = "John"

    @Test
    mutating func testValidUsername() throws {
        username = "ValidName"
        #expect($username.isValid) // Valid username should pass validation
    }

    @Test
    mutating func testInvalidUsername() throws {
        username = "No"  // Too short, validation should fail
        #expect(!$username.isValid)  // Validation should fail due to length

        username = "1234"  // Invalid pattern, validation should fail
        #expect(!$username.isValid)  // Validation should fail due to regex
    }

    @Test
    mutating func testUsernameValidationError() throws {
        username = "No"
        if let error = $username.validationError {
            #expect(error != nil)
        }
        
        username = "1234"
        if let error = $username.validationError {
            #expect(error != nil)
        }
    }
}

