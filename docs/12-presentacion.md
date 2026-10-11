# Presentación: cómo iniciar un proyecto Alfresco ADF

[⬅ Índice](../README.md) · Archivo: [`onboarding-adf.pptx`](onboarding-adf.pptx)

Contenido de la presentación de onboarding, diapositiva por diapositiva, con los mismos comandos y las notas del orador. Todos los comandos se ejecutaron en las pruebas de este repositorio (Windows 11, PowerShell / Git Bash), salvo los de Docker y Alfresco, indicados en la diapositiva 5.

# Introducción

---

## 1. Cómo iniciar un proyecto Alfresco ADF

Yeoman · Generador Nx · ACA · ADF a mano — el ejemplo más actual de cada camino, paso a paso. Onboarding, octubre 2026.

> **Notas del orador:** Bienvenida. Objetivo: que al terminar cada participante sepa elegir y ejecutar la forma correcta de iniciar un proyecto ADF según la versión de Angular que tenga. Todo lo que se muestra se probó en Windows 11 entre el 10 y el 11 de octubre de 2026. El material completo está en el repositorio alfresco-adf-onboarding.

---

## 2. Cuatro caminos para empezar un proyecto ADF

| Camino | Paquete / versión | Angular · ADF | Node | Estado |
|---|---|---|---|---|
| Yeoman | generator-alfresco-adf-app 6.1.1 | Angular 14 · ADF 6.1 | Node 16.20.2 | Obsoleto |
| Generador Nx | @alfresco/adf-generators 1.0.4 | Angular 19 · ADF 8.0 | Node 24 | Oficial actual |
| ACA | Alfresco Content App 8.0.0 | Angular 20 · ADF 9.0 | Node 24 (master: Angular 21) | App de referencia |
| ADF a mano | Angular CLI + paquetes ADF | Angular 22 · ADF 9.0.0 | Node 24.15+ | Proyectos existentes |

> **Notas del orador:** Hay cuatro formas de arrancar. Mostramos el ejemplo más actual de cada una. Yeoman quedó en Angular 14. El generador Nx es la forma oficial actual pero siempre genera Angular 19. ACA 8.0.0 es la última estable (Angular 20) y master ya está en Angular 21. Para la última versión de Angular (22) solo existe el camino manual.

---

## 3. Cómo encaja una app ADF con Alfresco

Navegador (app Angular + ADF) → `ng serve :4200` (proxy `/alfresco`) → ACS `:8080` (Docker).

- **app.config.json:** se lee al arrancar: ecmHost, authType (BASIC/OAUTH), providers (ECM/BPM/ALL)
- **Proxy:** evita CORS en desarrollo; ACA lo configura con BASE_URL en .env
- **Producción:** app y ACS bajo el mismo dominio (Nginx/Traefik) o CORS habilitado en ACS

> **Notas del orador:** ADF son librerías Angular que hablan con la API REST de Alfresco Content Services. En desarrollo, la app llama a su propio origen (localhost:4200/alfresco) y el proxy de Angular reenvía a ACS en el 8080. Por eso en app.config.json el ecmHost apunta a la propia app. Sin ACS levantado la app abre, pero el login responde 504.

---

## 4. Regla de oro: el ADF debe corresponder al Angular

1. ¿Qué Angular tengo? 2. Busco su fila en la tabla. 3. Instalo exactamente ese ADF y esa js-api.

```powershell
npx ng version
npm ls @angular/core
```

| Angular | ADF | js-api | Node probado |
|---|---|---|---|
| 14 | 6.9.1 | 7.8.1 | 16.20.2 |
| 16 | 7.0.0-alpha.7 | 8.0.0-alpha.7 | 16.20.2 |
| 18 | 7.0.1 | 8.0.1 | 24.19.0 |
| 19 | 8.0.0 (generador Nx) | 9.0.0 | 24.19.0 |
| 20 | 9.0.0 | 10.0.0 | 24.19.0 |
| 22 | 9.0.0 | 10.0.0 | 24.19.0 |

Si se mezclan versiones: `ERESOLVE` al instalar o errores al compilar. Todas las filas se probaron: instalar, compilar y abrir el login.

