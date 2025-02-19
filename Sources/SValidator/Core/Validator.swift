//
//  ValidatorBuilder.swift
//  SValidator
//
//  Created by Sam Rayatnia on 13.02.25.
//

/// A protocol that defines a general interface for input validation.
///
/// The `Validator` protocol is intended for any type that performs validation on an input of type `Input`.
/// It provides the core method `validate` to check if the value meets specific criteria, throwing an error if validation fails.
///
/// Conforming types must implement the `validate(_:)` method, which is used to check if the provided input satisfies the validator's conditions.
///
/// ### Example Usage:
/// ```swift
/// struct EmailValidator: Validator {
///     func validate(_ value: String) throws {
///         if !value.contains("@") {
///             throw ValidationError.invalidEmail
///         }
///     }
/// }
/// ```
///
/// - Parameter Input: The type of input to be validated.
public protocol Validator<Input>: Sendable, Equatable {
    associatedtype Input
    
    /// Validates a given value.
    ///
    /// This method performs the actual validation logic for a given input value. If the value is invalid,
    /// it throws an error.
    ///
    /// - Parameter value: The value to validate.
    /// - Throws: An error if validation fails.
    /// 
    /// @Metadata {
    ///   @Documentation(filename: "validate")
    /// }
    func validate(_ value: Input) throws
    
    /// A default initializer for the `Validator` type.
    init()
    
}

/// Extension providing helper methods for `Validator` types.
///
/// This extension adds convenience methods to `Validator` conformance that simplifies the validation process
/// and provides result-based validation handling.
public extension Validator {
    
    /// Checks whether the value is valid by attempting validation and returning a boolean result.
    ///
    /// This method attempts to validate the value and returns `true` if the validation succeeds and `false` if it fails.
    ///
    /// - Parameter value: The value to validate.
    /// - Returns: `true` if validation succeeds, `false` if validation fails.
    ///
    /// ### Example Usage:
    /// ```swift
    /// let emailValidator = EmailValidator()
    /// let isValid = emailValidator.isValid("test@example.com")
    /// ```
    ///
    /// @Metadata {
    ///   @Documentation(filename: "isValid")
    /// }
    func isValid(_ value: Input) -> Bool {
        (try? validate(value)) != nil
    }
    
    /// Validates the input value and returns a `Result` indicating success or failure.
    ///
    /// This method provides a `Result` type that contains the validated value on success and an error on failure.
    ///
    /// - Parameter value: The value to validate.
    /// - Returns: A `Result` containing the validated value on success, or an error on failure.
    ///
    /// ### Example Usage:
    /// ```swift
    /// let emailValidator = EmailValidator()
    /// let result = emailValidator.validateWithResult("test@example.com")
    /// ```
    /// @Metadata {
    ///   @Documentation(filename: "validateWithResult")
    /// }
    func validateWithResult(_ value: Input) -> Result<Input, Error> {
        Result { try validate(value); return value }
    }
    
}
