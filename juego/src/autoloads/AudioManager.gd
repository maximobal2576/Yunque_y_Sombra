# AudioManager.gd
# Gestor central de audio y Foley táctil para 'Yunque & Sombra' (/sonidista)
# Implementa precarga nativa compatible con Web/HTML5 (PCK) y fallback resiliente de muestras WAV.
extends Node

const POOL_SIZE: int = 12
const BACKGROUND_MUSIC_PATH: String = "res://assets/audio/music/musica_fondo_tranquila.wav"
const DEFAULT_MUSIC_VOLUME_DB: float = -13.5

var audio_streams: Dictionary = {}
var players_pool: Array[AudioStreamPlayer] = []
var pool_index: int = 0
var steam_player: AudioStreamPlayer = null
var forge_ambient_player: AudioStreamPlayer = null
var music_player: AudioStreamPlayer = null
var _music_active: bool = false
var _music_volume_db: float = DEFAULT_MUSIC_VOLUME_DB
var _forge_ambient_active: bool = false
var _forge_ambient_timer: float = 0.0
var _steam_tween: Tween = null
var _bellows_tween: Tween = null

const PRELOADED_SOUNDS: Dictionary = {
	"bell": preload("res://assets/audio/sfx/bell_ring.wav"),
	"bellows": preload("res://assets/audio/sfx/bellows_air.wav"),
	"fire": preload("res://assets/audio/sfx/fire_crackle.wav"),
	"anvil_1": preload("res://assets/audio/sfx/anvil_hit_1.wav"),
	"anvil_2": preload("res://assets/audio/sfx/anvil_hit_2.wav"),
	"anvil_3": preload("res://assets/audio/sfx/anvil_hit_3.wav"),
	"snip": preload("res://assets/audio/sfx/shear_snip.wav"),
	"quench": preload("res://assets/audio/sfx/quench_steam.wav"),
	"whetstone": preload("res://assets/audio/sfx/whetstone_scrape.wav"),
	"coins": preload("res://assets/audio/sfx/coins_clink.wav"),
	"place_item": preload("res://assets/audio/sfx/place_item.wav"),
	"temp_ready": preload("res://assets/audio/sfx/temp_ready.wav"),
	"temp_overheat": preload("res://assets/audio/sfx/temp_overheat.wav"),
	"pickaxe_hit": preload("res://assets/audio/sfx/pickaxe_hit.wav"),
	"rock_shatter": preload("res://assets/audio/sfx/rock_shatter.wav"),
	"torch_light": preload("res://assets/audio/sfx/torch_light.wav"),
	"step_complete": preload("res://assets/audio/sfx/step_complete.wav"),
	"bg_music": preload("res://assets/audio/music/musica_fondo_tranquila.wav")
}

