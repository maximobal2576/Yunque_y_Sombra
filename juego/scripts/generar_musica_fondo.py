# generar_musica_fondo.py
# Síntesis acústica procedural de música medieval/artesanal tranquila para 'Yunque & Sombra'
# Progresión en Re Dórico a ~68 BPM, arpa/laúd Karplus-Strong suavizado y colchón armónico cálido
# WAV PCM 16-bit (44100 Hz) con bucle perfecto (seamless crossfade loop) de ~28.2 segundos (32 pulsos).

import os
import math
import wave
import struct
import random

SAMPLE_RATE = 44100
BPM = 68.0
BEAT_SEC = 60.0 / BPM  # ~0.88235 s por pulso
TOTAL_BEATS = 32       # 8 compases de 4/4 = ~28.235 segundos
LOOP_DURATION = TOTAL_BEATS * BEAT_SEC
LOOP_SAMPLES = int(round(LOOP_DURATION * SAMPLE_RATE))

# Frecuencias exactas en Re Dórico (D Dorian: D, E, F, G, A, B, C)
NOTES = {
    "D2": 73.42,
    "F2": 87.31,
    "G2": 98.00,
    "A2": 110.00,
    "C3": 130.81,
    "D3": 146.83,
    "E3": 164.81,
    "F3": 174.61,
    "G3": 196.00,
    "A3": 220.00,
    "B3": 246.94,
    "C4": 261.63,
    "D4": 293.66,
    "E4": 329.63,
    "F4": 349.23,
    "G4": 392.00,
    "A4": 440.00,
}


def synthesize_lute_pluck(freq: float, duration_sec: float, velocity: float = 1.0, seed_val: int = 42) -> list:
    """
    Síntesis Karplus-Strong modificada con cuerpo de madera resonante y filtro pasa-bajos cálido
    para emular una cuerda de laúd/arpa medieval pulsada con la yema de los dedos (sin brillo estridente).
    """
    num_samples = int(duration_sec * SAMPLE_RATE)
    period = max(2, int(round(SAMPLE_RATE / freq)))
    rng = random.Random(seed_val)

    # Excitación inicial suave: ruido filtrado con ventana sinusoidal (pulsación de dedo, no púa metálica)
    ring_buffer = []
    for i in range(period):
        phase = i / float(period)
        # Mezcla de fundamental cálida y textura de cuerda
        raw = (
            0.55 * math.sin(2.0 * math.pi * phase)
            + 0.25 * math.sin(4.0 * math.pi * phase)
            + 0.20 * (rng.uniform(-1.0, 1.0))
        )
        ring_buffer.append(raw)

    # Pre-suavizado del buffer inicial (pasa-bajos para eliminar asperezas agudas)
    for _ in range(3):
        smoothed = []
        for i in range(period):
            smoothed.append(0.25 * ring_buffer[i - 1] + 0.50 * ring_buffer[i] + 0.25 * ring_buffer[(i + 1) % period])
        ring_buffer = smoothed

    out = [0.0] * num_samples
    # Factor de amortiguamiento dependiente de la altura para sostener graves cálidos
    damping = 0.9968 if freq < 200.0 else 0.9955
    lp_state = 0.0
    body_phase = 0.0
    body_inc = 2.0 * math.pi * freq / SAMPLE_RATE

    for i in range(num_samples):
        idx = i % period
        next_idx = (i + 1) % period
        # Promedio Karplus-Strong con pérdida suave
        avg = damping * (0.58 * ring_buffer[idx] + 0.42 * ring_buffer[next_idx])
        ring_buffer[idx] = avg

        # Resonancia cálida del cuerpo de madera del laúd (fundamental + octava suave)
        t = i / float(SAMPLE_RATE)
        body_env = math.exp(-t * 1.45)
        body_warmth = math.sin(body_phase) * 0.28 * body_env
        body_phase += body_inc

        raw_sample = avg * 0.72 + body_warmth

        # Filtro pasa-bajos de primer orden (corte dulce ~1100 Hz)
        lp_state = lp_state + 0.14 * (raw_sample - lp_state)

        # Envolvente de ataque suave (18 ms) para evitar clics y cola exponencial natural
        attack = min(1.0, i / (0.018 * SAMPLE_RATE))
        fade_out = 1.0
        tail_start = int(num_samples * 0.82)
        if i > tail_start:
            fade_out = max(0.0, 1.0 - (i - tail_start) / float(num_samples - tail_start))

        out[i] = lp_state * attack * fade_out * velocity

    return out


