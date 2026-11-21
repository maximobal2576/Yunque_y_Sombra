# 📜 YUNQUE & SOMBRA — SISTEMA DE PROGRESIÓN Y NARRATIVA POR HITOS (EVENT-DRIVEN)
## Arquitectura de Desbloqueo Orgánico por Objetos, Mejoras y Acciones del Jugador
*Documento Canónico de Diseño — Reemplaza la rigidez de días calendario fijos por progresión reactiva*

---

## 🎯 1. Filosofía de Diseño: Libertad de Ritmo vs. Días Fijos

### ¿Por qué NO usar días fijos en el calendario (ej. Día 1 al 30 rígidos)?
1. **Desincronización del Jugador:** Si un jugador ahorra con calma, perfecciona su técnica en el yunque o explora la mina a su propio paso, un evento prefijado para el "Día 10" le exigiría herramientas u oro que aún no posee.
2. **Eliminación del Relleno Artificial:** Forzar 30 días de contenido diario genera diálogos de relleno y frustración si el jugador no avanza mecánicamente al mismo compás.
3. **Sensación Genuina de Logro (Metroidvania / Moonlighter / Dave the Diver):** La historia **debe ser una consecuencia directa de las decisiones del jugador**. Cuando compras un objeto caro, cuando rompes una roca legendaria o cuando entregas un encargo maestro, el mundo reacciona de inmediato.

### El Bucle Dual Día/Noche se Mantiene Libre
* El reloj diario (06:00 a 17:00 comercial; 17:00 a 00:00 minería/nocturna; 00:00 descanso en cama) **sigue funcionando continuamente**.
* El contador de días (Día 1, Día 2, Día 5, Día 14...) simplemente mide el paso del tiempo vivido por el taller.
* Un jugador hábil puede completar la Demo en 8 o 10 días; un jugador metódico puede tomarse 20 o 25 días. **Ambos disfrutan de una experiencia coherente y sin fisuras.**

---

## 🗝️ 2. El Catálogo de Objetos Clave y Mejoras Desbloqueables

El avance del juego se organiza en torno a **Llaves de Progresión (Objetos, Herramientas e Instalaciones)** que el jugador adquiere en el Libro de Cuentas del Taller (Juan el Carpintero y Buhonero de la Comarca) o forja con sus propias manos:

```
┌──────────────────────────────────────────────────────────────────────────────────┐
│                           ÁRBOL DE DESBLOQUEO POR HITOS                          │
├──────────────────────────────────────────────────────────────────────────────────┤
│                                                                                  │
│   [HITO 0: Prólogo & Llegada]                                                    │
│         │                                                                        │
│         ▼                                                                        │
│   [Primer Clavo Forjado + Primera Mena de Hierro]                                │
│         │                                                                        │
│         ▼                                                                        │
│   [OBJETO: Crisol de Bronce Refractario] ──(80 Oro)──► [HITO 1: Pedidos Bronce]  │
│         │                                                                        │
│         ▼                                                                        │
│   [OBJETO: Pico de Bronce Reforzado] ──(120 Oro + 2 Bronce)──► [HITO 2: Mina L2] │
│         │                                                    (Derrumbe Roto +    │
│         │                                                     Diario del Tío)    │
│         ▼                                                                        │
│   [OBJETO: Aceite de Temple & Piedra Fina] ──(150 Oro)──► [HITO 3: Presión Feudo]│
│         │                                                (Daga de Mazmorra +     │
│         │                                                 Guardias Nocturnos)    │
│         ▼                                                                        │
│   [OBJETO: Fuelle Mecánico de Doble Cámara] ──(220 Oro)──► [HITO 4: CLÍMAX DEMO] │
│         │                                                (Llave del Yunque +     │
│         │                                                 Apertura Forja Oculta) │
│         ▼                                                                        │
│   [CLIFFHANGER: Aldabonazo a medianoche & continuará...]                         │
└──────────────────────────────────────────────────────────────────────────────────┘
```

