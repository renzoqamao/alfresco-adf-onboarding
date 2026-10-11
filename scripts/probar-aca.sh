#!/usr/bin/env bash
# Clona un tag de Alfresco Content App, crea .env, instala y ejecuta "nx build content-ce".
#
# Uso (Git Bash o Linux/macOS):
#   scripts/probar-aca.sh <tag> [carpeta-destino]
#   Ejemplos: 4.4.1 (Angular 14), 5.3.0 (Angular 16), 8.0.0 (Angular 20), master (Angular 21, pnpm)
set -euo pipefail

TAG=${1:?Uso: $0 <tag> [destino]}
DEST=${2:-./aca-$TAG}

case "$TAG" in
  4.*|5.*) NODE=18 ;;
  6.*)     NODE=20 ;;
  7.0.*|7.1.*|7.2.*|7.3.*|7.4.*) NODE=22 ;;
  *)       NODE=24 ;;
esac

find_node() {
  local want=$1 base
  if [ -n "${NVM_HOME:-}" ] || [ -n "${LOCALAPPDATA:-}" ]; then
    base=$(cygpath -u "${NVM_HOME:-$LOCALAPPDATA/nvm}" 2>/dev/null || echo "${NVM_HOME:-$LOCALAPPDATA/nvm}")
    ls -d "$base"/v"$want"* 2>/dev/null | sort -V | tail -1
  else
    ls -d "$HOME/.nvm/versions/node"/v"$want"*/bin 2>/dev/null | sort -V | tail -1
  fi
}
NODEDIR=$(find_node "$NODE")
[ -n "$NODEDIR" ] || { echo "No se encontró Node $NODE en nvm. Ejecutar: nvm install $NODE"; exit 1; }
export PATH="$NODEDIR:$PATH"
echo ">> ACA $TAG con Node $(node -v)"

git clone --depth 1 --branch "$TAG" https://github.com/Alfresco/alfresco-content-app.git "$DEST"
cd "$DEST"
printf 'BASE_URL="http://localhost:8080"\n' > .env

if grep -q '"packageManager": "pnpm' package.json; then
  corepack enable
  pnpm install
  NODE_OPTIONS=--max-old-space-size=6144 pnpm nx build content-ce
else
  npm install
  NODE_OPTIONS=--max-old-space-size=6144 npx nx build content-ce
fi
echo ">> OK: $(pwd). Ejecutar con: npm start (o pnpm start)  → http://localhost:4200"
