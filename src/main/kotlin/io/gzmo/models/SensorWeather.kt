package io.gzmo.models

import kotlinx.serialization.Serializable

@Serializable
data class SensorWeather(
    val timestamp: Long = 0,
    val sensor: Sensor = Sensor(),
    val openweather: Openweather = Openweather()
)
