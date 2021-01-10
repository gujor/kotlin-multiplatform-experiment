package com.example.kmmexperiment.shared


class Greeting {
    fun greeting(): String {
        return "Hello, ${Platform().platform}!"
    }

    fun successfulGreeting(): Result<String> {
        return Result.Success("Hello, Success!")
    }

    fun failedGreeting(): Result<String> {
        return Result.Failure(Throwable("Hello, Failure!"))
    }
}

