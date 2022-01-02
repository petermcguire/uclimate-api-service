package io.gzmo.models

import kotlinx.serialization.Serializable

@Serializable
data class Sys (

	val type : Int = 0,
	val id : Int = 0,
	val message : Double = 0.0,
	val country : String = "",
	val sunrise : Int = 0,
	val sunset : Int = 0
)