> **Notas del orador:** Antes de instalar nada, mirar la versión de Angular del proyecto. Cada fila de esta tabla se probó en el curso: se creó el proyecto, se instaló esa versión de ADF y se abrió el login sin errores. La guía docs/02-matriz-de-versiones.md tiene el detalle.

---

## 5. Preparar el entorno: nvm y ACS en Docker

**nvm** (todos los caminos):

```powershell
nvm install 24
nvm install 18.20.8
nvm install 16.20.2
nvm use 24
node -v ; npm -v
```

**ACS con Docker** (8–12 GB de RAM; no ejecutado en las pruebas, que llegaron hasta la pantalla de login):

```powershell
git clone --depth 1 `
  https://github.com/Alfresco/acs-deployment.git
cd acs-deployment\docker-compose
docker compose -f community-compose.yaml up -d
# usuario admin / admin
```

**Solo para Yeoman** (Visual Studio Build Tools 2022 + setuptools):

```powershell
# PowerShell como administrador
winget install --id Microsoft.VisualStudio.2022.BuildTools `
  --override "--wait --passive --add Microsoft.VisualStudio.Workload.VCTools --includeRecommended"
python -m pip install setuptools
npm config set msvs_version 2022
```

> **Notas del orador:** Node 24 sirve para el generador Nx, ACA 8 y master y ADF a mano con Angular 18, 20 y 22; Node 18 para ACA 4 y 5; Node 16 para Yeoman y ADF a mano con Angular 14 y 16. Los paquetes globales son por versión de Node. Los comandos de Docker no se ejecutaron en las pruebas del curso: todo se probó hasta la pantalla de login, sin backend. ACS tarda varios minutos en arrancar la primera vez; comprobar con curl http://localhost:8080/alfresco/api/-default-/public/alfresco/versions/1/probes/-ready-

# 1 · Yeoman

---

## 6. Portada de la sección 1: Yeoman

**Angular 14** — ADF 6.1 · Node 16.20.2 · npm 8.19.4. generator-alfresco-adf-app 6.1.1 (junio 2023). Obsoleto: sirve para mantener proyectos antiguos.

> **Notas del orador:** Yeoman fue el template clásico. Su última versión es la 6.1.1 y genera Angular 14 con ADF 6.1. No existe para Angular 16, 18, 20 ni 22. Lo vemos para entender proyectos heredados.

---

## 7. Yeoman: requisitos

- **Node 16.20.2 + npm 8.19.4:** Versión con la que se generó y compiló el proyecto
- **yo 4.3.1 + generador 6.1.1:** yo 7 exige Node 20+ y no funciona con este generador
- **Visual Studio Build Tools 2022 con C++:** El generador compila deasync, un módulo nativo de C++
- **Python 3 + setuptools:** node-gyp lo necesita; con Python 3.12+ falta distutils sin setuptools

```powershell
nvm install 16.20.2
nvm use 16.20.2
npm config set msvs_version 2022
node -v   # v16.20.2
```

> **Notas del orador:** El punto crítico es deasync. En Windows hace falta Visual Studio Build Tools 2022 con 'Desarrollo para el escritorio con C++'. Con Python 3.12 o superior hay que instalar setuptools. Si no se puede instalar Visual Studio, en dos diapositivas vemos la alternativa que no compila nada.

---

## 8. Yeoman: crear e iniciar el proyecto

```powershell
nvm use 16.20.2
npm install -g yo@4.3.1 `
  generator-alfresco-adf-app@6.1.1

yo alfresco-adf-app
#  nombre: mi-app · blueprint: ACS
#  instalar ahora: No · licencia: MIT

cd mi-app
npm install       # 2–3 min
npm start         # http://localhost:4200
```

**Lo que genera:**

- proxy.conf.js → localhost:8080
- src/app.config.json
- Login, home, documentos y visor
- CoreModule.forRoot() + ContentModule

**Renombrar el proyecto** (el `package.json` sale con `name: adf-cli-acs-template`):

```powershell
npm pkg set name=mi-app
```

> **Notas del orador:** Comprobado: yo generó el proyecto, npm install terminó y ng serve compiló. En modo semi-automático: yo alfresco-adf-app --name=mi-app --blueprint=adf-cli-acs-template --no-install. El subgenerador de licencia igual pregunta nombre, email y web. El archivo LICENSE queda en la carpeta padre: moverlo con Move-Item ..\LICENSE . si se quiere dentro del proyecto.

---

## 9. Atajo para el aula y errores frecuentes

Sin Visual Studio ni `yo`: el generador solo copia una carpeta, se extrae del paquete npm.

```powershell
nvm use 16.20.2
npm pack generator-alfresco-adf-app@6.1.1
tar xzf generator-alfresco-adf-app-6.1.1.tgz
Copy-Item -Recurse `
  package\app\templates\adf-cli-acs-template `
  mi-app
