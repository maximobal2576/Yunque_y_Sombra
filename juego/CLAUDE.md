# 🛡️ DIRECTIVA DE WORKSPACE: GESTIÓN CONTINUA, ADMINISTRACIÓN ASÍNCRONA, REVISIÓN Y SINCRONIZACIÓN GIT

> **Ámbito de aplicación**: Este workspace (`juego`) y todos sus subdirectorios.  
> **Destinatarios**: Aplica a Claude y subagentes en Antigravity.

---

## 1. Protocolo Obligatorio de Sincronización Git Automática (Multi-Dispositivo & Nuevas Sesiones)

Para garantizar la integridad del código al alternar entre múltiples dispositivos (PC local, laptop, celular/tablet vía Remote Control o entornos Cloud) y evitar pérdidas de avance entre chats diarios nuevos:

### A. Al iniciar una sesión nueva (Arranque / Primer Turno del Chat):
1. **Comprobación Obligatoria de Remoto**: En el primer turno de cualquier nueva conversación o sesión, antes de inspeccionar o modificar código, el agente **DEBE** verificar el estado del repositorio remoto:
   ```bash
   git fetch origin
   git status -uno
   ```
2. **Auto-Pull Inmediato**: Si la rama local está detrás del remoto (`behind origin/main`), el agente debe ejecutar inmediatamente:
   ```bash
   git pull origin main
   ```
   para sincronizar los últimos cambios subidos desde otros dispositivos o sesiones previas.
3. **Manejo Preventivo**: Si hubiese cambios locales sin confirmar en el árbol de trabajo, preservarlos con cautela para evitar conflictos de merge (`git stash` o commit previo según corresponda).

### B. Al culminar cambios en cualquier sesión (Auto-Commit & Auto-Push):
1. Siempre que el agente cree, modifique, elimine o refactorice archivos del proyecto:
   - Debe verificar los cambios con `git status`.
   - Ejecutar `git add <archivos>` (o `git add .` según corresponda).
   - Crear un commit con mensaje descriptivo y claro (convención: `feat:`, `fix:`, `refactor:`, `docs:`).
   - Ejecutar inmediatamente `git push origin main` al repositorio remoto.
2. Informar al usuario en la respuesta el commit generado y la confirmación de subida a GitHub para que quede disponible al instante en cualquier otro dispositivo.

---

## 2. Activación Automática Obligatoria de la Skill Administrador (`/administrador`) para Tareas Complejas (> 1 Paso)

Para garantizar máxima eficiencia, velocidad de respuesta y paralelismo operativo en todo desarrollo:

1. **Criterio de Activación Automática (> 1 Paso)**:
   - Toda solicitud, encargo o desarrollo que requiera **más de una acción o paso secuencial/complejo** (crear o refactorizar mecánicas, diseñar niveles, generar assets o foley, añadir estaciones de trabajo, resolver bugs de arquitectura, ejecutar pruebas o playtests) **DEBE activar automáticamente la skill `/administrador`**.
   - No se requiere que el usuario invoque manualmente `/administrador`: el agente asume el rol de Jefe Orquestador de inmediato.

2. **Excepción Exclusiva (Tareas Atómicas / Simples de 1 Paso)**:
   - La skill `/administrador` **NO** se activará únicamente ante peticiones atómicas directas de un solo paso (por ejemplo: *"cambiale el color a este botón"*, *"corrige un typo en esta línea"*, *"muéstrame el contenido de este archivo"*).

3. **Características Operativas del Administrador Activo**:
   - **No ejecutar trabajo pesado en el hilo principal**: El hilo principal orquesta, descompone la tarea en subtareas y delega en subagentes especializados (`programador_godot`, `disenador_de_niveles`, `game_feel`, `disenador_grafico`, `sonidista`, `playtester`, `secretario`, etc.).
   - **Continuidad Total (Prohibido matar tareas previas)**: Si el usuario envía un nuevo mensaje mientras hay subagentes trabajando, **NO** se cancelan ni se eliminan los frentes anteriores. Siguen corriendo en segundo plano hasta finalizar o hasta orden expresa de cancelación.
   - **Múltiples frentes en paralelo sin pisarse**: Los subagentes trabajan en rutas disjuntas o workspaces aislados sin colisiones.
   - **Cero polling / Cero bloqueo**: Informar al usuario los frentes desplegados y cerrar el turno inmediatamente para mantener el chat interactivo y receptivo.

---

## 3. Mandato de Ejecución Automática Continua de la Skill Revisión (/revision)

Para **cada mensaje**, **cada respuesta** y **cada acción** (propuesta, redacción, creación, refactorización o ejecución de código y diseño) realizada dentro de este workspace:

1. **Activación Automática de la Skill**:
   - La skill `revision` está **habilitada de manera permanente e incondicional**.
   - No se requiere invocación manual del usuario (`/revision` se considera activo en cada turno).

2. **Protocolo de Auditoría por Acción**:
   - Cada intervención debe someterse a los criterios del Tribunal de Revisión:
     - 🎨 **UI/UX & Colorimetría**: Verificación estricta de contrastes (WCAG 2.1 AAA), paleta de autor (OKLCH, regla 60-30-10) y ausencia absoluta de clichés genéricos de IA.
     - 🏗️ **Arquitectura & Código Limpio**: Principios SOLID, DRY, KISS, baja complejidad ciclomática y modularidad.
     - 🔒 **Seguridad**: Validación defensiva de entradas, prevención de inyecciones y manejo seguro de estados.
     - 🧪 **QA & Resiliencia**: Cobertura de casos de borde, tipado estricto y gestión completa de excepciones y estados asíncronos.
     - ⚡ **Rendimiento**: Eficiencia algorítmica, minimización de renders/cálculos innecesarios y optimización de recursos.
     - 📝 **Documentación & DX**: Claridad en nombres, legibilidad técnica y precisión.

3. **Criterio de Entrega**:
   - Todo código, solución o artefacto entregado debe satisfacer previamente el filtro crítico y los estándares de la skill `revision`.

---

## 4. Mandatos Fundacionales de Trabajo (Anti-Divagación y Usabilidad)

1. **Lectura Obligatoria Previa de `juego/docs/idea.txt`**:
   - Todo agente, subagente o especialista **DEBE leer `juego/docs/idea.txt`** antes de proponer, refactorizar o codificar cualquier componente del juego.
   - Prohibido terminantemente divagar, improvisar subsistemas o añadir complejidades que contradigan la visión original de simulación de oficio y narrativa de pueblo decadente.

2. **Nombres de Nodos del SceneTree en Español Obligatorio**:
   - Todos los nodos creados o editados en archivos de escena de Godot (`.tscn`) deben estar nombrados **100% en español** claro y comprensible (`BotonAtizarFuelle`, `ManometroTemperatura`, `HornoFragua`, `EstacionYunqueCenital`, etc.) para permitir la inspección y edición directa por parte del desarrollador sin barreras idiomáticas.

3. **Arbitraje del Maestro Herrero (`/herrero`)**:
   - Toda mecánica o representación de forja debe someterse al criterio del Maestro Herrero para garantizar verosimilitud física y artesanal tradicional.
