extends Node


const SAVE_FILE = "al_awadi_bullet_save.json"
var storage_path: String = "user://" + SAVE_FILE

var cache: Dictionary = {}


func _ready():
	load_from_disk()


func ingest_json(raw: String):
	var parser = JSON.new()
	var output = {}
	parser.parse(raw)
	if parser.data != null:
		output = parser.data
	cache = output


func export_for_web():
	var payload = JSON.stringify(cache)
	JavaScriptBridge.download_buffer(payload.to_utf8_buffer(), SAVE_FILE)


func write(key: String, value, alt_path: String = storage_path):
	cache[key] = value
	var payload = JSON.stringify(cache)
	var handle = FileAccess.open(alt_path, FileAccess.WRITE)
	handle.store_line(payload)
	handle.close()


func flush(alt_path: String = storage_path):
	var payload = JSON.stringify(cache)
	var handle = FileAccess.open(alt_path, FileAccess.WRITE)
	handle.store_line(payload)
	handle.close()


func read(key: String):
	var result = null
	if cache != null:
		result = cache.get(key)
	return result


func load_from_disk(alt_path: String = storage_path):
	var parser = JSON.new()
	var output = {}
	var handle = FileAccess.open(alt_path, FileAccess.READ)
	if handle:
		parser.parse(handle.get_as_text())
		handle.close()
	else:
		print("Save file not found, starting fresh.")
	if parser.data != null:
		output = parser.data
	cache = output