cd mi-app ; npm install ; npm start
```

| Error | Solución |
|---|---|
| gyp ERR! find VS | Build Tools 2022 (diapositiva 5) y `npm config set msvs_version 2022` |
| No module named 'distutils' | `python -m pip install setuptools` |
| Could not locate the bindings file | `npm install -g yo@4.3.1 generator-alfresco-adf-app@6.1.1` |
| yo: command not found | `nvm use 16.20.2` |

> **Notas del orador:** El atajo da el mismo resultado que yo, porque el generador no reemplaza nada en la plantilla. Comprobado con Node 16.20.2: npm install y ng build terminan bien. Si aparece 'Could not locate the bindings file' es porque deasync no se compiló: corregir Build Tools o setuptools y reinstalar.

# 2 · Generador Nx

---

## 10. Portada de la sección 2: Generador Nx

**Angular 19** — ADF 8.0 · Node 24.11.1+ · npm 11. @alfresco/adf-generators 1.0.4: la forma oficial actual de crear una app ADF nueva.

> **Notas del orador:** El generador Nx reemplaza a Yeoman. Todas sus versiones (1.0.0 a 1.0.4) generan Angular 19.2.6 con ADF 8.0.0 y js-api 9. No tiene opción para elegir otra versión de Angular.

---

## 11. Generador Nx: crear el workspace y la app

```powershell
nvm use 24
npx create-nx-workspace@latest adf-workspace `
  --preset=apps --nxCloud=skip `
  --packageManager=npm --no-interactive
cd adf-workspace

npx nx add @alfresco/adf-generators
npx nx g @alfresco/adf-generators:template-app `
  --name=template --template=acs `
  --authType=BASIC --provider=ECM `
  --no-interactive
```

| Opción | Valores |
|---|---|
| --template | empty, acs, aps, acs-aps, automate, apa, acs-apa |
| --authType | BASIC u OAUTH |
| --provider | ECM, BPM o ALL |

> **Notas del orador:** Comprobado con Node 24.19.0 y npm 11.17.0. Sin flags, create-nx-workspace pregunta: Workspace empty, Stack none, Prettier No, CI skip, Remote caching skip. Para una app sin componentes: npx nx g @alfresco/adf-generators:empty-app.

---

## 12. Generador Nx: configurar y ejecutar

```js
// template\proxy.conf.js
const ecmHost = 'http://localhost:8080';
const bpmHost = '';   // solo con APS
```

```powershell
cd template
npm install    # ~2 min
npm start      # http://localhost:4200
npm run build  # build de producción
```

**La app generada:**

- Es un proyecto npm propio dentro del workspace (Nx 21 + Angular 19)
- app.config.ts standalone con importProvidersFrom(AuthModule, CoreModule, ContentModule)
- Rutas: login, home, documents, files/:nodeId/view
- Layout con menú lateral (adf-sidenav-layout)
- Tema en theme.scss, colors.scss, variables.scss

> **Notas del orador:** El template sale con ecmHost y bpmHost vacíos en proxy.conf.js: hay que completar ecmHost. Con el template automate también se completan las variables OAuth en src/app.config.json. Comprobado: npm install y npm run build terminaron bien.

---

## 13. Generador Nx: comandos correctos

**Nombre completo del generador** — Al blog y a docs.hyland.com les falta @alfresco

```powershell
npx nx g @alfresco/adf-generators:template-app `
  --name=template --template=acs `
  --authType=BASIC --provider=ECM
```

**Instalar e iniciar sin pasos extra** — No instalar @angular-devkit/build-angular: el template ya lo trae

```powershell
cd template
npm install
npm start
```

