# Token Monitor

App de barra de menú para macOS que muestra los límites de uso de Codex y Claude Code.

## Uso

1. Inicia sesión en Codex y Claude Code en este Mac.
2. Ejecuta `./scripts/install-app.sh`.
3. Abre **Token Monitor** desde Aplicaciones y pulsa su icono en la barra de menú.

La app se actualiza cada cinco minutos. Muestra porcentajes de uso y reinicios de ventana, no un saldo fijo de tokens.

## Desarrollo

`./scripts/test.sh` comprueba el análisis de las respuestas. `./scripts/build-app.sh` crea la app en `dist/`.

Basada en [UsageBar de Lucas Barake](https://github.com/lucas-barake/usagebar), bajo licencia MIT; consulta [LICENSE](LICENSE). Esta copia no descarga ni instala actualizaciones del proyecto original.
