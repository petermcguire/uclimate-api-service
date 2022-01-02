package io.gzmo.plugins

import aws.sdk.kotlin.services.s3.S3Client
import aws.sdk.kotlin.services.s3.model.PutObjectRequest
import aws.smithy.kotlin.runtime.content.ByteStream
import io.gzmo.models.Openweather
import io.gzmo.models.Sensor
import io.gzmo.models.SensorWeather
import io.ktor.application.*
import io.ktor.auth.*
import io.ktor.client.*
import io.ktor.client.engine.cio.*
import io.ktor.client.request.*
import io.ktor.client.statement.*
import io.ktor.client.features.json.*
import io.ktor.client.features.json.serializer.*
import io.ktor.http.*
import io.ktor.request.*
import io.ktor.response.*
import io.ktor.routing.*
import kotlinx.serialization.encodeToString
import kotlinx.serialization.json.Json
import java.time.Instant

fun Application.configureRouting() {
    routing {
        get("/") {
            call.respondText("Hello World!")
        }
        get("/health") {
            call.respondText("HEALTHY")
        }
        authenticate("auth-basic") {
            post("/sensor/{id}") {

                val id: String = call.parameters["id"] as String
                val sensor = call.receive<Sensor>()
                call.respondText("Thanks id " + call.parameters["id"], status = HttpStatusCode.Created)
                val client = HttpClient(CIO) {
                    install(JsonFeature) {
                        serializer = KotlinxSerializer()
                    }
                }
                val openweather: Openweather = client.get("https://api.openweathermap.org/data/2.5/weather?lat=48.45325690191095&lon=-123.39907488016529&appid=608da98aac6fd11110539818290f7ace")
                val sensorWeather = SensorWeather(sensor, openweather)
                val request = PutObjectRequest {
                    bucket = "uclimate"
                    key = id + "-" + Instant.now().toEpochMilli().toString() + ".json"
                    this.body = ByteStream.fromString(Json.encodeToString(sensorWeather))
                }
                S3Client { region = "us-west-2" }.use { s3 ->
                    val response =s3.putObject(request)
                }
            }
        }
    }
}
