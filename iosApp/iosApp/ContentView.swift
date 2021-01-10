import SwiftUI
import shared

extension KotlinThrowable: Error {}

extension Swift.Result where Success: AnyObject, Failure == KotlinThrowable {
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

extension Result where T == NSString {
  var swift: Swift.Result<String, GreetingError> {
    Swift.Result(result: self)
      .map { $0 as String }
      .mapError { GreetingError.error(message: $0.message ?? "no message") }
  }
}

enum GreetingError: Error {
  case error(message: String)
}

struct ContentView: View {
  var body: some View {
    VStack {
      Text(Greeting().greeting())
      switch Greeting().successfulGreeting().swift {
      case .success(let success):
        Text("Success: \(success)")
      case .failure(let error):
        Text("Error: \(String(describing: error))")
      }
    }
  }
}

struct ContentView_Previews: PreviewProvider {
  static var previews: some View {
    ContentView()
  }
}