**Node 24, no 22** — El .nvmrc del repositorio de generadores pide 24.11.1

```powershell
nvm install 24
nvm use 24
node -v      # v24.x
```

> **Notas del orador:** En el blog de Hyland Connect y en docs.hyland.com el comando aparece como 'nx generate /adf-generators:...': se perdió @alfresco al publicar. También indican 'npm i -D @angular-devkit/build-angular' antes de instalar: no hace falta y, sin versión, instala la última de Angular y rompe el template. Aquí están los comandos que sí funcionan, todos probados.

# 3 · ACA

---

## 14. Portada de la sección 3: ACA

**Angular 20** — ACA 8.0.0 · ADF 9.0 · Node 24.13.1+ (master: Angular 21 + pnpm). Alfresco Content App: la aplicación de referencia, extensible con plugins.

> **Notas del orador:** ACA es un gestor documental completo hecho con ADF. Se usa como template oficial y se extiende sin modificar su código. Para Angular 14 existe ACA 4.4.1 y para Angular 16 ACA 5.3.0, ambos con Node 18; no hay ACA para Angular 18 ni 22.

---

## 15. ACA 8.0.0 (estable) y master (lo más nuevo)

**ACA 8.0.0 · Angular 20 · npm** (comprobado):

```powershell
nvm use 24
git clone --depth 1 --branch 8.0.0 https://github.com/Alfresco/alfresco-content-app.git aca
cd aca
Set-Content .env 'BASE_URL="http://localhost:8080"' -Encoding utf8
npm install       # ~40 s
npm start         # http://localhost:4200
```

**ACA master · Angular 21 · pnpm** (comprobado):

```powershell
nvm use 24        # >= 24.13.1
corepack enable   # activa pnpm 11
git clone --depth 1 https://github.com/Alfresco/alfresco-content-app.git aca
cd aca
Set-Content .env 'BASE_URL="http://localhost:8080"' -Encoding utf8
pnpm install
pnpm start
```

> **Notas del orador:** Comprobado: ACA 8.0.0 instaló en 40 segundos, compiló en 40 segundos y abrió el login con Angular 20.3.25. Master usa pnpm: con npm el preinstall lo bloquea, por eso se activa pnpm con corepack.

---

## 16. La guía oficial de ACA está desactualizada

| Tema | Guía de Hyland | Lo que funciona (probado) |
|---|---|---|
| Node | 18.x | 18 para ACA 4.x/5.x · 24.13.1+ para ACA 8 |
| Gestor | npm | npm hasta 8.0.0 · pnpm en master |
| .env | APP_CONFIG_ECM_HOST, APP_CONFIG_PLUGIN_AOS, APP_CONFIG_PLUGIN_CONTENT_SERVICE | Solo BASE_URL (4.4.1, 5.3.0, 8.0.0 y master) |

**Consola: «error loading discovery document» con `authType: BASIC`.** ACA busca un servidor OAuth (Keycloak) por el bloque `oauth2` de `app.config.json`. Quitarlo elimina el error (comprobado), desde la raíz de ACA:

```powershell
node -e "const f='app/src/app.config.json',fs=require('fs'),c=JSON.parse(fs.readFileSync(f));delete c.oauth2;fs.writeFileSync(f,JSON.stringify(c,null,2))"
```

> **Notas del orador:** La guía 'Deploy Alfresco Content App' de docs.hyland.com indica Node 18, npm y variables APP_CONFIG_*. Probamos cuatro versiones de ACA y todas usan solo BASE_URL. El error de discovery document se comprobó: al quitar el bloque oauth2 de app/src/app.config.json desaparece y el login sigue funcionando. Comando para borrarlo desde la raíz de ACA (probado en PowerShell): node -e "const f='app/src/app.config.json',fs=require('fs'),c=JSON.parse(fs.readFileSync(f));delete c.oauth2;fs.writeFileSync(f,JSON.stringify(c,null,2))" . Si después se quiere usar OAuth (Keycloak), hay que volver a poner ese bloque con los datos del servidor.

---

## 17. Extender ACA sin tocar su código

