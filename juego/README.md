# ⚒️ Yunque & Sombra: La Herencia del Artesano
> *Chronicle of Exile · Project Anvil*

---

> *"De día forjas las herramientas de un pueblo que despierta; de noche desentierras la conspiración que condenó a tu sangre."*

**Yunque & Sombra** es una experiencia de simulación de oficio, progresión comunitaria y misterio sociopolítico en 2D. Combina la adictiva microgestión táctil y háptica de taller en primer plano (*Papa's Series*, *Potion Punch*) con la exploración cenital rústica y la vida de pueblo (*Stardew Valley*).

---

## 🧭 Visión General & Propuesta de Valor

El jugador asume el control del taller abandonado de su tío en una aldea medieval en decadencia tras recibir una afectuosa carta de su madre. Lo que comienza como una acogedora rutina de forja, templado y atención al mostrador revela gradualmente una intriga opresiva: el progreso artesanal despierta la autonomía del pueblo, alertando a los señores feudales que silenciaron al antiguo herrero.

### 🌓 El Bucle de 24 Horas

1. **Fase Diurna (06:00 – 17:00) · El Mostrador & La Forja Táctil**
   - **Perspectiva:** Primer plano interactivo.
   - **Mecánicas:** Atención de clientes con barras de paciencia dinámicas, horneado con fuelle, forja rítmica en yunque, enfriamiento en tina y pulido de piezas.
   - **Evolución:** Desde clavos, bisagras y herraduras rústicas hasta armaduras de gala y orfebrería con gemas engarzadas.

2. **Fase Nocturna (17:00 – 00:00) · Exploración Top-Down & Vida Comunitaria**
   - **Perspectiva:** Vista cenital 2D (*Top-Down*).
   - **Mecánicas:** Exploración del poblado, interacción en tabernas y bazares, y descenso a la mina subterránea secreta para extraer carbón, metales y gemas preciosas.
   - **Economía Circular:** Los aldeanos utilizan y lucen en sus hogares las herramientas que el jugador manufacturó.

3. **Ciclo de Medianoche (00:00) · Descanso y Gestión de Energía**
   - Regreso obligatorio al hogar antes de las 00:00 para reponer estamina.
   - Penalizaciones por desmayo o fatiga (riesgo de asalto a la intemperie).

---

## 🏛️ Innovaciones Clave (USPs)

- **Mueblería Comunitaria de Juan:** Mobiliario con beneficios pasivos tangibles instalado directamente en el taller durante la noche.
- **El Códice Metalúrgico Manchado:** Árbol tecnológico desbloqueable mediante limpieza táctil con esponja y solventes.
- **Metaprogresión Visual Reactiva:** El pueblo transmuta en 3 etapas visibles: *Decadencia y Barro*, *Reconstrucción*, y *Esplendor Comunitario*.
- **Tensión Sociopolítica Progresiva:** Escalada narrativa orgánica a través de pedidos de la guardia y notas fragmentadas del diario del tío, culminando en un inolvidable giro de destierro.

---

## 🚀 Lanzadores Rápidos (.bat y Scripts)

El proyecto cuenta con accesos directos en la raíz para iniciar o desplegar el juego con un solo clic:

| Archivo | Tipo | Descripción |
|---|---|---|
| `ejecutar_juego.bat` | Script Batch | Inicia el juego directamente en ventana utilizando el binario local de Godot 4.x. |
| `ejecutar_playtest.bat` | Script Batch | Lanza la sesión de playtesting interactivo automatizado en pantalla (`GODOT_PLAYTEST=1`). |
| `JUGAR_EN_RED_LOCAL.bat` | Script Batch | Compila/verifica la versión Web HTML5 e inicia el servidor LAN dual (HTTP/HTTPS) para jugar en red local desde cualquier PC o dispositivo. |
| `ABRIR_LINK_HTTPS_PUBLICO.bat` | Script Batch | Levanta el servidor local y genera un túnel HTTPS público seguro (vía `localhost.run`) para compartir con evaluadores externos. |
| `iniciar_servidor_web_lan.py` | Python 3 | Servidor dual (HTTP 8080 / HTTPS 8443) con generación automática de certificados SSL locales (sin dependencias externas ni licencias). |

---

## 📂 Estructura del Repositorio

```plaintext
juego/
├── README.md                      # Índice principal y visión general del proyecto
├── CRONICA_DE_CAMPO.md            # Pergamino inmutable de decisiones técnicas y memoria de campo
├── AGENTS.md                      # Directrices y convenciones para agentes de IA
├── CLAUDE.md                      # Contexto de desarrollo para Claude Code
├── GEMINI.md                      # Contexto de desarrollo para Gemini / Antigravity
├── project.godot                  # Configuración maestra del motor Godot 4.x
├── export_presets.cfg             # Perfiles de exportación (Web HTML5, etc.)
│
├── ejecutar_juego.bat             # Lanzador nativo de escritorio
├── ejecutar_playtest.bat          # Lanzador del corredor interactivo de playtests
├── JUGAR_EN_RED_LOCAL.bat         # Lanzador del servidor Web local LAN
├── ABRIR_LINK_HTTPS_PUBLICO.bat   # Lanzador del túnel HTTPS público para playtesting
├── iniciar_servidor_web_lan.py    # Servidor web local HTTP/HTTPS con SSL
│
├── assets/                        # Recursos audiovisuales organizados por tipo
│   ├── audio/
│   │   ├── ambient/               # Paisajes sonoros y audios de ambiente (.ogg/.wav)
│   │   ├── music/                 # Bandas sonoras y temas diurnos/nocturnos (.ogg)
│   │   └── sfx/                   # Efectos de sonido e impactos hápticos (.wav)
│   ├── fonts/                     # Tipografías rústicas y técnicas (.ttf/.otf)
│   └── sprites/
│       ├── characters/            # Spritesheets y animaciones de personajes y clientes
│       ├── environment/           # Tilesets y props de aldea, taller y mina
│       ├── items/                 # Iconos de herramientas, minerales y orfebrería
│       └── ui/                    # Elementos de interfaz gráfica, barras y diales
│
├── build/                         # Compilaciones del proyecto
│   └── web/                       # Exportación HTML5 / WebAssembly lista para servidor
│
├── docs/                          # Documentación canónica y especificaciones de diseño
│   ├── GUIA_DE_ETAPAS_Y_SKILLS.md # Hoja de ruta por etapas y asignación de skills de IA
│   ├── plan_de_accion.txt         # Plan maestro de acción técnica en 9 fases
│   ├── idea.txt                   # GDD completo: diseño de sistemas, loops y narrativa
│   ├── resumen.txt                # Resumen ejecutivo y pitch deck comercial (formato texto)
│   └── resumen.docx               # Resumen ejecutivo en formato enriquecido (Word)
│
├── logs/                          # Registro histórico de ejecuciones, Godot y playtests
│   ├── godot_err.log              # Log de errores de ejecución de Godot
│   ├── godot_log.txt              # Registro general de salida de Godot
│   ├── godot_run.log              # Registro de corrida de pruebas
│   ├── godot_verbose.log          # Salida detallada en modo verbose
│   └── playtest_check.log         # Diagnóstico de controladores e interfaces de playtesting
│
├── screenshots/                   # Capturas de pantalla, evidencias visuales y auditorías
│   ├── 01_prologo_carta.png ...   # Vistas de juego, cartas y aldea exterior
│   ├── live_*                     # Capturas de verificación en vivo del taller
│   └── playtest_*                 # Secuencia completa de estaciones y ticket final
│
├── src/                           # Código fuente en GDScript y escenas de Godot 4
│   ├── autoload/                  # Singletons globales (GameManager, TimeManager, AudioManager)
│   ├── common/                    # Clases base, recursos .tres y utilidades compartidas
│   ├── components/                # Componentes térmicos y cinéticos desacoplados
│   └── scenes/                    # Escenas y nodos modulares
│       ├── levels/                # Entornos y niveles (GreyboxTown, MinaSubterranea)
│       ├── objects/               # Componentes y objetos interactivos (InteractableArea)
│       ├── player/                # Controlador cinemático del jugador
│       ├── ui/                    # Interfaces de usuario y HUD persistente (MainHUD, GuiaTutorial)
│       └── workshop/              # Minijuegos y estaciones de forja en primer plano
│
├── tests/                         # Pruebas automatizadas y simulaciones de usuario
│   ├── capture_game_views.gd      # Capturador automatizado de pantallas de escenas
│   ├── PlaytestDriver.gd          # Conductor interactivo de pruebas en pantalla
│   ├── playtest_gameplay_loop.gd  # Bucle completo de juego automatizado de punta a punta
│   ├── playtest_interactive_runner.gd # Corredor visual interactivo para pantalla
│   ├── playtest_yunque_juice.gd   # Test de sensación física y juice del yunque
│   └── retroalimentacion/         # Informes de evaluación por arquetipos de jugador
│       └── fase_02_taller_comercial/ # Reportes de casual, veterano, narrativo, UI y síntesis
│
└── tools/                         # Herramientas de soporte y subsistemas externos
    ├── generators/                # Generadores procedurales de audio, sprites y texturas
    │   ├── generar_musica_fondo.py     # Síntesis acústica de fondo en Re Dórico
    │   ├── generate_author_sprites.py  # Generador procedural PIL de sprites 2D
    │   ├── generate_foley_sfx.py       # Síntesis procedural de efectos de sonido (Foley)
    │   └── generate_workshop_assets.py # Generador procedural de fondo y piezas de taller
    ├── run_playtest_in_window.py  # Wrapper Win32 para forzar ventana en primer plano
    └── voice_assistant/           # Asistente por voz Jarvis, daemon y telemetría
        ├── asistente_daemon.py    # Servicio daemon de escucha y procesamiento
        ├── auto_auditor.py        # Auditoría continua de salud y rendimiento
        ├── system_bridge.py       # Puente de comandos con el sistema operativo
        ├── test_asistente.py      # Pruebas unitarias del subsistema de voz
        ├── config.json            # Configuración de voz y parámetros
        └── logs/                  # Telemetría y auditorías de Jarvis
```

---

## 📚 Documentación Canónica & Bitácora de Desarrollo

Para profundizar en los detalles conceptuales, mecánicos, hojas de ruta y seguimiento técnico del proyecto:

- 🗺️ **[Guía de Etapas y Skills del Proyecto](docs/GUIA_DE_ETAPAS_Y_SKILLS.md):** Mapa de ruta de producción en 6 etapas y matriz de asignación de roles de IA (`/disenador_de_niveles`, `/disenador_grafico`, `/sonidista`, `/game_feel`, `/playtester`, `/secretario`).
- 🛠️ **[Plan de Acción Integral (Fases 0 a 8)](docs/plan_de_accion.txt):** Desglose secuencial de ingeniería de software, arquitectura técnica y validaciones headless en Godot.
- 📜 **[GDD Canónico del Proyecto](docs/idea.txt):** Especificación exhaustiva de jugabilidad, balance, estaciones de forja táctil, minería top-down y clímax narrativo.
- 📜 **[Crónica Imperial de Campo (Taishi)](CRONICA_DE_CAMPO.md):** Registro histórico inmutable de actas de arquitectura, decisiones técnicas tomadas en sesión y testimonios de inspección ocular.
- 📋 **[Resumen Ejecutivo (Pitch Deck - TXT)](docs/resumen.txt):** Visión sintetizada, pilares clave, público objetivo y referencias comerciales.
- 📑 **[Resumen Ejecutivo Enriquecido (Pitch Deck - DOCX)](docs/resumen.docx):** Documento formal de presentación editorial.
- 👥 **[Panel de Retroalimentación de Jugadores](tests/retroalimentacion/fase_02_taller_comercial/SINTESIS_DEL_PANEL.md):** Síntesis de retroalimentación de arquetipos (casual, veterano, narrativo y accesibilidad).
