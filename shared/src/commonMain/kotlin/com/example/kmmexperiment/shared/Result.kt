package com.example.kmmexperiment.shared

sealed class Result<T> {
    data class Success<T>(val value: T) : Result<T>()
    data class Failure<Nothing>(val error: Throwable) : Result<Nothing>()
}

// This doesn't translate well in the shared Objective-C framework:
fun <R, T> Result<T>.fold(
    onSuccess: (value: T) -> R,
    onFailure: (error: Throwable) -> R
): R = when (this) {
    is Result.Success -> onSuccess(value)
    is Result.Failure -> onFailure(error)
}