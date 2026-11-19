#!/usr/bin/env python3
"""
Generador de Assets de Taller y Forja de Alta Fidelidad para 'Yunque & Sombra'.

Paleta Realista de Herrería Histórica:
- Maderas: Roble envejecido, nogal, tablas gastadas (#2b1a0d, #3d2614, #54371e, #734e2c)
- Metales fríos: Hierro forjado negro, acero al carbono (#1c1e22, #32363e, #555d6b, #9aa3b2, #d4dbe6)
- Brasas ardientes: Rojo brasa (#d82b11), naranja forja (#ff7700), amarillo ascua (#ffcc00), blanco incandescente (#fff4cc)
- Mampostería: Cantería oscura, granito, pizarra (#22252a, #2a2d32, #363a40, #454a52)
- Latón y bronce: Latón torneado con pátina natural (#6e5421, #a37f37, #c49d49)
- Cuero curtido: Piel envejecida (#3d210f, #5c371d, #7a4a27)
"""

import os
import math
import numpy as np
from PIL import Image, ImageDraw, ImageFilter

def _get_project_root() -> str:
    curr = os.path.dirname(os.path.abspath(__file__))
    while curr and os.path.dirname(curr) != curr:
        if os.path.exists(os.path.join(curr, "project.godot")):
            return curr
        curr = os.path.dirname(curr)
    return os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

BASE_DIR = _get_project_root()
WORKSHOP_DIR = os.path.join(BASE_DIR, "assets", "sprites", "workshop")
os.makedirs(WORKSHOP_DIR, exist_ok=True)

np.random.seed(1337)

def arr_f32(vals):
    return np.array(vals, dtype=np.float32)

def add_noise(arr, intensity=4.0):
    noise = np.random.normal(0, intensity, arr.shape[:2])
    res = arr.copy()
    for c in range(3):
        res[:, :, c] += noise
    return np.clip(res, 0, 255).astype(np.float32)

