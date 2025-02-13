//
//  ValidationOption.swift
//  SValidator
//
//  Created by Sam Rayatnia on 13.02.25.
//


/// An enumeration that defines the different validation options for a given context.
///
/// The `ValidationOption` enum provides options to control when validation should be applied,
/// such as during retrieval, assignment, or always. This enum is used for specifying
/// validation strategies in contexts where values are being accessed or modified.
///
/// - `onGet`: Applies validation when the value is retrieved.
/// - `onSet`: Applies validation when the value is set.
/// - `always`: Applies validation both when the value is set and retrieved.
///
/// Usage example:
/// ```swift
///  @Validate({...}, option: .onGet) var username: String = ""
/// ```
@frozen
public enum ValidationOption {
    /// Applies validation when the value is retrieved.
    case onGet
    
    /// Applies validation when the value is set.
    case onSet
    
    /// Applies validation both when the value is retrieved and set.
    case always
}

