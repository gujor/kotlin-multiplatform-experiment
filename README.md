# Kotlin Multiplatform Mobile

The [Kotlin Multiplatform Mobile](https://kotlinlang.org/lp/mobile/) (KMM) site sells the SDK as:

> Save time and effort by writing the business logic for your iOS and Android apps just once, in pure Kotlin.

Making business logic cross-platform while keeping UI truly native seems promising as you still have all the power provided by each platform to develop the best native user experience and the possibility to experiment with the latest technologies as [SwiftUI](https://developer.apple.com/xcode/swiftui/) and [Jetpack Compose](https://developer.android.com/jetpack/compose).

This test of KMM is not even scratching the surface at this point and consist only of a [Setup](#setup) and a shared [Result](#a-shared-result-type) type. More things to try out are [Reaktive](https://github.com/badoo/Reaktive) and [coroutines](https://github.com/Kotlin/kotlinx.coroutines) to see how fluently they can be translated to the iOS Swift world.

### Summary

- It's Kotlin to Objective-C, not Kotlin to Swift (no structs or enums).
- An additional mapping layer between the shared Objective-C framework and idiomatic Swift is needed.
- A lot of information is lost when exposing a shared `sealed class` to iOS, but manually transforming it to Swift seems feasible.
- Since the shared framework is written in Kotlin, KMM should't have a negative impact on Android development.
- Android and iOS developers unified by working together on shared framework seems advantageous.
- It's a young technology with a lack of examples and tutorials on the internet.
- It's used by by [Netflix](https://netflixtechblog.com/netflix-android-and-ios-studio-apps-kotlin-multiplatform-d6d4d8d25d23) and some other [companies](https://kotlinlang.org/lp/mobile/case-studies/).

## Setup

The Android Studio [wizard](https://kotlinlang.org/docs/mobile/create-first-app.html) was used to create initial project structure.

Random comments:

- Must update gitignore to include build folders for all platforms and Xcode specific things.
- Generated Xcode project had only one warning that could be automatically fixed with "Update to recommended settings".
- Xcode project deployment target is set to iOS 13.2 using SceneDelegate and SwiftUI.
- Both Android and iOS projects runs fine in simulator.

## Experiments

### A Shared Result type

Swift has [enum](https://docs.swift.org/swift-book/LanguageGuide/Enumerations.html) which is a [sum type](https://en.wikipedia.org/wiki/Tagged_union) to represent one value out of a number of possible values.

Swift's [Result](https://github.com/apple/swift/blob/main/stdlib/public/core/Result.swift) type is an enum representing success and failure values:

```
public enum Result<Success, Failure: Error> {
    case success(Success)
    case failure(Failure)
}
```

Kotlin has a [Result](https://kotlinlang.org/api/latest/jvm/stdlib/kotlin/-result/#result) type also, but it's [limited](https://github.com/Kotlin/KEEP/blob/master/proposals/stdlib/result.md#limitations) and can't be used as a return type. As an alternative, a shared result type can be constructed using Kotlin's [sealed classes](https://kotlinlang.org/docs/reference/sealed-classes.html):

```
sealed class Result<T> {
    data class Success<T>(val value: T) : Result<T>()
    data class Failure<Nothing>(val error: Throwable) : Result<Nothing>()
}
```

The above Result type will be exposed in the shared framework in Xcode as:

```
open class Result<T> : KotlinBase where T : AnyObject {}

public class ResultFailure<Nothing> : Result<Nothing> where Nothing : AnyObject {
    public init(error: KotlinThrowable)
    open var error: KotlinThrowable { get }
    ...
}

public class ResultSuccess<T> : Result<T> where T : AnyObject {
    public init(value: T?)
    open var value: T? { get }
    ...
}
```

Kotlin generics are translated to the less powerful Objective-C [lightweight](https://developer.apple.com/documentation/swift/imported_c_and_objective-c_apis/using_imported_lightweight_generics_in_swift) generics. To keep the Swift codebase nice and ergonomic we need to introduce a mapping layer that converts the shared Objective-C framework to idiomatic Swift, and in this case, transform the `Result<T>` class to a `Swift.Result<T, Error>` type.

Also, the [Nothing](https://kotlinlang.org/api/latest/jvm/stdlib/kotlin/-nothing.html) type above, which represents something that can't be instantiated (like Swift's [Never](https://developer.apple.com/documentation/swift/never)), is lost in the translation from Kotlin to Objective-C, and is an another example of something that needs to be taken care of in the "swiftify" layer.

The amount of work involved in keeping this mapping layer up to date with changes in the shared framework will be crucial for the success of KMM.

To transform the shared `Result<T>` class to `Swift.Result<T, KotlinThrowable>` this extension can be used:

```
extension Swift.Result
where Success: AnyObject, Failure == KotlinThrowable
{
  init(result: shared.Result<Success>) {
    switch result {
    case let success as ResultSuccess<Success>:
      self = .success(success.value!)
    case let failure as ResultFailure<Success>:
      self = .failure(failure.error)
    default:
      fatalError()
    }
  }
}

extension KotlinThrowable: Error {}
```

The Objective-C lightweight generics are sufficient to derive the `Success` type of the result in the code above.

If the shared `Result` can't be converted to a `Swift.Result` the failure is [non-recoverable](https://www.swiftbysundell.com/articles/picking-the-right-way-of-failing-in-swift/) and we choose to crash.

As the `Success` type will be a class, and the `Failure` type is a `KotlinThrowable`, further transformations are needed, but these can be done using standard Swift.Result functions like `map` and `mapError`.

The use of generic extensions on a shared generic Objective-C type is limited and you have to be explicit with the type (and essentially making the extension not generic), but it still might be useful:

```
extension Result where T == NSString { ... }
```

The Swift code for this can be found in [ContentView.swift](iosApp/iosApp/ContentView.swift) and the Kotlin one in [Result.kt](shared/src/commonMain/kotlin/com/example/kmmexperiment/shared/Result.kt).

Using `sealed class` in the Kotlin business layer, exposing them as Objective-C generics and manually mapping them to Swift seems doable.

## Misc Links

https://kotlinlang.org/docs/mobile/getting-started.html

https://touchlab.co/kotlin-multiplatform-for-ios-developers-touchlab-kit/

https://kotlinlang.org/docs/reference/mpp-intro.html

https://jdam.cd/kmm-exploration/
