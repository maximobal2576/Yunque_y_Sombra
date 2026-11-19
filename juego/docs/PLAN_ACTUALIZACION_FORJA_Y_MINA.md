# Plan Técnico Integral: Termodinámica por Metal, Cola de 3 Pedidos, Acopio en Barriles de Mina, Carga Pesada y Tutorial en 2 Fases

## 1. Audio de Voz, Cizalla Corta y Termodinámica Diferenciada por Metal
1. **Volumen de voz de los ciudadanos (`src/autoloads/AudioManager.gd`)**:
   - Subir volumen base de `play_voice_blip()` de `-11.0 dB` a `-2.5 dB` y amplitud de onda a `0.78` para máxima claridad durante el diálogo letra por letra.
2. **Menor largo máximo de Cizalla (`src/scenes/workshop/ManualCutStation.gd`)**:
   - Reducir `LARGO_MAXIMO_TRAZO` de `220.0 px` a `130.0 px` para exigir trazos precisos ajustados a cada rebaba individual.
3. **Puntos de Fusión, Caldeo de Forja y Maleabilidad propios por cada Metal (`GameManager.gd`, `WorkshopStationView.gd`, `AnvilTopDownStation.gd`)**:
   - `bronce_cobre` (Bronce de Forja):
     - Ventana de maleabilidad (forja): `750°C - 880°C`
     - Punto de fusión (fundición de mena en bruto): `1020°C`
     - Factor de maleabilidad en yunque: `1.25` (más blando)
   - `acero_carbono` (Acero al Carbono):
     - Ventana de maleabilidad (forja): `920°C - 1040°C`
     - Punto de fusión (fundición de mena en bruto): `1140°C`
     - Factor de maleabilidad en yunque: `0.78` (más tenaz y resistente al golpe)
   - `hierro_dulce` (Hierro Dulce):
     - Ventana de maleabilidad (forja): `1050°C - 1160°C`
     - Punto de fusión (fundición de mena en bruto): `1200°C`
     - Factor de maleabilidad en yunque: `1.00` (estándar)

## 2. Mostrador: Campana accionada por el Ciudadano, Tope de 3 Pedidos en Día 1 y Receta Lenta
1. **Aparición más lenta de la receta (`src/scenes/workshop/CounterShopView.gd`)**:
   - Reducir `VELOCIDAD_REVELADO_RECETA` de `1.45` a `0.42` para que los datos del pergamino aparezcan pausadamente tras finalizar el comentario hablado del cliente.
2. **Campana exclusiva del ciudadano y cola única de 3 pedidos el primer día (`CounterShopView.gd`)**:
   - Cada uno de los 3 clientes (*Sargento Godofredo*, *Eustaquio el Molinero*, *Doña Valeria*) llega una sola vez en el día (`pedidos_completados_hoy < 3`, sin repetirse si ya llegó).
   - Al quedar libre el mostrador, el ciudadano entrante toca la campana automáticamente al asomarse a la ventanilla.
   - El jugador no puede tocar la campana arbitrariamente cuando ya hay un cliente presente o cuando ya se completaron los 3 pedidos del día.

## 3. Dinámica de Barriles (Stock de 3), Inventario de Menas en Entrada de Mina y Caminata Lenta con Metal en Mano
1. **Stock de 3 lingotes por barril en la Fragua (`GameManager.gd`, `WorkshopStationView.gd`)**:
   - `stock_barriles_fragua = {"hierro_dulce": 3, "acero_carbono": 3, "bronce_cobre": 3}`.
   - Cada barril en la Fragua muestra su cantidad disponible (`3/3`, `2/3`, etc.) y consume `1` al meter un lingote al horno.
2. **Almacenamiento en Barriles a la Entrada de la Mina e Inventario de Selección (`MinaSubterranea.gd`, `GreyboxTown.gd`, `GreyboxTown.tscn`)**:
   - Al picar mineral en bruto en la mina, se deposita en `GameManager.menas_barril_mina`.
   - En la entrada de la mina (`AccesoMina`), un barril interactuable (`BarrilMenasEntrada`) abre un panel de inventario donde el jugador selecciona hasta `3` menas del mismo tipo.
   - Al confirmar la selección, el panel se cierra y el personaje sostiene el mineral en sus manos (`menas_en_mano_tipo`, `menas_en_mano_cantidad`).
3. **Caminata Lenta con Metal en Mano y Fundición a Temperatura Máxima (`Player.gd`, `Player.tscn`, `WorkshopStationView.gd`)**:
   - Mientras el jugador lleva menas en la mano, se visualiza el mineral sostenido en el personaje (`VisualMenaEnMano`) y su velocidad de movimiento se reduce al `55%` (`SPEED * 0.55`).
   - Al ingresar a la Fragua con menas en la mano, se cargan en el horno en modo **Fundición de Mena Bruta**, requiriendo atizar el fuelle hasta alcanzar el **punto de fusión máximo** del metal (`1020°C` / `1140°C` / `1200°C`). Al lograrlo, se funden en lingotes que recargan el barril correspondiente y completan la misión.

## 4. Tutorial Extendido en Dos Etapas (`src/scenes/ui/GuiaTutorial.gd`)
1. **Etapa 1 (Pasos 1 a 9 — Los 3 Encargos Comerciales)**:
   - Guía el ciclo de herrería. Al entregar el **3er pedido** en el mostrador (`pedidos_completados_hoy >= 3`), se oculta la primera parte del tutorial.
2. **Etapa 2 (Pasos 10 a 14 — Reanudación Automática: Sueño, Mina, Acopio, Carga Lenta y Fundición)**:
   - Paso 10 (*Descanso Nocturno*): Ir al dormitorio y dormir en la cama.
   - Paso 11 (*Extracción en la Mina*): Entrar a la mina subterránea y picar mineral en bruto.
   - Paso 12 (*Barril de Acopio*): Inspeccionar el barril a la entrada de la mina y retirar hasta 3 menas iguales.
   - Paso 13 (*Transporte Pesado*): Caminar lento con el mineral en las manos hasta el Taller de Forja.
   - Paso 14 (*Fundición a Temperatura Máxima*): Llevar la mena a la Fragua y fundirla a su temperatura máxima de fusión para concluir la misión.
