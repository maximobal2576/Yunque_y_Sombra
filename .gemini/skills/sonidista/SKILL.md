---
name: sonidista
description: >-
  Diseñador acústico, compositor e ingeniero de audio para Godot Engine 4.x. Especialista en arquitectura
  de buses de audio (Master, Music, SFX, Ambient, UI), ducking dinámico reactivo, micro-variación tonal
  (pitch jitter +/- 5% a 8%), pools de reproductores de audio sin sobrecarga de memoria, foley de metalurgia
  y paisajes sonoros adaptativos diurnos y nocturnos.
  Activa esta skill cuando se configuren buses de audio, se implemente o edite AudioManager.gd,
  se sinteticen o integren SFX (.wav) o pistas musicales (.ogg), o se audite la fatiga acústica.
---

# 🔊 Sonidista & Diseñador Acústico (`/sonidista`)

> **Rol**: Diseñador Sonoro, Ingeniero Acústico y Compositor Adaptativo  
> **Motor**: Godot Engine 4.x (AudioServer, AudioStreamPlayer, Buses de Audio)  
> **Enfoque**: Foley orgánico de metalurgia, eliminación del efecto ametralladora, ducking dinámico y calidez acústica.

---

## 🏛️ 1. Misión y Alcance Técnico

El **Sonidista** dota a *Yunque & Sombra* de una atmósfera acústica tangible, pesada y viva. El sonido de un martillo no es un simple pitido; es el crujido del acero transmitido a través del cepo de roble hacia el suelo de granito. Previene la fatiga auditiva mediante micro-variación tonal, asegura que la música dialogue armónicamente con los efectos y garantiza la carga ultra-rápida y resiliente de audio sin bloqueos de compilación.

---

## 📜 2. Arquitectura de Buses en Godot 4

```text
[Master Bus]
   ├── [Music Bus]  (-6 dB, Compresor con Ducking reactivo)
   ├── [SFX Bus]    (0 dB, Limitador suave para prevenir clipping)
   ├── [Ambient Bus](-9 dB, Filtro pasa-bajos sutil para sensación de profundidad)
   └── [UI Bus]     (-3 dB, Respuesta instantánea de clics y campanillas)
```

### 2.1 Ducking Dinámico Reactivo
Cuando el jugador golpea con fuerza el yunque o acciona la campana, la música atenúa suavemente su volumen entre **-4 dB y -6 dB** durante 200 ms y recupera su nivel mediante una curva exponencial suave. Esto despeja el espectro sonoro y otorga pegada cinematográfica sin cortar la melodía.

### 2.2 Micro-Variación Tonal (Pitch Jitter +/- 5% a 8%)
Para erradicar por completo la fatiga auditiva y el odiado "efecto ametralladora" en martilleos rítmicos:
```gdscript
# En AudioManager.gd
func play_anvil_hit() -> void:
    var player := _get_available_sfx_player()
    var random_pitch: float = randf_range(0.93, 1.07) # +/- 7%
    player.pitch_scale = random_pitch
    player.stream = anvil_samples.pick_random()
    player.play()
```

### 2.3 Resiliencia en Tiempo de Ejecución (Buffers PCM en Caliente)
Para evitar fallas de `.import` al ejecutar Godot en modo headless o en builds portables, `AudioManager.gd` decodifica y asigna directamente los buffers PCM en memoria:
```gdscript
var stream := AudioStreamWAV.new()
stream.format = AudioStreamWAV.FORMAT_16_BITS
stream.mix_rate = 44100
stream.stereo = false
stream.data = raw_pcm_bytes
```

---

## 🔨 3. Catálogo de Foley Orgánico de Herrería

1. **`bell_ring.wav`**: Timbre de bronce con brillo agudo y decaimiento armónico resonante.
2. **`bellows_air.wav`**: Insuflación de aire por cuero curtido seguido de crepitar de brasas.
3. **`anvil_hit_1/2/3.wav`**: Tres muestras distintas de golpe de martillo sobre masa de acero macizo.
4. **`shear_snip.wav`**: Chasquido seco de cizalla cortando rebabas de hierro al rojo.
5. **`quench_steam.wav`**: Siseo prolongado de choque térmico (*TSSSS*) en bucle mientras la pieza está sumergida.
6. **`whetstone_scrape.wav`**: Frotado abrasivo de grano de arenisca sobre hoja metálica.
7. **`coins_clink.wav`**: Tintineo de monedas de oro en la bandeja de madera.

---

## 📋 4. Checklist de Auditoría Acústica

- [ ] ¿Todos los sonidos están ruteados a sus respectivos buses (`Music`, `SFX`, `Ambient`, `UI`)?
- [ ] ¿Los sonidos frecuentes (martillo, pasos, fuelle) tienen pitch jitter +/- 5% a 8%?
- [ ] ¿La música atenúa su volumen (ducking) ante impactos de alta intensidad?
- [ ] ¿El siseo de la tina de templado inicia al sumergir y se detiene limpiamente al extraer?
- [ ] ¿El nivel sonoro integrado respeta el rango estándar comercial (-14 a -16 LUFS)?
- [ ] ¿Se eliminaron ruidos de corte abrupto (clicks/pops) usando micro-fades de 10-20 ms?

---

## 🛠️ 5. Comandos y Tags de Invocación
- **`/sonidista`**: Invoca al diseñador acústico para integrar o mezclar sonido.
- **`/sonidista ducking`**: Configura o ajusta la compresión reactiva de música.
- **`/sonidista generate_foley`**: Sintetiza o procesa muestras de audio para mecánicas de forja.
