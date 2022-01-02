package io.gzmo.models

import kotlinx.serialization.Serializable

@Serializable
data class Main (

	val temp : Double = 0.0,
	val feels_like : Double = 0.0,
	val temp_min : Double = 0.0,
	val temp_max : Double = 0.0,
	val pressure : Int = 0,
	val humidity : Int = 0,
	val sea_level : Double = 0.0,
	val grnd_level : Double = 0.0
)