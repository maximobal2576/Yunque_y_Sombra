# scripts/generate_foley_sfx.py
# Generador procedural de efectos de sonido Foley en WAV (44.1 kHz, 16-bit Mono)
# para 'Yunque & Sombra: La Herencia del Artesano' (/sonidista)

import os
import wave
import math
import struct
import random

SAMPLE_RATE = 44100

def create_wav(filename: str, samples: list[float]) -> None:
    os.makedirs(os.path.dirname(filename), exist_ok=True)
    with wave.open(filename, 'wb') as wav_file:
        wav_file.setnchannels(1) # Mono
        wav_file.setsampwidth(2) # 16-bit
        wav_file.setframerate(SAMPLE_RATE)
        
        # Micro-fades de 12 ms al inicio y al final para evitar clicks/pops y normalizar a 0.90
        num_s = len(samples)
        fade_len = min(int(0.012 * SAMPLE_RATE), num_s // 4)
        processed: list[float] = []
        for idx, s in enumerate(samples):
            val = float(s.real if isinstance(s, complex) else s)
            if idx < fade_len and fade_len > 0:
                val *= (idx / float(fade_len))
            elif idx >= num_s - fade_len and fade_len > 0:
                val *= ((num_s - 1 - idx) / float(fade_len))
            processed.append(val)
            
        max_val = max(abs(x) for x in processed) if processed else 1.0
        scale = 0.90 / max_val if max_val > 0.0 else 1.0
        
        raw_data = bytearray()
        for real_val in processed:
            val = int(real_val * scale * 32767.0)
            val = max(-32768, min(32767, val))
            raw_data.extend(struct.pack('<h', val))
            
        wav_file.writeframes(raw_data)
    print(f"[AUDIO OK] {filename} generado ({len(samples)/SAMPLE_RATE:.2f}s)")

# 1. CAMPANA DE MOSTRADOR (Bell Ring): Armónicos metálicos de latón con decaimiento suave
def gen_bell_ring() -> list[float]:
    duration = 1.4
    num_samples = int(duration * SAMPLE_RATE)
    samples = []
    freqs = [1760.0, 3520.0, 5280.0, 7040.0, 2480.0]
    weights = [0.55, 0.25, 0.12, 0.05, 0.15]
    decays = [2.8, 4.5, 6.0, 8.0, 3.5]
    
    for i in range(num_samples):
        t = i / SAMPLE_RATE
        val = 0.0
        strike = math.exp(-t * 28.0) * math.sin(2.0 * math.pi * 880.0 * t) * 0.4
        for f, w, d in zip(freqs, weights, decays):
            val += w * math.sin(2.0 * math.pi * f * t) * math.exp(-t * d)
        samples.append(val + strike)
    return samples

# 2. FUELLE DE CUERO (Bellows Air): Ráfaga de aire suave con soplido cálido
def gen_bellows_air() -> list[float]:
    duration = 0.55
    num_samples = int(duration * SAMPLE_RATE)
    samples = []
    random.seed(42)
    last_noise = 0.0
    for i in range(num_samples):
        t_norm = i / float(num_samples)
        # Envolvente suave
        env = (math.sin(t_norm * math.pi) ** 1.8) if 0.0 <= t_norm <= 1.0 else 0.0
        white = random.uniform(-1.0, 1.0)
        last_noise = (last_noise * 0.85) + (white * 0.15)
        wind = math.sin(2.0 * math.pi * 120.0 * (i / SAMPLE_RATE)) * 0.2
        samples.append((last_noise + wind) * env)
    return samples

# 3. CHISPORROTEO DE FUEGO (Fire Crackle): Micro-explosiones de ascuas de carbón
def gen_fire_crackle() -> list[float]:
    duration = 0.7
    num_samples = int(duration * SAMPLE_RATE)
    samples = [0.0] * num_samples
    random.seed(101)
    
    num_pops = 35
    for _ in range(num_pops):
        start_idx = random.randint(0, num_samples - 600)
        pop_len = random.randint(150, 500)
        pop_freq = random.uniform(800.0, 2400.0)
        pop_amp = random.uniform(0.3, 0.8)
        for k in range(pop_len):
            idx = start_idx + k
            if idx < num_samples:
                t = k / SAMPLE_RATE
                samples[idx] += pop_amp * math.sin(2.0 * math.pi * pop_freq * t) * math.exp(-t * 90.0)
                
    for i in range(num_samples):
        t = i / SAMPLE_RATE
        samples[i] += random.uniform(-0.06, 0.06) * math.sin(t * math.pi / duration)
    return samples

# 4. GOLPES DE YUNQUE (Anvil Strikes 1, 2, 3): Impactos de acero con timbre metálico distintivo
def gen_anvil_hit(fundamental_freq: float) -> list[float]:
    duration = 0.65
    num_samples = int(duration * SAMPLE_RATE)
    samples = []
    
    for i in range(num_samples):
        t = i / SAMPLE_RATE
        impact = math.exp(-t * 85.0) * (random.uniform(-0.8, 0.8) + math.sin(2.0 * math.pi * 320.0 * t))
        ping1 = math.sin(2.0 * math.pi * fundamental_freq * t) * math.exp(-t * 7.5) * 0.6
        ping2 = math.sin(2.0 * math.pi * (fundamental_freq * 2.76) * t) * math.exp(-t * 12.0) * 0.35
        ping3 = math.sin(2.0 * math.pi * (fundamental_freq * 5.4) * t) * math.exp(-t * 18.0) * 0.15
        
        samples.append(impact * 0.7 + ping1 + ping2 + ping3)
    return samples

# 5. CORTE DE TIJERA / CIZALLA (Shear Snip): Rozamiento de hojas afiladas y chasquido mecánico
def gen_shear_snip() -> list[float]:
    duration = 0.32
    num_samples = int(duration * SAMPLE_RATE)
    samples = []
    random.seed(88)
    
    for i in range(num_samples):
        t = i / SAMPLE_RATE
        val = 0.0
        if t < 0.12:
            scrape_env = t / 0.12
            val = random.uniform(-0.4, 0.4) * scrape_env * math.sin(2.0 * math.pi * 3800.0 * t)
        else:
            t_after = t - 0.12
            clac = math.exp(-t_after * 95.0) * (math.sin(2.0 * math.pi * 1450.0 * t_after) * 0.7 + random.uniform(-0.5, 0.5))
            val = clac
        samples.append(val)
    return samples

# 6. VAPOR DE TEMPLADO (Quench Steam): Siseo hirviendo y denso de agua contra metal ardiente
def gen_quench_steam() -> list[float]:
    duration = 1.8
    num_samples = int(duration * SAMPLE_RATE)
    samples = []
    random.seed(777)
    last_val = 0.0
    
    for i in range(num_samples):
        t = i / SAMPLE_RATE
        if t < 0.2:
            env = t / 0.2
        elif t < 1.4:
            env = 1.0
        else:
            env = max(0.0, 1.0 - ((t - 1.4) / 0.4))
            
        noise = random.uniform(-1.0, 1.0)
        last_val = (last_val * 0.7) + (noise * 0.3)
        bubble = math.sin(2.0 * math.pi * 24.0 * t) * 0.15
        samples.append((last_val + bubble) * env * 0.85)
    return samples

# 7. PIEDRA DE AFILAR (Whetstone Scrape): Raspado áspero de grano arenisca contra acero
def gen_whetstone_scrape() -> list[float]:
    duration = 0.45
    num_samples = int(duration * SAMPLE_RATE)
    samples = []
    random.seed(333)
    last_noise = 0.0
    
    for i in range(num_samples):
        t_norm = i / float(num_samples)
        env = (math.sin(t_norm * math.pi) ** 1.2) if 0.0 <= t_norm <= 1.0 else 0.0
        white = random.uniform(-1.0, 1.0)
        last_noise = (last_noise * 0.5) + (white * 0.5)
        metallic = math.sin(2.0 * math.pi * 2900.0 * (i / SAMPLE_RATE)) * 0.2
        samples.append((last_noise + metallic) * env * 0.75)
    return samples

# 8. TINTINEO DE MONEDAS (Coins Clink): Tintineo alegre y metálico de oro al cobrar
def gen_coins_clink() -> list[float]:
    duration = 0.8
    num_samples = int(duration * SAMPLE_RATE)
    samples = [0.0] * num_samples
    
    coin_times = [0.0, 0.11, 0.24]
    coin_freqs = [2400.0, 2750.0, 3100.0]
    
    for t_start, freq in zip(coin_times, coin_freqs):
        idx_start = int(t_start * SAMPLE_RATE)
        for i in range(idx_start, num_samples):
            t = (i - idx_start) / SAMPLE_RATE
            samples[i] += math.sin(2.0 * math.pi * freq * t) * math.exp(-t * 14.0) * 0.5
            samples[i] += math.sin(2.0 * math.pi * (freq * 1.6) * t) * math.exp(-t * 22.0) * 0.25
    return samples

# 9. COLOCAR PIEZA / ITEM (Place Item): "Clonk" táctil seco de madera de roble y metal pesado
def gen_place_item() -> list[float]:
    duration = 0.28
    num_samples = int(duration * SAMPLE_RATE)
    samples = []
    random.seed(202)
    last_noise = 0.0
    
    for i in range(num_samples):
        t = i / SAMPLE_RATE
        # Cuerpo de madera gruesa (formantes bajas 145 Hz y 280 Hz)
        wood_body = (
            math.sin(2.0 * math.pi * 145.0 * t) * math.exp(-t * 36.0) * 0.65 +
            math.sin(2.0 * math.pi * 280.0 * t) * math.exp(-t * 48.0) * 0.45
        )
        # Transiente metálico seco de lingote/herramienta
        metal_clack = (
            math.sin(2.0 * math.pi * 890.0 * t) * math.exp(-t * 72.0) * 0.35 +
            math.sin(2.0 * math.pi * 1420.0 * t) * math.exp(-t * 110.0) * 0.20
        )
        # Impacto de contacto filtrado
        white = random.uniform(-1.0, 1.0)
        last_noise = (last_noise * 0.6) + (white * 0.4)
        thud_noise = last_noise * math.exp(-t * 95.0) * 0.5
        
        # Micro-rebote secundario a los 45ms
        bounce = 0.0
        if t >= 0.045:
            tb = t - 0.045
            bounce = math.sin(2.0 * math.pi * 190.0 * tb) * math.exp(-tb * 65.0) * 0.25
            
        samples.append(wood_body + metal_clack + thud_noise + bounce)
    return samples

# 10. TEMPERATURA ÓPTIMA DE FORJA (Temp Ready): Resonancia cálida de hierro candente + crepitar vivo
def gen_temp_ready() -> list[float]:
    duration = 0.85
    num_samples = int(duration * SAMPLE_RATE)
    samples = [0.0] * num_samples
    random.seed(303)
    
    # Armónicos cálidos de hierro al rojo amarillo (1000°C - 1150°C)
    freqs = [440.0, 660.0, 880.0, 1320.0]
    weights = [0.45, 0.35, 0.22, 0.12]
    decays = [3.8, 4.5, 5.5, 7.0]
    
    for i in range(num_samples):
        t = i / SAMPLE_RATE
        attack = min(1.0, t / 0.025)
        shimmer = 1.0 + 0.08 * math.sin(2.0 * math.pi * 14.0 * t)
        chord = 0.0
        for f, w, d in zip(freqs, weights, decays):
            chord += w * math.sin(2.0 * math.pi * f * t) * math.exp(-t * d)
        samples[i] = chord * attack * shimmer
        
    # Crepitar vivo de brasas activas acompañando el aviso térmico
    for _ in range(18):
        start_idx = random.randint(int(0.03 * SAMPLE_RATE), num_samples - 500)
        pop_len = random.randint(140, 420)
        pop_freq = random.uniform(1100.0, 2600.0)
        pop_amp = random.uniform(0.15, 0.32)
        for k in range(pop_len):
            idx = start_idx + k
            if idx < num_samples:
                tk = k / SAMPLE_RATE
                samples[idx] += pop_amp * math.sin(2.0 * math.pi * pop_freq * tk) * math.exp(-tk * 85.0)
    return samples

# 11. SOBRECALENTAMIENTO / METAL QUEMADO (Temp Overheat): Siseo y chisporroteo agudo de alerta (>1150°C)
def gen_temp_overheat() -> list[float]:
    duration = 0.75
    num_samples = int(duration * SAMPLE_RATE)
    samples = [0.0] * num_samples
    random.seed(404)
    last_noise = 0.0
    
    for i in range(num_samples):
        t = i / SAMPLE_RATE
        # Envolvente de siseo urgente con doble pulso de advertencia
        pulse = 0.75 + 0.25 * math.sin(2.0 * math.pi * 9.5 * t)
        env = min(1.0, t / 0.015) * math.exp(-t * 2.8) * pulse
        
        # Ruido de alta frecuencia (siseo de chispas blancas quemando carbono)
        white = random.uniform(-1.0, 1.0)
        high_hiss = white - (last_noise * 0.55)
        last_noise = white
        
        # Tensión metálica aguda inarmónica
        sizzle_tone = (
            math.sin(2.0 * math.pi * 2350.0 * t) * 0.25 +
            math.sin(2.0 * math.pi * 3120.0 * t) * 0.20
        ) * math.exp(-t * 5.0)
        
        samples[i] = (high_hiss * 0.55 + sizzle_tone) * env
        
    # Ráfaga densa de chispas estallando
    for _ in range(42):
        start_idx = random.randint(0, num_samples - 400)
        pop_len = random.randint(90, 320)
        pop_freq = random.uniform(2200.0, 4800.0)
        pop_amp = random.uniform(0.25, 0.60)
        for k in range(pop_len):
            idx = start_idx + k
            if idx < num_samples:
                tk = k / SAMPLE_RATE
                samples[idx] += pop_amp * math.sin(2.0 * math.pi * pop_freq * tk) * math.exp(-tk * 120.0)
    return samples

# 12. GOLPE DE PICO EN MINA (Pickaxe Hit): Impacto contundente de acero templado contra roca mineral
def gen_pickaxe_hit() -> list[float]:
    duration = 0.52
    num_samples = int(duration * SAMPLE_RATE)
    samples = []
    random.seed(505)
    last_noise = 0.0
    
    for i in range(num_samples):
        t = i / SAMPLE_RATE
        # Golpe seco contra masa pétrea subterránea
        rock_thud = math.sin(2.0 * math.pi * 115.0 * t) * math.exp(-t * 32.0) * 0.70
        # Crujido mineral granular en los primeros 80ms
        white = random.uniform(-1.0, 1.0)
        last_noise = (last_noise * 0.45) + (white * 0.55)
        grit_crunch = last_noise * math.exp(-t * 55.0) * 0.65
        # Timbre de pico de acero vibrando tras el impacto
        steel_ping = (
            math.sin(2.0 * math.pi * 1280.0 * t) * math.exp(-t * 14.0) * 0.45 +
            math.sin(2.0 * math.pi * 2640.0 * t) * math.exp(-t * 22.0) * 0.28 +
            math.sin(2.0 * math.pi * 4150.0 * t) * math.exp(-t * 38.0) * 0.15
        )
        samples.append(rock_thud + grit_crunch + steel_ping)
    return samples

# 13. QUIEBRE DE VETA DE ROCA (Rock Shatter): Crujido estructural y desmoronamiento de mineral
def gen_rock_shatter() -> list[float]:
    duration = 1.05
    num_samples = int(duration * SAMPLE_RATE)
    samples = [0.0] * num_samples
    random.seed(606)
    last_noise = 0.0
    
    # Fractura principal grave + cascada de fragmentos cayendo al suelo de la galería
    debris_hits = [
        (0.00, 95.0, 0.90, 18.0),
        (0.07, 160.0, 0.65, 24.0),
        (0.16, 230.0, 0.55, 28.0),
        (0.28, 310.0, 0.42, 34.0),
        (0.41, 420.0, 0.32, 40.0),
        (0.56, 540.0, 0.22, 48.0),
        (0.72, 680.0, 0.15, 55.0)
    ]
    
    for t_start, freq, amp, decay in debris_hits:
        idx_start = int(t_start * SAMPLE_RATE)
        for i in range(idx_start, num_samples):
            t = (i - idx_start) / SAMPLE_RATE
            # Resonancia pétrea + brillo cristalino de mineral desprendido
            stone = math.sin(2.0 * math.pi * freq * t) * math.exp(-t * decay) * amp
            crystal = math.sin(2.0 * math.pi * (freq * 3.8) * t) * math.exp(-t * (decay * 1.4)) * (amp * 0.3)
            samples[i] += stone + crystal
            
    # Textura de fricción de escombros y polvo mineral
    for i in range(num_samples):
        t = i / SAMPLE_RATE
        white = random.uniform(-1.0, 1.0)
        last_noise = (last_noise * 0.72) + (white * 0.28)
        crumble_env = math.exp(-t * 4.2) * (0.7 + 0.3 * math.sin(2.0 * math.pi * 11.0 * t))
        samples[i] += last_noise * crumble_env * 0.55
    return samples

# 14. IGNICIÓN DE ANTORCHA (Torch Light): "Whoosh" cálido de brea y tela encendiéndose
def gen_torch_light() -> list[float]:
    duration = 0.68
    num_samples = int(duration * SAMPLE_RATE)
    samples = []
    random.seed(707)
    lp1 = 0.0
    lp2 = 0.0
    
    for i in range(num_samples):
        t = i / SAMPLE_RATE
        t_norm = t / duration
        # Envolvente de llamarada súbita ("whoosh") con ataque rápido y cola cálida
        if t < 0.14:
            env = (t / 0.14) ** 1.3
        else:
            env = math.exp(-(t - 0.14) * 5.8)
            
        white = random.uniform(-1.0, 1.0)
        # Filtro paso-bajo dinámico que barre hacia arriba durante la llamarada
        alpha = 0.08 + 0.22 * math.sin(min(1.0, t / 0.25) * math.pi)
        lp1 = lp1 + alpha * (white - lp1)
        lp2 = lp2 + alpha * (lp1 - lp2)
        
        # Turbulencia grave de combustión de aire en caverna
        flame_roar = (
            math.sin(2.0 * math.pi * (95.0 + 45.0 * (1.0 - t_norm)) * t) * 0.35 +
            math.sin(2.0 * math.pi * 180.0 * t) * 0.20 * math.exp(-t * 8.0)
        )
        # Chasquido inicial de chispa de pedernal
        spark = math.sin(2.0 * math.pi * 2100.0 * t) * math.exp(-t * 140.0) * 0.35
        
        samples.append(((lp2 * 1.4 + flame_roar) * env) + spark)
    return samples

# 15. PASO / ESTACIÓN COMPLETADA (Step Complete): Arpegio acústico medieval en laúd y campanilla
def gen_step_complete() -> list[float]:
    duration = 1.15
    num_samples = int(duration * SAMPLE_RATE)
    samples = [0.0] * num_samples
    
    # Arpegio modal medieval (Re - La - Re5 - Fa#5) cálido y artesanal
    notes = [
        (0.00, 293.66, 0.55), # D4
        (0.09, 440.00, 0.52), # A4
        (0.18, 587.33, 0.58), # D5
        (0.28, 739.99, 0.65)  # F#5
    ]
    
    for t_start, freq, amp in notes:
        idx_start = int(t_start * SAMPLE_RATE)
        for i in range(idx_start, num_samples):
            t = (i - idx_start) / SAMPLE_RATE
            attack = min(1.0, t / 0.008)
            # Cuerda pulsada de laúd (rica en armónicos pares e impares con decaimiento orgánico)
            lute = (
                math.sin(2.0 * math.pi * freq * t) * math.exp(-t * 4.2) * 0.60 +
                math.sin(2.0 * math.pi * (freq * 2.0) * t) * math.exp(-t * 6.8) * 0.28 +
                math.sin(2.0 * math.pi * (freq * 3.0) * t) * math.exp(-t * 10.5) * 0.14
            )
            # Toque sutil de campanilla de bronce en la octava superior
            chime = math.sin(2.0 * math.pi * (freq * 4.0) * t) * math.exp(-t * 14.0) * 0.09
            samples[i] += (lute + chime) * amp * attack
    return samples

def _get_project_root() -> str:
    curr = os.path.dirname(os.path.abspath(__file__))
    while curr and os.path.dirname(curr) != curr:
        if os.path.exists(os.path.join(curr, "project.godot")):
            return curr
        curr = os.path.dirname(curr)
    return os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

def main() -> None:
    project_root = _get_project_root()
    base_dir = os.path.join(project_root, "assets", "audio", "sfx")
    create_wav(os.path.join(base_dir, "bell_ring.wav"), gen_bell_ring())
    create_wav(os.path.join(base_dir, "bellows_air.wav"), gen_bellows_air())
    create_wav(os.path.join(base_dir, "fire_crackle.wav"), gen_fire_crackle())
    create_wav(os.path.join(base_dir, "anvil_hit_1.wav"), gen_anvil_hit(980.0))
    create_wav(os.path.join(base_dir, "anvil_hit_2.wav"), gen_anvil_hit(1050.0))
    create_wav(os.path.join(base_dir, "anvil_hit_3.wav"), gen_anvil_hit(1120.0))
    create_wav(os.path.join(base_dir, "shear_snip.wav"), gen_shear_snip())
    create_wav(os.path.join(base_dir, "quench_steam.wav"), gen_quench_steam())
    create_wav(os.path.join(base_dir, "whetstone_scrape.wav"), gen_whetstone_scrape())
    create_wav(os.path.join(base_dir, "coins_clink.wav"), gen_coins_clink())
    create_wav(os.path.join(base_dir, "place_item.wav"), gen_place_item())
    create_wav(os.path.join(base_dir, "temp_ready.wav"), gen_temp_ready())
    create_wav(os.path.join(base_dir, "temp_overheat.wav"), gen_temp_overheat())
    create_wav(os.path.join(base_dir, "pickaxe_hit.wav"), gen_pickaxe_hit())
    create_wav(os.path.join(base_dir, "rock_shatter.wav"), gen_rock_shatter())
    create_wav(os.path.join(base_dir, "torch_light.wav"), gen_torch_light())
    create_wav(os.path.join(base_dir, "step_complete.wav"), gen_step_complete())
    print("\n>>> ¡BANCO DE AUDIO FOLEY GENERADO CON ÉXITO! <<<")

if __name__ == "__main__":
    main()
