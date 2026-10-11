#!/usr/bin/env bash
# Crea un proyecto Angular de la versión indicada, le agrega ADF con las correcciones documentadas en
# docs/06-adf-manual.md, pone <adf-login> en la página y ejecuta "ng build".
#
# Uso (Git Bash o Linux/macOS):
#   scripts/probar-angular-adf.sh <14|16|18|20|22> [carpeta-destino]
#
# Requiere nvm con las versiones de Node instaladas (16.20.2 y 24.x). En Windows se busca Node en
# $NVM_HOME (por defecto %LOCALAPPDATA%\nvm); en Linux/macOS, en ~/.nvm/versions/node.
set -euo pipefail

NG=${1:?Uso: $0 <14|16|18|20|22> [destino]}
DEST=${2:-./adf-ng$NG}

case "$NG" in
  14) NODE=16.20.2; MODE=module; NEWFLAGS=""; CFG=src
      ADF="@alfresco/adf-core@6.9.1 @alfresco/adf-extensions@6.9.1 @alfresco/js-api@7.8.1 @ngx-translate/core@14 @mat-datetimepicker/core@10.1.1 @angular/material-date-fns-adapter@14 date-fns@2 minimatch-browser@1.0.0 pdfjs-dist@3.3.122"
      DEV="@types/node@16"; SKIPLIB=1 ;;
  16) NODE=16.20.2; MODE=module; NEWFLAGS=""; CFG=src
      ADF="@alfresco/adf-core@7.0.0-alpha.7 @alfresco/adf-extensions@7.0.0-alpha.7 @alfresco/js-api@8.0.0-alpha.7 @ngx-translate/core@14 @mat-datetimepicker/core@12.0.1 @angular/material-date-fns-adapter@16 date-fns@2 minimatch-browser@1.0.0 pdfjs-dist@3.3.122 ts-morph@20"
      DEV=""; SKIPLIB=1 ;;
  18) NODE=24; MODE=module; NEWFLAGS="--standalone=false --ssr=false"; CFG=public
      ADF="@alfresco/adf-core@7.0.1 @alfresco/adf-extensions@7.0.1 @alfresco/js-api@8.0.1 @ngx-translate/core@15 @mat-datetimepicker/core@14 @angular/material-date-fns-adapter@18 date-fns@2 minimatch@10 pdfjs-dist@3.3.122 ts-morph@20"
      DEV=""; SKIPLIB=0 ;;
  20) NODE=24; MODE=provide; NEWFLAGS="--standalone=false --ssr=false"; CFG=public
      ADF="@alfresco/adf-core@9.0.0 @alfresco/adf-extensions@9.0.0 @alfresco/js-api@10.0.0 @ngx-translate/core@17 @mat-datetimepicker/core@16 @angular/material-date-fns-adapter@20 @angular/animations@20 date-fns@2 angular-oauth2-oidc@19 minimatch@10 pdfjs-dist cropperjs"
      DEV=""; SKIPLIB=0 ;;
  22) NODE=24; MODE=standalone; NEWFLAGS="--ssr=false --ai-config=none"; CFG=public
      ADF="@alfresco/adf-core@9.0.0 @alfresco/adf-extensions@9.0.0 @alfresco/js-api@10.0.0 @ngx-translate/core@17 @mat-datetimepicker/core@12 @angular/material-date-fns-adapter@22 @angular/animations@22 date-fns@2 angular-oauth2-oidc@19 minimatch@10 pdfjs-dist cropperjs zone.js"
      DEV=""; SKIPLIB=0 ;;
  *) echo "Versión no soportada: $NG (usar 14, 16, 18, 20 o 22)"; exit 1 ;;
esac

# --- Localizar el Node pedido (sin cambiar el Node global) ---
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
echo ">> Angular $NG con Node $(node -v) / npm $(npm -v)"

# --- 1. Proyecto ---
NAME=$(basename "$DEST"); PARENT=$(dirname "$DEST"); mkdir -p "$PARENT"; cd "$PARENT"
CLI=$NG; [ "$NG" = 22 ] && CLI=latest
npx -y @angular/cli@$CLI new "$NAME" --style=scss --routing=false --skip-git --skip-install --defaults $NEWFLAGS
cd "$NAME"
printf 'legacy-peer-deps=true\n' > .npmrc
npm install

# --- 2. Material + ADF ---
npx ng add @angular/material@$NG --skip-confirmation --defaults
npm install $ADF
[ -n "$DEV" ] && npm install -D $DEV

# --- 3. Código ---
APP=src/app
first() { for f in "$@"; do [ -f "$f" ] && { echo "$f"; return 0; }; done; return 0; }
MOD=$(first $APP/app.module.ts $APP/app-module.ts)
CMP=$(first $APP/app.component.ts $APP/app.ts)
HTML=$(first $APP/app.component.html $APP/app.html)
CLS=$(grep -oE 'export class [A-Za-z]+' "$CMP" | awk '{print $3}')
IMP="./$(basename "$CMP" .ts)"