def synthesize_warm_pad_chord(freqs: list, duration_sec: float, amp: float = 0.12) -> list:
    """
    Colchón armónico acústico (armonio de fuelle de madera / viola de rueda suave)
    con ataque y caída de coseno para sostener la atmósfera tranquila sin fatiga.
    """
    num_samples = int(duration_sec * SAMPLE_RATE)
    out = [0.0] * num_samples
    attack_samples = int(0.85 * SAMPLE_RATE)
    release_samples = int(1.10 * SAMPLE_RATE)

    for i in range(num_samples):
        t = i / float(SAMPLE_RATE)
        # Envolvente suave tipo coseno
        env = 1.0
        if i < attack_samples:
            env = 0.5 * (1.0 - math.cos(math.pi * i / float(attack_samples)))
        elif i > num_samples - release_samples:
            rem = num_samples - i
            env = 0.5 * (1.0 - math.cos(math.pi * max(0, rem) / float(release_samples)))

        # Lenta respiración orgánica del fuelle
        breath = 1.0 + 0.06 * math.sin(2.0 * math.pi * 0.22 * t)

        val = 0.0
        for f in freqs:
            # Fundamental + 2º armónico muy tenue
            val += 0.82 * math.sin(2.0 * math.pi * f * t)
            val += 0.18 * math.sin(2.0 * math.pi * (f * 2.0) * t + 0.4)

        out[i] = (val / max(1, len(freqs))) * env * breath * amp

    return out


def add_event(buffer: list, start_beat: float, clip: list) -> None:
    """Suma un clip de audio en el tiempo indicado. Permite que la cola rebase LOOP_SAMPLES para el crossfade circular."""
    start_idx = int(round(start_beat * BEAT_SEC * SAMPLE_RATE))
    buf_len = len(buffer)
    for i, sample in enumerate(clip):
        target = start_idx + i
        if 0 <= target < buf_len:
            buffer[target] += sample


