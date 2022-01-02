package io.gzmo.models

import kotlinx.serialization.Serializable

@Serializable
data class Weather (

	val id : Int = 0,
	val main : String = "",
	val description : String = "",
	val icon : String = ""
)