# -------------------------------------------------------------------------
# 1. forge_hearth.png (540x360)
# Horno de forja con arco, lecho de brasas incandescentes, parrilla y campana
# -------------------------------------------------------------------------
def generate_forge_hearth():
    print("-> Generando forge_hearth.png (540x360)...")
    w, h = 540, 360
    arr = np.zeros((h, w, 4), dtype=np.float32)

    cx = w // 2

    # 1.1 Sombra y resplandor ambiental sobre el suelo
    for y in range(h):
        for x in range(w):
            dx = (x - cx) / 240.0
            dy = (y - 330) / 30.0
            d_sq = dx*dx + dy*dy
            if d_sq <= 1.0:
                arr[y, x] = [15, 12, 10, (1.0 - d_sq) * 160]

    # 1.2 Campana extractora de hierro remachada superior (Y: 20..130)
    # Se estrecha hacia arriba: Y=20 ancho 140, Y=130 ancho 380
    for y in range(20, 131):
        prog = (y - 20) / 110.0
        cur_w = 70 + prog * 120 # semi-ancho
        for x in range(int(cx - cur_w), int(cx + cur_w) + 1):
            norm_x = (x - cx) / cur_w
            # Hierro forjado martillado (#25282e a #383d47)
            light = 0.6 + 0.4 * (1.0 - abs(norm_x * 0.7)) - norm_x * 0.2
            iron_c = arr_f32([42, 46, 54]) * light
            
            # Fleje de refuerzo inferior de la campana (Y: 118..130)
            if y >= 118:
                iron_c = arr_f32([32, 35, 40])
                if y in [118, 130]:
                    iron_c += 15 # bisel
            arr[y, x] = [iron_c[0], iron_c[1], iron_c[2], 255]

    # Remaches de la campana inferior
    for rx in range(cx - 170, cx + 175, 34):
        for dy in range(-3, 4):
            for dx in range(-3, 4):
                if dx*dx + dy*dy <= 9:
                    arr[124 + dy, rx + dx] = [70, 78, 88, 255] if (dx < 0 or dy < 0) else [20, 22, 26, 255]

    # 1.3 Mampostería del cuerpo y arco de ladrillos refractarios (Y: 130..330)
    # Sillares de piedra y ladrillos refractarios
    for y in range(130, 331):
        for x in range(cx - 210, cx + 211):
            # Comprobar si está en el hueco del hogar (fuego interior)
            dx = x - cx
            dy_hearth = y - 230 # centro focal del lecho
            
            # El arco de la boca: semicírculo superior (Y: 150..230) + lecho rectangular (Y: 230..300)
            in_hearth_opening = False
            if 150 <= y <= 230:
                # Arco semicircular de radio 120
                if (dx / 120.0)**2 + ((y - 230) / 80.0)**2 <= 1.0:
                    in_hearth_opening = True
            elif 230 < y <= 295:
                if abs(dx) <= 120:
                    in_hearth_opening = True
                    
            if not in_hearth_opening:
                # Estructura exterior de piedra y dovelas
                # Dovelas del arco
                angle = math.atan2(y - 230, dx)
                rad_dist = math.sqrt((dx / 120.0)**2 + (max(0, 230 - y) / 80.0)**2)
                
                is_voussoir = (1.0 < rad_dist <= 1.35 and y <= 245)
                
                if is_voussoir:
                    # Dovelas de piedra labrada
                    dov_id = int((angle + math.pi) * 6)
                    dov_tint = ((dov_id * 17) % 7 - 3) * 4
                    stone_c = arr_f32([62, 56, 50]) + dov_tint
                    # Borde de mortero
                    if ((angle + math.pi) * 6) % 1.0 < 0.1:
                        stone_c = arr_f32([25, 22, 20])
                else:
                    # Sillares de piedra cantería (#363a40)
                    row_idx = (y - 130) // 25
                    col_idx = (x + row_idx * 40) // 60
                    tint = (((row_idx * 11 + col_idx * 19) % 7) - 3) * 3
                    stone_c = arr_f32([48, 52, 58]) + tint
                    # Juntas de mortero
                    if (y - 130) % 25 in [0, 1] or (x + row_idx * 40) % 60 in [0, 1]:
                        stone_c = arr_f32([22, 24, 28])
                        
                # Resplandor de la fragua bañando la mampostería frontal
                dist_fire = math.sqrt(dx*dx + (y - 250)**2)
                glow = max(0.0, 1.0 - dist_fire / 240.0)
                stone_c += arr_f32([glow * 65, glow * 32, glow * 6])
                
                arr[y, x] = [stone_c[0], stone_c[1], stone_c[2], 255]

    # 1.4 Lecho de brasas ardientes e incandescencia interior
    # Centro en cx, Y: 180..295
    for y in range(160, 296):
        for x in range(cx - 120, cx + 121):
            dx = x - cx
            dy = y - 245
            d_norm = math.sqrt((dx / 115.0)**2 + (dy / 55.0)**2)
            
            if d_norm <= 1.0:
                # Mapa de temperatura de la forja
                # Centro inferior es el punto más caliente (aire del fuelle)
                heat_cx = cx + 5
                heat_cy = 255
                d_heat = math.sqrt((x - heat_cx)**2 + (y - heat_cy)**2) / 95.0
                heat = max(0.0, 1.0 - d_heat)
                
                # Turbulencia y fragmentos de carbón
                noise_fire = (math.sin(x * 0.15) * math.cos(y * 0.18) +
                              math.sin(x * 0.35 + y * 0.25) * 0.5)
                heat_val = np.clip(heat + noise_fire * 0.2, 0.0, 1.0)
                
                # Gradiente térmico: Negro carbón -> Rojo brasa -> Naranja -> Amarillo -> Blanco
                if heat_val < 0.25:
                    # Carbón negro en bordes con chispas (#181513 con vetas rojas)
                    c_fire = arr_f32([35, 20, 15]) + heat_val * arr_f32([300, 60, 10])
                elif heat_val < 0.55:
                    # Rojo brasa (#d82b11)
                    t = (heat_val - 0.25) / 0.3
                    c_fire = arr_f32([216, 43, 17]) * (0.8 + 0.2 * t) + arr_f32([30, 40, 0]) * t
                elif heat_val < 0.85:
                    # Naranja forja vivo (#ff7700) a amarillo ascua (#ffcc00)
                    t = (heat_val - 0.55) / 0.3
                    c_fire = arr_f32([255, 119, 0]) * (1.0 - t) + arr_f32([255, 204, 0]) * t
                else:
                    # Blanco ascua incandescente (#fff4cc)
                    t = (heat_val - 0.85) / 0.15
                    c_fire = arr_f32([255, 204, 0]) * (1.0 - t) + arr_f32([255, 244, 204]) * t
                    
                # Trozos individuales de coque / carbón vegetal flotando en la brasa
                if ((x * 13 + y * 29) % 43 < 6) and (heat_val < 0.75):
                    c_fire = arr_f32([25, 20, 18])
                    
                arr[y, x] = [c_fire[0], c_fire[1], c_fire[2], 255]

    # 1.5 Rejilla frontal de hierro forjado (Parrilla del hogar: barras horizontales y verticales)
    # Barras horizontales en Y=265, Y=285
    for bar_y in [265, 285]:
        for y in range(bar_y - 2, bar_y + 3):
            for x in range(cx - 105, cx + 106):
                light = 1.0 if y == bar_y - 2 else (0.5 if y == bar_y + 2 else 0.8)
                arr[y, x] = [40 * light, 42 * light, 48 * light, 255]
                
    # Barras verticales cada 25px
    for bar_x in range(cx - 95, cx + 100, 24):
        for x in range(bar_x - 2, bar_x + 3):
            for y in range(250, 296):
                light = 1.0 if x == bar_x - 2 else (0.5 if x == bar_x + 2 else 0.8)
                arr[y, x] = [42 * light, 45 * light, 50 * light, 255]

    # 1.6 Chispas y ascuas voladoras
    for s_idx in range(45):
        sx = cx + int(np.random.normal(0, 55))
        sy = 150 + int(np.random.uniform(0, 120))
        if 0 <= sx < w and 0 <= sy < h and arr[sy, sx, 3] > 0:
            spark_c = arr_f32([255, 210, 60, 255]) if s_idx % 2 == 0 else arr_f32([255, 120, 20, 255])
            arr[sy, sx] = spark_c
            if 0 <= sx + 1 < w:
                arr[sy, sx + 1] = spark_c * 0.7

    out_img = Image.fromarray(np.clip(arr, 0, 255).astype(np.uint8), "RGBA")
    out_path = os.path.join(WORKSHOP_DIR, "forge_hearth.png")
    out_img.save(out_path)
    print(f"  -> Guardado: {out_path} [{w}x{h}]")

