package io.gzmo.models

import kotlinx.serialization.SerialName
import kotlinx.serialization.Serializable

@Serializable
data class Snow (
	@SerialName("1h")
	val _1h : Double = 0.0,
	@SerialName("3h")
	val _3h : Double = 0.0
)