### Tabla de Objetos y Efectos en el Juego:

| Objeto / Instalación | Tipo | Coste Estimado | Desbloqueo Jugable | Impacto Narrativo |
| :--- | :--- | :--- | :--- | :--- |
| **Crisol de Arcilla Refractaria** | Compra en Libro | 80 Monedas de Oro | Permite alear cobre y estaño para fundir **Bronce de Forja**. | Los aldeanos reconocen tu habilidad y piden piezas comunitarias (reja de arado, trípode). |
| **Pico de Bronce Reforzado** | Forjado / Compra | 120 Oro + 2 Lingotes Bronce | Permite picar roca dura y derribar el derrumbe del Nivel 1 de la mina. | Acceso al Nivel 2 de la mina. Hallazgo del **Cofre Oculto con el Diario de Rodrik**. |
| **Lámpara de Aceite de Roca** | Compra Buhonero | 95 Monedas de Oro | Radio de iluminación personal en la mina; no se apaga con corrientes subterráneas. | Permite explorar la galería profunda sin depender de soportes de antorcha fijos. |
| **Piedra de Afilar de Grano Fino** | Compra en Libro | 110 Monedas de Oro | Habilita el biselado y afilado de cuchillas en la estación de pulido. | El Sargento Godofredo exige la forja de la **Daga de Mazmorra** para el Feudo. |
| **Aceite de Temple de Linaza** | Compra Buhonero | 75 Monedas de Oro | Reduce la fragilidad al enfriar aceros y metales duros (score bonus en tina). | Permite templar aceros de alto carbono sin riesgo de fractura. |
| **Fuelle de Doble Cámara** | Mejora Taller | 220 Oro + 3 Lingotes Acero | Eleva la temperatura de la fragua hasta 1300°C con la mitad de esfuerzo de vigor. | Desbloquea la fundición de la **Aleación Sombría** descrita en el diario del tío. |
| **Llave del Yunque Olvidado** | Forja Especial | 1 Lingote Sombrío + Temple | Se introduce en el mecanismo secreto del pedestal del yunque. | **Detonador del Clímax Final de la Demo.** |

---

## 📜 3. Los 5 Hitos Narrativos de la Demo (Estructura de la Historia)

### 🔨 HITO 0 — Cenizas y Herencia (Onboarding & Primer Fuego)
* **Condición de Activación:** Inicio del juego (automático tras leer la carta sellada de la madre).
* **Objetivos del Jugador:**
  1. Cruzar la aldea hacia el taller de su tío desaparecido.
  2. Tocar la campana del mostrador y aceptar la comanda de Baldomero el leñador o el Sargento (*Clavo de mazmorra*).
  3. Completar las 5 estaciones de forja (Fragua -> Yunque -> Corte -> Tina -> Pulido) y cobrar las primeras monedas.
  4. Bajar a la mina al atardecer (17:00) y picar la primera mena de mineral de hierro.
* **Diálogos / Reacción del Mundo:**
  - El Sargento: *"Creí que este taller se pudriría tras la fuga de Rodrik. Haz tu trabajo y no husmees en asuntos de la fortaleza."*
  - Juan el Carpintero: Deja un catálogo básico sobre el mostrador para habilitar mejoras de confort.

---

### 🛡️ HITO 1 — El Crisol de Bronce y la Alianza Vecinal
* **Condición de Activación:** El jugador compra el **Crisol de Arcilla Refractaria** en el Libro del Taller (requiere 80 monedas ganadas forjando).
* **Consecuencias en el Juego:**
  - **Nuevos Clientes en el Mostrador:**
    1. *Mateo el Granjero:* Pide una *Reja de Arado Reforzada en Bronce*. Habla con gratitud: *"Si no siembro antes de la primera helada, los recaudadores se llevarán a mis hijos como peones."*
    2. *Greta la Curandera / Tabernera:* Pide un *Trípode de Caldero*. Deja un ungüento que restaura estamina y advierte: *"Tu tío no era un herrero común... oíamos ruidos bajo tierra a altas horas de la noche."*
  - **Rumor en el Resumen Diario:** *"Los aldeanos celebran en la plaza: las herramientas del nuevo herrero no se quiebran como las baratijas que impone el Feudo."*
  - **Desbloqueo en Tienda:** Se habilita la opción de adquirir o forjar el **Pico de Bronce Reforzado**.