# -------------------------------------------------------------------------
# 2. bellows_tool.png (180x180)
# Fuelle manual de herrería: madera de roble, piel de cuero plegada, remaches y tobera
# -------------------------------------------------------------------------
def generate_bellows_tool():
    print("-> Generando bellows_tool.png (180x180)...")
    size = 180
    arr = np.zeros((size, size, 4), dtype=np.float32)

    cx, cy = 90, 90

    # 2.1 Sombra suave
    for y in range(size):
        for x in range(size):
            dx = (x - cx) / 70.0
            dy = (y - 105) / 28.0
            d_sq = dx*dx + dy*dy
            if d_sq <= 1.0:
                arr[y, x] = [15, 12, 10, (1.0 - d_sq) * 130]

    # Geometría del fuelle (apuntando hacia la derecha):
    # Tobera en X: 140..170, Y: 85..95
    # Cuerpo en forma de pera/gota: de X=45 a X=140
    # Mangos saliendo hacia la izquierda: de X=15 a X=50
    
    # 2.2 Mangos traseros de roble macizo (mango superior e inferior divergentes)
    for (m_y1, m_y2) in [(72, 60), (108, 120)]: # mango superior e inferior
        for t in np.linspace(0, 1, 80):
            mx = 55 - t * 40
            my = m_y1 + t * (m_y2 - m_y1)
            for off in np.linspace(-4, 4, 12):
                px = int(mx)
                py = int(my + off)
                if 0 <= px < size and 0 <= py < size:
                    # Roble torneado (#54371e / #734e2c)
                    light = 0.65 + 0.35 * (1.0 - abs(off) / 4.0)
                    c = arr_f32([105, 68, 38]) * light
                    # Pomo esférico en el extremo
                    if t > 0.85:
                        c += 15
                    arr[py, px] = [c[0], c[1], c[2], 255]

    # 2.3 Fuelle de cuero curtido plegado (#5c371d, #3d210f)
    # Bounded between X: 50..135
    for x in range(50, 136):
        prog = (x - 50) / 85.0 # 0 atrás, 1 adelante
        # Ancho del cuerpo en forma de pera
        hw = 42 * math.sin(prog * 2.6)
        for y in range(int(cy - hw), int(cy + hw) + 1):
            norm_y = (y - cy) / max(1.0, hw)
            
            # Pliegues de fuelle en acordeón a lo largo de X
            fold = math.sin((x - 50) * 0.45) * 14
            # Cuero curtido
            light = 0.55 + 0.45 * (1.0 - abs(norm_y)) + (fold / 14.0) * 0.25
            c = arr_f32([88, 52, 28]) * light
            
            # Sombras en los pliegues profundos
            if fold < -6:
                c *= 0.65
            arr[y, x] = [c[0], c[1], c[2], 255]

    # 2.4 Tabla superior de madera de roble tallada (tapa del fuelle)
    for x in range(50, 136):
        prog = (x - 50) / 85.0
        hw = 36 * math.sin(prog * 2.6)
        for y in range(int(cy - hw * 0.85), int(cy + hw * 0.85) + 1):
            norm_y = (y - cy) / max(1.0, hw * 0.85)
            # Madera de roble con vetas longitudinales
            grain = math.sin(x * 0.15 + norm_y * 3.0) * 5
            light = 0.7 + 0.3 * (1.0 - abs(norm_y))
            c = arr_f32([115, 75, 44]) * light + grain
            
            # Válvula de cuero central circular (en x=85, y=90, radio 12)
            d_valve = math.sqrt((x - 85)**2 + (y - cy)**2)
            if d_valve <= 11:
                c = arr_f32([55, 30, 16]) # Cuero oscuro de la trampilla
                if d_valve in [10, 11]:
                    c = arr_f32([180, 145, 65]) # Remaches de latón de la válvula
                    
            arr[y, x] = [c[0], c[1], c[2], 255]

    # Tachuelas / Remaches perimetrales de latón/bronce (#c49d49)
    for x in range(55, 132, 11):
        prog = (x - 50) / 85.0
        hw = 36 * math.sin(prog * 2.6)
        for y_tack in [int(cy - hw * 0.85), int(cy + hw * 0.85)]:
            for dy in range(-2, 3):
                for dx in range(-2, 3):
                    if dx*dx + dy*dy <= 4:
                        arr[y_tack + dy, x + dx] = [196, 157, 73, 255]

    # 2.5 Tobera cónica de hierro forjado (X: 135..168, Y: 82..98)
    for x in range(135, 169):
        prog = (x - 135) / 33.0
        r_pipe = 8 - prog * 4.5 # cono que se estrecha hacia la punta
        for y in range(int(cy - r_pipe), int(cy + r_pipe) + 1):
            norm_y = (y - cy) / max(1.0, r_pipe)
            # Acero/hierro cilindrico brillante (#555d6b a #1c1e22)
            spec = max(0.0, 1.0 - abs(norm_y + 0.3)) ** 2
            light = 0.5 + 0.5 * spec
            c = arr_f32([55, 62, 72]) * light
            # Punta con hollín
            if x >= 165:
                c = arr_f32([22, 24, 28])
            arr[y, x] = [c[0], c[1], c[2], 255]

    out_img = Image.fromarray(np.clip(arr, 0, 255).astype(np.uint8), "RGBA")
    out_path = os.path.join(WORKSHOP_DIR, "bellows_tool.png")
    out_img.save(out_path)
    print(f"  -> Guardado: {out_path} [{size}x{size}]")

