#!/usr/bin/env python3
"""
Generador de Assets Gráficos Históricos y Realistas de Herrería Medieval
para 'Yunque & Sombra'.

Paleta Realista de Herrería Histórica:
- Maderas: Roble envejecido, nogal, tablas gastadas (#2b1a0d, #3d2614, #54371e, #734e2c)
- Metales fríos: Hierro forjado negro, acero al carbono, brillos satinados (#1c1e22, #32363e, #555d6b, #9aa3b2, #d4dbe6)
- Metales calientes: Fuego vivo incandescente (rojo brasa #d82b11, naranja fuego #ff7700, amarillo eléctrico #ffcc00, blanco ascua #fff4cc)
- Piedras y muros: Mampostería de granito, pizarra y mortero (#22252a, #2e3136, #454a52, #68707c)
- Bronce y latón: Bronce gastado con pátina natural (#6e5421, #a37f37, #c49d49)
- Pergamino y cueros: Pergamino de oveja natural envejecido (#e8dcbc, #cfbd93) y cuero curtido (#5c371d)
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

# Directorios de destino
BASE_DIR = _get_project_root()
SPRITES_DIR = os.path.join(BASE_DIR, "assets", "sprites")

DIRS = [
    os.path.join(SPRITES_DIR, "ui"),
    os.path.join(SPRITES_DIR, "characters"),
    os.path.join(SPRITES_DIR, "workshop"),
    os.path.join(SPRITES_DIR, "items"),
    os.path.join(SPRITES_DIR, "environment"),
]

for d in DIRS:
    os.makedirs(d, exist_ok=True)

np.random.seed(42)

def clamp(val, min_val=0, max_val=255):
    return int(max(min_val, min(max_val, val)))

def hex_to_rgb(hex_str):
    hex_str = hex_str.lstrip('#')
    return tuple(int(hex_str[i:i+2], 16) for i in (0, 2, 4))

def add_gaussian_noise(img_arr, intensity=10):
    noise = np.random.normal(0, intensity, img_arr.shape[:2])
    res = img_arr.astype(np.float32)
    for c in range(3):
        res[:, :, c] += noise
    return np.clip(res, 0, 255).astype(np.uint8)

# -------------------------------------------------------------------------
# 1. assets/sprites/ui/workshop_counter_bg.png (1280x720)
# -------------------------------------------------------------------------
def generate_workshop_counter_bg():
    print("-> Generando workshop_counter_bg.png (1280x720)...")
    w, h = 1280, 720
    img = Image.new("RGB", (w, h), (0, 0, 0))
    draw = ImageDraw.Draw(img)

    # 1.1 Muro de piedra de fondo (Y: 0..480)
    wall_arr = np.zeros((480, w, 3), dtype=np.float32)
    base_stone = np.array([44, 48, 54], dtype=np.float32) # #2c3036
    
    # Bloques de mampostería
    row_h = 36
    for y in range(480):
        row_idx = y // row_h
        y_in_block = y % row_h
        row_offset = (row_idx * 67) % 110
        for x in range(w):
            block_w = 90 + ((row_idx * 31 + (x // 90)) % 30)
            x_in_block = (x + row_offset) % block_w
            
            # Variación tonal por bloque
            block_id = ((x + row_offset) // block_w) * 17 + row_idx * 43
            tint = ((block_id % 19) - 9) * 1.5
            
            # Relieve de bordes de mortero
            edge_dist = min(x_in_block, block_w - x_in_block, y_in_block, row_h - y_in_block)
            if edge_dist <= 2:
                # Línea de mortero oscuro
                c = np.array([22, 24, 28], dtype=np.float32)
            elif edge_dist <= 5:
                # Bisel de la piedra
                c = base_stone + tint - (6 - edge_dist) * 3
            else:
                c = base_stone + tint
                
            wall_arr[y, x] = c

    # 1.2 Gran Arco de Ventana Central
    # Centro en X=640, base en Y=460, ancho 480, altura arco 360
    arch_cx, arch_base_y = 640, 460
    arch_w, arch_h = 440, 360
    arch_rx = arch_w // 2
    arch_ry = arch_h - 100

    for y in range(480):
        for x in range(w):
            dx = x - arch_cx
            # Comprobar si está dentro de la ventana
            inside_window = False
            border_voussoir = False
            
            if y >= (arch_base_y - arch_h + arch_ry): # Tramo recto inferior
                dist_x = abs(dx)
                if dist_x < arch_rx:
                    inside_window = True
                elif dist_x <= arch_rx + 32:
                    border_voussoir = True
            else: # Bóveda superior
                dy = y - (arch_base_y - arch_h + arch_ry)
                if dy <= 0:
                    rad_dist = math.sqrt((dx / arch_rx)**2 + (dy / arch_ry)**2)
                    if rad_dist < 1.0:
                        inside_window = True
                    elif rad_dist <= 1.0 + (32.0 / arch_rx):
                        border_voussoir = True
            
            if inside_window:
                # Cielo crepuscular frío medieval y siluetas del pueblo
                sky_factor = y / 460.0
                # Cielo nocturno brumoso
                sky_c = np.array([14, 18, 25], dtype=np.float32) * (1.0 - sky_factor * 0.4) + np.array([28, 30, 36], dtype=np.float32) * (sky_factor * 0.4)
                
                # Siluetas de tejados del pueblo en la parte inferior de la ventana (Y: 340..460)
                if y > 330:
                    # Perfil de tejados y chimenea
                    roof_h = 40 * math.sin((x - 420) * 0.035) + 25 * math.cos((x - 420) * 0.08)
                    # Aguja de iglesia en X=610
                    if 595 <= x <= 625:
                        steeple_tip = 320 + abs(x - 610) * 3.0
                        if y >= steeple_tip:
                            sky_c = np.array([10, 11, 14], dtype=np.float32)
                    elif y >= 400 - roof_h:
                        sky_c = np.array([12, 13, 16], dtype=np.float32)
                
                # Reja de hierro forjado en cruz gótica
                if abs(dx) <= 4 or abs(y - 280) <= 4 or abs(y - 380) <= 4 or (inside_window and abs(abs(dx) - 110) <= 3):
                    sky_c = np.array([20, 22, 26], dtype=np.float32)
                    
                wall_arr[y, x] = sky_c
            elif border_voussoir:
                # Dovelas de piedra tallada del arco (#454a52 / #352a22)
                angle = math.atan2(y - 200, dx)
                dovela_id = int((angle + math.pi) * 8)
                dov_tint = ((dovela_id % 7) - 3) * 3
                wall_arr[y, x] = np.array([55, 52, 48], dtype=np.float32) + dov_tint

    # Iluminación cálida de la forja (resplandor desde la izquierda X: -100, Y: 300)
    for y in range(480):
        for x in range(w):
            dist_forge = math.sqrt((x + 100)**2 + (y - 300)**2)
            glow = max(0.0, 1.0 - dist_forge / 850.0)
            # Tinte ámbar / fuego vivo #d82b11, #ff7700
            wall_arr[y, x, 0] += glow * 45
            wall_arr[y, x, 1] += glow * 22
            wall_arr[y, x, 2] += glow * 6

    # 1.3 Mostrador de Madera Maciza Envejecida (Y: 460..720)
    counter_arr = np.zeros((260, w, 3), dtype=np.float32)
    # Tapa superior biselada del mostrador (Y: 460..510 en coord globales -> 0..50 local)
    for y in range(50):
        depth_t = y / 50.0
        # Vetas horizontales de roble (#54371e a #3d2614)
        for x in range(w):
            grain = math.sin(x * 0.05 + y * 0.2) * 5 + math.sin(x * 0.012) * 8
            # Base roble con perspectiva
            c = np.array([65, 42, 24], dtype=np.float32) * (0.85 + depth_t * 0.3) + grain
            # Manchas y quemaduras de forja ocasionales
            if ((x * 13 + y * 7) % 317) < 5:
                c = c * 0.55
            counter_arr[y, x] = c
            
    # Borde de bisel con filo resaltado (y=49..51)
    counter_arr[48:51, :, :] = np.array([115, 78, 44], dtype=np.float32)

    # Faldón frontal del mostrador (Y: 510..720 -> 50..260 local)
    for y in range(50, 260):
        local_y = y - 50
        # Tablas verticales de roble macizo
        plank_w = 160
        for x in range(w):
            plank_idx = x // plank_w
            x_in_plank = x % plank_w
            plank_tint = ((plank_idx * 17) % 7 - 3) * 4
            
            # Veta vertical
            wood_grain = math.sin(local_y * 0.04 + math.sin(x * 0.02) * 3) * 6 + math.cos(local_y * 0.1) * 3
            c = np.array([50, 32, 18], dtype=np.float32) + plank_tint + wood_grain
            
            # Sombra superior bajo el vuelo del mostrador
            if local_y < 16:
                c = c * (0.4 + 0.6 * (local_y / 16.0))
                
            # Juntas oscuras entre tablas
            if x_in_plank <= 3 or x_in_plank >= plank_w - 3:
                c = np.array([20, 12, 7], dtype=np.float32)
                
            counter_arr[y, x] = c

    # Flejes de refuerzo de hierro forjado con remaches
    # Fleje superior horizontal (local y: 65..80) y fleje inferior (local y: 220..235)
    for band_y in [65, 220]:
        for y in range(band_y, band_y + 16):
            for x in range(w):
                # Hierro forjado #2c2f35
                iron_c = np.array([38, 42, 48], dtype=np.float32)
                if y == band_y or y == band_y + 15:
                    iron_c += 15 # bisel
                counter_arr[y, x] = iron_c

        # Remaches forjados cada 120px
        for riv_x in range(60, w, 120):
            for dy in range(-5, 6):
                for dx in range(-5, 6):
                    if dx*dx + dy*dy <= 25:
                        c_riv = np.array([75, 82, 92], dtype=np.float32) if (dx < 0 or dy < 0) else np.array([22, 24, 28], dtype=np.float32)
                        counter_arr[band_y + 8 + dy, riv_x + dx] = c_riv

    # Ensamblar imagen completa
    full_arr = np.vstack([wall_arr[:460], counter_arr])
    full_arr = add_gaussian_noise(full_arr, intensity=4)
    
    out_img = Image.fromarray(np.clip(full_arr, 0, 255).astype(np.uint8))
    out_path = os.path.join(SPRITES_DIR, "ui", "workshop_counter_bg.png")
    out_img.save(out_path)
    print(f"  -> Guardado: {out_path} [{w}x{h}]")

# -------------------------------------------------------------------------
# 2. assets/sprites/ui/service_bell.png (128x128)
# -------------------------------------------------------------------------
def generate_service_bell():
    print("-> Generando service_bell.png (128x128)...")
    size = 128
    img = Image.new("RGBA", (size, size), (0, 0, 0, 0))
    arr = np.zeros((size, size, 4), dtype=np.float32)

    cx, cy = 64, 76

    # 2.1 Sombra proyectada en la base
    for y in range(size):
        for x in range(size):
            dx = (x - cx) / 52.0
            dy = (y - 114) / 10.0
            dist_sq = dx*dx + dy*dy
            if dist_sq <= 1.0:
                shadow_alpha = (1.0 - dist_sq) * 160
                arr[y, x] = [15, 12, 10, shadow_alpha]

    # 2.2 Base de madera de nogal torneada (Y: 96..114)
    for y in range(96, 115):
        h_ratio = (y - 96) / 18.0
        r_step = 46 - 4 * (1.0 - h_ratio)
        for x in range(size):
            dx = x - cx
            if abs(dx) <= r_step:
                norm_x = dx / r_step
                wood_val = np.array([55, 34, 18], dtype=np.float32) # #372212
                # Vetas y reflejo cilíndrico
                light = 0.7 + 0.35 * (1.0 - norm_x**2) - 0.2 * norm_x
                c = wood_val * light
                if y in [96, 104, 114]:
                    c += 20 # anillas torneadas
                arr[y, x] = [c[0], c[1], c[2], 255]

    # 2.3 Cúpula de campana de bronce forjado
    # Centro cúpula: Y: 46..96, radio base 38, radio superior redondeado
    for y in range(46, 97):
        prog = (y - 46) / 50.0 # 0 arriba, 1 base
        # Perfil de campana acampanada clásica
        r_current = 14 + 24 * (prog**1.3)
        for x in range(size):
            dx = x - cx
            if abs(dx) <= r_current:
                norm_x = dx / r_current
                dy = (y - 46) / 50.0
                
                # Sombreado metálico esférico/cónico
                # Luz principal desde arriba-izquierda (norm_x ~ -0.4, dy ~ 0.3)
                specular = max(0.0, 1.0 - math.sqrt((norm_x + 0.35)**2 + (dy - 0.25)**2) * 2.2)
                specular_sharp = specular ** 8
                
                # Gradiente de bronce histórico
                # #a37f37 base, #c49d49 luz, #5a411a sombra profunda
                light = 0.5 + 0.5 * (1.0 - norm_x) + specular * 0.4
                bronze_base = np.array([163, 127, 55], dtype=np.float32)
                c = bronze_base * light + specular_sharp * np.array([255, 244, 204], dtype=np.float32)
                
                # Surcos de torno decorativos
                if y in [68, 70, 92, 94]:
                    c = c * 0.75
                # Labio inferior resaltado
                if y >= 95:
                    c = np.array([196, 157, 73], dtype=np.float32)
                    
                arr[y, x] = [c[0], c[1], c[2], 255]

    # 2.4 Perno superior y pulsador de bronce
    # Vástago central (Y: 28..46, X: 61..67)
    for y in range(28, 47):
        for x in range(61, 68):
            dx = (x - cx) / 3.0
            light = 0.6 + 0.4 * (1.0 - dx)
            c = np.array([140, 110, 48], dtype=np.float32) * light
            arr[y, x] = [c[0], c[1], c[2], 255]
            
    # Botón/Pomo pulsador superior (esfera en 64, 26, radio 7)
    for y in range(19, 33):
        for x in range(57, 72):
            dx = x - cx
            dy = y - 26
            dist = math.sqrt(dx*dx + dy*dy)
            if dist <= 6.5:
                norm_d = dist / 6.5
                spec = max(0.0, 1.0 - math.sqrt((dx + 2)**2 + (dy + 2)**2) / 4.0) ** 4
                c = np.array([170, 135, 60], dtype=np.float32) * (1.0 - norm_d * 0.4) + spec * np.array([255, 240, 190], dtype=np.float32)
                arr[y, x] = [c[0], c[1], c[2], 255]

    arr = np.clip(arr, 0, 255).astype(np.uint8)
    out_img = Image.fromarray(arr, "RGBA")
    out_path = os.path.join(SPRITES_DIR, "ui", "service_bell.png")
    out_img.save(out_path)
    print(f"  -> Guardado: {out_path} [{size}x{size}]")

# -------------------------------------------------------------------------
# 3. assets/sprites/ui/order_parchment.png (400x500)
# -------------------------------------------------------------------------
def generate_order_parchment():
    print("-> Generando order_parchment.png (400x500)...")
    w, h = 400, 500
    arr = np.zeros((h, w, 4), dtype=np.float32)

    # 3.1 Sombra suave proyectada detrás del pergamino
    for y in range(h):
        for x in range(w):
            if 35 <= x <= 375 and 35 <= y <= 475:
                dx = min(x - 35, 375 - x)
                dy = min(y - 35, 475 - y)
                edge = min(dx, dy)
                if edge < 25:
                    arr[y, x] = [15, 12, 10, (edge / 25.0) * 110]
                else:
                    arr[y, x] = [15, 12, 10, 110]

    # 3.2 Lámina de pergamino de piel de oveja envejecida
    # Bordes irregulares con ruido orgánico
    bx_min, bx_max = 40, 360
    by_min, by_max = 30, 460

    for y in range(h):
        for x in range(w):
            # Deformación de borde con armónicos
            edge_noise = (
                math.sin(y * 0.08) * 4 + math.sin(x * 0.09) * 3 +
                math.cos(y * 0.25) * 2 + math.cos(x * 0.22) * 2
            )
            in_x = (bx_min + edge_noise <= x <= bx_max - edge_noise)
            in_y = (by_min + edge_noise <= y <= by_max - edge_noise)
            
            if in_x and in_y:
                # Distancia al borde exterior para quemaduras y desgaste
                dist_to_edge = min(
                    x - (bx_min + edge_noise),
                    (bx_max - edge_noise) - x,
                    y - (by_min + edge_noise),
                    (by_max - edge_noise) - y
                )
                
                # Tono base: piel de oveja natural envejecida (#e8dcbc y #cfbd93)
                grain = math.sin(x * 0.2 + y * 0.15) * 4 + math.sin(x * 0.05) * 6
                # Textura de fibras
                fiber = (np.random.rand() - 0.5) * 8
                
                base_parchment = np.array([232, 220, 188], dtype=np.float32) + grain + fiber
                
                # Manchas de té/tiempo y tizne de carbón
                stain = math.sin(x * 0.02) * math.cos(y * 0.025) * 15
                base_parchment += np.array([stain, stain * 0.8, stain * 0.5], dtype=np.float32)
                
                # Borde quemado / tostado (#5c371d / #2b1a0d)
                if dist_to_edge < 18:
                    burn_factor = 1.0 - (dist_to_edge / 18.0)
                    burn_color = np.array([60, 35, 18], dtype=np.float32)
                    base_parchment = base_parchment * (1.0 - burn_factor) + burn_color * burn_factor
                    
                arr[y, x] = [base_parchment[0], base_parchment[1], base_parchment[2], 255]

    # Convertir a PIL para dibujar bordes y sello de lacre artesanal
    img = Image.fromarray(np.clip(arr, 0, 255).astype(np.uint8), "RGBA")
    draw = ImageDraw.Draw(img)

    # 3.3 Marco sutil de encabezado en tinta sepia suave (#3d2b1f con baja opacidad)
    ink_header = (60, 45, 30, 90)
    draw.line([(60, 60), (340, 60)], fill=ink_header, width=1)
    draw.line([(80, 64), (320, 64)], fill=ink_header, width=1)

    # 3.5 Sello de lacre rojo oscuro de herrería (#6d1f1b / #421210)
    seal_cx, seal_cy = 280, 410
    seal_r = 34
    for dy in range(-seal_r - 6, seal_r + 7):
        for dx in range(-seal_r - 6, seal_r + 7):
            d = math.sqrt(dx*dx + dy*dy)
            # Reborde irregular de cera derretida
            wobble = math.sin(math.atan2(dy, dx) * 6) * 3
            if d <= seal_r + wobble:
                edge_factor = (seal_r + wobble - d) / 8.0
                if d > seal_r - 6:
                    # Borde en relieve del sello
                    c_wax = (110, 31, 27, 255) # #6e1f1b
                else:
                    # Fondo de la matriz estampada
                    c_wax = (66, 18, 16, 255)  # #421210
                img.putpixel((seal_cx + dx, seal_cy + dy), c_wax)

    # Escudo estampado en el sello (martillo cruzado y yunque)
    draw.line([(seal_cx - 14, seal_cy + 10), (seal_cx + 14, seal_cy - 10)], fill=(135, 45, 38), width=3)
    draw.rectangle([seal_cx + 8, seal_cy - 16, seal_cx + 18, seal_cy - 8], fill=(135, 45, 38))
    draw.rectangle([seal_cx - 12, seal_cy + 4, seal_cx + 4, seal_cy + 14], fill=(135, 45, 38))

    out_path = os.path.join(SPRITES_DIR, "ui", "order_parchment.png")
    img.save(out_path)
    print(f"  -> Guardado: {out_path} [{w}x{h}]")

# -------------------------------------------------------------------------
# 4. assets/sprites/characters/sergeant_portrait.png (256x256)
# -------------------------------------------------------------------------
def generate_sergeant_portrait():
    print("-> Generando sergeant_portrait.png (256x256)...")
    size = 256
    img = Image.new("RGBA", (size, size), (0, 0, 0, 255))
    draw = ImageDraw.Draw(img)

    # 4.1 Fondo de armería de piedra oscura con tenue luz de antorcha
    arr = np.zeros((size, size, 3), dtype=np.float32)
    for y in range(size):
        for x in range(size):
            # Muro de mampostería oscura
            base = np.array([30, 33, 38], dtype=np.float32)
            # Resplandor de antorcha desde la izquierda
            torch = max(0.0, 1.0 - math.sqrt(x**2 + (y - 80)**2) / 220.0) * 40
            arr[y, x] = base + np.array([torch * 1.2, torch * 0.6, torch * 0.1], dtype=np.float32)
    
    img_bg = Image.fromarray(np.clip(arr, 0, 255).astype(np.uint8))
    img.paste(img_bg, (0, 0))

    # 4.2 Torso / Cota de Malla y Jubón de Cuero
    # Hombros y cuello (Y: 160..240)
    for y in range(160, 256):
        prog = (y - 160) / 96.0
        hw = 40 + int(prog * 85)
        for x in range(128 - hw, 128 + hw):
            # Anillas de cota de malla (#32363e con brillo metálico)
            mail_ring = ((x % 6 - 3)**2 + (y % 6 - 3)**2)
            if mail_ring < 5:
                c = (75, 82, 95) if (x < 128) else (35, 38, 44)
            else:
                c = (42, 46, 54)
            img.putpixel((x, y), c)

    # Cuello / Gambesón de cuero oscuro (#5c371d)
    draw.polygon([(100, 175), (156, 175), (145, 215), (111, 215)], fill=(65, 38, 22))

    # 4.3 Rostro del Sargento (Piel curtida, mentón recio, bigote)
    # Mandíbula y mejillas (Y: 110..175, X: 95..161)
    face_tones = np.zeros((65, 66, 3), dtype=np.uint8)
    for fy in range(65):
        y_abs = 110 + fy
        for fx in range(66):
            x_abs = 95 + fx
            dx = (fx - 33) / 33.0
            dy = (fy - 25) / 35.0
            if dx*dx + dy*dy <= 1.0:
                # Tono piel militar curtida (#b58965 y sombra #876246)
                light = 0.6 + 0.4 * (1.0 - dx * 0.8)
                c = np.array([181, 137, 101], dtype=np.float32) * light
                img.putpixel((x_abs, y_abs), tuple(c.astype(int)))

    # Ojos penetrantes bajo la sombra del yelmo
    # Ojo izquierdo (X: 112, Y: 122), Ojo derecho (X: 144, Y: 122)
    draw.rectangle([107, 120, 118, 124], fill=(30, 25, 22))
    draw.rectangle([138, 120, 149, 124], fill=(30, 25, 22))
    draw.point((113, 122), fill=(180, 195, 210)) # Brillo acerado
    draw.point((144, 122), fill=(180, 195, 210))

    # Bigote militar espeso y canoso (Y: 138..156, X: 104..152)
    for y in range(138, 156):
        prog = (y - 138) / 18.0
        w_mustache = int(22 * (1.0 - prog * 0.3))
        for x in range(128 - w_mustache, 128 + w_mustache):
            stray = (x * 7 + y * 13) % 5
            c = (90, 85, 80) if stray == 0 else (55, 45, 38)
            img.putpixel((x, y), c)

    # 4.4 Yelmo Normando Cónico de Acero Forjado
    # Centro en 128, punta cónica en Y=32, base cejas en Y=115
    for y in range(32, 116):
        prog = (y - 32) / 84.0 # 0 arriba, 1 base
        r_helm = int(8 + 48 * (prog ** 0.85))
        for x in range(128 - r_helm, 128 + r_helm + 1):
            dx = (x - 128) / float(r_helm)
            # Reflejo especular satinado en X ~ -0.3
            spec = max(0.0, 1.0 - abs(dx + 0.35) * 2.5) ** 4
            # Acero templado (#32363e base, #555d6b luz)
            light = 0.5 + 0.45 * (1.0 - dx) + spec * 0.7
            c = np.array([55, 62, 72], dtype=np.float32) * light
            img.putpixel((x, y), tuple(np.clip(c, 0, 255).astype(int)))

    # Cresta central del yelmo
    draw.line([(128, 32), (128, 115)], fill=(120, 130, 145), width=3)
    draw.line([(127, 32), (127, 115)], fill=(30, 32, 38), width=1)

    # Banda de refuerzo de bronce remachada en la base del yelmo (Y: 108..116)
    draw.rectangle([78, 108, 178, 115], fill=(163, 127, 55))
    # Remaches dorados
    for rx in range(86, 176, 14):
        draw.ellipse([rx - 2, 110, rx + 2, 114], fill=(210, 175, 90), outline=(50, 40, 20))

    # Nasal de hierro forjado que baja protegiendo la nariz (X: 124..132, Y: 115..142)
    draw.polygon([(123, 115), (133, 115), (131, 142), (125, 142)], fill=(45, 50, 58))
    draw.line([(124, 115), (126, 142)], fill=(110, 120, 135), width=1) # Brillo borde

    # 4.5 Marco de retrato de bronce y roble oscuro
    for d in range(10):
        c_frame = (163, 127, 55) if d in [2, 7] else ((43, 26, 13) if d < 6 else (25, 27, 30))
        draw.rectangle([d, d, 255 - d, 255 - d], outline=c_frame)

    out_path = os.path.join(SPRITES_DIR, "characters", "sergeant_portrait.png")
    img.save(out_path)
    print(f"  -> Guardado: {out_path} [{size}x{size}]")

# -------------------------------------------------------------------------
# 5. assets/sprites/characters/peasant_portrait.png (256x256)
# -------------------------------------------------------------------------
def generate_peasant_portrait():
    print("-> Generando peasant_portrait.png (256x256)...")
    size = 256
    img = Image.new("RGBA", (size, size), (0, 0, 0, 255))
    draw = ImageDraw.Draw(img)

    # 5.1 Fondo del interior del molino (Vigas de madera y atmósfera de polvo de grano)
    arr = np.zeros((size, size, 3), dtype=np.float32)
    for y in range(size):
        for x in range(size):
            # Muros de madera de roble (#3d2614)
            beam = math.sin(x * 0.04) * 8
            base = np.array([45, 30, 18], dtype=np.float32) + beam
            # Polvo en suspensión
            dust = (np.random.rand() - 0.5) * 6
            arr[y, x] = base + dust
    
    img_bg = Image.fromarray(np.clip(arr, 0, 255).astype(np.uint8))
    img.paste(img_bg, (0, 0))

    # 5.2 Ropaje / Blusón de lino pardo campesino (Y: 170..256)
    for y in range(170, 256):
        prog = (y - 170) / 86.0
        hw = 36 + int(prog * 88)
        for x in range(128 - hw, 128 + hw):
            # Trama de tejido de estameña/lino rústico (#5a4638)
            weave = ((x % 3 == 0) ^ (y % 3 == 0)) * 8
            c = np.array([85, 68, 52], dtype=np.float32) + weave
            # Polvillo blanco de harina en los hombros
            if y < 205 and ((x * 19 + y * 23) % 17 < 5):
                c += np.array([60, 60, 55], dtype=np.float32)
            img.putpixel((x, y), tuple(np.clip(c, 0, 255).astype(int)))

    # 5.3 Rostro de Eustaquio el Molinero (Arrugas, tez curtida, mirada astuta)
    # Cara (Y: 95..165, X: 96..160)
    for y in range(95, 166):
        for x in range(96, 161):
            dx = (x - 128) / 32.0
            dy = (y - 130) / 35.0
            if dx*dx + dy*dy <= 1.0:
                # Piel tostada por el sol (#9c7857)
                light = 0.65 + 0.35 * (1.0 - dx * 0.7)
                c = np.array([168, 128, 92], dtype=np.float32) * light
                # Arrugas / patas de gallo
                if (y in [112, 114, 126, 140]) and (abs(dx) > 0.4):
                    c = c * 0.8
                img.putpixel((x, y), tuple(c.astype(int)))

    # Ojos atentos y prudentes de campesino
    draw.ellipse([108, 118, 119, 124], fill=(40, 30, 25))
    draw.ellipse([137, 118, 148, 124], fill=(40, 30, 25))
    draw.point((113, 120), fill=(210, 195, 180))
    draw.point((142, 120), fill=(210, 195, 180))

    # Nariz ancha campesina
    draw.polygon([(126, 120), (131, 120), (133, 138), (124, 138)], fill=(155, 112, 78))

    # Barba y bigote de varios días, descuidada con canas (Y: 136..175)
    for y in range(136, 175):
        w_beard = int(26 * (1.0 - ((y - 136) / 40.0) * 0.4))
        for x in range(128 - w_beard, 128 + w_beard):
            if np.random.rand() > 0.2:
                grain = np.random.choice([60, 80, 110]) # hebras castañas y canas
                c = (grain, int(grain * 0.85), int(grain * 0.7))
                img.putpixel((x, y), c)

    # 5.4 Capucha rústica de lana gruesa en tinte madder terroso (#452a1b)
    # Envuelve la cabeza desde Y=40 hasta los hombros en Y=180
    for y in range(40, 180):
        prog = (y - 40) / 140.0
        r_outer = 40 + int(36 * (prog ** 0.8))
        r_inner = max(0, int(r_outer - 18 - 8 * math.sin(prog * 3.14)))
        for x in range(128 - r_outer, 128 + r_outer + 1):
            dx = abs(x - 128)
            # Hueco de la cara en el centro (Y: 90..165)
            if 85 <= y <= 165 and dx < 33:
                continue
            
            # Tejido de la capucha
            fold = math.sin((x + y) * 0.12) * 12
            light = 0.6 + 0.4 * (1.0 - (x - 128) / float(r_outer))
            c = (np.array([68, 42, 27], dtype=np.float32) + fold) * light
            
            # Polvillo de harina sobre la capucha
            if y < 80 and ((x * 31 + y * 17) % 19 < 4):
                c += np.array([70, 70, 65], dtype=np.float32)
                
            img.putpixel((x, y), tuple(np.clip(c, 0, 255).astype(int)))

    # 5.5 Marco de madera rústica con clavos de hierro
    for d in range(10):
        c_frame = (58, 38, 20) if d < 7 else (28, 18, 10)
        draw.rectangle([d, d, 255 - d, 255 - d], outline=c_frame)
    # Clavos en las esquinas
    for cx_c, cy_c in [(14, 14), (241, 14), (14, 241), (241, 241)]:
        draw.rectangle([cx_c - 3, cy_c - 3, cx_c + 3, cy_c + 3], fill=(30, 32, 36))

    out_path = os.path.join(SPRITES_DIR, "characters", "peasant_portrait.png")
    img.save(out_path)
    print(f"  -> Guardado: {out_path} [{size}x{size}]")

# -------------------------------------------------------------------------
# 6. assets/sprites/workshop/anvil_topdown.png (400x240)
# -------------------------------------------------------------------------
def generate_anvil_topdown():
    print("-> Generando anvil_topdown.png (400x240)...")
    w, h = 400, 240
    arr = np.zeros((h, w, 4), dtype=np.float32)

    cx, cy = 200, 120

    # 6.1 Sombra profunda proyectada sobre el suelo
    for y in range(h):
        for x in range(w):
            dx = (x - cx) / 165.0
            dy = (y - (cy + 10)) / 65.0
            dist_sq = dx*dx + dy*dy
            if dist_sq <= 1.0:
                alpha = (1.0 - dist_sq) * 170
                arr[y, x] = [15, 12, 10, alpha]

    # 6.2 Cepo de Roble (Base de tronco que asoma por debajo del yunque)
    for y in range(cy - 50, cy + 55):
        for x in range(cx - 145, cx + 145):
            dx = (x - cx) / 140.0
            dy = (y - cy) / 50.0
            if dx*dx + dy*dy <= 1.0:
                # Madera oscura de roble macizo (#3d2614 / #2b1a0d)
                c = np.array([48, 30, 16], dtype=np.float32) + (math.sin(x * 0.1) * 4)
                arr[y, x] = [c[0], c[1], c[2], 255]

    # 6.3 Cuerpo ensanchado del yunque de hierro fundido (visto en perspectiva cenital)
    for y in range(cy - 44, cy + 46):
        for x in range(cx - 150, cx + 150):
            dx = (x - cx) / 145.0
            dy = (y - cy) / 42.0
            if dx*dx + dy*dy <= 1.0:
                # Hierro oscuro (#1c1e22)
                arr[y, x] = [28, 30, 34, 255]

    # 6.4 Cara Superior de Acero Forjado del Yunque (Mesa de trabajo, cuerno y sufridera)
    # Longitud total: X de 65 a 335 (270px)
    # - Cuerno redondo (bickern): X: 65..150 (cónico hacia la izquierda)
    # - Mesa de corte (step): X: 150..168, ancho 64
    # - Cara principal plana pulida: X: 168..285, ancho 72
    # - Cola / talón: X: 285..335, ancho 68
    for y in range(cy - 38, cy + 40):
        dy = y - cy
        for x in range(65, 338):
            in_face = False
            is_horn = False
            is_step = False
            
            if 65 <= x < 150: # Cuerno cónico
                prog = (x - 65) / 85.0 # 0 en la punta, 1 en la base
                half_h = 4 + 28 * (prog ** 0.85)
                if abs(dy) <= half_h:
                    in_face = True
                    is_horn = True
            elif 150 <= x < 168: # Escalón de corte
                if abs(dy) <= 30:
                    in_face = True
                    is_step = True
            elif 168 <= x < 285: # Cara templada principal
                if abs(dy) <= 36:
                    in_face = True
            elif 285 <= x <= 335: # Talón con orificios
                if abs(dy) <= 33:
                    in_face = True

            if in_face:
                # Acero de alto carbono pulido al espejo (#32363e base, #555d6b mid, #9aa3b2 reflejo)
                # Textura de rectificado longitudinal y marcas de martillazos
                brush = math.sin(x * 0.4) * 2 + math.sin(y * 0.8) * 3
                # Reflejo especular satinado a lo largo del centro
                spec = max(0.0, 1.0 - abs(dy) / 28.0) ** 2
                
                steel_base = np.array([55, 60, 68], dtype=np.float32)
                if is_horn:
                    # El cuerno es redondeado, sombra cilíndrica
                    cyl_light = 0.5 + 0.5 * (1.0 - (dy / 30.0))
                    c = steel_base * cyl_light + brush
                elif is_step:
                    # Escalón de hierro dulce, algo más oscuro
                    c = steel_base * 0.75 + brush
                else:
                    # Cara de golpeo brillante y biselada
                    c = steel_base * (0.8 + spec * 0.6) + brush
                    
                # Bisel brillante en los bordes
                edge_d = min(abs(dy - 36), abs(dy + 36))
                if edge_d < 3 and (168 <= x <= 285):
                    c = np.array([175, 185, 200], dtype=np.float32) # Bisel de acero plateado
                    
                # Marcas de forja / hoyuelos de martillo
                if ((x * 17 + y * 31) % 157) < 3:
                    c = c * 0.75

                arr[y, x] = [c[0], c[1], c[2], 255]

    # 6.5 Orificio Cuadrado de Sufridera (Hardy Hole: X: 294..310, Y: 112..128)
    for y in range(cy - 8, cy + 9):
        for x in range(295, 312):
            # Agujero profundo oscuro con bisel interior
            if y == cy - 8 or x == 295:
                arr[y, x] = [18, 20, 24, 255] # Sombra profunda
            elif y == cy + 8 or x == 311:
                arr[y, x] = [95, 102, 115, 255] # Reflejo de borde opuesto
            else:
                arr[y, x] = [10, 11, 13, 255] # Profundidad negra

    # 6.6 Orificio Redondo de Punzonar (Pritchel Hole: X: 322, Y: 120, radio 5)
    for dy in range(-5, 6):
        for dx in range(-5, 6):
            if dx*dx + dy*dy <= 25:
                arr[cy + dy, 323 + dx] = [12, 13, 15, 255]

    out_img = Image.fromarray(np.clip(arr, 0, 255).astype(np.uint8), "RGBA")
    out_path = os.path.join(SPRITES_DIR, "workshop", "anvil_topdown.png")
    out_img.save(out_path)
    print(f"  -> Guardado: {out_path} [{w}x{h}]")

# -------------------------------------------------------------------------
# 7. assets/sprites/items/blacksmith_hammer.png (180x180)
# -------------------------------------------------------------------------
def generate_blacksmith_hammer():
    print("-> Generando blacksmith_hammer.png (180x180)...")
    size = 180
    arr = np.zeros((size, size, 4), dtype=np.float32)

    # 7.1 Sombra proyectada suave en diagonal
    for y in range(size):
        for x in range(size):
            # Línea de sombra del mango (de (35, 145) a (125, 55))
            dist_line = abs((55 - 145)*x - (125 - 35)*y + 125*145 - 55*35) / math.sqrt(90**2 + 90**2)
            if dist_line < 16 and (25 <= x <= 145):
                arr[y, x] = [15, 12, 10, (1.0 - dist_line / 16.0) * 80]

    # 7.2 Mango de Fresno/Hickory Torneado (de X=30, Y=150 hacia X=120, Y=60)
    for t in np.linspace(0, 1, 300):
        # Centro del mango a lo largo de la diagonal
        hx = 30 + t * 90
        hy = 150 - t * 90
        # Grosor variable ergonómico
        thickness = 8.5 + 2.0 * math.sin(t * 3.14)
        for offset in np.linspace(-thickness, thickness, 30):
            # Vector perpendicular a la diagonal (-1, -1) -> (1, -1)
            px = int(hx + offset * 0.707)
            py = int(hy + offset * 0.707)
            if 0 <= px < size and 0 <= py < size:
                norm_off = offset / thickness
                # Madera de fresno aceitada (#734e2c, #54371e)
                wood_base = np.array([105, 68, 38], dtype=np.float32)
                light = 0.65 + 0.35 * (1.0 - norm_off)
                c = wood_base * light
                # Empuñadura oscurecida por el hollín en la base (t < 0.25)
                if t < 0.25:
                    c = c * (0.5 + t * 2.0)
                arr[py, px] = [c[0], c[1], c[2], 255]

    # 7.3 Cabeza de Acero de Forja (Cruzada en el extremo superior X: 110..155, Y: 25..70)
    # Eje de la cabeza perpendicular al mango: de (100, 35) a (145, 80)
    head_cx, head_cy = 125, 55
    for dy in range(-25, 26):
        for dx in range(-25, 26):
            # Proyección en ejes del martillo (u paralelo a la cabeza, v perpendicular)
            # Cabeza orientada a 45 grados: u = (dx - dy)/sqrt(2), v = (dx + dy)/sqrt(2)
            u = (dx - dy) * 0.707
            v = (dx + dy) * 0.707
            
            # Bloque principal de la cabeza: u en [-28, 28], v en [-12, 12]
            in_head = False
            is_face = False # Boca plana de golpeo
            is_peen = False # Cuña de peña
            
            if -26 <= u <= 26 and -12 <= v <= 12:
                in_head = True
                if u > 22:
                    is_face = True
                elif u < -20:
                    is_peen = True
                    
            if in_head:
                px = int(head_cx + dx)
                py = int(head_cy + dy)
                if 0 <= px < size and 0 <= py < size:
                    # Acero macizo templado (#32363e base, #555d6b cuerpo, #9aa3b2 reflejo)
                    norm_v = v / 12.0
                    spec = max(0.0, 1.0 - abs(norm_v + 0.3)) ** 3
                    steel_c = np.array([55, 60, 70], dtype=np.float32) * (0.6 + spec * 0.8)
                    
                    if is_face:
                        # Cara de golpeo biselada y pulida espejo
                        steel_c = np.array([160, 172, 190], dtype=np.float32)
                    elif is_peen:
                        # Cuña peña estrecha
                        steel_c = steel_c * 0.85
                        
                    arr[py, px] = [steel_c[0], steel_c[1], steel_c[2], 255]

    # Ojo central con cuña de fijación de hierro
    for dy in range(-5, 6):
        for dx in range(-5, 6):
            if dx*dx + dy*dy <= 20:
                arr[head_cy + dy, head_cx + dx] = [30, 24, 18, 255]
    arr[head_cy, head_cx] = [160, 165, 175, 255] # Cuña de acero

    out_img = Image.fromarray(np.clip(arr, 0, 255).astype(np.uint8), "RGBA")
    out_path = os.path.join(SPRITES_DIR, "items", "blacksmith_hammer.png")
    out_img.save(out_path)
    print(f"  -> Guardado: {out_path} [{size}x{size}]")

# -------------------------------------------------------------------------
# 8. assets/sprites/items/shear_tool.png (160x160)
# -------------------------------------------------------------------------
def generate_shear_tool():
    print("-> Generando shear_tool.png (160x160)...")
    size = 160
    arr = np.zeros((size, size, 4), dtype=np.float32)

    cx, cy = 80, 80

    # 8.1 Sombra suave
    for y in range(size):
        for x in range(size):
            if 30 <= x <= 130 and 30 <= y <= 130:
                d = math.sqrt((x - cx)**2 + (y - cy)**2)
                if d < 60:
                    arr[y, x] = [15, 12, 10, (1.0 - d / 60.0) * 90]

    # 8.2 Brazos y Mangos de Hierro Forjado (dos palancas cruzadas)
    # Brazo 1: de (40, 130) pasando por (80, 80) hasta hoja en (120, 35)
    # Brazo 2: de (120, 130) pasando por (80, 80) hasta hoja en (40, 35)
    for (start_x, end_x, flip) in [(40, 120, 1), (120, 40, -1)]:
        for t in np.linspace(0, 1, 250):
            bx = start_x + t * (end_x - start_x)
            by = 130 - t * 95
            # Curvatura ergonómica del mango
            if t < 0.5:
                bx += math.sin(t * 3.14 * 2) * 8 * flip
                
            is_blade = (t > 0.55)
            thick = 4.0 if not is_blade else 7.0
            
            for off in np.linspace(-thick, thick, 15):
                px = int(bx + off)
                py = int(by)
                if 0 <= px < size and 0 <= py < size:
                    if is_blade:
                        # Hoja cortante de acero afilado (#9aa3b2 con filo brillante #d4dbe6)
                        edge_light = (off / thick) * flip
                        if edge_light > 0.4:
                            c = np.array([210, 220, 235], dtype=np.float32) # Filo afilado
                        else:
                            c = np.array([85, 92, 105], dtype=np.float32)
                    else:
                        # Mango de hierro forjado negro (#1c1e22 / #32363e)
                        c = np.array([42, 45, 52], dtype=np.float32) + (math.sin(t * 20) * 4)
                        
                    arr[py, px] = [c[0], c[1], c[2], 255]

    # Remache / Perno central de articulación (en 80, 80)
    for dy in range(-7, 8):
        for dx in range(-7, 8):
            d_sq = dx*dx + dy*dy
            if d_sq <= 49:
                # Arandela y perno de bronce (#a37f37)
                norm_d = math.sqrt(d_sq) / 7.0
                light = 0.6 + 0.4 * (1.0 - (dx + dy) / 10.0)
                c = np.array([163, 127, 55], dtype=np.float32) * light
                if d_sq <= 9:
                    c = np.array([40, 44, 50], dtype=np.float32) # Cabeza del perno de hierro
                arr[cy + dy, cx + dx] = [c[0], c[1], c[2], 255]

    out_img = Image.fromarray(np.clip(arr, 0, 255).astype(np.uint8), "RGBA")
    out_path = os.path.join(SPRITES_DIR, "items", "shear_tool.png")
    out_img.save(out_path)
    print(f"  -> Guardado: {out_path} [{size}x{size}]")

# -------------------------------------------------------------------------
# 9. assets/sprites/workshop/water_tub_topdown.png (360x240)
# -------------------------------------------------------------------------
def generate_water_tub_topdown():
    print("-> Generando water_tub_topdown.png (360x240)...")
    w, h = 360, 240
    arr = np.zeros((h, w, 4), dtype=np.float32)

    cx, cy = 180, 120
    rx_out, ry_out = 160, 100 # Borde exterior de roble
    rx_in, ry_in = 132, 74    # Cuenca interior de agua

    # 9.1 Sombra en el suelo
    for y in range(h):
        for x in range(w):
            dx = (x - cx) / (rx_out + 12.0)
            dy = (y - (cy + 8)) / (ry_out + 10.0)
            dist_sq = dx*dx + dy*dy
            if dist_sq <= 1.0:
                arr[y, x] = [15, 12, 10, (1.0 - dist_sq) * 160]

    # 9.2 Duelas de madera de roble perimetrales
    for y in range(h):
        for x in range(w):
            dx = (x - cx) / float(rx_out)
            dy = (y - cy) / float(ry_out)
            dist_out_sq = dx*dx + dy*dy
            
            dx_in = (x - cx) / float(rx_in)
            dy_in = (y - cy) / float(ry_in)
            dist_in_sq = dx_in*dx_in + dy_in*dy_in
            
            # Dentro del aro de madera
            if dist_out_sq <= 1.0 and dist_in_sq > 1.0:
                angle = math.atan2(dy, dx)
                # Duelas separadas radialmente
                stave_idx = int((angle + math.pi) * (24.0 / (2.0 * math.pi)))
                stave_tint = ((stave_idx * 13) % 7 - 3) * 4
                
                # Roble envejecido (#3d2614, #54371e)
                wood_base = np.array([65, 42, 24], dtype=np.float32) + stave_tint
                
                # Juntas oscuras entre duelas
                stave_fract = ((angle + math.pi) * (24.0 / (2.0 * math.pi))) % 1.0
                if stave_fract < 0.08 or stave_fract > 0.92:
                    wood_base = wood_base * 0.5
                    
                arr[y, x] = [wood_base[0], wood_base[1], wood_base[2], 255]

    # 9.3 Flejes concéntricos de hierro forjado
    for y in range(h):
        for x in range(w):
            dx = (x - cx) / float(rx_out)
            dy = (y - cy) / float(ry_out)
            d = math.sqrt(dx*dx + dy*dy)
            # Fleje exterior (d entre 0.92 y 0.98)
            if 0.92 <= d <= 0.98:
                arr[y, x] = [38, 42, 48, 255]

    # 9.4 Agua profunda de templado con ondas y salmuera
    for y in range(h):
        for x in range(w):
            dx_in = (x - cx) / float(rx_in)
            dy_in = (y - cy) / float(ry_in)
            dist_in_sq = dx_in*dx_in + dy_in*dy_in
            
            if dist_in_sq <= 1.0:
                d_center = math.sqrt(dist_in_sq)
                # Ondas concéntricas de inmersión reciente
                ripple = math.sin(d_center * 22.0) * 12
                
                # Agua oscura de salmuera (#1c2833 / #121f2d)
                water_base = np.array([22, 34, 46], dtype=np.float32) + ripple
                # Reflejo del cielo/taller en la superficie
                spec_ripple = max(0.0, ripple / 12.0) * np.array([30, 48, 65], dtype=np.float32)
                c = water_base + spec_ripple
                
                # Partículas de carbón flotando
                if ((x * 23 + y * 41) % 181) < 4:
                    c = np.array([10, 12, 14], dtype=np.float32)
                    
                arr[y, x] = [c[0], c[1], c[2], 255]

    out_img = Image.fromarray(np.clip(arr, 0, 255).astype(np.uint8), "RGBA")
    out_path = os.path.join(SPRITES_DIR, "workshop", "water_tub_topdown.png")
    out_img.save(out_path)
    print(f"  -> Guardado: {out_path} [{w}x{h}]")

# -------------------------------------------------------------------------
# 10. assets/sprites/items/whetstone.png (160x100)
# -------------------------------------------------------------------------
def generate_whetstone():
    print("-> Generando whetstone.png (160x100)...")
    w, h = 160, 100
    arr = np.zeros((h, w, 4), dtype=np.float32)

    cx, cy = 80, 50

    # 10.1 Sombra
    for y in range(h):
        for x in range(w):
            dx = (x - cx) / 72.0
            dy = (y - 56) / 32.0
            dist_sq = dx*dx + dy*dy
            if dist_sq <= 1.0:
                arr[y, x] = [15, 12, 10, (1.0 - dist_sq) * 140]

    # 10.2 Cuna de madera de nogal (Base de sujeción: X: 16..144, Y: 30..75)
    for y in range(30, 76):
        for x in range(16, 145):
            wood_c = np.array([55, 34, 18], dtype=np.float32) + (math.sin(x * 0.15) * 5)
            if y == 30 or y == 75 or x == 16 or x == 144:
                wood_c = wood_c * 0.7 # Borde biselado
            arr[y, x] = [wood_c[0], wood_c[1], wood_c[2], 255]

    # 10.3 Piedra de asentar de arenisca gris-oliva (#687067 / #52564f)
    # Dimensiones piedra: X: 26..134, Y: 36..68
    for y in range(36, 69):
        for x in range(26, 135):
            # Granularidad porosa mineral
            grain = (np.random.rand() - 0.5) * 14
            stone_c = np.array([95, 102, 94], dtype=np.float32) + grain
            
            # Huella húmeda de afilado (surco central de agua y aceite con polvillo de acero)
            dy_stone = abs(y - 52)
            if dy_stone < 8:
                slurry = (1.0 - dy_stone / 8.0) * 25
                stone_c = stone_c * 0.75 + np.array([slurry * 0.5, slurry * 0.6, slurry * 0.7], dtype=np.float32)
                
            # Bisel de los cantos de la piedra
            if x in [26, 134] or y in [36, 68]:
                stone_c += 20
                
            arr[y, x] = [stone_c[0], stone_c[1], stone_c[2], 255]

    out_img = Image.fromarray(np.clip(arr, 0, 255).astype(np.uint8), "RGBA")
    out_path = os.path.join(SPRITES_DIR, "items", "whetstone.png")
    out_img.save(out_path)
    print(f"  -> Guardado: {out_path} [{w}x{h}]")

# -------------------------------------------------------------------------
# 11. assets/sprites/environment/wood_floor.png (128x128) - SEAMLESS
# -------------------------------------------------------------------------
def generate_wood_floor():
    print("-> Generando wood_floor.png (128x128) [SEAMLESS]...")
    size = 128
    arr = np.zeros((size, size, 3), dtype=np.float32)

    # 4 Tablones horizontales periódicos de 32px de alto (Y: 0..32, 32..64, 64..96, 96..128)
    plank_h = 32

    for y in range(size):
        plank_idx = y // plank_h
        y_in_plank = y % plank_h
        plank_tint = ((plank_idx * 23) % 7 - 3) * 5
        
        for x in range(size):
            # Vetas de madera periódicas exactas usando funciones senoidales envolventes
            phase_x = 2.0 * math.pi * x / float(size)
            phase_y = 2.0 * math.pi * y / float(size)
            
            grain = (
                math.sin(phase_x * 3.0 + math.cos(phase_y * 4.0)) * 6 +
                math.sin(phase_x * 8.0) * 3 +
                math.cos(phase_x * 1.0) * 5
            )
            
            # Base roble gastado (#54371e a #3d2614)
            c = np.array([72, 48, 28], dtype=np.float32) + plank_tint + grain
            
            # Juntas de separación oscuras entre tablas (exactas en y=31..32, etc.)
            if y_in_plank == 0 or y_in_plank == plank_h - 1:
                c = np.array([20, 13, 8], dtype=np.float32)
            elif y_in_plank == 1:
                c += 12 # Bisel de luz superior de la tabla
                
            # Clavos de forja periódicos en los extremos de los tablones
            # Clavos cada 64px en X, cerca de las juntas
            if (x % 64 in [12, 52]) and (y_in_plank in [6, 26]):
                c = np.array([28, 30, 34], dtype=np.float32)
                
            arr[y, x] = c

    arr = add_gaussian_noise(arr, intensity=3)
    out_img = Image.fromarray(np.clip(arr, 0, 255).astype(np.uint8), "RGB")
    out_path = os.path.join(SPRITES_DIR, "environment", "wood_floor.png")
    out_img.save(out_path)
    print(f"  -> Guardado: {out_path} [{size}x{size}]")

# -------------------------------------------------------------------------
# 12. assets/sprites/environment/stone_floor.png (128x128) - SEAMLESS
# -------------------------------------------------------------------------
def generate_stone_floor():
    print("-> Generando stone_floor.png (128x128) [SEAMLESS]...")
    size = 128
    arr = np.zeros((size, size, 3), dtype=np.float32)

    # Generación de losas poligonales periódicas (Voronoi toroidal)
    # Puntos semilla en el toro [0, 128)
    np.random.seed(101)
    n_seeds = 9
    seeds_x = np.random.uniform(10, size - 10, n_seeds)
    seeds_y = np.random.uniform(10, size - 10, n_seeds)
    seed_tints = (np.random.rand(n_seeds) - 0.5) * 16

    for y in range(size):
        for x in range(size):
            # Distancia toroidal mínima a cada semilla
            min_d1 = 999.0
            min_d2 = 999.0
            closest_idx = 0
            
            for s in range(n_seeds):
                # Distancia mínima considerando envoltura toroidal
                dx = abs(x - seeds_x[s])
                dx = min(dx, size - dx)
                dy = abs(y - seeds_y[s])
                dy = min(dy, size - dy)
                dist = math.sqrt(dx*dx + dy*dy)
                
                if dist < min_d1:
                    min_d2 = min_d1
                    min_d1 = dist
                    closest_idx = s
                elif dist < min_d2:
                    min_d2 = dist

            # Distancia a la junta de mortero = (min_d2 - min_d1)
            mortar_dist = min_d2 - min_d1
            
            # Base de losa de granito/pizarra (#454a52 / #353a42)
            tint = seed_tints[closest_idx]
            granite_base = np.array([62, 66, 74], dtype=np.float32) + tint
            
            # Microtextura periódica de la piedra
            phase_x = 2.0 * math.pi * x / float(size)
            phase_y = 2.0 * math.pi * y / float(size)
            stone_tex = math.sin(phase_x * 5.0) * math.cos(phase_y * 5.0) * 4
            
            if mortar_dist <= 2.2:
                # Mortero oscuro con polvo de carbón (#1c1e22)
                c = np.array([24, 26, 30], dtype=np.float32)
            elif mortar_dist <= 5.0:
                # Bisel de la piedra
                c = granite_base + stone_tex - (5.0 - mortar_dist) * 4
            else:
                c = granite_base + stone_tex
                
            arr[y, x] = c

    arr = add_gaussian_noise(arr, intensity=4)
    out_img = Image.fromarray(np.clip(arr, 0, 255).astype(np.uint8), "RGB")
    out_path = os.path.join(SPRITES_DIR, "environment", "stone_floor.png")
    out_img.save(out_path)
    print(f"  -> Guardado: {out_path} [{size}x{size}]")

# -------------------------------------------------------------------------
# Ejecución General
# -------------------------------------------------------------------------
def main():
    print("================================================================")
    print(" INICIANDO GENERACIÓN DE ASSETS HISTÓRICOS DE HERRERÍA MEDIEVAL")
    print("================================================================")
    
    generate_workshop_counter_bg()
    generate_service_bell()
    generate_order_parchment()
    generate_sergeant_portrait()
    generate_peasant_portrait()
    generate_anvil_topdown()
    generate_blacksmith_hammer()
    generate_shear_tool()
    generate_water_tub_topdown()
    generate_whetstone()
    generate_wood_floor()
    generate_stone_floor()
    
    print("================================================================")
    print(" TODOS LOS ASSETS GENERADOS EXITOSAMENTE EN 'assets/sprites/'")
    print("================================================================")

if __name__ == "__main__":
    main()