---

### ⛏️ HITO 2 — La Brecha Subterránea y el Diario Quemado
* **Condición de Activación:** El jugador forja o equipa el **Pico de Bronce Reforzado** y destruye el muro de derrumbe al fondo de la mina subterránea.
* **Consecuencias en el Juego:**
  - **Apertura de la Galería Inferior (Nivel 2 de la Mina):** Nuevas vetas de cobre brillante, vetas de carbón fósil y atmósfera con goteo cavernoso.
  - **Hallazgo del Cofre de Hierro:** Al fondo de la caverna, el jugador encuentra un cofre con candado forzado que contiene el **Cuaderno Quemado de Rodrik** y un extraño fragmento de mineral violáceo.
  - **Texto del Fragmento del Diario:**
    > *«Día 42 tras la intimación del Barón. No quieren herraduras ni arados. Quieren armaduras que resistan el fuego de las revueltas campesinas y exigen la aleación que duerme en la falla profunda. Escondí el boceto del molde bajo el fuelle. Si alguien encuentra esto: no cedas ante las amenazas de la guardia.»*
  - **Reacción del Feudo:** A la mañana siguiente, el Sargento Godofredo entra al mostrador sin tocar la campana:
    - *"Te he visto salir tarde de las cavernas, muchacho. Tienes polvo de roca profunda en la pechera... Si encuentras algo que perteneció a tu tío, recuerda que todo lo que hay bajo esta tierra le pertenece al Señor Feudal."*

---

### ⚔️ HITO 3 — El Dilema de la Guardia y la Forja Clandestina
* **Condición de Activación:** El jugador adquiere la **Piedra de Afilar de Grano Fino** (o el Aceite de Temple Especial) y completa el encargo obligatorio del Sargento (*Daga de Mazmorra de Filo Biselado*).
* **Consecuencias en el Juego:**
  - **Tensión en las Calles:** Guardias patrullan con antorchas a partir de las 17:00. Quedarse en la calle después de medianoche incrementa el riesgo de intercepción.
  - **El Cliente Rebelde (Visita Clandestina):**
    - Al anochecer (18:00), un hombre con capucha andrajosa golpea tímidamente la persiana del mostrador.
    - Se presenta como Valerio, enviado de los campesinos alzados en las colinas:
    - *"El Sargento usará esa daga contra los campesinos que no puedan pagar el tributo. Necesitamos herramientas para romper cerrojos de las mazmorras... Te pagaremos el triple de lo que ofrece el Feudo."*
  - **El Jugador Forja su Destino:** Puede elegir abastecer al Feudo (oro seguro y protección temporal) o a los rebeldes (piezas clandestinas que otorgan la **Rueda Dentada de Bronce Antiguo**, pieza clave para la forja subterránea).
  - **Desbloqueo en Tienda:** Se habilita el plano para construir el **Fuelle de Doble Cámara**.

---