def build_medieval_track() -> list:
    # Reservamos espacio extra de 6 segundos al final para capturar todas las colas de resonancia
    # y envolverlas circularmente (wrap-around) al principio del loop para un bucle 100% seamless.
    tail_extra_samples = int(6.0 * SAMPLE_RATE)
    work_buffer = [0.0] * (LOOP_SAMPLES + tail_extra_samples)

    # Progresión de 8 compases (32 tiempos) en Re Dórico (D Dorian):
    # Compás 1 (0..4):   Dm  (D2 - A3 - D4 - F4) -> Hogar artesanal, brasa tranquila
    # Compás 2 (4..8):   C   (C3 - G3 - C4 - E4) -> Aire antiguo modal
    # Compás 3 (8..12):  G/B (G2 -D3 - G3 - B3) -> El color dórico luminoso y nostálgico
    # Compás 4 (12..16): Dm  (D2 - A2 - D3 - A3) -> Reposo sereno
    # Compás 5 (16..20): F   (F2 - C3 - F3 - A3) -> Calidez de madera y pergamino
    # Compás 6 (20..24): C   (C3 - G3 - C4 - E4) -> Horizonte tranquilo
    # Compás 7 (24..28): Am7 (A2 - E3 - G3 - C4) -> Cadencia modal suave
    # Compás 8 (28..32): Dm  (D2 - A2 - D3 - F3) -> Resolución natural hacia el compás 1

    pad_chords = [
        (0.0,  4.5, ["D3", "A3", "D4"]),
        (4.0,  4.5, ["C3", "G3", "E4"]),
        (8.0,  4.5, ["G2", "D3", "B3"]),
        (12.0, 4.5, ["D3", "A3", "F4"]),
        (16.0, 4.5, ["F2", "C3", "A3"]),
        (20.0, 4.5, ["C3", "G3", "E4"]),
        (24.0, 4.5, ["A2", "E3", "C4"]),
        (28.0, 4.8, ["D3", "A3", "D4"]),
    ]

    for start_b, dur_b, chord_names in pad_chords:
        freqs = [NOTES[n] for n in chord_names]
        pad_clip = synthesize_warm_pad_chord(freqs, dur_b * BEAT_SEC, amp=0.11)
        add_event(work_buffer, start_b, pad_clip)

    # Arpegios pausados de laúd/arpa medieval y melodía contemplativa (espaciada para no cansar)
    # Formato: (pulso_inicio, nota, duracion_segundos, velocidad)
    lute_score = [
        # Compás 1: Dm
        (0.0,  "D2", 4.2, 0.42),
        (0.5,  "A3", 3.2, 0.30),
        (1.0,  "D4", 3.4, 0.34),
        (2.0,  "F4", 3.2, 0.31),
        (3.0,  "E4", 2.8, 0.26),

        # Compás 2: C
        (4.0,  "C3", 4.2, 0.40),
        (4.5,  "G3", 3.2, 0.28),
        (5.0,  "C4", 3.2, 0.32),
        (6.5,  "E4", 3.0, 0.29),

        # Compás 3: G (toque dórico con B3)
        (8.0,  "G2", 4.2, 0.40),
        (8.5,  "D3", 3.2, 0.29),
        (9.0,  "B3", 3.4, 0.33),
        (10.5, "D4", 3.0, 0.30),
        (11.5, "A3", 2.6, 0.25),

        # Compás 4: Dm (reposo)
        (12.0, "D2", 4.5, 0.42),
        (12.5, "A2", 3.8, 0.30),
        (13.0, "F3", 3.5, 0.31),
        (14.5, "A3", 3.4, 0.28),

        # Compás 5: F
        (16.0, "F2", 4.2, 0.40),
        (16.5, "C3", 3.2, 0.29),
        (17.0, "A3", 3.4, 0.33),
        (18.0, "C4", 3.2, 0.32),
        (19.0, "D4", 2.8, 0.28),

        # Compás 6: C
        (20.0, "C3", 4.2, 0.40),
        (20.5, "G3", 3.2, 0.28),
        (21.0, "E4", 3.4, 0.32),
        (22.5, "C4", 3.0, 0.28),

        # Compás 7: Am7
        (24.0, "A2", 4.2, 0.40),
        (24.5, "E3", 3.2, 0.29),
        (25.0, "G3", 3.2, 0.30),
        (26.0, "C4", 3.2, 0.31),
        (27.0, "B3", 2.8, 0.26),

        # Compás 8: Dm (resolución suave hacia el inicio del bucle)
        (28.0, "D2", 4.5, 0.41),
        (28.5, "A2", 3.8, 0.29),
        (29.0, "D3", 3.6, 0.32),
        (30.0, "F3", 3.4, 0.29),
        (31.0, "A3", 3.0, 0.25),
    ]

    for idx, (beat_pos, note_name, dur_s, vel) in enumerate(lute_score):
        freq = NOTES[note_name]
        pluck = synthesize_lute_pluck(freq, dur_s, velocity=vel, seed_val=100 + idx)
        add_event(work_buffer, beat_pos, pluck)

    # Envolver circularmente la cola (tail wrap-around) sobre el inicio del loop
    # Esto garantiza que la resonancia de las últimas notas continúe exactamente al volver al sample 0
    loop_buffer = work_buffer[:LOOP_SAMPLES]
    for i in range(tail_extra_samples):
        loop_buffer[i] += work_buffer[LOOP_SAMPLES + i]

    # Filtro pasa-bajos maestro suave para calidez analógica y eliminación de cualquier transitorio áspero
    lp = loop_buffer[0]
    for _pass in range(2):
        # Pre-calentar el estado del filtro con el final del bucle para continuidad perfecta en la frontera
        lp = loop_buffer[-1]
        for i in range(LOOP_SAMPLES):
            lp = lp + 0.22 * (loop_buffer[i] - lp)
            loop_buffer[i] = lp

    # Asegurar coincidencia exacta de muestra y pendiente en el punto de bucle (micro-crossfade de 64 muestras)
    xfade_len = 64
    for i in range(xfade_len):
        alpha = i / float(xfade_len)
        # Mezclar suavemente los últimos 64 samples hacia la continuidad del sample 0
        idx_end = LOOP_SAMPLES - xfade_len + i
        loop_buffer[idx_end] = (1.0 - alpha) * loop_buffer[idx_end] + alpha * loop_buffer[0]

    # Normalización suave a un pico de 0.55 (-5.2 dBFS) para dejar amplio margen dinámico
    peak = max(abs(s) for s in loop_buffer)
    target_peak = 0.55
    scale = (target_peak / peak) if peak > 1e-6 else 1.0

    pcm_samples = [int(max(-32767, min(32767, round(s * scale * 32767.0)))) for s in loop_buffer]
    return pcm_samples


def main() -> None:
    base_dir = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
    out_dir = os.path.join(base_dir, "assets", "audio", "music")
    os.makedirs(out_dir, exist_ok=True)
    out_path = os.path.join(out_dir, "musica_fondo_tranquila.wav")

    print("Sintetizando pista musical medieval tranquila (Re Dórico, 68 BPM)...")
    samples = build_medieval_track()

    with wave.open(out_path, "wb") as wf:
        wf.setnchannels(1)
        wf.setsampwidth(2)  # 16-bit PCM
        wf.setframerate(SAMPLE_RATE)
        wf.writeframes(struct.pack(f"<{len(samples)}h", *samples))

    duration = len(samples) / float(SAMPLE_RATE)
    size_kb = os.path.getsize(out_path) / 1024.0
    print(f"Generado exitosamente: {out_path} ({duration:.2f} s, {len(samples)} samples, {size_kb:.1f} KB)")


if __name__ == "__main__":
    main()
