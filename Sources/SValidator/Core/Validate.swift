//
//  ValidatorBuilder.swift
//  SValidator
//
//  Created by Sam Rayatnia on 13.02.25.
//

/// A property wrapper that applies validation logic to a property using a set of `Validator` objects.
///
/// The `@Validate` property wrapper ensures that any assigned value passes a series of validation rules.
/// If validation fails, the value does not update, and an error is logged.
///
/// This property wrapper leverages the `ValidatorBuilder` result builder to collect multiple validators
/// and apply them consistently.
///
/// - Parameter Input: The type of input being validated, which must conform to `Sendable`.
///
/// ### Example Usage:
/// ```swift
/// struct User {
///     @Validate({
///         LengthValidator(min: 5, max: 10)
///         RegexValidator(pattern: "^[a-zA-Z]+$")
///     })
///     var username: String = "JohnDoe"
/// }
/// ```
@frozen
@propertyWrapper
@available(iOS 12.0, macOS 13.0, tvOS 12.0, watchOS 5.0, *)
public struct Validate<Input: Sendable> {
    private var storedValue: Input
    private let validators: [any Validator<Input>]

    /// Initializes a new `@Validate` property wrapper with a default value and a set of validators.
    ///
    /// The provided validators are collected using the `ValidatorBuilder` and applied when the value changes.
    /// If the initial value does not pass validation, an error message is printed.
    ///
    /// - Parameters:
    ///   - wrappedValue: The initial value to validate.
    ///   - builder: A `ValidatorBuilder` closure that defines the set of validators.
    ///
    /// ### Example:
    /// ```swift
    /// @Validate(wrappedValue: "default", {
    ///     LengthValidator(min: 3, max: 10)
    /// })
    /// var name: String
    /// ```
    /// @Metadata {
    ///   @Documentation(filename: "init")
    /// }
    public init(wrappedValue: Input, @ValidatorBuilder<Input> _ builder: @escaping (() -> [any Validator<Input>])) {
        self.storedValue = wrappedValue
        self.validators = builder()

        // Validate the initial value
        do {
            try validate(storedValue)
        } catch {
            print("Initial validation failed: \(error) storedValue: \(storedValue)")
        }
    }

    /// The wrapped property value.
    ///
    /// Each time a new value is assigned, it undergoes validation. If validation fails, the assignment is ignored.
    public var wrappedValue: Input {
        get { storedValue }
        set {
            do {
                try validate(newValue)
                storedValue = newValue
            } catch {
                print("Validation failed: \(error)")
            }
        }
    }

    /// Provides access to the `Validate` instance itself.
    ///
    /// Enables retrieval of validation state properties like `isValid` or `validationError`.
    ///
    /// ### Example:
    /// ```swift
    /// if $username.isValid {
    ///     print("Valid username")
    /// }
    /// ```
    public var projectedValue: Validate<Input> { self }
    
    /// Returns the first validation error encountered, or `nil` if the value is valid.
    ///
    /// - Returns: An `Error` if validation fails, otherwise `nil`.
    ///
    /// ### Example:
    /// ```swift
    /// if let error = $username.validationError {
    ///     print("Validation failed with error: \(error)")
    /// }
    /// ```
    public var validationError: Error? {
        if case .failure(let error) = validateWithResult(storedValue) {
            return error
        }
        return nil
    }

    /// Indicates whether the current value is valid.
    ///
    /// - Returns: `true` if the value is valid, otherwise `false`.
    ///
    /// ### Example:
    /// ```swift
    /// if $username.isValid {
    ///     print("Username is valid")
    /// }
    /// ```
    public var isValid: Bool {
        validationError == nil
    }
    
    /// Validates the provided value using all configured validators.
    ///
    /// If any validator throws an error, validation stops, and the error is propagated.
    ///
    /// - Parameter newValue: The new value to validate.
    /// - Throws: A validation error if the value does not meet the criteria.
    ///
    /// @Metadata {
    ///   @Documentation(filename: "validate")
    /// }
    private func validate(_ newValue: Input) throws {
        for validator in validators {
            try validator.validate(newValue)
        }
    }
    
    /// Validates the input and returns a `Result` indicating success or failure.
    ///
    /// - Parameter input: The value to validate.
    /// - Returns: `.success(input)` if validation passes, `.failure(error)` if it fails.
    ///
    /// @Metadata {
    ///   @Documentation(filename: "validateWithResult")
    /// }
    private func validateWithResult(_ input: Input) -> Result<Input, Error> {
        for validator in validators {
            let result: Result<Input, Error> = validator.validateWithResult(input)
            if case .failure(let error) = result {
                return .failure(error)
            }
        }
        return .success(input)
    }
}
