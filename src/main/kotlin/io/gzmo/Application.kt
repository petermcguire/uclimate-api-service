package io.gzmo

import io.gzmo.plugins.configureRouting
import io.ktor.application.*
import io.ktor.auth.*
import io.ktor.features.*
import io.ktor.serialization.*
import io.ktor.server.engine.*
import io.ktor.server.netty.*

fun main() {
    embeddedServer(Netty, port = 80) {
        install(ContentNegotiation) {
            json()
        }
        install(Authentication) {
            basic("auth-basic") {
                realm = "Access to the '/' path"
                validate { credentials ->
                    if (credentials.name == System.getenv("uclimate_basicauth_username") && credentials.password == System.getenv("uclimate_basicauth_password")) {
                        UserIdPrincipal(credentials.name)
                    } else {
                        null
                    }
                }
            }
        }
        configureRouting()
    }.start(wait = true)
}