const SOUND_PATHS: Dictionary = {
	"bell": "res://assets/audio/sfx/bell_ring.wav",
	"bellows": "res://assets/audio/sfx/bellows_air.wav",
	"fire": "res://assets/audio/sfx/fire_crackle.wav",
	"anvil_1": "res://assets/audio/sfx/anvil_hit_1.wav",
	"anvil_2": "res://assets/audio/sfx/anvil_hit_2.wav",
	"anvil_3": "res://assets/audio/sfx/anvil_hit_3.wav",
	"snip": "res://assets/audio/sfx/shear_snip.wav",
	"quench": "res://assets/audio/sfx/quench_steam.wav",
	"whetstone": "res://assets/audio/sfx/whetstone_scrape.wav",
	"coins": "res://assets/audio/sfx/coins_clink.wav",
	"place_item": "res://assets/audio/sfx/place_item.wav",
	"temp_ready": "res://assets/audio/sfx/temp_ready.wav",
	"temp_overheat": "res://assets/audio/sfx/temp_overheat.wav",
	"pickaxe_hit": "res://assets/audio/sfx/pickaxe_hit.wav",
	"rock_shatter": "res://assets/audio/sfx/rock_shatter.wav",
	"torch_light": "res://assets/audio/sfx/torch_light.wav",
	"step_complete": "res://assets/audio/sfx/step_complete.wav",
	"bg_music": BACKGROUND_MUSIC_PATH
}

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	_load_all_samples()
	
	# Instanciar pool fijo de reproductores para SFX one-shot (cero nodos huérfanos)
	for i: int in range(POOL_SIZE):
		var p := AudioStreamPlayer.new()
		p.name = "ReproductorSFX_%d" % i
		p.bus = &"Master"
		add_child(p)
		players_pool.append(p)
		
	# Reproductor dedicado para loop de vapor en la tina
	steam_player = AudioStreamPlayer.new()
	steam_player.name = "ReproductorVaporTina"
	steam_player.bus = &"Master"
	if audio_streams.has("quench"):
		steam_player.stream = audio_streams["quench"] as AudioStream
	add_child(steam_player)

	# Reproductor dedicado para ambiente de brasas de la fragua
	forge_ambient_player = AudioStreamPlayer.new()
	forge_ambient_player.name = "ReproductorAmbienteFragua"
	forge_ambient_player.bus = &"Master"
	forge_ambient_player.volume_db = -11.0
	if audio_streams.has("fire"):
		forge_ambient_player.stream = audio_streams["fire"] as AudioStream
	add_child(forge_ambient_player)
	
	# Reproductor dedicado para música tranquila medieval/artesanal de fondo
	music_player = AudioStreamPlayer.new()
	music_player.name = "ReproductorMusicaFondo"
	music_player.bus = &"Music" if AudioServer.get_bus_index(&"Music") != -1 else &"Master"
	music_player.volume_db = _music_volume_db
	var music_stream: AudioStream = _prepare_background_music_stream()
	if music_stream != null:
		music_player.stream = music_stream
	add_child(music_player)
	start_background_music()

func _exit_tree() -> void:
	if _steam_tween != null and _steam_tween.is_valid():
		_steam_tween.kill()
	if _bellows_tween != null and _bellows_tween.is_valid():
		_bellows_tween.kill()
	stop_background_music()
	stop_all_sfx()
	players_pool.clear()

func stop_all_sfx() -> void:
	for p: AudioStreamPlayer in players_pool:
		if is_instance_valid(p):
			p.stop()
			p.stream = null
	if is_instance_valid(steam_player):
		steam_player.stop()
		steam_player.stream = null
	if is_instance_valid(forge_ambient_player):
		forge_ambient_player.stop()
		forge_ambient_player.stream = null
	if is_instance_valid(music_player):
		_music_active = false
		music_player.stop()
		music_player.stream = null

func _process(delta: float) -> void:
	if not _forge_ambient_active and not _music_active:
		set_process(false)
		return
		
	if _music_active and is_instance_valid(music_player):
		if music_player.stream != null and not music_player.playing:
			music_player.play()
			
	if _forge_ambient_active and is_instance_valid(forge_ambient_player):
		_forge_ambient_timer -= delta
		if not forge_ambient_player.playing and _forge_ambient_timer <= 0.0:
			forge_ambient_player.pitch_scale = randf_range(0.92, 1.06)
			forge_ambient_player.volume_db = randf_range(-12.5, -9.5)
			forge_ambient_player.play()
			_forge_ambient_timer = randf_range(0.15, 0.45)

func _prepare_background_music_stream() -> AudioStream:
	var stream: AudioStream = null
	if audio_streams.has("bg_music") and audio_streams["bg_music"] is AudioStream:
		stream = audio_streams["bg_music"] as AudioStream
	else:
		stream = _load_wav_resilient(BACKGROUND_MUSIC_PATH)
	if stream == null:
		stream = _generate_procedural_music_fallback()
	if stream is AudioStreamWAV:
		var wav_stream: AudioStreamWAV = stream as AudioStreamWAV
		wav_stream.loop_mode = AudioStreamWAV.LOOP_FORWARD
		wav_stream.loop_begin = 0
		var bytes_per_sample: int = 2 if wav_stream.format == AudioStreamWAV.FORMAT_16_BITS else 1
		if wav_stream.stereo:
			bytes_per_sample *= 2
		if bytes_per_sample > 0 and wav_stream.data.size() > 0:
			wav_stream.loop_end = int(wav_stream.data.size() / bytes_per_sample)
	audio_streams["bg_music"] = stream
	return stream

