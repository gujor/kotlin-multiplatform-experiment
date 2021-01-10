package com.example.kmmexperiment.shared


class Greeting {
    fun greeting(): String {
        return "Hello, ${Platform().platform}!"
    }
}
