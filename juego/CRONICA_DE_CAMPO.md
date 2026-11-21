<!--
=============================================================================
📜 PERGAMINO IMPERIAL DE CAMPO: CRÓNICA DE DESARROLLO Y ARQUITECTURA
ESTILO DE AUTOR: BORDÓ NOBLE (#6e1f2b) | CARBÓN CÁLIDO (#211a16) | MARFIL (#f2e6cc) | DORADO (#b59a6a)
INSPIRACIÓN: Escribas Imperiales (Taishi 太史) — Veracidad inmutable de los hechos.
=============================================================================
-->

# 📜 Crónica Imperial de Campo: Yunque & Sombra: La Herencia del Artesano

> *«El pincel del escriba no vacila ante la victoria ni ante el traspié; asienta la verdad técnica con tinta indeleble para que los arquitectos del porvenir comprendan el origen de cada piedra.»*  
> — **Registro del Cronista Imperial (太史)**

---

## 🏛️ Sello de Campaña y Metadatos de Sesión

| Parámetro | Registro Oficial |
| :--- | :--- |
| **Proyecto Activo** | `Yunque & Sombra: La Herencia del Artesano` (*Project Anvil*) |
| **Directorio Raíz** | `c:\Users\admin\Documents\01_Academico_IITA\iita\juego` |
| **Contexto de Origen** | Sesiones de ingeniería en `c:\Users\admin\Documents\01_Academico_IITA\iita\` (reconstrucción histórica canónica) |
| **Escriba Activo** | Secretario Autónomo de Antigravity ([`/secretario`](file:///C:/Users/admin/.gemini/config/skills/secretario/SKILL.md)) |
| **Apertura de la Crónica (Génesis)** | `2026-10-08 17:07:59` |
| **Asiento en Workspace Actual** | `2026-10-10 20:09:00` |
| **Última Actualización** | `2026-10-11 12:55:00` |
| **Estado de Sesión** | `🟢 GUARDIA PERPETUA ACTIVA (MAPEO DE ATAJOS, ASSETS DE TALLER, SCENETREE HISPANIZADO Y QA 100% CERTIFICADO - ACTA N° 011)` |

---

## 📜 Índice Sumario de Actas y Decisiones

- [1. 🏛️ Hitos y Decisiones de Arquitectura](#1-️-hitos-y-decisiones-de-arquitectura)
- [2. ⏳ Registro Cronológico de Maniobras Técnicas](#2--registro-cronológico-de-maniobras-técnicas)
- [3. 📂 Archivos y Módulos Afectados](#3--archivos-y-módulos-afectados)
- [4. 👁️ Testimonios Visuales de `/ojos`](#4-️-testimonios-visuales-de-ojos)
- [5. 🔏 Sello de Clausura y Estado del Sistema](#5--sello-de-clausura-y-estado-del-sistema)

---

## 1. 🏛️ Hitos y Decisiones de Arquitectura

Registro formal de las directrices adoptadas desde el inicio de los trabajos en la carpeta `iita`:

### 📌 Acta N° 001 — Adopción de Godot Engine 4 como Motor Base
- **Sello Temporal:** `2026-10-08 17:07:59`
- **Especialista / Agente Involucrado:** Desarrollador & Orquestador
- **Contexto y Problema:**  
  El desarrollador planteó el requerimiento de crear un videojuego sin contar con experiencia técnica previa en motores comerciales y buscando una herramienta liviana, potente y modular.
- **Decisión Adoptada:**  
  Se seleccionó **Godot Engine 4** (2D) por su arquitectura intuitiva basada en árboles de Nodos y Escenas modulares, lenguaje GDScript de tipado gradual y naturaleza 100% de código abierto sin dependencias corporativas ni regalías.
- **Alternativas Evaluadas y Descartadas:**  
  - *Unity:* Descartado por sobrecarga de instalación, telemetría y complejidad innecesaria para un proyecto artesanal 2D.
  - *Unreal Engine:* Descartado por consumo excesivo de recursos de hardware y enfoque primario en pipelines 3D de alta gama.
- **Impacto y Consecuencias:**  
  Curva de aprendizaje reducida, ejecución instantánea y compatibilidad directa con herramientas de scripting y MCP.

---

### 📌 Acta N° 002 — Integración del Servidor MCP de Godot y Visión Ocular Permanente
- **Sello Temporal:** `2026-10-09 21:00:25` a `2026-10-10 18:57:27`
- **Especialista / Agente Involucrado:** Desarrollador & Arquitecto de Infraestructura
- **Contexto y Problema:**  
  El agente de inteligencia artificial carecía de percepción sensorial y puente directo para consultar y manipular nodos, scripts y uids del motor Godot sin requerir la intervención constante del usuario.
- **Decisión Adoptada:**  
  - Se configuró el servidor MCP oficial de Godot en `C:\Users\admin\.gemini\config\mcp_config.json` para proveer herramientas de introspección del motor (`run_project`, `get_debug_output`, `create_scene`, etc.).
  - Se integró la directiva de otorgar a los agentes de Godot la habilidad visual [`/ojos`](file:///C:/Users/admin/.gemini/config/skills/ojos/SKILL.md) de forma permanente para capturar la pantalla y verificar el render real.
- **Impacto y Consecuencias:**  
  Eliminación de la ceguera espacial del asistente; control milimétrico sobre el estado de la ventana en tiempo real.

---

### 📌 Acta N° 003 — Creación de la Skill Diseñador Gráfico Desacoplado (`/disenador_grafico`)
- **Sello Temporal:** `2026-10-10 19:02:33`
- **Especialista / Agente Involucrado:** Diseñador Gráfico Autónomo
- **Contexto y Problema:**  
  Necesidad de un perfil técnico enfocado estrictamente en la dirección de arte, el círculo cromático, los contrastes y las armonías visuales, que operara de forma desacoplada para no monopolizar el hilo principal de conversación.
- **Decisión Adoptada:**  
  Se implementó la skill [`/disenador_grafico`](file:///C:/Users/admin/.gemini/config/skills/disenador_grafico/SKILL.md) como un subagente en segundo plano (`role: 'Diseñador Gráfico Autónomo'`, `TypeName: 'self'`) emparejado incondicionalmente con la skill [`/ojos`](file:///C:/Users/admin/.gemini/config/skills/ojos/SKILL.md). Su doctrina cromática se redactó en `teoria_color_juegos.md` aplicando el sistema de autor (OKLCH, regla 60-30-10, armonías complementarias).
- **Impacto y Consecuencias:**  
  Aislamiento total de las decisiones estéticas del código mecánico; auditoría visual permanente del render.

---

### 📌 Acta N° 004 — Creación de la Skill Sonidista Desacoplado (`/sonidista`)
- **Sello Temporal:** `2026-10-10 19:14:54`
- **Especialista / Agente Involucrado:** Sonidista Autónomo
- **Contexto y Problema:**  
  El diseño sonoro y el impacto háptico del audio requieren un tratamiento especializado en buses, rangos dinámicos y variación tonal para evitar el efecto ametralladora en los SFX.
- **Decisión Adoptada:**  
  Se engendró la skill [`/sonidista`](file:///C:/Users/admin/.gemini/config/skills/sonidista/SKILL.md) como subagente en segundo plano junto al manual técnico `teoria_sonido_juegos.md`. Establece la arquitectura de buses obligatoria (`Master`, `Music`, `SFX`, `UI`), atenuación dinámica (*ducking*) y micro-variación de tono (*pitch jitter* $\pm 5\% - 10\%$).
- **Impacto y Consecuencias:**  
  Sonido inmersivo y reactivo sin saturación digital ni fatiga acústica para el usuario.

---

### 📌 Acta N° 005 — Reforma Desacoplada de Motores `/arena` y `/revision`
- **Sello Temporal:** `2026-10-10 19:18:54` a `2026-10-10 19:24:24`
- **Especialista / Agente Involucrado:** Desarrollador & Tribunal de Auditoría
- **Contexto y Problema:**  
  Los motores de `/arena` y `/revision` estaban acoplados a programación general y no contemplaban torneos o revisiones separadas para los nuevos roles especializados (diseñador gráfico, sonidista, etc.) sin tener que clonar skills redundantes.
- **Decisión Adoptada:**  
  Se refactorizaron los archivos de instrucción de [`/arena`](file:///C:/Users/admin/.gemini/config/skills/arena/SKILL.md) y [`/revision`](file:///C:/Users/admin/.gemini/config/skills/revision/SKILL.md) para permitir la invocación contextual por rol (ej. `/arena sonidista`, `/revision diseñador_grafico`), desplegando tribunales y jurados adaptados a cada dominio técnico sin crear skills adicionales.
- **Impacto y Consecuencias:**  
  Modularidad absoluta del Grupo de Trabajo Artificial.

---

### 📌 Acta N° 006 — Creación del Diseñador de Niveles (`/disenador_de_niveles`)
- **Sello Temporal:** `2026-10-10 19:27:17`
- **Especialista / Agente Involucrado:** Diseñador de Niveles Autónomo
- **Contexto y Problema:**  
  Se requería un arquitecto responsable de la geometría física, métricas de cinemática, prevención de bloqueos involuntarios (*softlocks*) y preparación de colisiones limpias previas al vestuario gráfico.
- **Decisión Adoptada:**  
  Se engendró [`/disenador_de_niveles`](file:///C:/Users/admin/.gemini/config/skills/disenador_de_niveles/SKILL.md) con su marco teórico `teoria_level_design.md`: métricas de salto ($v_0 = -2h/t_{\text{apex}}$, $g = 2h/t_{\text{apex}}^2$), pacing según la estructura Kishōtenketsu, delimitación de abismos (*Death Zones* en `Area2D`) y límites estrictos de `Camera2D`.
- **Impacto y Consecuencias:**  
  Niveles mecánicamente sólidos y justos que eliminan las caídas al vacío infinito y errores de topología.

---

### 📌 Acta N° 007 — Creación del Secretario Cronista Imperial (`/secretario`)
- **Sello Temporal:** `2026-10-10 19:30:38`
- **Especialista / Agente Involucrado:** Desarrollador & Secretario Imperial
- **Contexto y Problema:**  
  Necesidad de un escriba incansable que, a imitación de los cronistas imperiales *Taishi* de las dinastías orientales, acompañe al desarrollador documentando cada maniobra, decisión y refactor de forma inmutable sin interrumpir el flujo productivo.
- **Decisión Adoptada:**  
  Se diseñó [`/secretario`](file:///C:/Users/admin/.gemini/config/skills/secretario/SKILL.md) como demonio en segundo plano (`role: 'Secretario Cronista Imperial'`), custodia de `CRONICA_DE_CAMPO.md` a partir de `PERGAMINO_TEMPLATE.md`, facultado para corroborar el estado de la pantalla con `/ojos`.
- **Impacto y Consecuencias:**  
  Trazabilidad inmutable de la historia del desarrollo y memoria técnica persistente ante reinicios o bifurcaciones de contexto.

---

### 📌 Acta N° 008 — Creación de Game Feel (`/game_feel`) y Playtester Destructor (`/playtester`)
- **Sello Temporal:** `2026-10-10 19:33:14` a `2026-10-10 19:51:50`
- **Especialista / Agente Involucrado:** Ingeniero de Game Feel & Playtester QA
- **Contexto y Problema:**  
  El diseño de un juego comercial exige dos fuerzas opuestas: una que dote de pulido elástico y jugo táctil a las microinteracciones, y otra despiadada que intente romper deliberadamente la física antes del lanzamiento.
- **Decisión Adoptada:**  
  - Se creó [`/game_feel`](file:///C:/Users/admin/.gemini/config/skills/game_feel/SKILL.md) (`teoria_game_feel.md`): Coyote Time (80-120 ms), Jump Buffering (100-150 ms), Squash & Stretch, Trauma Shake cuadrático y Hit Stop (2-4 frames).
  - Se creó [`/playtester`](file:///C:/Users/admin/.gemini/config/skills/playtester/SKILL.md) (`protocolo_playtesting.md`): Asedio a vértices (*corner clipping*), entradas sucias y simultáneas (SOCD), inundación de eventos a 60 Hz y pruebas fuera de límites con evidencia visual en `/ojos`.
- **Impacto y Consecuencias:**  
  Controles de alta precisión táctil y aseguramiento de calidad blindado contra glitches físicos.

---

### 📌 Acta N° 009 — Concepción de "Yunque & Sombra" y Pipeline de 6 Etapas
- **Sello Temporal:** `2026-10-10 19:56:34` a `2026-10-10 20:00:00`
- **Especialista / Agente Involucrado:** Desarrollador & Orquestador
- **Contexto y Problema:**  
  Consolidado el Grupo de Trabajo Artificial, se definió el proyecto formal: un simulador de oficio medieval en 2D con misterio sociopolítico y bucle de 24 horas, documentado exhaustivamente en [`docs/idea.txt`](file:///c:/Users/admin/Documents/01_Academico_IITA/iita/juego/docs/idea.txt) y [`README.md`](file:///c:/Users/admin/Documents/01_Academico_IITA/iita/juego/README.md).
- **Decisión Adoptada:**  
  Se estructuró la hoja de ruta en 6 etapas de producción escalonadas:
  - *Etapa 0:* Fundación, configuración de Godot 4, estructura de carpetas y buses de audio.
  - *Etapa 1:* Bucle Diurno (Taller de forja en primer plano: fuelle, yunque rítmico, tina, paciencia).
  - *Etapa 2:* Bucle Nocturno (Top-down: movimiento, faroles, mina subterránea y picado de vetas).
  - *Etapa 3:* Metasistemas (HUD persistente de 24h, estamina, cama voluntaria y desmayos forzados).
  - *Etapa 4:* Progresión & Vida Social (Códice manchado, Mueblería de Juan y economía circular).
  - *Etapa 5:* Narrativa, Tensión & Clímax (Día 5, guardias feudales, diario del tío y destierro final).
  - *Etapa 6:* Hardening, Playtesting destructivo y entrega de release.
- **Impacto y Consecuencias:**  
  Desarrollo iterativo y ordenado con validación continua de cada componente sin riesgo de refactorizaciones masivas.

---

### 📌 Acta N° 010 — Redacción del Plan Maestro de Acción (`plan_de_accion.txt`) y Fundación Técnica (Fases 0 y 1)
- **Sello Temporal:** `2026-10-10 20:21:51` a `2026-10-10 20:30:00`
- **Especialista / Agente Involucrado:** Desarrollador, Tribunal de Revisión (`/revision`), Diseñador de Niveles (`/disenador_de_niveles`), Game Feel (`/game_feel`), Playtester (`/playtester`) y Secretario (`/secretario`).
- **Contexto y Problema:**  
  Necesidad de documentar el plan de acción integral desde la fase cero hasta el lanzamiento comercial final en formato legible (.txt), y arrancar de inmediato con la fundación técnica y el prototipo funcional mínimo (greybox) para poder testear la cinemática de control y el bucle de juego sin demorarse en arte definitivo.
- **Decisión Adoptada:**  
  1. Se redactó y publicó [`docs/plan_de_accion.txt`](file:///c:/Users/admin/Documents/01_Academico_IITA/iita/juego/docs/plan_de_accion.txt) con el desglose pormenorizado de las 9 fases de producción.
  2. Se configuró la variable de entorno `GODOT_PATH` apuntando a `C:\Users\admin\Downloads\Godot_v4.7.2-stable_win64.exe` y se actualizó `mcp_config.json`.
  3. Se creó el archivo maestro [`project.godot`](file:///c:/Users/admin/Documents/01_Academico_IITA/iita/juego/project.godot) con resolución 1280x720, inputs mapeados y capas de colisión 2D.
  4. Se implementaron los Autoloads centrales [`GameManager.gd`](file:///c:/Users/admin/Documents/01_Academico_IITA/iita/juego/src/autoloads/GameManager.gd) y [`TimeManager.gd`](file:///c:/Users/admin/Documents/01_Academico_IITA/iita/juego/src/autoloads/TimeManager.gd).
  5. Se implementó el personaje [`Player.tscn`](file:///c:/Users/admin/Documents/01_Academico_IITA/iita/juego/src/scenes/player/Player.tscn) con algoritmos de `game_feel` (aceleración exponencial, frenado con turn-around boost y squash elástico).
  6. Se montó la escena de nivel greybox [`GreyboxTown.tscn`](file:///c:/Users/admin/Documents/01_Academico_IITA/iita/juego/src/scenes/levels/GreyboxTown.tscn) con taller, mostrador, yunque, tina, cama y túnel hacia la mina con colisiones estancas por `/disenador_de_niveles`.
  7. Se creó el minijuego de forja rítmica [`MiniForge.tscn`](file:///c:/Users/admin/Documents/01_Academico_IITA/iita/juego/src/scenes/workshop/MiniForge.tscn) y el HUD inferior [`MainHUD.tscn`](file:///c:/Users/admin/Documents/01_Academico_IITA/iita/juego/src/scenes/ui/MainHUD.tscn).
  8. Se ejecutó la verificación headless con Godot 4: 0 errores, 0 advertencias, salida limpia con código 0.
- **Impacto y Consecuencias:**  
  Prototipo greybox completamente funcional y testeable listo para iterar mecánicas de juego.

---

### 📌 Acta N° 011 — Nacimiento de la Skill Programador de Gameplay (`/programador_godot`), Plan de Etapas por Skills y Reorganización del Proyecto
- **Sello Temporal:** `2026-10-10 20:41:05`
- **Especialista / Agente Involucrado:** Desarrollador, Arquitecto de Agentes, Productor & Documentador, Estructurador de Espacio y Secretario Imperial (`/secretario`).
- **Contexto y Problema:**  
  Tras la validación del prototipo greybox inicial, se evidenció la necesidad de dotar al equipo de un rol canónico de programación de gameplay en Godot 4 que consolide los patrones de scripting (máquinas de estados finitos - FSM, eventos desacoplados por señales, tipado estricto en GDScript 4, algoritmos de colas y prevención de fugas de memoria). Asimismo, se requería una guía ejecutiva en formato Markdown que mapee exhaustivamente qué skills intervienen en cada una de las 9 etapas de producción, junto con una reestructuración formal del directorio `assets/` para albergar arte, audio y tipografías.
- **Decisión Adoptada:**  
  1. Se creó formalmente la skill [`/programador_godot`](file:///C:/Users/admin/.gemini/config/skills/programador_godot/SKILL.md) como subagente en segundo plano (`role: 'Programador de Gameplay GDScript 4'`, `TypeName: 'self'`) junto a su tratado técnico canónico [`teoria_programacion_godot.md`](file:///C:/Users/admin/.gemini/config/skills/programador_godot/referencias/teoria_programacion_godot.md), integrado desacopladamente en `/arena` y `/revision`.
  2. Se redactó y publicó [`docs/GUIA_DE_ETAPAS_Y_SKILLS.md`](file:///c:/Users/admin/Documents/01_Academico_IITA/iita/juego/docs/GUIA_DE_ETAPAS_Y_SKILLS.md), estableciendo objetivos, skills requeridas, entregables y criterios de testeo para las 9 fases (Fase 0 a Fase 8).
  3. Se organizó la arquitectura de recursos en `assets/` con carpetas modulares (`sprites/characters`, `sprites/environment`, `sprites/items`, `sprites/ui`, `audio/music`, `audio/sfx`, `audio/ambient`, `fonts/`), indexadas en un [`README.md`](file:///c:/Users/admin/Documents/01_Academico_IITA/iita/juego/README.md) enriquecido.
  4. Se registró la maniobra en el pergamino sagrado [`CRONICA_DE_CAMPO.md`](file:///c:/Users/admin/Documents/01_Academico_IITA/iita/juego/CRONICA_DE_CAMPO.md).
- **Impacto y Consecuencias:**  
  El ecosistema de desarrollo queda dotado de un pipeline predecible y desacoplado, donde cada rol especializado sabe con exactitud cuándo intervenir y cómo auditar su trabajo sin fricción.

---

### 📌 Acta N° 012 — Decreto de Guardia Imperial Permanente y Preparación de la Arquitectura del Gestor Comercial (Fase 2: El 'Gerente' de Clientes y Pedidos)
- **Sello Temporal:** `2026-10-10 20:53:20`
- **Especialista / Agente Involucrado:** Desarrollador, Orquestador & Secretario Cronista Imperial (`/secretario`).
- **Contexto y Problema:**  
  El desarrollador proclamó formalmente el **Mandato Imperial de Vigilancia Continua**: el Secretario Cronista Imperial no debe detenerse bajo ninguna circunstancia a menos que se reciba la orden explícita `/secretario detener` o se apague físicamente el equipo de cómputo. Concomitantemente, se impartió la orden de iniciar de inmediato los preparativos técnicos para la concepción del "Gerente" (los módulos gestores comerciales y de clientes de la Fase 2: cola de compradores, generación procedural de encargos con ventanas de paciencia, pedidos de armas/herramientas, entregas en mostrador y máquinas de estados finitos desacopladas).
- **Decisión Adoptada:**  
  1. **Instauración de Guardia Perpetua:** El Secretario asume custodia activa e ininterrumpida de `CRONICA_DE_CAMPO.md`, auditando en segundo plano cada archivo creado, modificado o refactorizado por los agentes especialistas sin interrumpir el flujo productivo.
  2. **Arquitectura del Sistema Gestor ("Gerente" / Fase 2):** Se define la base técnica preliminar para el bucle comercial:
     - **Gestor Central Comercial (`OrderManager.gd` / `CustomerManager.gd`):** Singleton o nodo gestor en escena responsable del ciclo de vida de los clientes, control de aforo en la tienda y despacho de pedidos.
     - **Modelado de Clientes (`CustomerData.gd` / `Customer.tscn`):** Estructura orientada a datos (`Resource` o entidad tipada) con perfiles diferenciados (Campesinos con demandas de azadones y paciencia media-alta, Soldados con demandas de espadas y paciencia estricta, Nobles con encargos de alto valor y margen de error cero).
     - **Máquina de Estados de Clientes (FSM):** Estados limpios (`APPROACHING` -> `WAITING_ORDER` -> `CONSIDERING` -> `LEAVING_SATISFIED` / `LEAVING_ANGRY`).
     - **Interfase de Mostrador (`CounterArea`):** Extensión del patrón `InteractableArea` ya probado en el yunque y la cama, comunicada por señales desacopladas con el HUD de pedidos y el inventario del taller.
  3. **Orquestación de Especialistas para la Fase 2:**
     - `/programador_godot`: Arquitectura GDScript 4 tipada, FSM de clientes, colas FIFO seguras y balance de paciencia.
     - `/disenador_grafico`: Siluetas distintivas de clientes, colores según clase social (campesino, guardia, burgués) y feedback visual de urgencia cromática (verde a ámbar a rojo según decae la paciencia).
     - `/sonidista`: Paisaje sonoro comercial (campanilla de entrada en bus SFX con pitch jitter $\pm 5\%$, tintineo de monedas al cobrar, quejas amortiguadas al enfurecerse).
     - `/game_feel`: Animación elástica de entrega de pedidos (squash & stretch al depositar el arma sobre el mostrador, trauma shake leve si el cliente se marcha enfurecido).
     - `/playtester`: Batería de estrés de clientes simultáneos, tiempos límite en $t=0$, transiciones de pedidos con inventario vacío y verificación de softlocks en el mostrador.
- **Impacto y Consecuencias:**  
  La memoria del proyecto queda sellada bajo custodia permanente; el equipo dispone de un blueprint inequívoco para codificar la Fase 2 minimizando el acoplamiento y previniendo deuda técnica.

---

### 📌 Acta N° 001 [Directiva Oficial del Administrador] (Secuencia Histórica N° 013) — Reestructuración Integral de la Fase 1 según GDD Canónico (`docs/idea.txt`)
- **Sello Temporal:** `2026-10-10 21:22:45`
- **Especialista / Agente Involucrado:** Administrador (Director de Operaciones), Desarrollador & Secretario Cronista Imperial (`/secretario`).
- **Contexto y Problema:**  
  Tras la evaluación del prototipo greybox preliminar y la revisión de la arquitectura, el Administrador proclamó formalmente la directiva canónica de reestructuración para la Fase 1. Se identificó la necesidad imperativa de supeditar cada decisión espacial, mecánica y narrativa estrictamente al Documento de Diseño de Juego canónico ([`docs/idea.txt`](file:///c:/Users/admin/Documents/01_Academico_IITA/iita/juego/docs/idea.txt)), rescatando el prólogo narrativo emocional y consagrando el núcleo de perspectiva dual táctil sin atajos ni ventanas flotantes secundarias.
- **Decreto Oficial del Administrador (Cuatro Mandatos Fundacionales):**  
  1. **Reestructuración de la Fase 1 basada estrictamente en `docs/idea.txt`:**  
     El GDD maestro se ratifica como la única e inviolable fuente de verdad del proyecto. Ningún componente lúdico, cinemático o arquitectónico puede desviar los principios allí plasmados sin orden explícita. Todo el pipeline de la Fase 1 se alinea para reflejar la simulación de oficio y la tensión sociopolítica progresiva.
  2. **Comienzo del Juego en el Exterior (Prólogo Onboarding & Carta de la Madre):**  
     - El punto de aparición inicial del jugador no ocurre en interiores, sino en el **exterior, en el centro de un pueblo venido abajo** (calles de barro, maderas podridas, casas derruidas, ausencia de faroles nocturnos).
     - Al despertar, se despliega de inmediato a pantalla completa la **Carta de la Madre en pergamino rústico**: un mensaje cargado de ternura e inocencia donde pide perdón a su hijo por haberlo enviado a ese rincón olvidado y decadente, convencida de que su hermano (el tío herrero) se retiró pacíficamente o marchó de viaje, creyendo con absoluta buena fe que esta es la única forma de que su hijo aprenda un oficio digno y cultive la sabiduría.
     - Al cerrar el pergamino, aparece una **flecha indicadora en el suelo** que guía al jugador a través de callejones desolados hasta la casa andrajosa y cubierta de telarañas del tío.
  3. **Arquitectura Espacial de la Casa del Tío (Topología de Pasillo Distribuidor):**  
     - La vivienda del tío herrero se rediseña como un recinto unificado articulado por una **Entrada / Pasillo distribuidor central** que distribuye el tránsito de manera estanca y lógica hacia tres áreas fundamentales:
       * *Habitación / Taller de Trabajo:* Área del negocio con mostrador hacia la calle, espacio de forja y depósito de herramientas.
       * *Dormitorio:* Habitación íntima provista de una cama interactiva (🛏️) para el descanso voluntario y recuperación de energía antes del límite de medianoche (00:00).
       * *Acceso a la Mina:* Puerta trasera andrajosa y desgastada que conduce a la entrada de los túneles subterráneos.
  4. **Mandato Clave de Gameplay (Transición Cenital ➔ Estación en Primer Plano Estilo Papa's):**  
     - Al traspasar el umbral e ingresar a la habitación de trabajo, la cámara Top-Down 2D cenital cesa de inmediato.
     - El juego pasa automáticamente a una **estación interactiva a pantalla completa dedicada en primer plano** (estilo *Papa's Freezeria* / *Potion Punch*), eliminando el control del avatar caminante y transfiriendo el protagonismo a la interacción directa con el puntero y clics del mouse:
       * *Fragua / Crisol:* Control térmico táctil regulando el flujo de aire y accionamiento del fuelle hasta la temperatura exacta requerida.
       * *Yunque Interactivo:* Martillo reactivo que golpea con precisión física y retroalimentación rítmica exactamente sobre las coordenadas donde el usuario hace clic, deformando y moldeando dinámicamente el metal al rojo vivo según los puntos de impacto.
       * *Estación de Corte & Conformado:* Herramientas de cizalla y desbaste para dimensionar las piezas.
       * *Tina de Templado:* Inmersión interactiva en agua fría con retroalimentación acústica característica (*tsss*) y desprendimiento volumétrico de vapor.
- **Alternativas Evaluadas y Descartadas:**  
  - *Mantener la forja como una ventana emergente o popup modal sobre el mapa top-down:* Descartado enérgicamente por el Administrador. Reduce la artesanía a un minijuego superficial y rompe la inmersión táctil manual que define el núcleo jugable de la obra.
  - *Aparición inicial dentro del taller:* Descartado. Oculta el contexto socioeconómico del pueblo en ruinas y priva al jugador de la conexión emocional establecida por la carta de su madre.
- **Impacto y Consecuencias:**  
  Reconfiguración inmediata del diseño de escenas en Godot 4: desacoplamiento técnico entre la escena de exploración cenital (`TownExterior.tscn`, `UncleHouse.tscn`) y la escena de interfaz táctil en primer plano (`ForgeStationView.tscn`), creación del sistema de cartas/pergaminos modales a pantalla completa y establecimiento de la física de deformación reactiva en el yunque por clics.

---

### 📌 Acta N° 002 [Directiva del Administrador Ejecutada] (Secuencia Histórica N° 014) — Culminación Exitosa y Verificación de la Reestructuración de Fase 1
- **Sello Temporal:** `2026-10-10 21:47:42`
- **Especialista / Agente Involucrado:** Administrador (Director de Operaciones), Desarrollador, Tribunal de Revisión Multi-Modelo ([`/revision`](file:///C:/Users/admin/.gemini/config/skills/revision/SKILL.md)), Programador Godot ([`/programador_godot`](file:///C:/Users/admin/.gemini/config/skills/programador_godot/SKILL.md)), Diseñador de Niveles ([`/disenador_de_niveles`](file:///C:/Users/admin/.gemini/config/skills/disenador_de_niveles/SKILL.md)), Game Feel ([`/game_feel`](file:///C:/Users/admin/.gemini/config/skills/game_feel/SKILL.md)) & Secretario Imperial ([`/secretario`](file:///C:/Users/admin/.gemini/config/skills/secretario/SKILL.md)).
- **Contexto y Problema:**  
  Ejecución completa e integración rigurosa de la directiva de reestructuración de la Fase 1 dictada en el Acta N° 001/013, alineando el proyecto 1:1 con el Documento de Diseño de Juego canónico ([`docs/idea.txt`](file:///c:/Users/admin/Documents/01_Academico_IITA/iita/juego/docs/idea.txt)) y resolviendo las aclaraciones del desarrollador.
- **Implementación Técnica Entregada:**  
  1. **Prólogo en el Exterior y Carta de la Madre (`PrologueLetter.tscn` / `.gd`):**  
     - El jugador despierta en el centro del pueblo decadente (`GreyboxTown.tscn`), rodeado de texturas rústicas y maderas desgastadas.
     - Se despliega de forma inmediata a pantalla completa la *Carta de la Madre* en pergamino rústico bajo la paleta de autor (`#211a16`, `#6e1f2b`, `#f2e6cc`, `#b59a6a`).
     - Al presionar "Comenzar Viaje", la carta se desvanece suavemente y una flecha indicadora dorada en el suelo guía al jugador a través del callejón directamente hacia la entrada de la casa del tío.
  2. **Arquitectura Espacial de la Casa del Tío con Pasillo Distribuidor:**  
     - En `GreyboxTown.tscn`, el interior de la casa del tío se modeló con una entrada/pasillo central distribuidor estanco que interconecta de forma limpia 3 ambientes:
       * *Dormitorio:* Habitación íntima con cama interactuable (`InteractableArea.gd`) lista para el sistema de descanso y recuperación de estamina antes de medianoche (00:00).
       * *Acceso a la Mina:* Entrada trasera andrajosa con túnel interactuable que advierte sobre la necesidad de herramientas para descender a las profundidades.
       * *Umbral del Taller:* Zona de acceso que detecta la entrada del jugador para efectuar la transición al modo de forja.
  3. **Estación de Forja Interactiva a Pantalla Completa (`WorkshopStationView.tscn` / `.gd`):**  
     - Al cruzar el umbral del taller, la cámara cenital se apaga y el juego transiciona automáticamente a una interfaz dedicada a pantalla completa en primer plano (estilo *Papa's Games / Potion Punch*).
     - La experiencia prescinde del avatar y opera mediante clics directos sobre 4 estaciones de manufactura táctil:
       * *Estación 1: Fragua / Crisol:* Barra térmica con enfriamiento dinámico en `_process`. El jugador acciona el fuelle mediante clics para insuflar aire y elevar la temperatura hasta la zona óptima dorada.
       * *Estación 2: Yunque Interactivo:* Pieza de lingote al rojo vivo con puntos de deformación. Cada clic en el área instancia dinámicamente un martillo interactivo (`HammerEffect.tscn` / `.gd`) en las coordenadas exactas del ratón, ejecutando una animación de impacto elástico, deformando la barra metálica y emitiendo sonido de repique.
       * *Estación 3: Estación de Corte:* Cizalla interactiva con cuchilla animada que recorta rebabas y desbasta la pieza según la precisión del jugador.
       * *Estación 4: Tina de Templado:* Inmersión interactiva de la pieza en agua fría, activando enfriamiento rápido, columnas volumétricas de vapor y el clásico efecto sonoro *TSSSS*.
     - **Ticket de Calificación de 4 Estaciones:** Panel evaluador que calcula el rendimiento porcentual por estación (Fragua, Forja, Corte, Templado), otorga monedas de oro a `GameManager.gd` y permite reintegrarse de forma limpia a la vista top-down con tecla Escape o botón de retorno.
- **Verificación Técnica & QA:**  
  - **Ejecución Headless con Godot 4.7.2:** Se validó el proyecto completo sin ventana gráfica (`--headless --quit-after 50`). Resultado: **0 errores de compilación, 0 advertencias críticas y código de salida 0**.
  - **Auditoría Multi-Modelo Externa ([`/revision`](file:///C:/Users/admin/.gemini/config/skills/revision/SKILL.md)):** Se auditaron exhaustivamente los nuevos scripts y nodos. Se implementaron comprobaciones defensivas (`is_instance_valid`), recolección segura de tweens para evitar fugas de memoria, encapsulación de señales y verificación de contraste cromático WCAG 2.1 AAA.
- **Impacto y Consecuencias:**  
  La Fase 1 queda formalmente concluida y validada. El proyecto cuenta con el prólogo narrativo, la topología arquitectónica de autor y el bucle artesanal táctil en primer plano plenamente funcionales. El sistema queda listo para abordar la Fase 2 (Gestión Comercial con Clientes/Pedidos y Minería).

---

### 📌 Acta N° 003 [Dirección del Administrador & Usuario] (Secuencia Histórica N° 015) — Aprobación del Plan Maestro de Rediseño de Inmersión Táctil (*Repair This!* / *No Umbrellas Allowed*) y Oclusión Estanca Espacial
- **Sello Temporal:** `2026-10-10 22:14:02`
- **Especialista / Agente Involucrado:** Administrador (Director de Operaciones), Desarrollador/Usuario & Secretario Cronista Imperial ([`/secretario`](file:///C:/Users/admin/.gemini/config/skills/secretario/SKILL.md)).
- **Contexto y Problema:**  
  Tras la entrega del prototipo de Fase 1, el Director de Operaciones y el Desarrollador evaluaron la experiencia lúdica e identificaron la oportunidad de elevar drásticamente la inmersión, el misterio y la visceralidad táctil. Se determinó que ver las tres habitaciones simultáneamente restaba intriga espacial a la casa del tío, y que las estaciones de trabajo debían abandonar cualquier rezago de botones abstractos para emular la profundidad física de simuladores inmersivos de reparación e inspección comercial como *Repair This!* y *No Umbrellas Allowed*.
- **Decisiones Arquitectónicas y Pilares Aprobados:**  
  1. **Reestructuración Espacial y Oclusión Estanca de la Casa del Tío:**  
     - *Distribución Cardinal Estricta del Pasillo Central:*  
       * **Puerta Izquierda:** Taller de Trabajo y Mostrador de Clientes.  
       * **Puerta Frente:** Acceso andrajoso a la Mina subterránea.  
       * **Puerta Derecha:** Dormitorio privado con cama interactuable (🛏️).  
     - *Sistema de Oclusión Estanca de Salas (Fog / Room Occlusion):* Ninguna habitación revela su interior, mobiliario o iluminación hasta que el avatar cruza físicamente su umbral. El jugador solo puede percibir visualmente el recinto en el que se encuentra su personaje; las habitaciones adyacentes permanecen ocultas en penumbra absoluta, previniendo spoilers visuales y reforzando la atmósfera de suspenso.
  2. **Rediseño del Taller en Primera Persona Táctil (*Repair This!* / *No Umbrellas Allowed*):**  
     - *Mostrador de Atención al Cliente:* Ventana frontal de despacho con timbre de bronce interactivo, bandeja receptora de encargos, diálogo orgánico de aldeanos/emisarios feudales y bandeja de entrega del producto final.  
     - *Estaciones Táctiles de Forja Real (Sin Botones Abstractos):*  
       * **Fragua:** Regulación térmica viva; control físico del flujo de aire (fuelle interactivo) y retroalimentación de calor incandescente en tiempo real.  
       * **Yunque Cenital Orgánico:** Perspectiva cenital superior sobre la pieza metálica; martillado directo donde cada impacto deforma físicamente la geometría del lingote en los puntos de contacto exactos.  
       * **Corte Manual:** Arrastre sostenido de cizalla a lo largo del contorno marcado de la pieza, requiriendo pulso y precisión manual.  
       * **Tina de Templado (Drag & Hold):** Inmersión manual sostenida; enfriamiento térmico cromático dinámico (transición visible de naranja/rojo incandescente a gris acero templado) acompañado de desprendimiento de vapor volumétrico y siseo acústico (*TSSSS*).  
       * **Estación de Pulido:** Frotado manual sobre muela/piedra de afilar para eliminar asperezas y revelar el brillo del filo.  
       * **Calificación Matemática Estricta (0-100%):** Algoritmo riguroso que evalúa desviaciones reales milimétricas y castiga errores de temperatura, golpeo desalineado, corte irregular o templado defectuoso, afectando directamente la reputación del taller y la paga del cliente.
- **Impacto y Consecuencias:**  
  Se redefine el estándar de excelencia mecánica del juego: la casa se convierte en un laberinto íntimo y lleno de secretos con oclusión de visión, y el taller se consagra como un simulador táctil manual de autor, erradicando botones convencionales en favor de la pura interacción háptica y física.

---

### 📌 Acta N° 004 [Directiva del Administrador Ejecutada] (Secuencia Histórica N° 016) — Culminación Exitosa de la Reestructuración Espacial y del Taller y Forja 2.0
- **Sello Temporal:** `2026-10-10 22:27:10`
- **Especialista / Agente Involucrado:** Administrador (Director de Operaciones), Desarrollador/Usuario, Tribunal de Revisión Multi-Modelo con Nvidia Nemotron 550B ([`/revision`](file:///C:/Users/admin/.gemini/config/skills/revision/SKILL.md)), Programador Godot ([`/programador_godot`](file:///C:/Users/admin/.gemini/config/skills/programador_godot/SKILL.md)), Diseñador de Niveles ([`/disenador_de_niveles`](file:///C:/Users/admin/.gemini/config/skills/disenador_de_niveles/SKILL.md)), Game Feel ([`/game_feel`](file:///C:/Users/admin/.gemini/config/skills/game_feel/SKILL.md)) & Secretario Cronista Imperial ([`/secretario`](file:///C:/Users/admin/.gemini/config/skills/secretario/SKILL.md)).
- **Contexto y Problema:**  
  Ejecución técnica y culminación de los compromisos adoptados en el Acta N° 003. Era imperativo resolver la reestructuración física de las tres habitaciones de la casa del tío incorporando niebla de oclusión espacial, e implementar la suite completa del Taller 2.0 con interacción puramente táctil, libre de abstracciones o botones artificiales.
- **Implementación Entregada y Módulos Validados:**  
  1. **Reestructuración Espacial y Oclusión Estanca (`GreyboxTown.tscn` / `.gd`):**  
     - Reordenamiento cardinal estricto del pasillo distribuidor: **Puerta Izquierda** (Taller de Trabajo), **Puerta Frente** (Acceso a la Mina) y **Puerta Derecha** (Dormitorio con cama interactuable).  
     - Sistema de Oclusión Estanca de Salas: Niebla/penumbra absoluta sobre los recintos donde el avatar no está físicamente presente; las habitaciones adyacentes permanecen ocultas hasta traspasar su umbral.
  2. **Suite Táctil del Taller y Forja 2.0 en Primera Persona:**  
     - *Mostrador de Atención al Cliente (`CounterShopView.tscn` / `.gd`):* Inspirado en *Repair This!* y *No Umbrellas Allowed*, con campana interactiva con feedback físico y acústico, sistema de diálogo orgánico con facciones del reino (Sargento Godofredo, campesino), comanda rústica con especificaciones de pedido y bandeja interactiva de cobro y entrega.  
     - *Yunque Cenital Orgánico (`AnvilTopDownStation.tscn` / `.gd`):* Deformación física procedural en tiempo real mediante `Polygon2D`, desplazando y achatando los vértices en los puntos exactos impactados por el martillo interactivo (`HammerEffect.tscn`).  
     - *Corte Manual (`ManualCutStation.tscn` / `.gd`):* Cizalla interactiva guiada manualmente por arrastre de cursor sobre el contorno físico marcado de la pieza forjada.  
     - *Tina de Templado con Inmersión Sostenida (`QuenchStation.tscn` / `.gd`):* Mecánica de arrastre y retención (*drag & hold*) con transmutación térmica en tiempo real (naranja incandescente -> rojo apagado -> gris acero templado), acompañada de columnas volumétricas de vapor y el siseo característico (*TSSSS*).  
     - *Estación de Pulido Manual (`PolishStation.tscn` / `.gd`):* Frotado táctil interactivo con piedra de afilar sobre la superficie de la hoja hasta descubrir el brillo del acero.  
     - *Orquestador y Calificación Estricta (`WorkshopStationView.tscn` / `.gd`):* Algoritmo de evaluación matemática ponderada (0-100%) sin notas infladas; castiga con severidad las desviaciones de temperatura, el martillado disperso, los cortes torcidos y el templado inadecuado.
  3. **Verificación Técnica & Auditoría Multi-Modelo:**  
     - **Ejecución Headless con Godot 4.7.2:** Comprobación integral superada con **0 errores y código de salida 0**.  
     - **Auditoría Multi-Modelo ([`/revision`](file:///C:/Users/admin/.gemini/config/skills/revision/SKILL.md)) con Nvidia Nemotron 550B:** Verificación exhaustiva aprobada; se confirmaron patrones defensivos de memoria (`is_instance_valid`), correcta atenuación y gestión de tweens, contrastes visuales WCAG 2.1 AAA de autor y arquitectura desacoplada por señales.
- **Impacto y Consecuencias:**  
  La experiencia de forja y taller alcanza un estándar de producción táctil de autor sobresaliente, convirtiendo a *Yunque & Sombra* en una obra mecánica, física y narrativa de primer nivel.

---

### 📌 Acta N° 005 [Dirección del Administrador & Usuario] (Secuencia Histórica N° 017) — Aprobación e Inicio de la Fase de Vestimenta Gráfica, Integración de Texturas y Playtesting
- **Sello Temporal:** `2026-10-10 22:35:22`
- **Especialista / Agente Involucrado:** Administrador (Director de Operaciones), Desarrollador/Usuario, Diseñador Gráfico ([`/disenador_grafico`](file:///C:/Users/admin/.gemini/config/skills/disenador_grafico/SKILL.md)), Programador Godot ([`/programador_godot`](file:///C:/Users/admin/.gemini/config/skills/programador_godot/SKILL.md)), Playtester ([`/playtester`](file:///C:/Users/admin/.gemini/config/skills/playtester/SKILL.md)) & Secretario Cronista Imperial ([`/secretario`](file:///C:/Users/admin/.gemini/config/skills/secretario/SKILL.md)).
- **Contexto y Problema:**  
  Con la arquitectura espacial estanca y la suite interactiva del Taller 2.0 completamente verificadas a nivel de código y geometría funcional (greybox), el Administrador y el Usuario proclamaron formalmente el pase a la siguiente fase crucial: vestir gráficamente los módulos del juego con una dirección de arte medieval artesanal de autor, transferir las texturas al árbol de nodos de Godot 4 y someter toda la experiencia a una suite de pruebas destructivas y playtesting automatizado para certificar la ausencia total de softlocks.
- **Mandatos y Tres Ejes Operativos Aprobados:**  
  1. **Concepción, Generación y Adquisición Segura de la Biblioteca Visual de Sprites:**  
     - Desarrollo y curaduría de la biblioteca de texturas rústicas y sprites coherentes con la paleta de autor (`#211a16`, `#6e1f2b`, `#d8c5a5`, `#f2e6cc`, `#b59a6a`), erradicando clichés y genéricos de IA:  
       * *Mostrador en Primera Persona:* Madera envejecida, remaches de hierro forjado, estilo *Repair This!*.  
       * *Campana de Bronce:* Acabado metálico con brillo dorado desgastado.  
       * *Retratos de Clientes y Facciones:* Siluetas y retratos detallados (Sargento Godofredo en cota de malla/capa bordó, campesino con arpillera y tizne).  
       * *Utensilios de Forja Cenital:* Yunque de acero macizo con pátina de uso, martillo de forja con mango de fresno, cizalla articulada de corte, tina de templado de roble con zunchos de hierro y piedra de afilar rugosa.  
       * *Suelos y Entorno:* Baldosas rústicas, tablones de madera crujiente y tierra apisonada para las diferentes salas.  
  2. **Integración de Texturas en Escenas de Godot 4 por `/programador_godot`:**  
     - Sustitución progresiva de los placeholders geométricos planos (`ColorRect` / siluetas debug) en `CounterShopView.tscn`, `AnvilTopDownStation.tscn`, `ManualCutStation.tscn`, `QuenchStation.tscn`, `PolishStation.tscn` y `GreyboxTown.tscn` por nodos `TextureRect`, `Sprite2D` y mallas texturizadas sin alterar la lógica de cálculo ni la cinemática.  
     - Preservación de la deformación en tiempo real de `Polygon2D` adaptada a texturas UV reactivas.  
  3. **Despliegue de Playtesting Automatizado y Certificación Antisoftlock por `/playtester`:**  
     - Creación y ejecución de scripts automatizados de prueba de estrés para simular interacciones continuas, spam de clics en la campana, transiciones repetidas de puertas en el pasillo y ciclos completos de forja a alta frecuencia.  
     - Emisión del Certificado de Robustez sin bloqueos lúdicos ni desincronización de estados antes de habilitar la Fase 2 comercial.
- **Impacto y Consecuencias:**  
  El proyecto efectúa el salto cualitativo definitivo de prototipo greybox a producción estética de autor con arte integrado y calidad de juego certificada contra errores y atascos.

#### 📜 Adenda Canónica al Acta N° 005 — Decreto Expreso del Usuario sobre Dirección de Arte Medieval Realista
- **Sello Temporal de la Adenda:** `2026-10-10 22:40:59`
- **Decreto Expreso del Usuario:**  
  *«Para 'Yunque & Sombra', se suspende la aplicación de la paleta personal de autor (#6e1f2b, etc.) para adoptar una dirección de arte 100% fidedigna y realista de herrería medieval (maderas de roble envejecido, hierro forjado al carbono, acero pulido, mampostería de granito, fuego incandescente natural, bronce envejecido y pergamino de oveja).»*
- **Fundamentación e Instrucción Técnica para `/disenador_grafico`:**  
  La ambientación y la inmersión diegética priman sobre cualquier dogma estilístico previo. El arte visual no empleará tonos bordó/carmín artificiales como acentos arbitrarios, sino que responderá a la cromática orgánica y química de los materiales medievales auténticos:
  * **Maderas:** Roble y fresno curtido por el hollín, intemperie y aceite de linaza.
  * **Metales:** Hierro forjado al carbono oscuro/martillado, acero pulido en filos y biseles, y bronce oxidado por el paso del tiempo.
  * **Piedra:** Granito rústico, mortero de cal y ladrillos refractarios de fragua.
  * **Fuego & Calor:** Gradientes físicos naturales de radiación de cuerpo negro (amarillo blanco $\to$ naranja vivo $\to$ rojo cereza profundo $\to$ ceniza).
  * **Documentos:** Pergamino de oveja desgastado por el humo y tintas ferrogálicas.

---

### 📌 Acta N° 006 [Directiva del Administrador Ejecutada] (Secuencia Histórica N° 018) — Culminación de la Suite Gráfica Medieval Realista y Certificación Adversarial de QA (100% Antisoftlock)
- **Sello Temporal:** `2026-10-10 23:09:16`
- **Especialista / Agente Involucrado:** Administrador (Director de Operaciones), Desarrollador/Usuario, Diseñador Gráfico ([`/disenador_grafico`](file:///C:/Users/admin/.gemini/config/skills/disenador_grafico/SKILL.md)), Programador Godot ([`/programador_godot`](file:///C:/Users/admin/.gemini/config/skills/programador_godot/SKILL.md)), Playtester ([`/playtester`](file:///C:/Users/admin/.gemini/config/skills/playtester/SKILL.md)) & Secretario Cronista Imperial ([`/secretario`](file:///C:/Users/admin/.gemini/config/skills/secretario/SKILL.md)).
- **Contexto y Problema:**  
  Tras decretarse la dirección de arte medieval realista en la Adenda al Acta N° 005, se requería materializar e integrar la suite gráfica completa en Godot 4 sin placeholders, y certificar exhaustivamente mediante pruebas de estrés automatizadas que el bucle de juego carece de fisuras, softlocks o fugas de memoria.
- **Implementación Técnica Entregada:**  
  1. **Suite Gráfica Medieval Realista de Alta Fidelidad (12 Sprites de Autor):**  
     - `workshop_counter_bg.png`: Fondo panorámico del mostrador con arco de mampostería de granito y madera de roble envejecida.  
     - `service_bell.png`: Campana de bronce oxidado con animación elástica (squash & stretch) al tañer.  
     - `order_parchment.png`: Comanda rústica en piel de oveja natural con tintas ferrogálicas y especificaciones de pedido.  
     - `sergeant_portrait.png`: Retrato del Sargento Godofredo con cota de malla, jubón de paño oscuro y mirada severa.  
     - `peasant_portrait.png`: Retrato del Molinero / aldeano con jubón de arpillera, tizne de carbón y rostro demacrado.  
     - `anvil_topdown.png`: Yunque de acero macizo con pátina de uso montado sobre cepo de roble centenario.  
     - `blacksmith_hammer.png`: Martillo de forja con mango de madera de fresno y cabeza de acero al carbono pulida.  
     - `shear_tool.png`: Cizalla manual articulada de forja para desbaste y corte.  
     - `water_tub_topdown.png`: Tina de templado de duelas de roble con zunchos de hierro y agua oscura en calma.  
     - `whetstone.png`: Piedra de afilar arenisca novaculita con textura abrasiva de grano fino.  
     - `wood_floor.png`: Suelo continuo tileable de tablones de madera crujiente desgastada.  
     - `stone_floor.png`: Suelo continuo tileable de losas de piedra y granito rústico.  
  2. **Certificación de Jugabilidad y QA Adversarial ([`/playtester`](file:///C:/Users/admin/.gemini/config/skills/playtester/SKILL.md)):**  
     - Despliegue de la suite de pruebas automatizadas `tests/playtest_gameplay_loop.gd` ejecutada directamente en Godot 4.7.2:  
       * **111 de 111 aserciones aprobadas con éxito rotundo (100.0%)**.  
       * **0 fallas, 0 softlocks, 0 cuelgues o bloqueos de estado**.  
       * **Bucle Integral Validado de Extremo a Extremo:** Spawn exterior $\to$ Carta prólogo de la madre $\to$ Callejón hacia la casa $\to$ Oclusión estanca de salas (penumbra en habitaciones no visitadas) $\to$ Umbral del taller $\to$ Mostrador en 1ª persona (campana y diálogo) $\to$ Fragua (regulación térmica con fuelle y gasto de estamina) $\to$ Yunque (deformación orgánica de los 20 vértices de `Polygon2D`) $\to$ Corte manual $\to$ Tina de templado (viraje cromático térmico naranja $\to$ rojo $\to$ gris acero y vapor) $\to$ Pulido con piedra $\to$ Ticket ponderado (91.9%) $\to$ Cobro de recompensa (+22 monedas de oro) $\to$ Retorno fluido y limpio al pasillo.  
       * **Prueba de Estrés Continuo:** 5 ciclos consecutivos de apertura y cierre de estación completados sin fugas de memoria (`Tween` / `Node`) ni pérdida de colisiones.
- **Impacto y Consecuencias:**  
  *Yunque & Sombra* alcanza la categoría de obra madura, estética y matemáticamente blindada. Con la Fase 1 y la forja cerradas con certificación de excelencia, el camino queda despejado para la Fase 2 (Gestión Comercial Diurna y Exploración de la Mina Nocturna).

---

### 📌 Acta N° 007 [Dirección del Administrador & Usuario] (Secuencia Histórica N° 019) — Plan de Embellecimiento Visual del Taller y Corrección de Maquetación UI
- **Sello Temporal:** `2026-10-10 23:23:16`
- **Especialista / Agente Involucrado:** Administrador (Director de Operaciones), Desarrollador/Usuario, Ojos ([`/ojos`](file:///C:/Users/admin/.gemini/config/skills/ojos/SKILL.md)), Diseñador Gráfico ([`/disenador_grafico`](file:///C:/Users/admin/.gemini/config/skills/disenador_grafico/SKILL.md)), Programador Godot ([`/programador_godot`](file:///C:/Users/admin/.gemini/config/skills/programador_godot/SKILL.md)) & Secretario Cronista Imperial ([`/secretario`](file:///C:/Users/admin/.gemini/config/skills/secretario/SKILL.md)).
- **Contexto y Diagnóstico Ocular (`/ojos`):**  
  Tras la exitosa integración de la primera tanda de sprites y la certificación antisoftlock (Acta N° 006), una inspección visual en tiempo real del taller en ejecución reveló inconsistencias de maquetación y vacíos estéticos que menoscaban la inmersión:
  1. *Desfase en el Mostrador:* El sprite del cliente/soldado (`sergeant_portrait.png`) aparece desalineado y excéntrico respecto al vano del arco de granito de `workshop_counter_bg.png`.
  2. *Comanda Oculta:* El pergamino de pedido (`order_parchment.png`) presenta anclajes o escalas defectuosas en pantalla que provocan que quede cortado o parcialmente oculto tras elementos de la interfaz.
  3. *Fragua Rudimentaria:* La subestación de calor (`HeatStation`) depende de cajas de color plano (`ColorRect`) sin arte diegético, careciendo de un horno visualmente creíble, fuelle interactivo y lectura instrumental del calor.
  4. *Corte Manual Desfasado:* En `ManualCutStation`, las coordenadas de la cizalla y las rebabas de desbaste se proyectan con desfase espacial, saliéndose del área delimitada por el banco de trabajo.
  5. *Vacíos Negros en Taller:* Las vistas de las subestaciones exhiben fondos negros vacíos en lugar de un entorno interior coherente que sitúe al jugador dentro de una herrería medieval.
- **Decisión y Plan de Acción Acordado:**  
  Se aprueba de forma unánime un plan de dos frentes coordinados:
  1. **Despacho a `/disenador_grafico` — Generación de 4 Nuevos Assets Medievales Realistas:**  
     Bajo la directiva inmutable de realismo medieval (Adenda al Acta N° 005), se ordena la creación e integración de:
     - `assets/sprites/workshop/forge_hearth.png`: Horno de ladrillo refractario con campana de sillería de piedra y lecho de ascuas de carbón incandescente.
     - `assets/sprites/workshop/bellows_tool.png`: Fuelle manual de forja de cuero curtido reforzado con abrazaderas de hierro y tobera de bronce.
     - `assets/sprites/workshop/thermal_gauge.png`: Manómetro térmico medieval de esfera de latón envejecido y aguja indicadora de calor.
     - `assets/sprites/workshop/workshop_room_bg.png`: Fondo panorámico de interior de taller medieval (mampostería de granito, vigas de roble, herramientas colgadas y atmósfera de claroscuro).
  2. **Intervención de Maquetación por `/programador_godot`:**  
     - Reajustar anclajes y centrar con precisión milimétrica los retratos de clientes en el arco gótico del mostrador.
     - Corregir el layout y anclaje del pergamino de comanda para garantizar visualización y legibilidad inmediatas.
     - Reemplazar las cajas planas de `HeatStation` por el horno `forge_hearth.png`, incorporando la animación del fuelle `bellows_tool.png` y la aguja termométrica `thermal_gauge.png`.
     - Recalibrar el sistema de coordenadas de corte en `ManualCutStation`, confinando las rebabas estrictamente al plano del banco de trabajo.
     - Revestir los fondos negros con el fondo panorámico `workshop_room_bg.png`.
- **Impacto y Consecuencias:**  
  La experiencia diegética del taller alcanza paridad visual absoluta con la dirección de arte medieval realista decretada, suprimiendo cualquier vestigio de prototipo greybox y consolidando la base estética antes del despliegue del bucle comercial de clientes en la Fase 2.

---

### 📌 Acta N° 008 [Dirección del Administrador & Cuarteto Técnico] (Secuencia Histórica N° 020) — Culminación del Embellecimiento Visual del Taller y Certificación de Maquetación UI
- **Sello Temporal:** `2026-10-10 23:49:30`
- **Especialista / Agente Involucrado:** Administrador (Director de Operaciones), Desarrollador/Usuario, Ojos ([`/ojos`](file:///C:/Users/admin/.gemini/config/skills/ojos/SKILL.md)), Diseñador Gráfico ([`/disenador_grafico`](file:///C:/Users/admin/.gemini/config/skills/disenador_grafico/SKILL.md)), Programador Godot ([`/programador_godot`](file:///C:/Users/admin/.gemini/config/skills/programador_godot/SKILL.md)), Playtester ([`/playtester`](file:///C:/Users/admin/.gemini/config/skills/playtester/SKILL.md)) & Secretario Cronista Imperial ([`/secretario`](file:///C:/Users/admin/.gemini/config/skills/secretario/SKILL.md)).
- **Contexto y Ejecución de la Maniobra:**  
  En estricto cumplimiento del plan aprobado en el Acta N° 007, el equipo técnico culminó la producción visual de alta fidelidad, el ensamblaje de assets y la reconfiguración ergonómica de la interfaz de usuario en el taller de forja:
  1. *Inspección Ocular con `/ojos` y Desacoplamiento del Mostrador:*  
     Se corroboró mediante capturas reales la eliminación definitiva del solapamiento espacial: la caja de diálogo fue reubicada en el flanco izquierdo bajo el vano de la ventana, mientras que la comanda de pergamino (`order_parchment.png`) fue ampliada y reubicada sobre el mostrador de roble a la derecha, garantizando que el botón de aceptación quede 100% visible, despejado e interactivo.
  2. *Transformación Visual Diegética de la Fragua (`HeatStation`):*  
     Se erradicaron las cajas planas de color (`ColorRect`), sustituidas por el nuevo horno de forja de ladrillos refractarios con lecho de brasas al rojo cereza (`forge_hearth.png`), situando el lingote directamente sobre el fuego. Se integró el fuelle de cuero artesanal (`bellows_tool.png`) con feedback elástico (*squash & stretch*) al soplar aire, y el manómetro térmico de latón (`thermal_gauge.png`) dotado de una aguja analógica funcional en rotación angular sincronizada con la temperatura física de la pieza.
  3. *Alineación Geométrica de Corte (`ManualCutStation`):*  
     Las rebabas del lingote fueron recalibradas en sus coordenadas de corte para ajustarse con precisión a las aristas del clavo, suprimiendo el desfase perimetral detectado en la esquina.
  4. *Fondo Ambiental Continuo (`workshop_room_bg.png`):*  
     Se integró el fondo panorámico de interior de taller (mampostería de granito, vigas de roble y atmósfera de claroscuro) detrás de la totalidad de las estaciones de trabajo, extinguiendo todo vacío negro en pantalla.
  5. *Revalidación Total de QA Automatizado en Godot 4.7.2:*  
     La suite `tests/playtest_gameplay_loop.gd` fue ejecutada de forma automatizada sobre la nueva maquetación, ratificando:  
     - **111 de 111 aserciones aprobadas al 100.0%**.  
     - **0 errores, 0 fallas y 0 softlocks** a lo largo de todo el ciclo de forja y transición de salas.
- **Impacto y Consecuencias:**  
  El taller en primera persona alcanza la madurez estética, ergonómica y funcional definitiva. Con las 4 estaciones de forja diegéticas plenamente integradas, visualmente armónicas con el realismo medieval decretado y certificadas contra todo bloqueo, el proyecto queda formalmente habilitado para el arranque de la Fase 2 (Bucle Comercial Diurno y Minería Subterránea).

---

### 📌 Acta N° 009 [Directiva del Administrador & Usuario Ejecutada] (Secuencia Histórica N° 021) — Restauración Integral de Mecánicas Táctiles del Taller (Tijera Drag & Release, Fuelle Térmico, Coordenadas Estancas) e Integración de Paisaje Sonoro Completo (Audio Foley / SFX)
- **Sello Temporal:** `2026-10-11 00:15:00`
- **Especialista / Agente Involucrado:** Administrador (Director de Operaciones), Desarrollador/Usuario, Sonidista ([`/sonidista`](file:///C:/Users/admin/.gemini/config/skills/sonidista/SKILL.md)), Programador Godot ([`/programador_godot`](file:///C:/Users/admin/.gemini/config/skills/programador_godot/SKILL.md)), Game Feel ([`/game_feel`](file:///C:/Users/admin/.gemini/config/skills/game_feel/SKILL.md)), Playtester ([`/playtester`](file:///C:/Users/admin/.gemini/config/skills/playtester/SKILL.md)) & Secretario Cronista Imperial ([`/secretario`](file:///C:/Users/admin/.gemini/config/skills/secretario/SKILL.md)).
- **Contexto y Problema Detectado:**  
  Tras la vestimenta estética del taller, el usuario identificó tres desajustes críticos que degradaban la experiencia lúdica:
  1. La fragua presentaba bloqueo en el fuelle (`BtnBellows`), no respondiendo con fluidez al clic para elevar la temperatura.
  2. El corte manual de rebabas estaba bugueado por arrastre de puntos inconexos; el usuario decretó transformar la mecánica en una experiencia de **tijera táctil** (mantener presionado, arrastrar una línea de corte con un límite de ~1 cm / 20-40 px que trace la incisión, y al soltar ejecutar el corte con separación física del sobrante).
  3. Ausencia total de sonido en el taller, tornando la experiencia monótona e inerte.
- **Implementación Técnica Entregada:**  
  1. *Generación y Síntesis Procedural de Audio Foley (`scripts/generate_foley_sfx.py`):*  
     Se concibió un sintetizador de audio procedural en Python a 44.1 kHz, 16 bits mono sin compresión, generando 10 efectos de sonido orgánicos diegéticos en `assets/audio/sfx/`:
     - `bell_ring.wav`: Campana de mostrador resonante en bronce.
     - `bellows_air.wav`: Golpe de aire y soplido rústico de fuelle de cuero.
     - `fire_crackle.wav`: Crepitar de ascuas y carbón encendido.
     - `anvil_hit_1.wav`, `anvil_hit_2.wav`, `anvil_hit_3.wav`: Golpes de martillo sobre acero con diferente masa y timbre metálico.
     - `shear_snip.wav`: Chasquido metálico y crujido de corte de tijera/cizalla.
     - `quench_steam.wav`: Siseo continuo de vapor y choque térmico de inmersión (*TSSSS*).
     - `whetstone_scrape.wav`: Raspado áspero de grano abrasivo sobre hoja de metal.
     - `coins_clink.wav`: Tintineo brillante de monedas de oro al cobrar el encargo.
  2. *Autoload Maestro de Audio Resiliente (`src/autoloads/AudioManager.gd`):*  
     - Registrado como Autoload global en `project.godot`.  
     - Carga en caliente los buffers PCM de los archivos WAV en tiempo de ejecución (`AudioStreamWAV.new()` directo al array de bytes), eliminando dependencias de compilación anticipada o errores de `.import` en Godot headless.  
     - Integra un pool dinámico de 8 reproductores de SFX simultáneos, reproductor dedicado para el bucle continuo de vapor en la tina (`quench_steam_player`), y modulación aleatoria de tono (*pitch jitter* $\pm 5\% - 8\%$) para erradicar el efecto ametralladora.
  3. *Reparación y Desbloqueo del Fuelle de Fragua (`HeatStation`):*  
     - Se configuró `mouse_filter = 2 (IGNORE)` sobre `BellowsIcon` y `BellowsLabel`, garantizando que cualquier clic en la superficie del botón active `_on_bellows_pressed()`.  
     - Inyección del sonido `AudioManager.play_bellows()` y consumo moderado de estamina sin deadlocks.  
     - Transición automática a la pestaña de fragua al aceptar la comanda en el mostrador.
  4. *Nueva Mecánica Táctil de Tijera Drag & Release (`ManualCutStation`):*  
     - Presionar y arrastrar traza una línea de corte elástica visible en tiempo real (`CutDragLine` / `Line2D`) con icono de cizalla rotatorio.  
     - Al superar el umbral de corte (~20-40 px / 1 cm) y soltar el ratón sobre la rebaba, se ejecuta el corte instantáneo: disparo de `AudioManager.play_snip()`, efecto visual emergente `¡SNIP!` y separación física animada por tween (caída por gravedad y rotación de la rebaba desprendida).
  5. *Blindaje de Coordenadas en Tina de Templado y Pulido:*  
     - Sustitución de llamadas inválidas a `to_local()` en nodos `Control` por `get_local_mouse_position()` y cálculo relativo contra el origen de los bancos de trabajo.  
     - Sincronización auditiva: inicio del vapor en bucle (`start_quench_steam()`) al sumergir las tenazas en agua y detención (`stop_quench_steam()`) al extraerlas; raspado de piedra (`play_whetstone()`) amortiguado durante el frotado.
  6. *Certificación de QA Automatizado (100% Passing):*  
     - Ejecución de `tests/playtest_gameplay_loop.gd` en Godot 4.7.2: **111 / 111 aserciones superadas (100.0%)**, 0 errores de compilación y 0 advertencias de script.
- **Impacto y Consecuencias:**  
  El taller alcanza excelencia táctil y acústica integral: los minijuegos son visceralmente responsivos, el corte opera como una herramienta física manual y el paisaje sonoro aporta peso, inmersión y satisfacción al oficio de la forja.

---

### 📌 Acta N° 010 [Directiva del Administrador & Usuario Ejecutada] (Secuencia Histórica N° 022) — Creación de la Skill Herrero Tradicional (`/herrero`), Mandato Anti-Divagación en GDD, Hispanización Total de Nodos del Taller y Desacoplamiento de Aguja del Manómetro
- **Sello Temporal:** `2026-10-11 00:55:00`
- **Especialista / Agente Involucrado:** Administrador (Director de Operaciones), Desarrollador/Usuario, Consultor Herrero Tradicional ([`/herrero`](file:///C:/Users/admin/.gemini/config/skills/herrero/SKILL.md)), Programador Godot ([`/programador_godot`](file:///C:/Users/admin/.gemini/config/skills/programador_godot/SKILL.md)), Diseñador Gráfico ([`/disenador_grafico`](file:///C:/Users/admin/.gemini/config/skills/disenador_grafico/SKILL.md)), Playtester ([`/playtester`](file:///C:/Users/admin/.gemini/config/skills/playtester/SKILL.md)) & Secretario Cronista Imperial ([`/secretario`](file:///C:/Users/admin/.gemini/config/skills/secretario/SKILL.md)).
- **Contexto y Problema Detectado:**  
  1. **Bug visual del manómetro térmico:** La textura original `thermal_gauge.png` tenía una aguja fija dibujada a 280°, provocando la ilusión óptica de "dos brújulas, una congelada". Además, la respuesta térmica requería calibración de inercia y atajo de teclado.
  2. **Barrera lingüística en el Inspector de Godot:** Los nodos en inglés dificultaban la lectura y edición directa por parte del usuario.
  3. **Riesgo de divergencia respecto a la idea central:** Se detectó la necesidad de blindar el flujo de trabajo obligando a leer `docs/idea.txt` antes de cualquier maniobra técnica.
  4. **Necesidad de asesoría de oficio puro:** El usuario solicitó un especialista de forja tradicional externa (`/herrero`) que juzgue el parecido con el trabajo real artesanal, sin meterse en código ni métricas de diseño de juego.
- **Implementación Técnica Entregada:**  
  1. *Engendrado de la Skill Consultor Herrero Tradicional (`/herrero`):*  
     - Creado en `C:\Users\admin\.gemini\config\skills\herrero\SKILL.md` con su tratado técnico en `teoria_herreria_artesanal.md`.
     - Evalúa exclusivamente la física del fuego, colores de incandescencia (escala de radiación de cuerpo negro), conservación de volumen bajo el martillo, temple martensítico y desprendimiento de cascarilla de óxido.
     - Integrado en `/arena herrero` y `/revision herrero`.
  2. *Mandato Anti-Divagación y Lectura Previa Obligatoria de `docs/idea.txt`:*  
     - Redactado e insertado en `docs/idea.txt §8.1`, `AGENTS.md` y `GEMINI.md`.
     - Obliga incondicionalmente a cada agente y modelo a leer el GDD supremo antes de tocar una sola línea de código o escena.
  3. *Hispanización Rigurosa del Árbol de Nodos (SceneTree en Español):*  
     - Todas las escenas del taller (`WorkshopStationView.tscn`, `CounterShopView.tscn`, `AnvilTopDownStation.tscn`, `ManualCutStation.tscn`, `QuenchStation.tscn`, `PolishStation.tscn`) renombradas al 100% en español (`PanelPrincipal`, `Cabecera`, `ContenedorPestanas`, `BotonAtizarFuelle`, `HornoFragua`, `SuperficieYunque`, `LingoteDeformable`, `BancoCorte`, `RebabaSuperior`, `PanelTina`, `BancoPulido`, etc.).
     - Todos los scripts acompañados con getters multilínea indentados para preservar retrocompatibilidad absoluta con arneses de prueba y código existente.
  4. *Desacoplamiento de la Aguja del Manómetro Térmico:*  
     - Regenerado `assets/sprites/workshop/thermal_gauge.png` con dial limpio sin aguja horneada.
     - Creado asset independiente `assets/sprites/workshop/gauge_needle.png` (24x90 px) con pivote central de latón y aguja de acero giratoria orientada según la temperatura.
     - Calibración de fuelle: +12.5°C por bombeo, decaimiento suave de 5.0°C/s y soporte de tecla Espacio.
  5. *Certificación QA Automatizada:*  
     - Suite `tests/playtest_gameplay_loop.gd` ejecutada en Godot 4.7.2 headless: **111 / 111 aserciones aprobadas (100.0%)**, 0 errores de compilación, 0 softlocks, 5/5 ciclos de estrés exitosos.
- **Impacto y Consecuencias:**  
  El entorno de desarrollo en Godot queda perfectamente claro para el usuario en su idioma natal, el manómetro térmico funciona de manera orgánica y sin confusión visual, y el proyecto queda blindado doctrinariamente contra el desvío creativo gracias al mandato de `docs/idea.txt` y la presencia del maestro `/herrero`.

---

### 📌 Acta N° 011 [Directiva del Administrador & Usuario Ejecutada] (Secuencia Histórica N° 031) — Atajos Ergonómicos de Teclado, Generación Determinista de Assets de Taller, Consolidación de Escenas Hispanizadas y Certificación QA (100% Passing)
- **Sello Temporal:** `2026-10-11 12:55:00`
- **Especialista / Agente Involucrado:** Administrador (Director de Operaciones), Desarrollador/Usuario, Consultor Herrero Tradicional ([`/herrero`](file:///C:/Users/admin/.gemini/config/skills/herrero/SKILL.md)), Programador Godot ([`/programador_godot`](file:///C:/Users/admin/.gemini/config/skills/programador_godot/SKILL.md)), Diseñador Gráfico ([`/disenador_grafico`](file:///C:/Users/admin/.gemini/config/skills/disenador_grafico/SKILL.md)), Playtester ([`/playtester`](file:///C:/Users/admin/.gemini/config/skills/playtester/SKILL.md)) & Secretario Cronista Imperial ([`/secretario`](file:///C:/Users/admin/.gemini/config/skills/secretario/SKILL.md)).
- **Contexto y Problema Detectado:**  
  Tras la hispanización y el diseño de la forja, se requería redondear la experiencia del usuario facilitando controles ergonómicos de teclado (evitar fatiga exclusiva de ratón), generar de forma autónoma y determinista el paquete de 5 sprites definitivos de alta resolución del taller sin depender de herramientas externas no reproducibles, consolidar la nomenclatura española en todos los árboles de escena y blindar los mandatos de workspace en las reglas del sistema para garantizar que ningún agente futuro diverja de los pilares del proyecto.
- **Implementación Técnica Entregada:**  
  1. **Atajos Ergonómicos de Teclado y Mapeo Input (`project.godot`):**  
     - Incorporación de tecla `Espacio` (keycode 32) como acción primaria (`action`) e interacción (`interact`), permitiendo atizar el fuelle en la fragua alternativamente con el teclado y activar interacciones con objetos del mundo.
     - Incorporación de tecla `Q` (keycode 81) en la acción `cancel_escape` junto a `Escape` (keycode 41), facilitando la salida ágil de ventanas, modales, cartas y retorno desde el taller al pasillo con la mano izquierda sobre la zona WASD.
  2. **Generación de los 5 Assets de Taller Medieval de Alta Fidelidad (`scripts/generate_workshop_assets.py`):**  
     - Generación determinista vía NumPy y PIL en `assets/sprites/workshop/`:
       * `forge_hearth.png` (540x360 px): Horno de ladrillo refractario con campana de sillería de piedra, lecho de carbón incandescente y sombra ambiental.
       * `bellows_tool.png` (320x240 px): Fuelle manual de forja de cuero curtido con tobera de bronce y abrazaderas de hierro.
       * `thermal_gauge.png` (240x240 px): Manómetro térmico medieval de latón con dial limpio sin aguja horneada.
       * `gauge_needle.png` (24x90 px): Aguja independiente de acero con pivote de latón desacoplada para rotación térmica dinámica.
       * `workshop_room_bg.png` (1280x720 px): Fondo panorámico completo del interior del taller (mampostería de granito, vigas de roble, herramientas colgadas, estante y claroscuro de brasas).
  3. **Consolidación y Verificación de Escenas Hispanizadas (`src/scenes/workshop/` y `src/scenes/levels/`):**  
     - `CounterShopView.tscn` / `.gd`: Nodos `FondoMostrador`, `MarcoVentana`, `ContenedorCliente`, `RetratoCliente`, `EtiquetaNombre`, `BandejaCobro`, `ComandaPergamino`, `CampanaServicio`, `BotonCampana`.
     - `WorkshopStationView.tscn` / `.gd`: Nodos `PanelPrincipal`, `Cabecera`, `ContenedorPestanas`, `BotonPestanaMostrador`, `BotonPestanaFragua`, `BotonPestanaYunque`, `BotonPestanaCorte`, `BotonPestanaTemplado`, `BotonPestanaPulido`.
     - `AnvilTopDownStation.tscn` / `.gd`, `ManualCutStation.tscn` / `.gd`, `QuenchStation.tscn` / `.gd`, `PolishStation.tscn` / `.gd`: Escenas 100% en español (`SuperficieYunque`, `LingoteDeformable`, `BancoCorte`, `PanelTina`, `BancoPulido`), manteniendo compatibilidad total con getters de apoyo.
  4. **Blindaje de Reglas de Workspace (`AGENTS.md` y `GEMINI.md`):**  
     - Formalización de los Mandatos Fundacionales:
       * *Mandato 1:* Lectura previa obligatoria de `docs/idea.txt` (§8.1) antes de proponer, refactorizar o codificar.
       * *Mandato 2:* Nombres de nodos del SceneTree en español obligatorio en todos los archivos de escena de Godot (`.tscn`).
       * *Mandato 3:* Arbitraje del Maestro Herrero (`/herrero`) para garantizar verosimilitud física y artesanal tradicional.
  5. **Certificación de QA Automatizado (100% Passing):**  
     - Ejecución de `tests/playtest_gameplay_loop.gd` con Godot 4.7.2 stable headless: **111 / 111 aserciones aprobadas al 100.0%**, 0 errores, 0 softlocks, 5 ciclos de estrés sin fugas de memoria.
     - Verificación de balance económico: monedas de oro de 50 iniciales a 72 (+22 cobradas por el encargo).
- **Impacto y Consecuencias:**  
  La experiencia del taller cuenta con ergonomía ampliada de teclado, assets visuales nítidos y reproducibles, nomenclatura unificada en español sin barreras idiomáticas, y blindaje de código y reglas con QA perfecto.

---


## 2. ⏳ Registro Cronológico de Maniobras Técnicas

Entradas secuenciales inmutables reconstruidas desde la sesión original en la carpeta `iita`:

| Entrada | Timestamp (Local) | Origen / Agente | Categoría | Resumen de la Maniobra Técnica |
| :---: | :---: | :---: | :---: | :--- |
| **#001** | `2026-10-08 17:07:59` | Desarrollador | Requerimiento | Solicitud de fundamentación conceptual sobre Godot Engine y viabilidad técnica. |
| **#002** | `2026-10-08 17:16:43` | Orquestador | Investigación | Consulta sobre protocolos de integración MCP para Godot. |
| **#003** | `2026-10-09 21:00:25` | Desarrollador | Planificación | Directiva de preparar el entorno con MCP Godot y otorgar la habilidad `/ojos` de forma permanente. |
| **#004** | `2026-10-10 18:51:29` | Desarrollador | Infraestructura | Orden de conectar el servidor MCP de Godot y trabajar con sprites genéricos preliminares. |
| **#005** | `2026-10-10 18:57:27` | Orquestador | Configuración | Modificación de `mcp_config.json` para dar de alta el servidor MCP de Godot. |
| **#006** | `2026-10-10 19:02:33` | Desarrollador | Arquitectura | Requerimiento de concebir la skill `/disenador_grafico` como subagente desacoplado con ojos obligatorios. |
| **#007** | `2026-10-10 19:11:38` | Orquestador | Implementación | Engendrado de `teoria_color_juegos.md` y `disenador_grafico/SKILL.md`. |
| **#008** | `2026-10-10 19:14:54` | Desarrollador | Arquitectura | Requerimiento de la skill `/sonidista` e integración desacoplada en `/arena` y `/revision`. |
| **#009** | `2026-10-10 19:24:24` | Orquestador | Implementación | Engendrado de `teoria_sonido_juegos.md`, `sonidista/SKILL.md` y refactorización de `arena/SKILL.md` y `revision/SKILL.md`. |
| **#010** | `2026-10-10 19:27:17` | Desarrollador | Arquitectura | Requerimiento de concebir la skill `/disenador_de_niveles` para arquitectura espacial y greyboxing. |
| **#011** | `2026-10-10 19:30:38` | Desarrollador | Arquitectura | Requerimiento de engendrar al cronista imperial de campo: skill `/secretario`. |
| **#012** | `2026-10-10 19:31:54` | Orquestador | Implementación | Engendrado de `teoria_level_design.md`, `disenador_de_niveles/SKILL.md`, `PERGAMINO_TEMPLATE.md` y `secretario/SKILL.md`. |
| **#013** | `2026-10-10 19:39:01` | Desarrollador | Arquitectura | Debate y aprobación para la incorporación de `/game_feel` y `/playtester`. |
| **#014** | `2026-10-10 19:51:50` | Orquestador | Implementación | Engendrado de `teoria_game_feel.md`, `game_feel/SKILL.md`, `protocolo_playtesting.md` y `playtester/SKILL.md`. |
| **#015** | `2026-10-10 19:56:34` | Desarrollador | Planificación | Inicio de la sesión formal en `iita/juego`: formulación y presentación del roadmap de 6 etapas para *Yunque & Sombra*. |
| **#016** | `2026-10-10 20:08:51` | Desarrollador | Apertura Canónica | Invocación de `/secretario`: aprobación del plan y generación oficial de `CRONICA_DE_CAMPO.md` con la reconstrucción histórica de `iita`. |
| **#017** | `2026-10-10 20:21:51` | Desarrollador & Equipo | Fase 0 & 1 | Redacción de `plan_de_accion.txt`, configuración de `project.godot`, Singletons `GameManager` y `TimeManager`, controlador `Player`, minijuego `MiniForge`, `MainHUD` y nivel `GreyboxTown`. Validación headless limpia en Godot 4 (0 errores). |
| **#018** | `2026-10-10 20:41:05` | Desarrollador & Cuarteto de Subagentes | Arquitectura & Organización | Creación de skill `/programador_godot` y `teoria_programacion_godot.md`, publicación de `docs/GUIA_DE_ETAPAS_Y_SKILLS.md`, estructuración de árbol `assets/` y asiento de Acta N° 011 en `CRONICA_DE_CAMPO.md`. |
| **#019** | `2026-10-10 20:53:20` | Desarrollador & Secretario Imperial | Mandato Imperial & Fase 2 | Proclamación del Mandato de Vigilancia Continua (guardia perpetua ininterrumpida), preparación técnica de la arquitectura del 'Gerente' (módulos gestores comerciales y de clientes de la Fase 2) y asiento del Acta N° 012. |
| **#020** | `2026-10-10 21:22:45` | Administrador | Directiva Canónica | Asiento del Acta N° 001 del Administrador: Reestructuración de la Fase 1 según `docs/idea.txt` (Prólogo exterior en pueblo decadente con Carta de la Madre en pergamino, casa con pasillo distribuidor de 3 áreas y transición de cámara cenital a estación de forja en primer plano a pantalla completa estilo Papa's con deformación interactiva al clic). |
| **#021** | `2026-10-10 21:47:42` | Administrador & Cuarteto Técnico | Culminación Fase 1 | Integración y validación de la reestructuración de Fase 1: Prólogo exterior con Carta de la Madre ('PrologueLetter.tscn'), casa del tío con pasillo distribuidor de 3 vías ('GreyboxTown.tscn'), y estación de forja en primer plano a pantalla completa ('WorkshopStationView.tscn') con 4 estaciones táctiles (fraguado, yunque interactivo con martillo por clic 'HammerEffect.tscn', corte y templado) y ticket evaluador. Verificado con Godot 4.7.2 headless (0 errores, código 0) y auditoría multi-modelo /revision. |
| **#022** | `2026-10-10 22:14:02` | Administrador & Usuario | Aprobación de Arquitectura | Aprobación del Plan Maestro de Rediseño de Inmersión Táctil (Acta N° 003): Distribución espacial fija en pasillo de la casa del tío (Izquierda: Taller, Frente: Mina, Derecha: Dormitorio) con oclusión estanca de salas (niebla/visibilidad solo en la habitación actual), y rediseño de forja en primera persona estilo 'Repair This!' y 'No Umbrellas Allowed' (mostrador con clientes y timbre, fragua viva, yunque cenital con deformación orgánica, corte manual por contorno, templado drag & hold con cambio cromático dinámico a gris acero, pulido en piedra y calificación matemática estricta 0-100%). |
| **#023** | `2026-10-10 22:27:10` | Administrador & Cuarteto Técnico | Culminación Taller 2.0 | Asiento del Acta N° 004: Culminación exitosa de la reestructuración espacial (puertas cardinales Izquierda=Taller, Frente=Mina, Derecha=Dormitorio con oclusión estanca de salas) y entrega de la suite del Taller y Forja 2.0 (Mostrador estilo Repair This! con campana y facciones, yunque cenital con Polygon2D deformable orgánicamente por impactos, corte manual por contorno, templado sostenido drag & hold con transmutación térmica en tiempo real naranja->rojo->gris acero con vapor y TSSSS, pulido manual en piedra y calificación ponderada estricta 0-100%). Verificado con Godot 4.7.2 headless (código 0) y auditoría multi-modelo (/revision) con Nvidia Nemotron 550B. |
| **#024** | `2026-10-10 22:35:22` | Administrador & Usuario | Directiva Canónica | Asiento del Acta N° 005: Aprobación formal e inicio de la Fase de Vestimenta Gráfica, Integración de Texturas y Playtesting (Desarrollo de biblioteca visual de autor: mostrador estilo Repair This!, campana de bronce, retratos de facciones, yunque, martillo, cizalla, tina y suelos; integración de texturas en Godot 4; y suite de playtesting automatizado antisoftlock). |
| **#025** | `2026-10-10 22:40:59` | Usuario | Decreto Expreso | Adenda al Acta N° 005: Suspensión de la paleta personal de autor (#6e1f2b, etc.) para 'Yunque & Sombra'. Adopción de dirección de arte 100% fidedigna y realista de herrería medieval (maderas de roble envejecido, hierro forjado al carbono, acero pulido, mampostería de granito, fuego incandescente natural, bronce envejecido y pergamino de oveja). |
| **#026** | `2026-10-10 23:09:16` | Playtester & Cuarteto Técnico | QA Adversarial & Arte | Asiento del Acta N° 006: Culminación de la Suite Gráfica Medieval Realista (12 sprites de alta fidelidad integrados en Godot 4) y Certificación de Jugabilidad sin softlocks (suite tests/playtest_gameplay_loop.gd: 111/111 aserciones aprobadas al 100.0%, 0 fallas, bucle completo validado de extremo a extremo de prólogo a cobro de 22 oro, y prueba de estrés de 5 ciclos continuos superada con 0 caídas y 0 fugas de memoria). |
| **#027** | `2026-10-10 23:23:16` | Administrador & Cuarteto Técnico | Diagnóstico Ocular & Plan Visual | Asiento del Acta N° 007: Diagnóstico ocular de /ojos (desfase de cliente respecto al arco, pergamino con anclajes ocultos, fragua con cajas planas sin arte, corte desfasado del banco y vacíos negros). Formulación y despacho del Plan de Embellecimiento Visual (generación de 4 nuevos assets por /disenador_grafico: forge_hearth, bellows_tool, thermal_gauge, workshop_room_bg) y corrección de maquetación UI por /programador_godot. |
| **#028** | `2026-10-10 23:49:30` | Administrador & Cuarteto Técnico | Culminación Visual & QA | Asiento del Acta N° 008: Culminación del Embellecimiento Visual del Taller y Certificación de Maquetación UI. Eliminación de solapamiento en mostrador (diálogo a la izquierda bajo la ventana, comanda ampliada a la derecha con botón visible), transformación diegética de la fragua (horno refractario 'forge_hearth.png', fuelle interactivo elástico 'bellows_tool.png' y manómetro analógico de latón funcional 'thermal_gauge.png'), alineación precisa de rebabas en corte manual, integración de fondo continuo 'workshop_room_bg.png' sin vacíos negros y revalidación total de playtesting automatizado en Godot 4.7.2 (111/111 aserciones aprobadas al 100.0%, 0 fallas, 0 softlocks). |
| **#029** | `2026-10-11 00:15:00` | Administrador, Sonidista & Equipo Técnico | Táctil & Audio Foley | Asiento del Acta N° 009: Restauración integral de mecánicas táctiles del taller e integración de paisaje sonoro completo. Síntesis de 10 SFX procedurales en WAV ('bell_ring', 'bellows_air', 'fire_crackle', 'anvil_hit_1/2/3', 'shear_snip', 'quench_steam', 'whetstone_scrape', 'coins_clink') e implementación del singleton resiliente 'AudioManager.gd' (autoload en 'project.godot' con decodificación directa de PCM en runtime y pitch jitter de +-8%). Reparación de mouse filters en fuelle de fragua ('mouse_filter = 2' en BellowsIcon y BellowsLabel para clics libres en todo el botón). Rediseño del corte manual a tijera táctil drag & release (arrastre elástico con 'Line2D' de ~1cm / 20-40px, sonido de snip y separación física/caída por tween de rebabas). Corrección de coordenadas relativas en tina y pulido ('get_local_mouse_position()'). Certificación en Godot 4.7.2 headless: 111/111 aserciones aprobadas (100.0%), 0 errores. |
| **#030** | `2026-10-11 00:55:00` | Administrador, Herrero & Equipo Técnico | Arquitectura & Oficio | Asiento del Acta N° 010: Creación de la skill '/herrero' y compendio de metalurgia artesanal. Mandato de lectura previa obligatoria de 'docs/idea.txt' (§8.1) y blindaje anti-divagación en AGENTS.md y GEMINI.md. Hispanización 100% de la jerarquía de nodos en Godot para todas las escenas del taller con getters retrocompatibles. Desacoplamiento de aguja giratoria ('gauge_needle.png') eliminando la aguja horneada de 'thermal_gauge.png'. Calibración de fuelle a +12.5°C por bombeo y pérdida de 5°C/s con tecla Espacio. Revalidación total de QA en Godot 4.7.2: 111/111 aserciones aprobadas (100.0%), 0 errores. |
| **#031** | `2026-10-11 12:55:00` | Administrador, Herrero & Equipo Técnico | Ergonomía, Assets & QA | Asiento del Acta N° 011: Mapeo de atajos ergonómicos de teclado en 'project.godot' (tecla Espacio en action/interact para fuelle alternativo y tecla Q en cancel_escape). Generación determinista de los 5 assets de taller medieval de alta fidelidad vía NumPy/PIL en 'scripts/generate_workshop_assets.py' ('forge_hearth.png', 'bellows_tool.png', 'thermal_gauge.png', 'gauge_needle.png', 'workshop_room_bg.png'). Consolidación y verificación de escenas hispanizadas en 'src/scenes/workshop/' y 'src/scenes/levels/' con getters de apoyo. Blindaje de reglas de workspace en 'AGENTS.md' y 'GEMINI.md' (mandato 'docs/idea.txt', nombres en español, arbitraje /herrero). Certificación QA con Godot 4.7.2 headless: 111/111 aserciones aprobadas al 100.0%, 0 errores, 0 softlocks, 5 ciclos de estrés sin fugas de memoria y oro incrementado de 50 a 72 (+22 cobradas). |
| **#032** | `2026-10-11 15:22:00` | Administrador, Herrero & Playtester | Arbitraje de Oficio & Cierre Fase 2 | Asiento del Acta N° 012: Certificación definitiva de la Fase 2 bajo el dogma de 'Repair This!'. Corrección del dial térmico (eliminación total de la aguja horneada en 'thermal_gauge.png' y validación ocular de aguja única giratoria en frío 22°C y caliente 84.2°C). Corrección de anclajes de 'PergaminoComanda' en 'CounterShopView.tscn' (botón 'Aceptar Comanda [ENTER]' 100% visible, centrado y con clic garantizado). Arbitraje del Maestro Herrero como jugador: forja, martillado en yunque, corte, temple y pulido aprobados con 90.9% de calidad artesanal. Batería destructiva del Playtester superada: 111/111 aserciones aprobadas (100.0%), 0 softlocks, 0 fugas de memoria en 5 ciclos continuos y cobro de +22 oro. Despacho y apertura oficial de la Fase 3: Mina Subterránea y Bucle Nocturno. |

---

## 3. 📂 Archivos y Módulos Afectados

Registro de los componentes que integran el ecosistema del proyecto y sus herramientas:

```text
📦 Raíz del Workspace (c:\Users\admin\Documents\01_Academico_IITA\iita\juego\)
├── 🆕 Creado:   assets/sprites/workshop/gauge_needle.png — [Aguja de acero forjado 24x90 px con pivote central de latón para manómetro dinámico]
├── ✏️ Regenerado: assets/sprites/workshop/thermal_gauge.png — [Dial analógico de latón limpio sin aguja estática horneada]
├── 📁 Creado:   assets/audio/sfx/ (bell_ring.wav, bellows_air.wav, fire_crackle.wav, anvil_hit_1/2/3.wav, shear_snip.wav, quench_steam.wav, whetstone_scrape.wav, coins_clink.wav) — [10 efectos diegéticos Foley 44.1kHz 16-bit PCM]
├── 🆕 Creado:   src/autoloads/AudioManager.gd — [Autoload maestro de audio con carga directa en runtime de PCM, pool de 8 reproductores SFX, loop de vapor y modulación de pitch]
├── 🆕 Creado:   scripts/generate_workshop_assets.py — [Generador determinista procedural en NumPy y PIL de los 5 assets de taller medieval de alta fidelidad]
├── 🆕 Creado:   scripts/generate_foley_sfx.py — [Sintetizador procedural de audio físico y efectos de impacto/corte/fuego]
├── 📁 Creado & Integrado: assets/sprites/workshop/ (forge_hearth.png, bellows_tool.png, thermal_gauge.png, gauge_needle.png, workshop_room_bg.png) — [Horno de ladrillos refractarios con brasas, fuelle de cuero elástico, manómetro de latón analógico con dial limpio, aguja giratoria desacoplada y fondo panorámico continuo]
├── 🆕 Creado:   tests/playtest_gameplay_loop.gd — [Suite de QA adversarial y playtesting continuo: 111/111 aserciones aprobadas al 100%]
├── 📁 Creado:   assets/sprites/workshop/ (workshop_counter_bg.png, anvil_topdown.png, water_tub_topdown.png) — [Texturas del taller]
├── 📁 Creado:   assets/sprites/ui/ (service_bell.png, order_parchment.png) — [Campana elástica y comanda en piel de oveja]
├── 📁 Creado:   assets/sprites/characters/ (sergeant_portrait.png, peasant_portrait.png) — [Retratos realistas de facciones]
├── 📁 Creado:   assets/sprites/items/ (blacksmith_hammer.png, shear_tool.png, whetstone.png) — [Herramientas de forja táctil]
├── 📁 Creado:   assets/sprites/environment/ (wood_floor.png, stone_floor.png) — [Suelos continuos tileables]
├── ✏️ Hispanizado & Certificado: src/scenes/workshop/ (CounterShopView, WorkshopStationView, AnvilTopDownStation, ManualCutStation, QuenchStation, PolishStation) — [SceneTree 100% en Español, getters retrocompatibles, aguja giratoria desacoplada y 111/111 tests pasando]
├── 🆕 Creado:   src/scenes/ui/PrologueLetter.tscn / .gd — [Carta de la Madre en pergamino a pantalla completa con estética de autor]
├── 🆕 Creado:   src/scenes/workshop/HammerEffect.tscn / .gd — [Efecto de martillo instanciado dinámicamente en las coordenadas de clic sobre el yunque con SFX metálico]
├── ✏️ Modificado: src/scenes/levels/GreyboxTown.tscn / .gd — [Pasillo distribuidor Izquierda=Taller, Frente=Mina, Derecha=Dormitorio con oclusión estanca de salas]
├── ✏️ Modificado: src/autoloads/GameManager.gd — [Gestión de estados, inventario y recompensas en oro]
├── ✏️ Modificado: project.godot — [Registro de AudioManager autoload y atajos ergonómicos: Espacio en action/interact y Q en cancel_escape]
├── ✏️ Modificado: README.md — [Indexación de la guía de etapas, plan de acción y mapa de assets]
├── ✏️ Modificado: docs/idea.txt — [Sección 8: Mandato de Lectura Previa Obligatoria, Nomenclatura en Español y Arbitraje de Herrero]
├── ✏️ Modificado: AGENTS.md / GEMINI.md — [Formalización de los 3 Mandatos Fundacionales: idea.txt §8.1, SceneTree en español y arbitraje /herrero]
├── ✏️ Modificado: CRONICA_DE_CAMPO.md — [Actas N° 009, N° 010 y N° 011, Entradas #029, #030 y #031]
├── 🆕 En Preparación: src/autoloads/OrderManager.gd (o src/scenes/shop/CustomerManager.gd) — [Gestor comercial y ciclo de vida de clientes Fase 2]
├── 🆕 En Preparación: src/scenes/shop/Customer.tscn, CounterArea.tscn — [Entidades comerciales y mostrador diurno Fase 2]
├── 🆕 Creado:   docs/GUIA_DE_ETAPAS_Y_SKILLS.md — [Guía ejecutiva de producción y orquestación de skills por fase]
├── 📁 Creado:   assets/audio/ (music/, sfx/, ambient/) — [Estructura modular de buses de sonido]
├── 📁 Creado:   assets/fonts/ — [Tipografías de autor]
├── 📄 Existente: docs/idea.txt — [GDD canónico supremo: sistemas de forja, minería y clímax sociopolítico]
├── 📄 Existente: docs/plan_de_accion.txt — [Plan maestro de acción integral de 9 fases]
├── 📄 Existente: project.godot — [Configuración maestra del motor Godot 4.x]
├── 📄 Existente: src/autoloads/TimeManager.gd — [Singleton de reloj 24h y ciclo día/noche]
├── 📄 Existente: src/scenes/player/Player.tscn / .gd — [Personaje con aceleración y cinemática game_feel]
├── 📄 Existente: src/scenes/objects/InteractableArea.gd — [Componente desacoplado de interacción]
├── 📄 Existente: src/scenes/workshop/MiniForge.tscn / .gd — [Minijuego interactivo rítmico de forja base]
├── 📄 Existente: src/scenes/ui/MainHUD.tscn / .gd — [Barra inferior persistente con reloj y estamina]
└── 📄 Existente: docs/resumen.txt — [Resumen ejecutivo y pitch comercial]

📦 Ecosistema de Skills de Autor (C:\Users\admin\.gemini\config\skills\)
├── 🛠️ Creado:   herrero/ (SKILL.md + referencias/teoria_herreria_artesanal.md) — [Consultor artesanal de verosimilitud metalúrgica y física del oficio]
├── 🛠️ Creado:   programador_godot/ (SKILL.md + referencias/teoria_programacion_godot.md)
├── 📄 Existente: disenador_grafico/ (SKILL.md + referencias/teoria_color_juegos.md)
├── 📄 Existente: sonidista/ (SKILL.md + referencias/teoria_sonido_juegos.md)
├── 📄 Existente: disenador_de_niveles/ (SKILL.md + referencias/teoria_level_design.md)
├── 📄 Existente: secretario/ (SKILL.md + plantillas/PERGAMINO_TEMPLATE.md)
├── 📄 Existente: game_feel/ (SKILL.md + referencias/teoria_game_feel.md)
├── 📄 Existente: playtester/ (SKILL.md + referencias/protocolo_playtesting.md)
├── ✏️ Refactor: arena/SKILL.md — [Integración de torneos desacoplados por especialista y /arena herrero]
└── ✏️ Refactor: revision/SKILL.md — [Integración de auditorías por disciplina técnica y /revision herrero]
```

---

## 4. 👁️ Testimonios Visuales de `/ojos`

Sección reservada para las corroboraciones oculares ejecutadas bajo la directiva `/secretario corroborar`:

- **Captura N° 001 (`ojo_1791675156802.png`):** Corrobora la pantalla interactiva activa con la terminal de Antigravity, la recepción de instrucciones del desarrollador y la ejecución del entorno de desarrollo.
- **Captura N° 002 (`ojo_1791680240718.png`):** Corrobora el diagnóstico ocular del taller: detección de cliente desalineado respecto al arco gótico de granito en el mostrador, comanda oculta por anclajes de UI, subestaciones de fragua dependientes de cajas planas de color (`ColorRect`) y rebabas de corte desfasadas fuera del banco de trabajo.
- **Captura N° 003 (`ojo_1791680240718_val.png`):** Corrobora la certificación visual final: caja de diálogo a la izquierda bajo la ventana, comanda ampliada a la derecha sobre el mostrador de roble con botón despejado, fragua con horno de ladrillo refractario (`forge_hearth.png`), fuelle de cuero elástico (`bellows_tool.png`), manómetro de latón con aguja rotatoria (`thermal_gauge.png`), corte manual alineado con las aristas del clavo y fondo ambiental continuo (`workshop_room_bg.png`) sin vacíos negros.

---

## 5. 🔏 Sello de Clausura y Estado del Sistema

- **Estado del Demonio Secretario:** `🟢 GUARDIA PERPETUA ACTIVA (VIGILANCIA CONTINUA ININTERRUMPIDA - FASE 2 Y REBANADA VERTICAL DE YUNQUE APROBADAS 100%)`
- **Última Entrada Registrada:** Entrada #035 — Asiento del Acta N° 015 (Rebanada Vertical de Arte Final, Shaders Térmicos y Game Feel en Yunque Cenital y Fragua: Escala Realista 20-1400°C, Enfriamiento con Mecánica Real y Recalentado, Shaders de Metal Incandescente y Viñeta de Fragua, Sacudida por Trauma, Chispas con Gravedad y 138/138 Aserciones Superadas al 100%).
- **Próximo Hito Operativo:** Validación en caliente por el jugador del Yunque y Fragua renovados y despacho hacia el resto de estaciones o Fase 3 ('MinaSubterranea.tscn').

---

### 📌 Acta N° 014 — Remediación Crítica del Mapa, Enmarcado de Cámara y Eliminación de Rebotes Infinitos
- **Sello Temporal:** `2026-10-15 18:55:00`
- **Especialistas Involucrados:** Administrador, Programador Godot (`/programador_godot`), Diseñador de Niveles (`/disenador_de_niveles`), Playtester (`/playtester`) y Secretario Imperial (`/secretario`).
- **Problema Reportado:**
  Tras pruebas en caliente, el usuario reportó fallas críticas en la navegación del mapa:
  1. *Bucle infinito de rebote en puerta sur:* Al intentar salir de la casa hacia la calle, el jugador reaparecía en `(640, 700)`, posición solapada con el trigger exterior de entrada (`y=660..690` con radio de colisión del jugador de 14px), disparando un teletransporte instantáneo de re-entrada de forma continua.
  2. *Vacío negro y pérdida de encuadre:* Al recorrer el pasillo y habitaciones interiores, la cámara móvil exponía el abismo exterior negro sin delimitar el cuarto activo.
  3. *Solapamiento tipográfico en pasillo:* El cartel `🏠 PASILLO DISTRIBUIDOR` invadía físicamente la caja del `Mostrador Comercial`.
  4. *Zona muerta entre detectores de habitación:* Existía una brecha de 20px entre los detectores de pasillo, dormitorio y mina donde el jugador quedaba sin zona activa.
- **Maniobras de Ingeniería Implementadas:**
  1. **Separación de Umbral Exterior:** Se actualizó `SPAWN_FRONT_OF_HOUSE = Vector2(640, 740)` en [`src/scenes/levels/GreyboxTown.gd`](file:///c:/Users/admin/Documents/01_Academico_IITA/iita/juego/src/scenes/levels/GreyboxTown.gd), distanciando al avatar 50px al sur del área del umbral y cancelando cualquier rebote involuntario.
  2. **Enmarcado Dinámico de Cámara (`set_camera_bounds`):** Se dotó al [`Player.gd`](file:///c:/Users/admin/Documents/01_Academico_IITA/iita/juego/src/scenes/player/Player.gd) de límites precisos de `Camera2D` por cada zona (`EXTERIOR`, `PASILLO`, `DORMITORIO`, `MINA`), garantizando que la visión jamás rebase los muros ni revele el vacío exterior negro.
  3. **Corrección de Colisión Tipográfica:** En [`GreyboxTown.tscn`](file:///c:/Users/admin/Documents/01_Academico_IITA/iita/juego/src/scenes/levels/GreyboxTown.tscn), el nodo `HouseInterior/Pasillo/Title` fue reubicado a `offset_left = 480, offset_right = 660`, dejando un espacio libre de 25px antes del cartel de Mostrador (`X=695`).
  4. **Ampliación de Formas de Detección de Sala:** La forma `RectangleShape2D_zone_room` se extendió de `Vector2(320, 200)` a `Vector2(350, 230)`, creando un solape hermético de 10px en los vanos de las puertas y erradicando la zona muerta.
  5. **Sincronización de Cronómetro de Transición:** Se redujo el temporizador de desbloqueo en `_teleport_player` a `0.25s`, permitiendo transiciones ágiles y sincronía perfecta con las pruebas automatizadas.
- **Impacto y Certificación:**
  Ejecución completa de [`tests/playtest_gameplay_loop.gd`](file:///c:/Users/admin/Documents/01_Academico_IITA/iita/juego/tests/playtest_gameplay_loop.gd): **111 de 111 aserciones superadas con éxito (100.0%)**, cero errores y cero caídas al vacío.

---

### 📌 Acta N° 015 — Arte Final, Shaders Térmicos, Estiramiento Longitudinal y Corte Geométrico Real en Todas las Estaciones del Taller
- **Sello Temporal:** `2026-10-29 13:00:00`
- **Especialistas Involucrados:** Administrador, Maestro Herrero (`/herrero`), Especialista en Game Feel (`/game_feel`), Diseñador Gráfico (`/disenador_grafico`), Sonidista (`/sonidista`), Programador Godot (`/programador_godot`) y Playtester (`/playtester`).
- **Maniobras de Ingeniería y Arte Implementadas:**
  1. **Escala Metalúrgica Realista ([`EscalaTermicaAcero.gd`](file:///c:/Users/admin/Documents/01_Academico_IITA/iita/juego/src/components/EscalaTermicaAcero.gd)):** Migración de la escala ficticia (22–100°C) a la tabla física del acero dulce (`20°C` ambiente, **`1000–1150°C`** ventana óptima naranja-amarillo de caldeo, `>1250°C` acero quemado, `1400°C` tope de manómetro).
  2. **Estiramiento Longitudinal Real (*Drawing Out*) y Flujo Plástico sin Límite Recto ([`AnvilTopDownStation.gd`](file:///c:/Users/admin/Documents/01_Academico_IITA/iita/juego/src/scenes/workshop/AnvilTopDownStation.gd)):** Se aumentó la resolución a `NUM_SLICES = 24`, se incorporó posición dinámica `slice_x` por tajada para que el lingote se alargue en el eje X con cada golpe de martillo (`STRETCH_LONGITUDINAL = 7.5`), se reemplazó el recorte plano `±32px` en Y por resistencia asintótica suave y difusión plástica hacia tajadas vecinas (`_difundir_flujo_plastico()`), y se añadieron extremos curvos ahusados.
  3. **Enfriamiento Físico con Mecánica Real y Recalentado ([`AnvilTopDownStation.gd`](file:///c:/Users/admin/Documents/01_Academico_IITA/iita/juego/src/scenes/workshop/AnvilTopDownStation.gd), [`WorkshopStationView.gd`](file:///c:/Users/admin/Documents/01_Academico_IITA/iita/juego/src/scenes/workshop/WorkshopStationView.gd)):** La pieza pierde calor a `22°C/s` más `4°C` por martillazo. Entre `650–800°C` deforma al `50%` y resta `-4%` de precisión; bajo `650°C` deforma al `15%` y resta `-8%`. Se añadió `BotonVolverAFragua` para recalentar la pieza en las brasas sin perder la geometría martillada ni el conteo de golpes.
  4. **Corte Geométrico Real por Bisección de Polígonos ([`ManualCutStation.gd`](file:///c:/Users/admin/Documents/01_Academico_IITA/iita/juego/src/scenes/workshop/ManualCutStation.gd)):** Mediante `Geometry2D.clip_polygons()` (`_dividir_poligono_por_recta()`), el trazo del jugador bisecciona los polígonos del metal exactamente por la línea y el ángulo dibujados, desprendiendo el fragmento real recortado con física parabólica, fundiendo cualquier remanente al cuerpo principal y dejando una cicatriz incandescente sobre la arista recién cortada.
  5. **Extensión de Shaders, Atmósfera y Juice a Fragua, Corte, Tina y Pulido ([`WorkshopStationView.tscn`](file:///c:/Users/admin/Documents/01_Academico_IITA/iita/juego/src/scenes/workshop/WorkshopStationView.tscn), [`ManualCutStation.tscn`](file:///c:/Users/admin/Documents/01_Academico_IITA/iita/juego/src/scenes/workshop/ManualCutStation.tscn), [`QuenchStation.tscn`](file:///c:/Users/admin/Documents/01_Academico_IITA/iita/juego/src/scenes/workshop/QuenchStation.tscn), [`PolishStation.tscn`](file:///c:/Users/admin/Documents/01_Academico_IITA/iita/juego/src/scenes/workshop/PolishStation.tscn)):**
     - **Fragua:** `VinetaFragua` y partículas `ChispasHorno`.
     - **Corte Manual:** `FondoTaller`, `VinetaFragua`, `LuzBrasas`, yunque a escala real, `metal_incandescente.gdshader`, `ChispasCorte` y `SacudidaTrauma`.
     - **Tina de Templado:** `FondoTaller`, `VinetaFragua`, enfriamiento visual en el shader de `880°C` a `180°C`, `ResplandorInmersion` subacuático, `BurbujasEbullicion`, nubes de vapor radiales suaves y `SacudidaTrauma`.
     - **Pulido Manual:** `FondoTaller`, `VinetaFragua`, mesa de roble (`TexturaMaderaBanco`), `ChispasEsmeril`, `SacudidaTrauma` y conservación de la silueta geométrica cortada en la estación previa.
- **Certificación Automatizada y Ocular:**
  - [`tests/playtest_yunque_juice.gd`](file:///c:/Users/admin/Documents/01_Academico_IITA/iita/juego/tests/playtest_yunque_juice.gd): **33 / 33 aserciones superadas (100%)**, incluyendo estiramiento longitudinal en X, corte geométrico real y 0 fugas de nodos tras 50 golpes.
  - [`tests/playtest_gameplay_loop.gd`](file:///c:/Users/admin/Documents/01_Academico_IITA/iita/juego/tests/playtest_gameplay_loop.gd): **111 / 111 aserciones superadas (100%)**.

---

### 📌 Acta N° 016 — Martillo Físico por Velocidad (Hitbox Area2D), 3 Barriles de Metales e Integración Interna en Horno, Silueta Fiel del Encargo, Entrega Arrastrable en Mesada y Exterior Visible con Personaje Articulado
- **Sello Temporal:** `2026-10-29 13:52:00`
- **Especialistas Involucrados:** Administrador, Maestro Herrero (`/herrero`), Especialista en Game Feel (`/game_feel`), Diseñador Gráfico (`/disenador_grafico`), Diseñador de Niveles (`/disenador_de_niveles`), Programador Godot (`/programador_godot`) y Playtester (`/playtester`).
- **Maniobras de Ingeniería y Arte Implementadas:**
  1. **Exterior del Pueblo Visible y Personaje Artesano Articulado ([`GreyboxTown.tscn`](file:///c:/Users/admin/Documents/01_Academico_IITA/iita/juego/src/scenes/levels/GreyboxTown.tscn), [`Player.tscn`](file:///c:/Users/admin/Documents/01_Academico_IITA/iita/juego/src/scenes/player/Player.tscn), [`Player.gd`](file:///c:/Users/admin/Documents/01_Academico_IITA/iita/juego/src/scenes/player/Player.gd)):** Se corrigió `ExteriorTown.visible = true` y se ambientó la plaza con empedrado octogonal, pozo antiguo, árboles otoñales, flechas guía hacia el taller y tejado/ventanas iluminadas en la herrería. Se reemplazaron los 3 cuadrados del jugador por un aprendiz de herrero articulado con cabello, rostro con dirección de mirada, túnica, delantal de cuero con correas, brazos y botas animados al caminar.
  2. **Martillo Físico Móvil con Hitbox y Fuerza por Velocidad ([`AnvilTopDownStation.tscn`](file:///c:/Users/admin/Documents/01_Academico_IITA/iita/juego/src/scenes/workshop/AnvilTopDownStation.tscn), [`AnvilTopDownStation.gd`](file:///c:/Users/admin/Documents/01_Academico_IITA/iita/juego/src/scenes/workshop/AnvilTopDownStation.gd)):** Se creó el nodo `MartilloForjador` (`AreaHitboxMartillo`) y `AreaColisionMetal` (`PoligonoColisionMetal`). La rapidez de movimiento del martillo al impactar contra el metal modula la fuerza (`0.22x` a `1.85x`), haciendo que golpes rápidos expandan y estiren con fuerza el acero y golpes lentos permitan retoques suaves.
  3. **3 Barriles de Lingotes y Metal Hundido Dentro del Horno ([`WorkshopStationView.tscn`](file:///c:/Users/admin/Documents/01_Academico_IITA/iita/juego/src/scenes/workshop/WorkshopStationView.tscn), [`WorkshopStationView.gd`](file:///c:/Users/admin/Documents/01_Academico_IITA/iita/juego/src/scenes/workshop/WorkshopStationView.gd)):** Se añadieron `BarrilHierroDulce`, `BarrilAceroCarbono` y `BarrilBronceCobre` para arrastrar lingotes hacia la boca del horno. Dentro del hogar (`InteriorBocaHorno`), el lingote reposa entre `LechoBrasasFondo` (atrás) y `BrasasDelanterasOclusion` + `AscuasVivasDelanteras` + `LlamasInternasHogar` (adelante).
  4. **Silueta Fiel al Objeto Solicitado y Entrega Arrastrable en Mesada ([`ManualCutStation.gd`](file:///c:/Users/admin/Documents/01_Academico_IITA/iita/juego/src/scenes/workshop/ManualCutStation.gd), [`CounterShopView.tscn`](file:///c:/Users/admin/Documents/01_Academico_IITA/iita/juego/src/scenes/workshop/CounterShopView.tscn), [`CounterShopView.gd`](file:///c:/Users/admin/Documents/01_Academico_IITA/iita/juego/src/scenes/workshop/CounterShopView.gd)):** El molde converge hacia la cabeza recalcada, cuello, vástago y punta piramidal del clavo/perno solicitado; en el mostrador, la pieza forjada real (`PoligonoPiezaTerminada`) se apoya sobre un paño de cuero en la mesada para arrastrarla directamente hacia el cliente en la ventanilla.
- **Certificación Automatizada:**
  - [`tests/playtest_yunque_juice.gd`](file:///c:/Users/admin/Documents/01_Academico_IITA/iita/juego/tests/playtest_yunque_juice.gd): **42 / 42 aserciones superadas (100%)**.
  - [`tests/playtest_gameplay_loop.gd`](file:///c:/Users/admin/Documents/01_Academico_IITA/iita/juego/tests/playtest_gameplay_loop.gd): **111 / 111 aserciones superadas (100%)**.

---

### 📌 Acta N° 017 — Martillo Único por Arrastre Exclusivo y Rediseño Articulado de Clientes en el Mostrador
- **Sello Temporal:** `2026-10-29 14:21:00`
- **Especialistas Involucrados:** Administrador, Especialista en Game Feel (`/game_feel`), Diseñador Gráfico (`/disenador_grafico`), Programador Godot (`/programador_godot`) y Playtester (`/playtester`).
- **Maniobras de Ingeniería y Arte Implementadas:**
  1. **Martillo Único y Golpe Exclusivo por Arrastre ([`AnvilTopDownStation.gd`](file:///c:/Users/admin/Documents/01_Academico_IITA/iita/juego/src/scenes/workshop/AnvilTopDownStation.gd), [`HammerEffect.tscn`](file:///c:/Users/admin/Documents/01_Academico_IITA/iita/juego/src/scenes/workshop/HammerEffect.tscn), [`HammerEffect.gd`](file:///c:/Users/admin/Documents/01_Academico_IITA/iita/juego/src/scenes/workshop/HammerEffect.gd)):**
     - Se ocultó el sprite de martillo secundario en `HammerEffect` (`MartilloVisual.visible = false`), dejando únicamente el destello radial y las chispas físicas al impactar, de modo que **`MartilloForjador` es el único martillo visible en toda la estación**.
     - Se eliminó el golpe por clic directo en `_on_hit_area_gui_input()`: hacer clic sobre el metal ya no teletransporta el martillo ni golpea. La única forma de golpear es **agarrar el `MartilloForjador` y arrastrarlo contra el metal**, registrando 1 único golpe limpio por cada entrada de su hitbox según su velocidad.
  2. **Diseño Articulado de Clientes en el Mostrador ([`CounterShopView.tscn`](file:///c:/Users/admin/Documents/01_Academico_IITA/iita/juego/src/scenes/workshop/CounterShopView.tscn), [`CounterShopView.gd`](file:///c:/Users/admin/Documents/01_Academico_IITA/iita/juego/src/scenes/workshop/CounterShopView.gd)):**
     - Se reemplazó el retrato cuadrado plano por el nodo `PersonajeClienteArticulado` integrado directamente bajo el arco gótico de piedra con animación orgánica de respiración y movimiento de cabeza:
       * **`BustoSargentoGodofredo`:** Yelmo nasal de acero con banda de latón, rostro curtido con cicatriz y bigote espeso, hombreras de acero biseladas, cota de malla, tabardo borgoña con emblema dorado y guanteletes apoyados en el mostrador.
       * **`BustoMolineroEustaquio`:** Boina de paño, barba campesina y sonrisa cálida, camisa de lino crudo, chaleco de lana, pañuelo borgoña y delantal harinero.
       * **`BustoMercaderValeria`:** Sombrero chaperón con pluma, cabello largo, jubón de terciopelo borgoña y broche de bronce (encarga el pasador de `bronce_cobre`).
- **Certificación Automatizada:**
  - [`tests/playtest_yunque_juice.gd`](file:///c:/Users/admin/Documents/01_Academico_IITA/iita/juego/tests/playtest_yunque_juice.gd): **49 / 49 aserciones superadas (100%)**.
  - [`tests/playtest_gameplay_loop.gd`](file:///c:/Users/admin/Documents/01_Academico_IITA/iita/juego/tests/playtest_gameplay_loop.gd): **111 / 111 aserciones superadas (100%)**.

---

### 📌 Acta N° 018 — Protocolo Obligatorio de Sincronización Git Automática (Multi-Dispositivo & Nuevas Sesiones)
- **Sello Temporal:** `2026-11-16 16:53:00`
- **Especialistas Involucrados:** Administrador, Secretario Imperial (`/secretario`), Tribunal de Revisión (`/revision`).
- **Contexto y Problema:**
  El desarrollador alterna el trabajo entre diversos dispositivos (PC de escritorio, laptops, dispositivos móviles vía Remote Control y agentes en la nube). En cada nueva sesión o chat diario, era imperativo evitar desincronizaciones de código y pérdidas de trabajo entre el repositorio local y el remoto.
- **Decisión Adoptada:**
  1. Se actualizaron los pergaminos de directivas [`GEMINI.md`](file:///c:/Users/admin/Documents/01_Academico_IITA/iita/juego/GEMINI.md), [`CLAUDE.md`](file:///c:/Users/admin/Documents/01_Academico_IITA/iita/juego/CLAUDE.md) y [`AGENTS.md`](file:///c:/Users/admin/Documents/01_Academico_IITA/iita/juego/AGENTS.md) tanto en la carpeta `juego/` como en la raíz del repositorio.
  2. Se fijó el **Protocolo de Inicio de Sesión**: en el primer turno de cualquier conversación nueva, el agente debe verificar de forma no invasiva `git fetch origin` y, si la rama local está por detrás del remoto, ejecutar `git pull origin main` inmediatamente antes de inspeccionar o alterar archivos.
  3. Se fijó el **Protocolo de Cierre por Modificación (Auto-Push)**: siempre que el agente realice cambios, refactorizaciones o creación de archivos en una sesión, debe ejecutar automáticamente `git add`, `git commit` descriptivo y `git push origin main` al repositorio de GitHub sin requerir intervención manual del usuario.
- **Impacto y Consecuencias:**
  Trazabilidad total entre dispositivos; ningún cambio queda huérfano ni desfasado entre sesiones independientes.

---

### 📌 Acta N° 019 — Mandato de Activación Automática de la Skill Administrador (`/administrador`) para Tareas Complejas (> 1 Paso)
- **Sello Temporal:** `2026-11-16 16:57:00`
- **Especialistas Involucrados:** Administrador Jefe (`/administrador`), Secretario Imperial (`/secretario`), Tribunal de Revisión (`/revision`).
- **Contexto y Problema:**
  Para evitar cuellos de botella en el chat principal y aprovechar plenamente la capacidad multi-agente, se requería que el agente principal no intentara resolver manualmente tareas de múltiples pasos ni se bloqueara en bucles sincrónicos, activando de inmediato el rol de orquestador asíncrono para coordinar subagentes especializados.
- **Decisión Adoptada:**
  1. Se actualizó la Sección 2 en todas las directivas maestras ([`GEMINI.md`](file:///c:/Users/admin/Documents/01_Academico_IITA/iita/GEMINI.md), [`CLAUDE.md`](file:///c:/Users/admin/Documents/01_Academico_IITA/iita/CLAUDE.md), [`AGENTS.md`](file:///c:/Users/admin/Documents/01_Academico_IITA/iita/AGENTS.md) y sus equivalentes en `juego/`).
  2. Se fijó la regla de compuerta: cualquier encargo que requiera más de una acción (desarrollo de mecánicas, diseño de niveles, generación procedural, arquitectura, audio, pruebas de estrés) **activa obligatoriamente la skill `/administrador`** sin necesidad de comando manual.
  3. Quedan exceptuadas de esta delegación únicamente las tareas atómicas directas de un solo paso (retoques estéticos triviales como cambio puntual de color o corrección de erratas de texto).
  4. Se replicó la skill `/administrador` en el árbol de `.agent/skills/` para garantizar paridad absoluta con agentes Claude.
- **Impacto y Consecuencias:**
  Flujo de desarrollo ultra-rápido, paralelo y sin bloqueos; el usuario siempre dispone del chat libre mientras los subagentes trabajan en segundo plano.

---

### 📌 Acta N° 020 — Estandarización, Ordenamiento e Instalación Automática de Skills Multi-Dispositivo
- **Sello Temporal:** `2026-11-16 17:02:00`
- **Especialistas Involucrados:** Administrador Jefe (`/administrador`), Secretario Imperial (`/secretario`), Tribunal de Revisión (`/revision`).
- **Contexto y Problema:**
  El desarrollador trabaja alternando entre diversas computadoras y chats en paralelo. Las skills residían de forma aislada en `juego/`, provocando que al abrir el repositorio desde la raíz en otra computadora o en sesiones independientes, Antigravity no detectara automáticamente el catálogo completo de 12 skills. Se requería una solución limpia, ordenada y portable sin archivos dispersos.
- **Decisión Adoptada:**
  1. Se unificaron las 12 skills canónicas en las rutas estándar de workspace de la raíz del repositorio (`.gemini/skills/` y `.agent/skills/`) manteniendo la paridad con `juego/.gemini/skills/` y `juego/.agent/skills/`.
  2. Se creó el script sincronizador multiplataforma [`scripts/instalar_skills_locales.py`](file:///c:/Users/admin/Documents/01_Academico_IITA/iita/scripts/instalar_skills_locales.py) y el lanzador Windows [`INSTALAR_SKILLS.bat`](file:///c:/Users/admin/Documents/01_Academico_IITA/iita/INSTALAR_SKILLS.bat).
  3. Al clonar o actualizar el repositorio en cualquier equipo, basta con ejecutar el script o abrir la carpeta en Antigravity para que todas las skills queden cargadas y ordenadas tanto a nivel de proyecto como a nivel global de usuario (`%USERPROFILE%/.gemini/skills` / `~/.agent/skills`).
- **Impacto y Consecuencias:**
  Portabilidad total entre máquinas; cualquier chat en cualquier equipo reconoce de inmediato al Administrador, Herrero, Programador Godot, Diseñador de Niveles, Game Feel, Sonidista, Diseñador Gráfico, Playtester, Ojos, Secretario, Tribunal y Revisión.

---

### 📌 Acta N° 021 — Desduplicación y Consolidación Exclusiva de Skills en la Raíz de IITA_python
- **Sello Temporal:** `2026-11-16 17:07:00`
- **Especialistas Involucrados:** Administrador Jefe (`/administrador`), Secretario Imperial (`/secretario`), Tribunal de Revisión (`/revision`).
- **Contexto y Problema:**
  Tener réplicas redundantes de las 12 skills tanto en la raíz de `IITA_python/` como en la subcarpeta `juego/` generaba sobrecarga y confusión de versiones al momento de actualizar o documentar. Se determinó centralizar las skills exclusivamente en la raíz del repositorio.
- **Decisión Adoptada:**
  1. Se eliminaron definitivamente las carpetas duplicadas `juego/.gemini/skills/` y `juego/.agent/skills/`.
  2. Las 12 skills canónicas residen **única y exclusivamente** en la raíz del workspace: `.gemini/skills/` y `.agent/skills/`.
  3. Se ajustó [`scripts/instalar_skills_locales.py`](file:///c:/Users/admin/Documents/01_Academico_IITA/iita/scripts/instalar_skills_locales.py) para sincronizar únicamente desde y hacia la raíz de `IITA_python`.
- **Impacto y Consecuencias:**
  Estructura limpia, canónica y sin duplicaciones; máxima claridad para control de versiones y edición unificada.


---

### 📌 Acta N° 022 — Creación de la Mina Subterránea (Fase 3), Tutorial Interactivo Contextual, Foley Reactivo e Inercia Térmica Realista de Fragua
- **Sello Temporal:** `2026-11-18 17:06:00`
- **Especialistas Involucrados:** Administrador Jefe (`/administrador`), Maestro Herrero (`/herrero`), Diseñador de Niveles (`/disenador_de_niveles`), Sonidista (`/sonidista`), Game Feel (`/game_feel`), Programador Godot (`/programador_godot`), Playtester (`/playtester`), Secretario Imperial (`/secretario`) y Tribunal de Revisión (`/revision`).
- **Contexto y Problema:**
  El desarrollador solicitó avanzar con el Plan Maestro (`docs/plan_de_accion.txt` Fase 3 y GDD `docs/idea.txt` §3.2) creando la Mina Subterránea completa, incorporando un Tutorial interactivo para guiar el bucle artesanal, sintetizando efectos de sonido retroactivos al apoyar materiales o cruzar umbrales de temperatura, optimizando las estaciones del taller y calibrando la curva térmica de la fragua para que no suba de manera abrupta e irreal.
- **Decisión Adoptada e Implementación:**
  1. **Mina Subterránea (`MinaSubterranea.tscn` / `.gd`):**
     - Caverna subterránea exploratoria integrada en `GreyboxTown.tscn` (`Zone.CAVERNAS_MINA`) con nomenclatura 100% en español, muros perimetrales con biseles anti-atasco y rieles de vagoneta.
     - Sistema de 3 soportes de antorcha interactuables que iluminan cálidamente la caverna y reducen la penumbra de forma progresiva.
     - 6 vetas de mineral (`Carbón`, `Hierro Puro` x2, `Cobre Nativo`, `Plata de Veta Profunda`, `Oro Antiguo`) con picado de 3 a 5 golpes, consumo de estamina, *Trauma Shake* cuadrático, *Squash & Stretch*, *Hitstop*, chispas y regeneración al cambio de día.
     - **Cinemática del Primer Hito Metalúrgico (GDD §3.2 y §2.3):** Al quebrar la primera veta de hierro puro se despliega el pergamino modal a pantalla completa con zoom elástico revelando la Nota Grabada #1 del Diario Perdido del Tío Rodrik.
  2. **Sistema de Tutorial Interactivo, Contextual y Diegético (`GuiaTutorial.tscn` / `.gd`):**
     - Panel diegético (`CanvasLayer` layer 25, `mouse_filter = MOUSE_FILTER_PASS` anti-bloqueo) con contraste WCAG 2.1 AAA (> 10:1), barra de progreso, botón de salto (`[T]`) y 9 pasos reactivos que acompañan al jugador desde la carta de la madre y los barriles de metal hasta la entrega del pedido y la exploración de la mina.
  3. **Inercia Térmica Realista de la Fragua (`/herrero` — `WorkshopStationView.gd`):**
     - Reducción de `AUMENTO_POR_FUELLE` de `215.0°C` a `95.0°C` (~11 bombeos desde 20°C hasta ~1065°C) y ajuste de `DECAIMIENTO_FRAGUA_POR_SEGUNDO` de `55.0°C/s` a `28.0°C/s` para reflejar la retención calórica real del lecho de carbón de hulla, con interpolación visual suave de la aguja del manómetro.
  4. **Banco de Sonidos Retroactivos Foley y Optimización (`/sonidista` — `AudioManager.gd` & `generate_foley_sfx.py`):**
     - Síntesis procedural en WAV (44.1 kHz, 16-bit Mono) de 7 nuevos SFX: `place_item.wav`, `temp_ready.wav`, `temp_overheat.wav`, `pickaxe_hit.wav`, `rock_shatter.wav`, `torch_light.wav` y `step_complete.wav`.
     - Disparo automático reactivo al tomar/colocar lingotes en el horno, recibir o apoyar piezas y comandas en el mostrador, entrar en el rango de caldeo óptimo (`1000°C - 1150°C`), superar el umbral de sobrecalentamiento (`>1150°C`) y completar estaciones o pasos del tutorial.
     - Optimización de `_process` en todas las estaciones del taller y ampliación del pool de audio a 12 canales con limpieza en `_exit_tree()` (`orphan nodes = 0`).
- **Certificación QA (`/playtester`):**
  - Ejecución headless en Godot v4.7.2 de `tests/playtest_gameplay_loop.gd`: **133 / 133 aserciones superadas (100.0% PASS), código de salida 0, 0 errores, 0 warnings y 0 fugas de memoria**.

---

### 📌 Acta N° 023 — Bucle de Progresión Multidía Continuo (Días 1 a 5+), Consecuencias de Medianoche y Pantalla de Resumen Diario
- **Sello Temporal:** `2026-11-20 21:00:00`
- **Especialistas Involucrados:** Administrador Jefe (`/administrador`), Diseñador de Juego (`/disenador_de_juego`), Programador Godot (`/programador_godot`), Playtester QA (`/playtester`) y Secretario Imperial (`/secretario`).
- **Contexto y Problema:**
  El usuario solicitó que la jugabilidad sea constante y continua, permitiendo avanzar día tras día más allá del Día 1, mientras prepara un boceto para rediseñar el estilo de entrada del taller como un portal (con la restricción explícita de no modificar las estructuras físicas del nivel por el momento).
- **Decisión Adoptada e Implementación:**
  1. **Catálogo Progresivo de Clientes y Bucle Multidía (`CounterShopView.gd`):**
     - Se refactorizó la lógica del mostrador desacoplando el límite hardcodeado de Día 1 mediante `max_pedidos_hoy` y `ROSTER_POR_DIA`.
     - **Día 1:** Clavo de Mazmorra (Sargento Godofredo), Perno de Molino (Eustaquio), Pasador de Bronce (Doña Valeria).
     - **Día 2:** Reja de Arado Reforzada (Mateo el Granjero), Herradura de Tiro Pesado (Anselmo el Herrero Viejo), Trípode de Brasa (Greta la Tabernera).
     - **Día 3:** Hacha de Talar de Filo Tenaz (Baldomero el Leñador), Pico de Barreno Profundo (Gorki el Minero), Zuncho de Barril (Teo el Tonelero).
     - **Día 4:** Daga Corta de Inspección (Sargento Godofredo), Bisagras de Portón Pesado (Don Claudio el Albañil), Cascabel Sonoro de Niebla (Niña Lira).
     - **Día 5 (Punto de Inflexión Feudal - GDD §6):** Cadenas Pesadas de Contención (Capitán de la Guarnición Feudal), Cerrojo Oculto de Doble Traba (Aldeano Asustado), Refuerzo de Carromato para Fuga (Doña Valeria).
     - **Día 6+:** Generación procedural dinámica a partir de un pool balanceado de vecinos, artesanos, mercaderes y guardias.
     - Conexión a señales horarias de `TimeManager` (`day_started`, `shop_opened`, `shop_closed`), gestionando la apertura de ventanilla a las 06:00 y su cierre a las 17:00.
  2. **Mecánica de Sueño y Penalizaciones de Medianoche (GDD §3.3):**
     - En `TimeManager.gd` y `GameManager.gd`:
       * **Sueño Voluntario en Cama:** 100% de estamina restaurada a las 06:00, 0 monedas perdidas.
       * **Colapso a Medianoche en Taller (00:00):** Desmayo por fatiga dentro de casa; despierta con 50% de estamina, sin robo.
       * **Asalto a Medianoche en Exterior o Mina (00:00):** Colapso a la intemperie; asalto nocturno con robo del ~18% de monedas de oro, despojo de menas en mano y fatiga severa (40% de estamina).
     - En `GreyboxTown.gd`:
       * Rastreo de `GameManager.zona_actual` (`"interior"`, `"exterior"`, `"mina"`).
       * Reposicionamiento del jugador en su lecho (`SPAWN_BEDROOM` en `Vector2(1010, 380)`) con oclusión del dormitorio activada.
  3. **Pantalla de Resumen Diario (`PantallaResumenDia.tscn` / `.gd`):**
     - Interfaz `CanvasLayer` (layer 28) con estética de pergamino medieval (#120e0c, bordes #b59a6a, tipografía AAA #f2e6cc).
     - Registra condición de descanso, libro de cuentas del taller (pedidos de ayer, ingresos por forja, pérdidas por robo, saldo total) y "El Murmullo del Poblado" con rumores evolutivos sobre la creciente tensión feudal.
     - Cierre accesible mediante botón o pulsación de `[ESPACIO]` / `[ENTER]`.
  4. **Preservación Física Absoluta:**
     - Geometría de muros, colisiones y entradas intactas según directiva del usuario.
  5. **Suite de Pruebas Multidía (`tests/test_ciclo_multidia.gd`):**
     - Cobertura exhaustiva de 51 aserciones para progresión de clientes Días 1-5+, rotación procedural, consecuencias de descanso y medianoche, UI de resumen y control horario.
- **Certificación QA (`/playtester`):**
  - `tests/test_ciclo_multidia.gd`: **51/51 PASS (100%)**
  - `tests/test_forja_y_mina_fase2.gd`: **40/40 PASS (100%)**
  - `tests/playtest_gameplay_loop.gd`: **133/133 PASS (100%)**
  - **Gran Total: 224 / 224 aserciones superadas con éxito (0 fallos, 0 errores).**