# -------------------------------------------------------------------------
# 3. thermal_gauge.png (220x220)
# Manómetro / termómetro de latón circular con marcas térmicas y aguja de forja
# -------------------------------------------------------------------------
def generate_thermal_gauge():
    print("-> Generando thermal_gauge.png (220x220)...")
    size = 220
    arr = np.zeros((size, size, 4), dtype=np.float32)

    cx, cy = 110, 110
    r_outer = 102
    r_dial = 80

    # 3.1 Sombra circular suave
    for y in range(size):
        for x in range(size):
            d = math.sqrt((x - cx)**2 + (y - (cy + 4))**2)
            if d <= r_outer + 6:
                alpha = max(0.0, 1.0 - (d / (r_outer + 6.0))) * 140
                arr[y, x] = [15, 12, 10, alpha]

    # 3.2 Bisel exterior de latón fundido torneado (d: 80..102)
    for y in range(size):
        for x in range(size):
            d = math.sqrt((x - cx)**2 + (y - cy)**2)
            if d <= r_outer and d > r_dial:
                dx = (x - cx) / float(r_outer)
                dy = (y - cy) / float(r_outer)
                # Reflejo metálico de latón (#a37f37, #c49d49, #6e5421)
                angle = math.atan2(dy, dx)
                spec = (math.cos(angle * 2.0 - 0.8) + 1.0) * 0.5
                light = 0.55 + 0.45 * spec
                
                # Ranuras concéntricas torneadas
                ring = math.sin((d - r_dial) * 1.5) * 15
                c = arr_f32([163, 127, 55]) * light + ring
                
                # Borde biselado interior y exterior
                if d >= r_outer - 2 or d <= r_dial + 2:
                    c = arr_f32([196, 157, 73])
                arr[y, x] = [c[0], c[1], c[2], 255]

    # Tornillos / remaches de montaje en el bisel (4 tornillos a 90°)
    for deg in [0, 90, 180, 270]:
        rad = math.radians(deg)
        tx = cx + int(math.cos(rad) * 91)
        ty = cy + int(math.sin(rad) * 91)
        for dy in range(-3, 4):
            for dx in range(-3, 4):
                if dx*dx + dy*dy <= 9:
                    arr[ty + dy, tx + dx] = [45, 48, 55, 255] if (dx == 0 or dy == 0) else [180, 145, 65, 255]

    # 3.3 Cuadrante interior (Disco de pergamino envejecido / latón claro: d <= 80)
    for y in range(size):
        for x in range(size):
            d = math.sqrt((x - cx)**2 + (y - cy)**2)
            if d <= r_dial:
                # Textura de pergamino / latón esmaltado (#decfae / #cfbd93)
                grain = math.sin(x * 0.2 + y * 0.15) * 3
                c = arr_f32([218, 202, 168]) + grain
                
                # Sombra interior del bisel
                if d >= r_dial - 6:
                    c *= (0.6 + 0.4 * ((r_dial - d) / 6.0))
                arr[y, x] = [c[0], c[1], c[2], 255]

    # 3.4 Arco térmico de graduación de forja
    # Ángulo de 135° (izquierda abajo) a 405° (45° derecha abajo): 270° de barrido
    # Temperaturas: Negro/Frío -> Cereza -> Naranja -> Amarillo -> Blanco
    for deg in range(135, 406):
        rad = math.radians(deg)
        prog = (deg - 135) / 270.0 # 0 frío, 1 máximo
        
        # Color del arco de temperatura
        if prog < 0.25:
            arc_c = arr_f32([45, 52, 60]) # Frío / templado inicial
        elif prog < 0.5:
            arc_c = arr_f32([158, 26, 26]) # Rojo cereza (#9e1a1a)
        elif prog < 0.75:
            arc_c = arr_f32([230, 92, 0])  # Naranja forja (#e65c00)
        elif prog < 0.9:
            arc_c = arr_f32([245, 179, 0]) # Amarillo caldeo (#f5b300)
        else:
            arc_c = arr_f32([255, 240, 170]) # Blanco térmico (#fff0aa)
            
        for r_arc in range(62, 72):
            px = int(cx + math.cos(rad) * r_arc)
            py = int(cy + math.sin(rad) * r_arc)
            arr[py, px] = [arc_c[0], arc_c[1], arc_c[2], 255]

    # Convertir a PIL para trazar marcas graduadas, números romanos y aguja
    img = Image.fromarray(np.clip(arr, 0, 255).astype(np.uint8), "RGBA")
    draw = ImageDraw.Draw(img)

    # Ticks de escala cada 15° y mayores cada 45°
    for deg in range(135, 406, 15):
        rad = math.radians(deg)
        is_major = (deg % 45 == 0)
        r_inner = 54 if is_major else 58
        r_outer_t = 61
        x1 = cx + math.cos(rad) * r_inner
        y1 = cy + math.sin(rad) * r_inner
        x2 = cx + math.cos(rad) * r_outer_t
        y2 = cy + math.sin(rad) * r_outer_t
        draw.line([(x1, y1), (x2, y2)], fill=(40, 32, 24, 255), width=2 if is_major else 1)

    # Marcas y números góticos / romanos (I, II, III, IV, V)
    marks_pos = [
        (cx - 46, cy + 18, "I"),
        (cx - 42, cy - 28, "II"),
        (cx - 6, cy - 46, "III"),
        (cx + 32, cy - 28, "IV"),
        (cx + 38, cy + 18, "V")
    ]
    for mx, my, txt in marks_pos:
        draw.text((mx, my), txt, fill=(50, 38, 26, 230))

    # (La aguja NO se dibuja en la textura base; es controlada dinámicamente en Godot)

    # Perno central de pivote decorativo de latón (radio 9)
    draw.ellipse([cx - 9, cy - 9, cx + 9, cy + 9], fill=(163, 127, 55, 255), outline=(40, 44, 52, 255), width=2)
    draw.ellipse([cx - 4, cy - 4, cx + 4, cy + 4], fill=(210, 175, 90, 255))

    # Reflejo curvo del cristal convexo
    draw.arc([cx - 68, cy - 68, cx + 68, cy + 68], start=200, end=260, fill=(255, 255, 255, 60), width=4)

    out_path = os.path.join(WORKSHOP_DIR, "thermal_gauge.png")
    img.save(out_path)
    print(f"  -> Guardado: {out_path} [Dial limpio sin aguja fija]")

