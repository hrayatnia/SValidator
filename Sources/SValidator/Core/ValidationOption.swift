//
//  ValidationOption.swift
//  SValidator
//
//  Created by Sam Rayatnia on 13.02.25.
//


/// An enumeration that defines the different validation options for a given context.
///
/// The ``ValidationOption`` enum provides options for controlling when validation should be applied,
/// such as during value retrieval, assignment, or both. This enum is used to specify validation
/// strategies in contexts where values are being accessed or modified.
///
/// Validation options:
/// - `onGet`: Applies validation when the value is retrieved.
/// - `onSet`: Applies validation when the value is set.
/// - `always`: Applies validation both when the value is set and retrieved.
///
/// Additionally, the enum allows configuration of validation behavior with strategies, skipping
/// conditions, and logging:
/// - `strategy`: Defines how multiple validators should interact (e.g., all validators must pass,
///   at least one must pass, or a specific number must pass).
/// - `skipper`: Conditions that determine when validation should be skipped (e.g., on nil or default values).
/// - `logger`: Specifies the logging level for validation (e.g., verbose or silent).
///
/// Usage example:
/// ```swift
/// @Validate({...}, option: .onGet) var username: String = ""
/// @Validate({...}, option: .strategy(.any)) var email: String = ""
/// ```
@frozen
@available(macOS 13.0, iOS 16.0, tvOS 16.0, watchOS 9.0, visionOS 1.0, *)
public enum ValidationOption: Equatable {
    
    /// Validation strategy that defines how multiple validators interact.
    ///
    /// The `Strategy` enum determines how multiple validators should behave when applied to a value.
    /// - `all`: All validators must pass for validation to succeed.
    /// - `any`: At least one validator must pass for validation to succeed.
    /// - `some(Int)`: A specific number of validators must pass for validation to succeed.
    public enum Strategy: Equatable {
        case all  // All validators must pass
        case any  // At least one validator must pass
        case some(Int) // A specific number of validators must pass
        
        public static func == (lhs: Strategy, rhs: Strategy) -> Bool {
            switch (lhs, rhs) {
            case (.all, .all), (.any, .any):
                return true
            case let (.some(a), .some(b)):
                return a == b
            default:
                return false
            }
        }
    }

    /// Validation behavior when retrieving or setting a value.
    ///
    /// The `Retrieval` enum specifies when validation should be applied in relation to the value.
    /// - `onGet`: Applies validation when the value is retrieved.
    /// - `onSet`: Applies validation when the value is set.
    /// - `always`: Applies validation during both retrieval and setting.
    public enum Retrieval {
        case onGet
        case onSet
        case always
    }

    /// Conditions under which validation should be skipped.
    ///
    /// The ``Skipper`` enum provides conditions where validation will be bypassed.
    /// - ``Skipper/skipOnNil``: Skips validation if the value is `nil`.
    /// - ``Skipper/skipOnDefault``: Skips validation if the value is its default state (e.g., empty string).
    public enum Skipper {
        case skipOnNil
        case skipOnDefault
    }

    /// Controls logging behavior for validation.
    ///
    /// The `Logger` enum determines the level of logging for validation.
    /// - `verbose`: Logs detailed validation information.
    /// - `silent`: Suppresses validation logging.
    public enum Logger {
        case verbose
        case silent
    }

    /// The validation option can be one of several types:
    ///
    /// - `retrieval(Retrieval)`: Defines when validation should be applied (on retrieval, on setting, or always).
    /// - `skipper(Skipper)`: Defines conditions for skipping validation (e.g., `nil` or default values).
    /// - `logger(Logger)`: Defines the logging behavior for validation.
    /// - `strategy(Strategy)`: Defines the strategy for how multiple validators interact.
    case retrieval(Retrieval)
    case skipper(Skipper)
    case logger(Logger)
    case strategy(Strategy)
    
    public static func == (lhs: ValidationOption, rhs: ValidationOption) -> Bool {
        switch (lhs, rhs) {
        case let (.retrieval(a), .retrieval(b)): return a == b
        case let (.skipper(a), .skipper(b)): return a == b
        case let (.logger(a), .logger(b)): return a == b
        case let (.strategy(a), .strategy(b)): return a == b
        default: return false
        }
    }
}
