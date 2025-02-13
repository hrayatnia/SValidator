//
//  ValidatorBuilder.swift
//  SValidator
//
//  Created by Sam Rayatnia on 13.02.25.
//


/// A structure used to build a collection of validators for a specific input type using a result builder.
///
/// This struct provides the functionality to build multiple `Validator` objects and return them as a list. It is
/// marked with `@frozen` to allow for future optimization by the Swift compiler and is available on iOS 12.0+,
/// macOS 13.0+, tvOS 12.0+, and watchOS 5.0+.
///
/// The `ValidatorBuilder` can be used with any type that conforms to the `Validator` protocol, allowing a flexible
/// way of combining validators in a declarative manner. It utilizes Swift's result builders to construct a list of
/// validators in a concise way.
///
/// - Parameter Input: The type of input to be validated.
///
/// ### Example Usage:
/// ```swift
/// let validators = ValidatorBuilder<String> {
///     EmailValidator()
///     LengthValidator(min: 5, max: 10)
/// }
/// ```
@frozen
@resultBuilder
@available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, visionOS 1.0, *)
public struct ValidatorBuilder<Input> {
    
    /// Builds and returns a single validator element.
    ///
    /// - Parameter element: A `Validator` object to be returned as is.
    /// - Returns: The same validator object that was passed as an argument.
    ///
    /// This method is used to build a single validator element.
    ///
    /// ### Example Usage:
    /// ```swift
    /// let emailValidator = ValidatorBuilder<String>.build(EmailValidator())
    /// ```
    /// @Metadata {
    ///   @Documentation(filename: "build")
    /// }
    static func build<V: Validator>(_ element: V) -> V {
        element
    }
    
    /// Builds and returns a collection of `Validator` elements.
    ///
    /// - Parameter components: A list of validator components that conform to the `Validator` protocol.
    /// - Returns: An array of `Validator` objects.
    ///
    /// This method is used with the result builder syntax to combine multiple validators into an array.
    ///
    /// ### Example Usage:
    /// ```swift
    /// let validators = ValidatorBuilder<String>.buildBlock(
    ///     EmailValidator(),
    ///     LengthValidator(min: 5, max: 10)
    /// )
    /// ```
    /// @Metadata {
    ///   @Documentation(filename: "buildBlock")
    /// }
    public static func buildBlock(_ components: (any Validator<Input>)...) -> [any Validator<Input>] {
        var results: [any Validator<Input>] = []
        for validator in components {
            results.append(validator)
        }
        return results
    }
}
