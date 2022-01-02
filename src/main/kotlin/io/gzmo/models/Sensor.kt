package io.gzmo.models

import kotlinx.serialization.Serializable

@Serializable
data class Sensor(
    val id: Int = 0,
    val red: Int = 0,
    val green: Int = 0,
    val blue: Int = 0,
    val tmp: Double = 0.0,
    val rh: Double = 0.0
)