case "$MODE" in
module) cat > "$MOD" <<EOF
import { NgModule } from '@angular/core';
import { BrowserModule } from '@angular/platform-browser';
import { BrowserAnimationsModule } from '@angular/platform-browser/animations';
import { RouterModule } from '@angular/router';
import { TranslateLoader, TranslateModule } from '@ngx-translate/core';
import { AuthModule, CoreModule, TranslateLoaderService } from '@alfresco/adf-core';
import { $CLS } from '$IMP';

@NgModule({
  declarations: [$CLS],
  imports: [
    BrowserModule,
    BrowserAnimationsModule,
    RouterModule.forRoot([]),
    TranslateModule.forRoot({ loader: { provide: TranslateLoader, useClass: TranslateLoaderService } }),
    CoreModule.forRoot(),
    AuthModule.forRoot({ useHash: true })
  ],
  bootstrap: [$CLS]
})
export class AppModule {}
EOF
  echo '<adf-login></adf-login>' > "$HTML" ;;
provide) cat > "$MOD" <<EOF
import { NgModule, provideZoneChangeDetection } from '@angular/core';
import { BrowserModule } from '@angular/platform-browser';
import { provideAnimations } from '@angular/platform-browser/animations';
import { provideRouter } from '@angular/router';
import { LoginComponent, provideAppConfig, provideCoreAuth, provideI18N } from '@alfresco/adf-core';
import { $CLS } from '$IMP';

@NgModule({
  declarations: [$CLS],
  imports: [BrowserModule, LoginComponent],
  providers: [
    provideZoneChangeDetection({ eventCoalescing: true }),
    provideAnimations(),
    provideRouter([]),
    provideAppConfig(),
    provideI18N(),
    provideCoreAuth()
  ],
  bootstrap: [$CLS]
})
export class AppModule {}
EOF
  echo '<adf-login></adf-login>' > "$HTML" ;;
standalone)
  cat > $APP/app.config.ts <<'EOF'
import { ApplicationConfig, provideBrowserGlobalErrorListeners, provideZoneChangeDetection } from '@angular/core';
import { provideRouter } from '@angular/router';
import { provideAnimations } from '@angular/platform-browser/animations';
import { provideAppConfig, provideCoreAuth, provideI18N } from '@alfresco/adf-core';

export const appConfig: ApplicationConfig = {
  providers: [
    provideBrowserGlobalErrorListeners(),
    provideZoneChangeDetection({ eventCoalescing: true }),
    provideRouter([]),
    provideAnimations(),
    provideAppConfig(),
    provideI18N(),
    provideCoreAuth()
  ]
};
EOF
  cat > "$CMP" <<'EOF'
import { Component } from '@angular/core';
import { LoginComponent } from '@alfresco/adf-core';

@Component({
  selector: 'app-root',
  imports: [LoginComponent],
  template: `<adf-login successRoute="/"></adf-login>`
})
export class App {}
EOF
  rm -f "$APP/app.html" "$APP/app.scss" "$APP/app.spec.ts" ;;
esac

# --- 4. app.config.json, proxy, angular.json, tsconfig ---
mkdir -p "$CFG"
cat > "$CFG/app.config.json" <<'EOF'
{
  "ecmHost": "http://localhost:4200",
  "providers": "ECM",
  "authType": "BASIC",
  "loginRoute": "login",
  "application": { "name": "ADF" }
}
EOF
printf '{\n  "/alfresco": { "target": "http://localhost:8080", "secure": false, "changeOrigin": true }\n}\n' > proxy.conf.json

CFG=$CFG SKIPLIB=$SKIPLIB MODE=$MODE node -e '
const fs = require("fs");
const j = JSON.parse(fs.readFileSync("angular.json"));
const p = Object.values(j.projects)[0];
const o = p.architect.build.options;
if (process.env.CFG === "src") o.assets.unshift("src/app.config.json");
o.assets.push({ glob: "**/*", input: "node_modules/@alfresco/adf-core/bundles/assets", output: "/assets" });
if (process.env.MODE === "standalone") o.polyfills = ["zone.js"];
p.architect.serve.options = { ...(p.architect.serve.options || {}), proxyConfig: "proxy.conf.json" };
for (const b of p.architect.build.configurations.production.budgets || [])
  if (b.type === "initial") { b.maximumWarning = "4mb"; b.maximumError = "6mb"; }
fs.writeFileSync("angular.json", JSON.stringify(j, null, 2));
if (process.env.SKIPLIB === "1") {
  const raw = fs.readFileSync("tsconfig.json", "utf8").replace(/^\/\*[\s\S]*?\*\/\s*/, "");
  const t = JSON.parse(raw); t.compilerOptions.skipLibCheck = true;
  fs.writeFileSync("tsconfig.json", JSON.stringify(t, null, 2));
}'

# --- 5. Build ---
npx ng build
echo ">> OK: $(pwd). Ejecutar con: npm start  (http://localhost:4200)"