func _generate_procedural_music_fallback() -> AudioStreamWAV:
	# Fallback procedural en memoria por si aún no se importó el WAV en modo headless
	var mix_rate: int = 22050
	var duration_sec: float = 8.0
	var total_samples: int = int(mix_rate * duration_sec)
	var data := PackedByteArray()
	data.resize(total_samples * 2)
	var chord_freqs: Array[float] = [146.83, 220.00, 293.66, 349.23] # Re menor cálido
	for i: int in range(total_samples):
		var t: float = float(i) / float(mix_rate)
		var env: float = 0.5 - 0.5 * cos(TAU * t / duration_sec)
		var val: float = (
			0.45 * sin(TAU * chord_freqs[0] * t)
			+ 0.30 * sin(TAU * chord_freqs[1] * t)
			+ 0.15 * sin(TAU * chord_freqs[2] * t)
			+ 0.10 * sin(TAU * chord_freqs[3] * t)
		) * env * 0.25
		var sample_int: int = clampi(int(round(val * 32767.0)), -32767, 32767)
		data.encode_s16(i * 2, sample_int)
	var wav := AudioStreamWAV.new()
	wav.format = AudioStreamWAV.FORMAT_16_BITS
	wav.mix_rate = mix_rate
	wav.stereo = false
	wav.data = data
	wav.loop_mode = AudioStreamWAV.LOOP_FORWARD
	wav.loop_begin = 0
	wav.loop_end = total_samples
	return wav

func start_background_music() -> void:
	if not is_instance_valid(music_player):
		return
	if music_player.stream == null:
		music_player.stream = _prepare_background_music_stream()
	_music_active = true
	music_player.volume_db = _music_volume_db
	if not music_player.playing and music_player.stream != null:
		music_player.play()
	set_process(true)

func stop_background_music() -> void:
	_music_active = false
	if is_instance_valid(music_player) and music_player.playing:
		music_player.stop()
	if not _forge_ambient_active:
		set_process(false)

func set_music_volume_db(vol: float) -> void:
	_music_volume_db = clampf(vol, -60.0, 6.0)
	if is_instance_valid(music_player):
		music_player.volume_db = _music_volume_db

func _load_all_samples() -> void:
	for key: String in SOUND_PATHS.keys():
		if PRELOADED_SOUNDS.has(key) and PRELOADED_SOUNDS[key] is AudioStream:
			audio_streams[key] = PRELOADED_SOUNDS[key]
			continue
		var path: String = str(SOUND_PATHS[key])
		var stream: AudioStream = _load_wav_resilient(path)
		if stream != null:
			audio_streams[key] = stream

func _load_wav_resilient(path: String) -> AudioStream:
	if path.is_empty():
		return null
	if ResourceLoader.exists(path):
		var res: Resource = ResourceLoader.load(path)
		if res is AudioStream:
			return res as AudioStream
			
	if not FileAccess.file_exists(path):
		return null
		
	var file: FileAccess = FileAccess.open(path, FileAccess.READ)
	if file == null:
		return null
		
	var buffer: PackedByteArray = file.get_buffer(file.get_length())
	if buffer.size() < 44:
		return null
		
	var stream := AudioStreamWAV.new()
	stream.format = AudioStreamWAV.FORMAT_16_BITS
	stream.mix_rate = 44100
	stream.stereo = false
	# El encabezado estándar RIFF WAV mide 44 bytes; el cuerpo PCM inicia en el byte 44
	stream.data = buffer.slice(44)
	return stream

func _get_available_sfx_player() -> AudioStreamPlayer:
	if players_pool.is_empty():
		return null
	var count: int = players_pool.size()
	# Priorizar un reproductor libre que no esté sonando para soportar concurrencia limpia
	for offset: int in range(count):
		var idx: int = (pool_index + offset) % count
		var candidate: AudioStreamPlayer = players_pool[idx]
		if is_instance_valid(candidate) and not candidate.playing:
			pool_index = (idx + 1) % count
			return candidate
	# Si todos están ocupados, reciclar en orden round-robin sin instanciar nodos nuevos
	var fallback: AudioStreamPlayer = players_pool[pool_index]
	pool_index = (pool_index + 1) % count
	if is_instance_valid(fallback):
		fallback.stop()
		return fallback
	return null

