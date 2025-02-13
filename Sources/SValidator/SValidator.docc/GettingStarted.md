# How to Start

## Installation
To use SValidator in your project, add the following dependency to your `Package.swift`:

```swift
.package(url: "https://github.com/yourrepo/SValidator.git", from: "1.0.0")
```

## Usage

### Using @Validate
The ``Validate`` property wrapper allows defining validation rules inline:

```swift
struct User {
    @Validate({
        LengthValidator(min: 5, max: 10)
        RegexValidator(pattern: "^[a-zA-Z]+$")
    })
    var username: String = "JohnDoe"
}
```

### Implementing a Custom Validator
To define a custom validator, conform to the `Validator` protocol:

```swift
struct EmailValidator: Validator {
    func validate(_ value: String) throws {
        if !value.contains("@") {
            throw ValidationError.invalidEmail
        }
    }
}
```

### Using `ValidatorBuilder`
The `ValidatorBuilder` enables grouping multiple validators concisely:

```swift
let validators = ValidatorBuilder<String> {
    EmailValidator()
    LengthValidator(min: 5, max: 50)
}
```

## Validation Checks
You can check validation states dynamically:

```swift
if $username.isValid {
    print("Valid username")
} else if let error = $username.validationError {
    print("Validation error: \(error)")
}
```

## Contributing
Contributions are welcome! Feel free to submit issues or pull requests.

## License
MIT License. See `LICENSE` file for details.