```text
aca/
├─ .env                 # BASE_URL
├─ app/
│  ├─ proxy.conf.js
│  └─ src/
│     ├─ app.config.json
│     └─ app/extensions.module.ts
└─ projects/
   ├─ aca-content/      # funciones
   │  └─ assets/app.extensions.json
   └─ ext/               # tu extensión
```

**Crear una extensión** (desde la raíz de ACA 8.0.0, comprobado: genera, instala y compila):

```powershell
npx nx add @alfresco/aca-generators
npx nx g @alfresco/aca-generators:aca-extension `
  --name=ext --directory=ext
npm install
npm start
```

- Crea projects/ext y la registra en extensions.module.ts
- Agrega un ítem de menú que lleva a #/ext
- Rutas, acciones y reglas se declaran en JSON

> **Notas del orador:** Comprobado en ACA 8.0.0: nx add instaló el plugin, el generador creó projects/ext y actualizó app/src/app/extensions.module.ts, app/project.json y tsconfig.json; luego npm install y npx nx build content-ce terminaron bien. El ítem de menú se ve después de iniciar sesión, con ACS levantado. La documentación de ACA (carpeta docs/ y alfresco-content-app.netlify.app) tiene tutoriales de extensiones.

# 4 · ADF a mano

---

## 18. Portada de la sección 4: ADF a mano

**Angular 22** — ADF 9.0.0 · Node 24.15+ · npm 11. Agregar ADF a un proyecto Angular nuevo o existente. Única opción para la última versión de Angular.

> **Notas del orador:** Para Angular 22 no hay generador ni ACA. Usamos ADF 9.0.0 y funciona sin errores: se probó con Angular 22.2. La guía del repositorio tiene la misma receta para Angular 14, 16, 18 y 20, y el script scripts/probar-angular-adf.sh 22 hace todos estos pasos de una vez.

---

## 19. Angular 22: crear el proyecto e instalar ADF

```powershell
nvm use 24                                  # >= 24.15
npx @angular/cli@latest new mi-app --style=scss --ssr=false --ai-config=none
cd mi-app
Set-Content .npmrc 'legacy-peer-deps=true' -Encoding ascii
npx ng add @angular/material@22 --skip-confirmation --defaults
npm install @alfresco/adf-core@9.0.0 @alfresco/adf-extensions@9.0.0 `
  @alfresco/js-api@10.0.0 @ngx-translate/core@17 @mat-datetimepicker/core@12 `
  @angular/material-date-fns-adapter@22 @angular/animations@22 date-fns@2 `
  angular-oauth2-oidc@19 minimatch@10 pdfjs-dist cropperjs zone.js
```

| Por qué | Motivo |
|---|---|
| legacy-peer-deps | evita ERESOLVE: los peers de ADF están desalineados |
| ng add material | tema de Material, fuente Roboto y Material Icons |
| zone.js | Angular 21+ crea el proyecto sin zone.js y ADF lo usa |

> **Notas del orador:** Comandos completos, tal como se probaron con Angular 22.2 y Node 24.19. Para usar documentos, visor y búsqueda se agrega: npm install @alfresco/adf-content-services@9.0.0.

---

## 20. Angular 22: configurar ADF 9 en el código

```ts
// src/app/app.config.ts
import { ApplicationConfig, provideZoneChangeDetection } from '@angular/core';
import { provideRouter } from '@angular/router';
import { provideAnimations } from '@angular/platform-browser/animations';
import { provideAppConfig, provideCoreAuth, provideI18N } from '@alfresco/adf-core';

export const appConfig: ApplicationConfig = {
  providers: [provideZoneChangeDetection(), provideRouter([]), provideAnimations(),
              provideAppConfig(), provideI18N(), provideCoreAuth()]
};
```

```ts
// src/app/app.ts
import { Component } from '@angular/core';
import { LoginComponent } from '@alfresco/adf-core';

@Component({ selector: 'app-root', imports: [LoginComponent],
             template: '<adf-login></adf-login>' })
export class App {}
```

> **Notas del orador:** En ADF 9 se configura con provide*() y los componentes son standalone: se importa cada uno (LoginComponent, DocumentListComponent...). provideZoneChangeDetection() es necesario porque Angular 22 crea el proyecto sin zone.js. Probado: el login se abre en Chrome sin errores.

---

## 21. Angular 22: archivos y ajustes de angular.json

