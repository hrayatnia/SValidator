//
//  ValidatorBuilder.swift
//  SValidator
//
//  Created by Sam Rayatnia on 13.02.25.
//


/// A property wrapper that applies validation logic to a property using a set of `Validator` objects.
///
/// The ``Validate`` property wrapper ensures that any assigned value passes a series of validation rules.
/// If validation fails, the value is not updated, and an error is logged. This wrapper leverages the
/// ``ValidatorBuilder`` result builder to collect multiple validators and apply them consistently.
///
/// ### Parameters:
/// - `Input`: The type of input being validated, which must conform to ``Sendable``.
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
    private let options: [ValidationOption]

    /// Initializes a new `@Validate` property wrapper with a default value and a set of validators.
    ///
    /// The provided validators are collected using the ``ValidatorBuilder`` and applied based on the selected option.
    /// By default, the option is ``ValidationOption/onGet``. If the initial value does not pass validation,
    /// an error message is printed.
    ///
    /// - Parameters:
    ///   - wrappedValue: The initial value to validate.
    ///   - builder: A closure that defines the set of validators using `ValidatorBuilder`.
    ///   - options: An optional array of `ValidationOption` to define when validation should occur (e.g., `.onSet`).
    ///
    /// ### Example:
    /// ```swift
    /// @Validate(wrappedValue: "default", {
    ///     LengthValidator(min: 3, max: 10)
    /// })
    /// var name: String
    /// ```
    ///
    /// - SeeAlso: ``ValidatorBuilder``, ``ValidationOption``
    public init(
        wrappedValue: Input,
        @ValidatorBuilder<Input> _ builder: @escaping () -> [any Validator<Input>],
        options: [ValidationOption] = [.retrieval(.onSet)]
    ) {
        self.storedValue = wrappedValue
        self.validators = builder()
        self.options = options

        applyValidation(for: .onSet, value: storedValue)
    }

    /// The wrapped property value.
    ///
    /// Every time a new value is assigned, it undergoes validation. If validation fails, the assignment is ignored.
    ///
    /// - SeeAlso: ``Validate/validate``, ``Validate/applyValidation``
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
    /// This allows you to check the validation state of the property, such as whether it is valid or not.
    ///
    /// ### Example:
    /// ```swift
    /// if $username.isValid {
    ///     print("Valid username")
    /// }
    /// ```
    ///
    /// - SeeAlso: ``Validate/isValid``, ``Validate/validationError``
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
    ///
    /// - SeeAlso: ``Validate/isValid``
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
    ///
    /// - SeeAlso: ``Validate/validationError``
    public var isValid: Bool {
        validationError == nil
    }

    /// Validates the provided value using all configured validators.
    ///
    /// The validation strategy determines how the validators interact (e.g., `all`, `any`, `some`). If any
    /// validator throws an error, validation stops, and the error is propagated.
    ///
    /// - Parameter newValue: The new value to validate.
    /// - Throws: A validation error if the value does not meet the criteria.
    ///
    /// ### Example:
    /// ```swift
    /// try validate("test")  // Will throw an error if validation fails
    /// ```
    ///
    /// - SeeAlso: ``Validate/validateWithResult``, ``Validate/validationError``
    private func validate(_ newValue: Input) throws {
        let strategy = options.validationStrategy()
        
        switch strategy {
        case .all:
            for validator in validators {
                try validator.validate(newValue)
            }
        case .any:
            let isValid = validators.contains { validator in
                (try? validator.validate(newValue)) != nil
            }
            if !isValid {
                throw ValidationError.failedValidation
            }
        case .some(let count):
            let validCount = validators.reduce(0) { result, validator in
                result + ((try? validator.validate(newValue)) != nil ? 1 : 0)
            }
            if validCount < count {
                throw ValidationError.failedValidation
            }
        }
    }

    /// Validates the input and returns a `Result` indicating success or failure.
    ///
    /// - Parameter input: The value to validate.
    /// - Returns: `.success(input)` if validation passes, `.failure(error)` if it fails.
    ///
    /// ### Example:
    /// ```swift
    /// let result = validateWithResult("test")
    /// switch result {
    /// case .success:
    ///     print("Validation passed")
    /// case .failure(let error):
    ///     print("Validation failed with error: \(error)")
    /// }
    /// ```
    ///
    /// - SeeAlso: ``Validate/validate``
    private func validateWithResult(_ input: Input) -> Result<Input, Error> {
        do {
            try validate(input)
            return .success(input)
        } catch {
            return .failure(error)
        }
    }

    /// Applies validation to the given value based on the specified retrieval event.
    ///
    /// This method checks the validation options and applies the validation logic accordingly.
    ///
    /// - Parameter event: The event type (e.g., `.onGet`, `.onSet`) that triggers validation.
    /// - Parameter value: The value to validate.
    ///
    /// - SeeAlso: ``ValidationOption``
    private func applyValidation(for event: ValidationOption.Retrieval, value: Input) {
        guard options.allowsRetrieval(event) else { return }
        if options.shouldSkipValidation(for: value) { return }

        do {
            try validate(value)
        } catch {
            if options.shouldLogVerbose() {
                print("Validation failed: \(error)")
            }
        }
    }
}


/// Represents the validation error encountered when a value fails validation.
///
/// This enum helps identify the type of validation failure encountered during the validation process.
///
/// - `failedValidation`: Represents a generic validation failure.
/// - `customError`: Represents a custom error with an associated message.
public enum ValidationError: Error, Equatable {
    case failedValidation
}