### 🚪 HITO 4 — La Forja Oculta (CLÍMAX DE LA DEMO & SUSPENSO)
* **Condición de Activación:** El jugador reúne los recursos (220 monedas de oro + lingotes de acero) y compra el **Fuelle de Doble Cámara**, alcanzando los 1300°C en la fragua para forjar la **Llave del Yunque Olvidado**.
* **Secuencia Cinemática del Final de la Demo:**
  1. **La Forja de la Llave:** El jugador realiza el minijuego de forja con la máxima exigencia: temperatura al rojo vivo, martillado simétrico de las estrías de la llave y choque térmico en aceite.
  2. **La Activación:** Con la llave terminada, el jugador interactúa con la ranura secreta oculta en la base del pedestal del yunque.
  3. **El Mecanismo:** Se produce un estruendo sísmico. El yunque rota 90 grados y la pared de mampostería tras la fragua desciende hacia el subsuelo.
  4. **La Revelación:** Una corriente de aire cálido y violeta sube por una escalera de piedra labrada que conduce a una forja colosal subterránea que perteneció a los antiguos maestros metalúrgicos.
  5. **El Punto de Quiebre (Cliffhanger):**
     - En ese instante exacto, suenan golpes violentos y rotundos en la puerta exterior de madera del taller:
     - **¡PUM! ¡PUM! ¡PUM!**
     - Voz del Capitán de la Guardia desde el exterior:
       > *"¡Herrero! ¡Abre de inmediato en nombre del Barón y del Feudo! ¡Sabemos lo que desenterraste en la mina y tus manos pagarán por la traición de Rodrik!"*
     - El jugador mira hacia la puerta estremecida y luego hacia la escalera subterránea iluminada por el resplandor violeta.
     - Pantalla funde a negro con un acorde grave de campana de taller.
  6. **Pantalla Final de la Demo:**
     ```
     ═══════════════════════════════════════════════════════════════
                    YUNQUE & SOMBRA — FIN DE LA DEMO
     ═══════════════════════════════════════════════════════════════
       Has dominado el fuelle, el yunque y el choque térmico.
       Has devuelto la vida al taller y descubierto el legado de Rodrik.

       ¿Qué aguarda en la forja subterránea?
       ¿Te entregarás a la guardia feudal o descenderás al abismo?

       El destino del valle continuará en la versión completa.
     ═══════════════════════════════════════════════════════════════
     ```

---

## 🛠️ 4. Integración Técnica en la Arquitectura de Godot 4

Para soportar este sistema de manera robusta, `GameManager.gd` gestiona un diccionario de hitos y objetos con señales desacopladas:

```gdscript
# GameManager.gd
signal hito_desbloqueado(clave_hito: String, titulo: String, descripcion: String)
signal objeto_comprado(clave_objeto: String)

var hitos_desbloqueados: Dictionary = {
	"hito_0_primer_encargo": false,
	"hito_0_primera_mina": false,
	"hito_1_crisol_bronce": false,
	"hito_2_pico_reforzado": false,
	"hito_2_derrumbe_mina_roto": false,
	"hito_2_diario_encontrado": false,
	"hito_3_piedra_afilar": false,
	"hito_3_daga_sargento_entregada": false,
	"hito_4_fuelle_doble": false,
	"hito_4_llave_yunque_forjada": false,
	"hito_4_climax_activado": false
}

var objetos_adquiridos: Array[String] = []

func registrar_compra_objeto(clave: String) -> void:
	if not objetos_adquiridos.has(clave):
		objetos_adquiridos.append(clave)
		objeto_comprado.emit(clave)
		verificar_disparadores_hitos()

func registrar_desbloqueo_hito(clave_hito: String, titulo: String, desc: String) -> void:
	if hitos_desbloqueados.has(clave_hito) and not hitos_desbloqueados[clave_hito]:
		hitos_desbloqueados[clave_hito] = true
		hito_desbloqueado.emit(clave_hito, titulo, desc)
		post_notification("¡Nuevo Hito Desbloqueado: %s!" % titulo)
```

### Ventajas de esta Arquitectura:
1. **Zero Acoplamiento Temporal:** El mostrador de clientes (`CounterShopView.gd`) consulta `GameManager.hitos_desbloqueados["hito_1_crisol_bronce"]` para decidir qué diálogos y pedidos ofrecer, sin importar si es el Día 2 o el Día 15.
2. **Modular y Escalable:** Agregar nuevos objetos o recetas solo requiere agregarlos a la tienda y vincularlos a un flag booleano.
3. **Guardado y Persistencia Limpia:** Guardar la partida solo requiere serializar `objetos_adquiridos` e `hitos_desbloqueados`.
