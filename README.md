# Token Monitor

App de barra de menú para macOS que muestra los límites de uso de Codex y Claude Code.

## Uso

1. Inicia sesión en Codex y Claude Code en este Mac.
2. Ejecuta `./scripts/install-app.sh`.
3. Abre **Token Monitor** desde Aplicaciones y pulsa su icono en la barra de menú.

La app se actualiza cada cinco minutos. La cifra de la barra muestra el promedio de uso semanal de Codex y Claude; si falta uno, queda vacía. El panel muestra los porcentajes y reinicios de cada ventana, no un saldo fijo de tokens.

En **Nueva tarea**, escribe lo que necesitas y elige la carpeta del proyecto. Token Monitor consulta las cuotas y abre una sesión de la IA con más capacidad disponible. Compara el porcentaje libre de la ventana más ajustada de cada cuenta; no existen saldos absolutos de tokens comparables entre suscripciones.

Para repartir una tarea entre actividades desde otro agente o la terminal, ejecuta `'/Applications/Token Monitor.app/Contents/MacOS/token-route' choose` antes de cada actividad. `token-route run 'actividad'` la asigna y ejecuta con una sola IA, escogida de nuevo en ese momento. Las tareas escritas directamente en las apps de Codex o Claude ya han empezado en esa IA; las instrucciones globales las derivan cuando el monitor elige la otra.

## Desarrollo

`./scripts/test.sh` comprueba el análisis de las respuestas. `./scripts/build-app.sh` crea la app en `dist/`.

Basada en [UsageBar de Lucas Barake](https://github.com/lucas-barake/usagebar), bajo licencia MIT; consulta [LICENSE](LICENSE). Esta copia no descarga ni instala actualizaciones del proyecto original.
