extends Node


func parse_vector3(source: String) -> Vector3:
	var trimmed = source.substr(1, source.length() - 2)
	var parts = trimmed.split(",")
	return Vector3(parts[0].to_float(), parts[1].to_float(), parts[2].to_float())


func parse_color(source: String) -> Color:
	var trimmed = source.substr(1, source.length() - 2)
	var parts = trimmed.split(",")
	return Color(parts[0].to_float(), parts[1].to_float(), parts[2].to_float(), parts[3].to_float())


var sensitivity_presets: Dictionary = {
	"Valorant": 0.0707589285714285,
	"CounterStrike": 0.0222372497081799,
	"Fortnite": 0.00561534231977053
}


var mode_3d: Dictionary = {
	"3D_HEAD_LEVEL_V1": {
		"spawn_x_min": 24,
		"spawn_x_max": -24,
		"spawn_y_min": 4,
		"spawn_y_max": 4,
		"allow_move": false,
		"scale": 0.5,
		"spawn_count": 1
	},
	"3D_MULTIPLE_BASIC_TARGETS_MOVEMENT_V1": {
		"spawn_x_min": 12,
		"spawn_x_max": -12,
		"spawn_y_min": 4,
		"spawn_y_max": 20,
		"allow_move": true,
		"scale": 0.5,
		"spawn_count": 6
	},
	"3D_MULTIPLE_BASIC_TARGETS_V1": {
		"spawn_x_min": 12,
		"spawn_x_max": -12,
		"spawn_y_min": 4,
		"spawn_y_max": 20,
		"allow_move": false,
		"scale": 0.5,
		"spawn_count": 6
	},
	"3D_MULTIPLE_MEDIUM_TARGETS_V1": {
		"spawn_x_min": 11,
		"spawn_x_max": -11,
		"spawn_y_min": 4,
		"spawn_y_max": 15,
		"allow_move": false,
		"scale": 3,
		"spawn_count": 3
	}
}


var mode_2d: Dictionary = {
	"2D_GRIDSHOT_V1": {
		"edge_margin": 100,
		"size": 60,
		"spawn_count": 3,
		"round_time": 60
	},
	"2D_REFLEX_V1": {
		"edge_margin": 100,
		"size": 40,
		"spawn_count": 1,
		"round_time": 60
	},
	"2D_MOVING_TARGETS_V1": {
		"edge_margin": 100,
		"size": 40,
		"spawn_count": 5,
		"round_time": 60,
		"allow_move": true
	}
}


var active_mode: String = ""