def generate_gauge_needle():
    print("-> Generando gauge_needle.png (24x90)...")
    w, h = 24, 90
    arr = np.zeros((h, w, 4), dtype=np.float32)
    img = Image.fromarray(np.clip(arr, 0, 255).astype(np.uint8), "RGBA")
    draw = ImageDraw.Draw(img)

    cx = 12
    pivot_y = 75 # Punto de rotación
    tip_y = 8    # Punta de la aguja

    # Sombra
    draw.polygon([(cx - 3 + 1, pivot_y + 1), (cx + 1, tip_y + 1), (cx + 3 + 1, pivot_y + 1), (cx + 1, pivot_y + 11)], fill=(15, 12, 10, 120))

    # Aguja de acero forjado afilada
    draw.polygon([(cx - 3, pivot_y), (cx, tip_y), (cx + 3, pivot_y), (cx, pivot_y + 10)], fill=(38, 42, 50, 255))
    # Arista central brillante de acero
    draw.line([(cx, pivot_y + 8), (cx, tip_y + 1)], fill=(90, 102, 120, 255), width=1)

    # Perno circular de latón con remache
    draw.ellipse([cx - 6, pivot_y - 6, cx + 6, pivot_y + 6], fill=(180, 145, 65, 255), outline=(35, 38, 44, 255), width=1)
    draw.ellipse([cx - 3, pivot_y - 3, cx + 3, pivot_y + 3], fill=(225, 190, 105, 255))

    out_path = os.path.join(WORKSHOP_DIR, "gauge_needle.png")
    img.save(out_path)
    print(f"  -> Guardado: {out_path} [{w}x{h}]")