```jsonc
// public/app.config.json
{ "ecmHost": "http://localhost:4200",
  "providers": "ECM", "authType": "BASIC",
  "loginRoute": "login" }
```

```jsonc
// proxy.conf.json (raíz del proyecto)
{ "/alfresco": {
    "target": "http://localhost:8080",
    "secure": false, "changeOrigin": true } }
```

```jsonc
// angular.json → projects.mi-app.architect
"build": { "options": {
  "polyfills": ["zone.js"],
  "assets": [ { "glob": "**/*", "input": "public" },
    { "glob": "**/*", "output": "/assets",
      "input": "node_modules/@alfresco/adf-core/bundles/assets" } ] },
  "configurations": { "production": { "budgets": [
    { "type": "initial", "maximumWarning": "4mb", "maximumError": "6mb" } ] } } },
"serve": { "options": { "proxyConfig": "proxy.conf.json" } }
```

Después: `npm start` → http://localhost:4200

> **Notas del orador:** Solo se agregan o cambian esas claves; el resto de angular.json queda como lo generó ng new. Después: npm start y abrir http://localhost:4200. El budget se sube porque ADF supera el límite de 1 MB que trae ng new y sin el cambio ng build falla.

---

## 22. Cinco errores reales y cómo se resuelven

| Error | Solución |
|---|---|
| Página en blanco y «app.config.json contains validation errors» | `# Angular 18+: el archivo va en public/`<br>`Move-Item src\assets\app.config.json public\` |
| NullInjectorError: No provider for RedirectAuthService (ADF 6/7) | `// app.module.ts → imports`<br>`AuthModule.forRoot({ useHash: true })` |
| Errores TS dentro de node_modules (Angular 14/16) | `npm install -D @types/node@16      # Angular 14`<br>`// tsconfig.json: "skipLibCheck": true` |
| bundle initial exceeded maximum budget | `// angular.json → budgets (initial)`<br>`"maximumWarning": "4mb", "maximumError": "6mb"` |
| Se ve el texto «visibility» en vez del ícono | `npx ng add @angular/material@22 --skip-confirmation` |

> **Notas del orador:** Todos aparecieron en las pruebas. El primero es el más engañoso: si app.config.json queda en src/assets, el servidor devuelve index.html y ADF muestra 'validation errors'. En Angular 14 a 17 el archivo va en src/app.config.json y hay que agregar "src/app.config.json" a assets en angular.json. Si ng add no agrega Material Icons, poner en src/index.html: <link href="https://fonts.googleapis.com/icon?family=Material+Icons" rel="stylesheet">

# Cierre

---

## 23. ¿Qué camino elegir?

|  | Yeoman | Generador Nx | ACA | ADF a mano |
|---|---|---|---|---|
| Angular | 14 | 19 | 20 (master: 21) | 14 a 22 |
| ADF | 6.1 | 8.0 | 9.0 | 6.9.1 a 9.0.0 |
| Node | 16.20.2 | 24.11.1+ | 24.13.1+ | 16 a 24.15+ |
| Gestor | npm 8 | npm 11 | npm (master: pnpm) | npm + legacy-peer-deps |
| Usar para | Proyectos heredados | App ADF nueva | Gestor documental completo | Proyecto Angular existente |

Regla práctica: miren la versión de Angular del proyecto y busquen su fila en la matriz de versiones.

> **Notas del orador:** Resumen para decidir. Aula moderna: generador Nx o ACA 8.0.0 con Node 24. Proyecto existente: ADF a mano según su Angular. Proyecto heredado en Angular 14: Yeoman o ACA 4.4.1.

---

## 24. Para seguir aprendiendo

- **docs/00–11:** Guía completa por versión de Angular
- **Tutorial mini app:** Login → documentos → visor (Angular 20 + ADF 9)
- **scripts/:** probar-angular-adf.sh y probar-aca.sh
- **Repos oficiales:** alfresco-ng2-components · alfresco-content-app · alfresco-front-end-generators

> **Notas del orador:** Próximos pasos sugeridos: levantar ACS con Docker y hacer el tutorial completo con datos reales; crear una extensión de ACA; practicar agregar ADF a un proyecto Angular propio. Preguntas.