func play_sfx(key: String, volume_db: float = 0.0, pitch_jitter: float = 0.0) -> void:
	if key.is_empty() or not audio_streams.has(key):
		return
	var player: AudioStreamPlayer = _get_available_sfx_player()
	if player == null:
		return
		
	player.stream = audio_streams[key] as AudioStream
	player.volume_db = clampf(volume_db, -40.0, 6.0)
	var safe_jitter: float = clampf(pitch_jitter, 0.0, 0.35)
	if safe_jitter > 0.0:
		player.pitch_scale = randf_range(1.0 - safe_jitter, 1.0 + safe_jitter)
	else:
		player.pitch_scale = 1.0
	player.play()

func play_bell() -> void:
	play_sfx("bell", 1.0, 0.05)

func play_bellows() -> void:
	play_sfx("bellows", 0.5, 0.06)
	if _bellows_tween != null and _bellows_tween.is_valid():
		_bellows_tween.kill()
	_bellows_tween = create_tween()
	_bellows_tween.tween_interval(0.08)
	_bellows_tween.tween_callback(func() -> void: play_sfx("fire", -3.0, 0.08))

func play_fire() -> void:
	play_sfx("fire", 0.0, 0.06)

func play_anvil(temperatura: float = 1050.0) -> void:
	var hits: Array[String] = ["anvil_1", "anvil_2", "anvil_3"]
	var chosen: String = hits[randi() % hits.size()]
	if not audio_streams.has(chosen):
		return
	var player: AudioStreamPlayer = _get_available_sfx_player()
	if player == null:
		return
	player.stream = audio_streams[chosen] as AudioStream
	# Metal caliente: golpe grave y sordo; metal frío: campaneo más agudo y seco
	var base_pitch: float = 1.0 if temperatura >= 800.0 else (1.08 if temperatura >= 650.0 else 1.16)
	player.pitch_scale = base_pitch * randf_range(0.94, 1.06)
	player.volume_db = 2.0 + randf_range(-0.8, 0.8)
	player.play()

func start_forge_ambience() -> void:
	_forge_ambient_active = true
	_forge_ambient_timer = 0.0
	set_process(true)

func stop_forge_ambience() -> void:
	_forge_ambient_active = false
	if not _music_active:
		set_process(false)
	if is_instance_valid(forge_ambient_player) and forge_ambient_player.playing:
		forge_ambient_player.stop()

func play_snip() -> void:
	play_sfx("snip", 1.5, 0.06)

func play_whetstone() -> void:
	play_sfx("whetstone", 0.0, 0.08)

func play_coins() -> void:
	play_sfx("coins", 1.0, 0.05)

func play_place_item() -> void:
	play_sfx("place_item", 0.5, 0.07)

func play_temp_ready() -> void:
	play_sfx("temp_ready", 1.0, 0.05)

func play_temp_overheat() -> void:
	play_sfx("temp_overheat", 1.2, 0.06)

func play_pickaxe_hit() -> void:
	play_sfx("pickaxe_hit", 1.5, 0.07)

func play_rock_shatter() -> void:
	play_sfx("rock_shatter", 1.8, 0.06)

func play_torch_light() -> void:
	play_sfx("torch_light", 0.8, 0.07)

func play_step_complete() -> void:
	play_sfx("step_complete", 1.0, 0.05)

func start_quench_steam() -> void:
	if is_instance_valid(steam_player):
		if _steam_tween != null and _steam_tween.is_valid():
			_steam_tween.kill()
		if steam_player.stream == null and audio_streams.has("quench"):
			steam_player.stream = audio_streams["quench"] as AudioStream
		steam_player.volume_db = 1.5
		steam_player.pitch_scale = randf_range(0.94, 1.06)
		if not steam_player.playing:
			steam_player.play()

func stop_quench_steam() -> void:
	if is_instance_valid(steam_player) and steam_player.playing:
		if _steam_tween != null and _steam_tween.is_valid():
			_steam_tween.kill()
		_steam_tween = create_tween()
		_steam_tween.tween_property(steam_player, "volume_db", -30.0, 0.25)
		_steam_tween.tween_callback(func() -> void:
			if is_instance_valid(steam_player):
				steam_player.stop()
		)