# -------------------------------------------------------------------------
# 4. workshop_room_bg.png (1280x720)
# Fondo de interior de herrería: cantería oscura, vigas de roble, estantes y herramientas
# -------------------------------------------------------------------------
def generate_workshop_room_bg():
    print("-> Generando workshop_room_bg.png (1280x720)...")
    w, h = 1280, 720
    arr = np.zeros((h, w, 3), dtype=np.float32)

    # 4.1 Muros de mampostería de cantería oscura (#2a2d32) (Y: 0..520)
    for y in range(520):
        row_idx = y // 40
        row_offset = (row_idx * 73) % 120
        for x in range(w):
            block_w = 100 + ((row_idx * 29 + (x // 100)) % 25)
            x_in_block = (x + row_offset) % block_w
            y_in_block = y % 40
            
            # Variación tonal de la piedra
            block_id = ((x + row_offset) // block_w) * 19 + row_idx * 37
            tint = ((block_id % 13) - 6) * 2.0
            
            edge_dist = min(x_in_block, block_w - x_in_block, y_in_block, 40 - y_in_block)
            if edge_dist <= 2:
                c = arr_f32([20, 22, 25]) # Mortero
            elif edge_dist <= 5:
                c = arr_f32([42, 45, 50]) + tint - (6 - edge_dist) * 2.5
            else:
                c = arr_f32([42, 45, 50]) + tint
                
            arr[y, x] = c

    # 4.2 Suelo de losas de piedra y ceniza en el tercio inferior (Y: 520..720)
    for y in range(520, h):
        depth_t = (y - 520) / 200.0
        row_idx = (y - 520) // 45
        row_offset = (row_idx * 89) % 150
        for x in range(w):
            block_w = 120
            x_in_block = (x + row_offset) % block_w
            y_in_block = (y - 520) % 45
            edge_d = min(x_in_block, block_w - x_in_block, y_in_block, 45 - y_in_block)
            
            base_floor = arr_f32([35, 38, 42]) * (0.8 + depth_t * 0.3)
            if edge_d <= 2:
                base_floor = arr_f32([18, 19, 22])
            # Tizne de carbón y virutas de hierro
            if ((x * 19 + y * 37) % 211) < 8:
                base_floor *= 0.6
            arr[y, x] = base_floor

    # 4.3 Vigas maestras de roble en el techo (Y: 0..110)
    # Viga transversal principal horizontal en Y: 80..110
    for y in range(80, 111):
        for x in range(w):
            grain = math.sin(x * 0.05 + y * 0.2) * 4
            c = arr_f32([52, 34, 20]) + grain
            if y == 80 or y == 110:
                c = arr_f32([25, 16, 9]) # arista
            arr[y, x] = c
            
    # Vigas de soporte en perspectiva cada 220px
    for bx in range(80, w, 220):
        for x in range(bx - 14, bx + 15):
            norm_x = (x - bx) / 14.0
            for y in range(0, 80):
                c = arr_f32([48, 30, 18]) * (0.7 + 0.3 * (1.0 - abs(norm_x)))
                arr[y, x] = c

    # 4.4 Estantería de forja con herramientas colgadas (Y: 220..380)
    # Tablón de la estantería en Y: 260..275 (X: 180..1100)
    for y in range(260, 276):
        for x in range(180, 1101):
            c = arr_f32([65, 42, 24])
            if y == 260:
                c += 15 # bisel luz superior
            elif y == 275:
                c = arr_f32([22, 14, 8]) # sombra inferior
            arr[y, x] = c

    # Ménsulas de forja de sujeción bajo el estante cada 200px
    for mx in range(240, 1060, 200):
        for y in range(276, 320):
            prog = (y - 276) / 44.0
            w_bracket = int(8 * (1.0 - prog))
            for x in range(mx - w_bracket, mx + w_bracket + 1):
                arr[y, x] = [32, 35, 40]

    # Convertir a PIL para pintar siluetas de herramientas en penumbra en la pared y estante
    img = Image.fromarray(np.clip(arr, 0, 255).astype(np.uint8), "RGB")
    draw = ImageDraw.Draw(img)

    # Herramientas sobre el estante (tarros de fundente, piedras de afilar, punzones)
    # Bloques de piedra de afilar sobre el estante
    draw.rectangle([310, 246, 370, 260], fill=(85, 90, 85), outline=(40, 42, 40))
    draw.rectangle([620, 242, 690, 260], fill=(75, 80, 75), outline=(35, 38, 35))
    draw.rectangle([880, 248, 930, 260], fill=(120, 95, 45), outline=(50, 40, 20)) # Crisol de latón

    # Tenazas de forja (tongs) colgadas en la pared bajo el estante (Y: 280..420)
    # Tenaza 1 en X=410
    draw.line([(410, 275), (405, 380)], fill=(32, 35, 40), width=4)
    draw.line([(410, 275), (415, 375)], fill=(32, 35, 40), width=4)
    draw.ellipse([407, 285, 413, 291], fill=(140, 110, 48)) # Remache
    draw.arc([404, 270, 416, 285], start=0, end=180, fill=(35, 38, 44), width=3) # Mandíbulas

    # Tenaza 2 en X=560
    draw.line([(560, 275), (554, 400)], fill=(30, 32, 38), width=4)
    draw.line([(560, 275), (566, 395)], fill=(30, 32, 38), width=4)
    draw.ellipse([557, 287, 563, 293], fill=(140, 110, 48))

    # Martillo de mano colgado en X=730
    draw.line([(730, 275), (730, 370)], fill=(85, 55, 30), width=5) # Mango madera
    draw.rectangle([718, 285, 742, 300], fill=(45, 50, 58)) # Cabeza

    # Cadena de hierro forjado colgada en X=860
    for cy_chain in range(275, 420, 12):
        draw.ellipse([857, cy_chain, 863, cy_chain + 10], outline=(40, 44, 50), width=2)

    # 4.5 Resplandor ambiental de la fragua (iluminación lateral cálida desde la izquierda X=-50, Y=380)
    arr_final = np.array(img, dtype=np.float32)
    for y in range(h):
        for x in range(w):
            d_forge = math.sqrt((x + 50)**2 + (y - 380)**2)
            glow = max(0.0, 1.0 - d_forge / 880.0)
            # Ámbar vivo y calidez de fuego
            arr_final[y, x, 0] += glow * 55
            arr_final[y, x, 1] += glow * 28
            arr_final[y, x, 2] += glow * 8

    arr_final = add_noise(arr_final, intensity=3.5)
    out_img = Image.fromarray(np.clip(arr_final, 0, 255).astype(np.uint8), "RGB")
    out_path = os.path.join(WORKSHOP_DIR, "workshop_room_bg.png")
    out_img.save(out_path)
    print(f"  -> Guardado: {out_path} [{w}x{h}]")

# -------------------------------------------------------------------------
# Ejecución General
# -------------------------------------------------------------------------
def main():
    print("================================================================")
    print(" INICIANDO GENERACIÓN DE 4 NUEVOS ASSETS DEL TALLER Y FORJA")
    print("================================================================")
    
    generate_forge_hearth()
    generate_bellows_tool()
    generate_thermal_gauge()
    generate_gauge_needle()
    generate_workshop_room_bg()
    
    print("================================================================")
    print(" LOS 5 ASSETS DEL TALLER FUERON GENERADOS EXITOSAMENTE")
    print("================================================================")

if __name__ == "__main__":
    main()
