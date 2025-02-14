//
//  ValidatorBuilder.swift
//  SValidator
//
//  Created by Sam Rayatnia on 13.02.25.
//


/// A property wrapper that applies validation logic to a property using a set of `Validator` objects.
///
/// The ``Validate`` property wrapper ensures that any assigned value passes a series of validation rules.
/// If validation fails, the value does not update, and an error is logged.
///
/// This property wrapper leverages the ``ValidatorBuilder`` result builder to collect multiple validators
/// and apply them consistently.
///
/// - Parameters Input: The type of input being validated, which must conform to ``Sendable``.
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
@available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, visionOS 1.0, *)
public struct Validate<Input: Sendable> {
    private var storedValue: Input
    private let validators: [any Validator<Input>]
    private let option: ValidationOption

    /// Initializes a new `@Validate` property wrapper with a default value and a set of validators.
    ///
    /// The provided validators are collected using the `ValidatorBuilder` and applied based on selected option, the options is ``ValidationOption/onGet`` by default.
    /// If the initial value does not pass validation, an error message is printed.
    ///
    /// - Parameters:
    ///   - wrappedValue: The initial value to validate.
    ///   - builder: A ``ValidatorBuilder`` closure that defines the set of validators.
    ///   - option: an optional value to pick the validation strategy on data state ``ValidationOption``
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
    ///
    // TODO: - add following params
    // - all, any, linking validators
    // - logger
    public init(wrappedValue: Input, @ValidatorBuilder<Input> _ builder: @escaping (() -> [any Validator<Input>]), option: ValidationOption = .onSet) {
        self.storedValue = wrappedValue
        self.option = option
        self.validators = builder()
        applyValidation(for: .onSet, value: storedValue)
    }

    /// The wrapped property value.
    ///
    /// Each time a new value is assigned, it undergoes validation. If validation fails, the assignment is ignored.
    public var wrappedValue: Input {
            get {
                applyValidation(for: .onGet, value: storedValue)
                return storedValue
            }
            set {
                applyValidation(for: .onSet, value: newValue)
                storedValue = newValue
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
    
    private func applyValidation(for event: ValidationOption, value: Input) {
           guard option == .always || option == event else { return }
           do {
               try validate(value)
           } catch {
               print("Validation failed: \(error)")
           }
       }
}

