# Kotlin Multiplatform Mobile

The [Kotlin Multiplatform Mobile](https://kotlinlang.org/lp/mobile/) (KMM) site summeries the SDK as:

> Save time and effort by writing the business logic for your iOS and Android apps just once, in pure Kotlin.

Which sounds great as UI is still implemented ... compared to ...

Summary

- It's Kotlin to Objective-C, not Kotlin to Swift.
- Only classes and closures in the shared framework, no Swift structs or enums.
- For idiomatic Swift, a conversion layer between shared Objective-C code and Swift is needed.
- Young technology, lack of examples and tutorials on the internet.
- It has been used in production by ..., ... and ...

## Setup

The Android Studio [wizard](https://kotlinlang.org/docs/mobile/create-first-app.html) was used to create initial project structure.

Some random comments:

- Update gitignore to include build folders for all platforms.
- Genereted Xcode project had only one warning that could be automatically fixed with "Update to recommended settings".
- Deployment target is set to iOS 13.2 using SceneDelegate and SwiftUI.
- Both Android and iOS projects runs fine in simulator.

## A Shared Result type

Swift got [enum](https://docs.swift.org/swift-book/LanguageGuide/Enumerations.html) / [sum type](https://en.wikipedia.org/wiki/Tagged_union) to represent ...

Swift's [Result](https://github.com/apple/swift/blob/main/stdlib/public/core/Result.swift) type is defined as:

```
public enum Result<Success, Failure: Error> {
    /// A success, storing a `Success` value.
    case success(Success)

    /// A failure, storing a `Failure` value.
    case failure(Failure)
}
```

In Kotlin we also got a [Result](https://kotlinlang.org/api/latest/jvm/stdlib/kotlin/-result/#result) type but it's [limited](https://github.com/Kotlin/KEEP/blob/master/proposals/stdlib/result.md#limitations) as it can't be used as a return type. So instead of using Kotlin's result type, let's define one of our own using [sealed classes](...):

```
// code goes here
```

...

## Links

https://kotlinlang.org/docs/mobile/getting-started.html

https://touchlab.co/kotlin-multiplatform-for-ios-developers-touchlab-kit/

https://kotlinlang.org/docs/reference/mpp-intro.html
