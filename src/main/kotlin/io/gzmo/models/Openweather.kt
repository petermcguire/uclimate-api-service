package io.gzmo.models

import kotlinx.serialization.Serializable

@Serializable
data class Openweather (

	val coord : Coord = Coord(),
	val weather : List<Weather> = listOf<Weather>(),
	val base : String = "",
	val main : Main = Main(),
	val visibility : Int = 0,
	val wind : Wind = Wind(),
	val clouds : Clouds = Clouds(),
	val rain : Rain = Rain(),
	val snow : Snow = Snow(),
	val dt : Int = 0,
	val sys : Sys = Sys(),
	val timezone : Int = 0,
	val id : Int = 0,
	val name : String = "",
	val cod : Int = 0
)