package io.gzmo.models

import kotlinx.serialization.Serializable

@Serializable
data class Wind (

	val speed : Double = 0.0,
	val deg : Int = 0,
	val gust: Double = 0.0
)