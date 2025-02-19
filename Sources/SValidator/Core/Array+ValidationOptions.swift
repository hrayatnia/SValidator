//
//  Array+ValidationOptions.swift
//  SValidator
//
//  Created by Sam Rayatnia on 16.02.25.
//


extension Array where Element == ValidationOption {

    /// Checks if the given retrieval option is enabled.
    ///
    /// This method checks if the provided retrieval event (e.g., `.onGet`, `.onSet`) is part of the
    /// validation options for the array. It returns `true` if the event is enabled, or if the
    /// validation is always applied.
    func allowsRetrieval(_ event: ValidationOption.Retrieval) -> Bool {
        let retrievalOptions = compactMap {
            if case let .retrieval(opt) = $0 { return opt }
            return nil
        }
        return retrievalOptions.contains(.always) || retrievalOptions.contains(event)
    }

    /// Checks if validation should be skipped for a given value.
    ///
    /// This method checks if any of the skipper conditions (``ValidationOpyion/skipOnNil``, ``ValidationOption/skipOnDefault``) apply to
    /// the provided value. It returns `true` if validation should be skipped based on the value's state.
    func shouldSkipValidation<T>(for value: T) -> Bool {
        let skipperOptions = compactMap {
            if case let .skipper(opt) = $0 { return opt }
            return nil
        }

        if skipperOptions.contains(.skipOnNil), isNil(value) {
            return true
        }
        if skipperOptions.contains(.skipOnDefault), isDefault(value) {
            return true
        }
        return false
    }

    /// Determines the validation strategy.
    ///
    /// This method returns the first strategy found in the options array, or defaults to ``ValidationOption/Strategy/all``
    /// if no strategy is specified.
    func validationStrategy() -> ValidationOption.Strategy {
        return compactMap {
            if case let .strategy(opt) = $0 { return opt }
            return nil
        }.first ?? .all  // Default to `.all` strategy
    }

    /// Checks if verbose logging is enabled.
    ///
    /// This method checks if any of the validation options specify verbose logging.
    func shouldLogVerbose() -> Bool {
        return contains(.logger(.verbose))
    }

    private func isNil<T>(_ value: T) -> Bool {
        return (value as? AnyOptional)?.isNil ?? false
    }

    private func isDefault<T>(_ value: T) -> Bool {
        return value is String && (value as! String).isEmpty
    }
}

// Helper protocol for checking nil values
protocol AnyOptional {
    var isNil: Bool { get }
}
extension Optional: AnyOptional {
    var isNil: Bool { return self == nil }
}
