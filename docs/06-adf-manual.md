# 06 · Agregar ADF a mano a un proyecto Angular

[⬅ ACA](05-aca.md) · [Índice](../README.md) · [Siguiente: Tutorial mini app ➡](07-tutorial-mini-app.md)

Es el camino para **agregar componentes ADF a un proyecto Angular que ya existe**, o para crear una
app mínima (un dashboard, un portal) sin el peso de ACA.

> **Comprobado el 2026-10-10:** para **Angular 14, 16, 18, 20 y 22** se creó el proyecto con
> `ng new`, se instaló ADF, se configuró y se abrió `<adf-login>` en Chrome **sin errores en
> consola**. Se puede reproducir con [`scripts/probar-angular-adf.sh`](../scripts/probar-angular-adf.sh).

## Índice

- [Pasos comunes a todas las versiones](#pasos-comunes-a-todas-las-versiones)
- [Angular 14 → ADF 6.9.1](#angular-14--adf-691)
- [Angular 16 → ADF 7.0.0-alpha.7](#angular-16--adf-700-alpha7)
- [Angular 18 → ADF 7.0.1](#angular-18--adf-701)
- [Angular 20 → ADF 9.0.0](#angular-20--adf-900)
- [Angular 22 (última) → ADF 9.0.0](#angular-22-última--adf-900)
- [Otras versiones (15, 17, 19, 21)](#otras-versiones-15-17-19-21)
- [Proyecto existente: cómo saber qué instalar](#proyecto-existente-cómo-saber-qué-instalar)

## Resumen

| Angular | ADF | Node | Configuración | `app.config.json` en | Ajustes extra |
|---|---|---|---|---|---|
| 14 | 6.9.1 | 16.20.2 | `CoreModule.forRoot()` + `AuthModule.forRoot()` | `src/` (+ assets) | `skipLibCheck`, `@types/node@16` |
| 16 | 7.0.0-alpha.7 | 16.20.2 | igual que 14 | `src/` (+ assets) | `skipLibCheck` |
| 18 | 7.0.1 | 24 (oficial 18.19 / 20 / 22) | igual que 14 | `public/` | — |
| 20 | 9.0.0 | 24 | `provideAppConfig()` + `provideI18N()` + `provideCoreAuth()` | `public/` | — |
| 22 | 9.0.0 | 24.15+ | igual que 20 + `zone.js` | `public/` | zoneless → zone.js |

---

## Pasos comunes a todas las versiones

Cada sección de versión enlaza a estos pasos.

### C1. `.npmrc` con `legacy-peer-deps`

Las dependencias de ADF tienen `peerDependencies` desalineados: `@mat-datetimepicker/core`, y en ADF
7 alpha también `@angular/*` exactos. Sin esto, npm falla con `ERESOLVE`:

```powershell
"legacy-peer-deps=true" | Out-File -Encoding ascii .npmrc
```

### C2. Angular Material

```powershell
npx ng add @angular/material@<versión de Angular> --skip-confirmation --defaults
```

Instala `@angular/material` y `@angular/cdk`, agrega un tema prediseñado y pone en `src/index.html`
las fuentes **Roboto** y **Material Icons**. Sin Material Icons, se ve el texto `visibility` en vez
del ícono del ojo en el campo contraseña.

### C3. `app.config.json`

ADF lo descarga desde la **raíz** de la app (`/app.config.json`) al arrancar:

```json
{
  "ecmHost": "http://localhost:4200",
  "providers": "ECM",
  "authType": "BASIC",
  "loginRoute": "login",
  "application": { "name": "Mi App" }
}
```

| Angular | Ubicación | Registro |
|---|---|---|
| 14 – 17 | `src/app.config.json` | Agregar `"src/app.config.json"` al principio de `architect.build.options.assets` en `angular.json` |
| 18+ | `public/app.config.json` | Ninguno (`public/` ya está registrado) |

Si queda en `src/assets/`, el servidor devuelve `index.html`, ADF muestra **"app.config.json contains
validation errors"** y la app queda **en blanco**. En ADF 6/7 no aparece ningún otro error.

### C4. Assets de ADF (traducciones e imágenes)

En `angular.json` → `architect.build.options.assets` (y en `test`):

```json
{ "glob": "**/*", "input": "node_modules/@alfresco/adf-core/bundles/assets", "output": "/assets" }
```

Con `adf-content-services`, agregar también:

```json
{ "glob": "**/*", "input": "node_modules/@alfresco/adf-content-services/bundles/assets", "output": "/assets" }
```

### C5. Proxy de desarrollo

`proxy.conf.json` en la raíz:

```json
{
  "/alfresco": { "target": "http://localhost:8080", "secure": false, "changeOrigin": true }
}
```

Y en `angular.json` → `architect.serve.options.proxyConfig: "proxy.conf.json"`.

### C6. Budget de producción

ADF supera el límite de 1 MB que trae `ng new` y `ng build` falla con `bundle initial exceeded
maximum budget`. En `architect.build.configurations.production.budgets`, en la entrada
`"type": "initial"`:

```json
{ "type": "initial", "maximumWarning": "4mb", "maximumError": "6mb" }
```

### C7. Ejecutar

```powershell
npm start            # ng serve → http://localhost:4200 (con ACS en :8080 para iniciar sesión)
npx ng build         # build de producción → dist/
```

---

## Angular 14 → ADF 6.9.1

### Requisitos

| Requisito | Versión |
|---|---|
| Node.js | **16.20.2** (probado) |
| npm | 8.19.4 |
| Angular CLI | 14.2.x (`ng new` instaló 14.3.0) |
| TypeScript | 4.7 (el de Angular 14) |
| ADF | `@alfresco/adf-core@6.9.1`, `@alfresco/adf-extensions@6.9.1` |
| js-api | `@alfresco/js-api@7.8.1` |

### Instalar requisitos

```powershell
nvm install 16.20.2
nvm use 16.20.2
```

### Crear el proyecto (o usar uno existente en Angular 14)

```powershell
npx @angular/cli@14 new mi-app --style=scss --routing=false
cd mi-app
```

### Instalar ADF

```powershell
"legacy-peer-deps=true" | Out-File -Encoding ascii .npmrc                  # C1
npx ng add @angular/material@14 --skip-confirmation --defaults             # C2
npm install @alfresco/adf-core@6.9.1 @alfresco/adf-extensions@6.9.1 @alfresco/js-api@7.8.1 `
  @ngx-translate/core@14 @mat-datetimepicker/core@10.1.1 @angular/material-date-fns-adapter@14 `
  date-fns@2 minimatch-browser@1.0.0 pdfjs-dist@3.3.122
npm install -D @types/node@16
# Opcional: @alfresco/adf-content-services@6.9.1
```

- `date-fns` y `@angular/material-date-fns-adapter` no están en los `peerDependencies` de ADF 6.9.1,
  pero el código los importa. Sin ellos falla con `Can't resolve 'date-fns'`.
- `@types/node@16`: `webpack-dev-server` arrastra el `@types/node` más reciente, cuya sintaxis no
  entiende TypeScript 4.7 (`error TS1139` en `ffi.d.ts`).

En `tsconfig.json` → `compilerOptions`:

```json
"skipLibCheck": true
```

Sin esto aparecen errores de tipos **dentro de `node_modules`** (`@types/node`, `pdfjs-dist`).

### Configurar

`src/app/app.module.ts`:

```ts
import { NgModule } from '@angular/core';
import { BrowserModule } from '@angular/platform-browser';
import { BrowserAnimationsModule } from '@angular/platform-browser/animations';
import { RouterModule } from '@angular/router';
import { TranslateLoader, TranslateModule } from '@ngx-translate/core';
import { AuthModule, CoreModule, TranslateLoaderService } from '@alfresco/adf-core';
import { AppComponent } from './app.component';

@NgModule({
  declarations: [AppComponent],
  imports: [
    BrowserModule,
    BrowserAnimationsModule,
    RouterModule.forRoot([]),
    TranslateModule.forRoot({ loader: { provide: TranslateLoader, useClass: TranslateLoaderService } }),
    CoreModule.forRoot(),
    AuthModule.forRoot({ useHash: true })
  ],
  bootstrap: [AppComponent]
})
export class AppModule {}
```

`src/app/app.component.html`:

```html
<adf-login></adf-login>
```

Luego: `src/app.config.json` + registrarlo en assets ([C3](#c3-appconfigjson)), assets de ADF
([C4](#c4-assets-de-adf-traducciones-e-imágenes)), proxy ([C5](#c5-proxy-de-desarrollo)), budget
([C6](#c6-budget-de-producción)) y ejecutar ([C7](#c7-ejecutar)).

---

## Angular 16 → ADF 7.0.0-alpha.7

> ADF 7.0.0-alpha.7 es una **prerelease**, pero es la versión compilada con Angular 16 y la que usa
> ACA 5.3.0.

### Requisitos

| Requisito | Versión |
|---|---|
| Node.js | **16.20.2** (probado; Angular 16 también soporta 18.10+) |
| npm | 8.19.4 |
| Angular CLI | 16.2.x (`ng new` instaló 16.2.12) |
| ADF | `7.0.0-alpha.7` (pide `@angular/*` **16.2.9 exacto** → `legacy-peer-deps`) |
| js-api | `8.0.0-alpha.7` |

### Instalar requisitos

```powershell
nvm install 16.20.2
nvm use 16.20.2
```

### Crear el proyecto

```powershell
npx @angular/cli@16 new mi-app --style=scss --routing=false      # NgModule por defecto
cd mi-app
```

### Instalar ADF

```powershell
"legacy-peer-deps=true" | Out-File -Encoding ascii .npmrc
npx ng add @angular/material@16 --skip-confirmation --defaults
npm install @alfresco/adf-core@7.0.0-alpha.7 @alfresco/adf-extensions@7.0.0-alpha.7 `
  @alfresco/js-api@8.0.0-alpha.7 @ngx-translate/core@14 @mat-datetimepicker/core@12.0.1 `
  @angular/material-date-fns-adapter@16 date-fns@2 minimatch-browser@1.0.0 pdfjs-dist@3.3.122 ts-morph@20
# Opcional: @alfresco/adf-content-services@7.0.0-alpha.7
```

En `tsconfig.json` → `compilerOptions`: `"skipLibCheck": true`. Sin esto aparecen errores como
`TS7016: Could not find a declaration file for module 'event-emitter'` o `TS2411` en
`@alfresco/adf-extensions`.

### Configurar

El `app.module.ts` es **idéntico al de Angular 14** (`CoreModule.forRoot()` + `AuthModule.forRoot()` +
`TranslateModule` con `TranslateLoaderService`). Luego los pasos C3 a C7, con `app.config.json` en `src/`.

---

## Angular 18 → ADF 7.0.1

> No existe ADF compilado con Angular 18. Se usa **ADF 7.0.1**, compilado con Angular 17, cuyos
> `peerDependencies` aceptan `@angular/* >= 16`. Funciona, pero no es una combinación oficial.

### Requisitos

| Requisito | Versión |
|---|---|
| Node.js | Oficial: `^18.19.1 \|\| ^20.11.1 \|\| >=22`. Probado con **24.19.0** |
| npm | 11.x (con Node 24) |
| Angular CLI | 18.2.x (`ng new` instaló 18.2.14) |
| ADF | `7.0.1` |
| js-api | `8.0.1` |

### Instalar requisitos

```powershell
nvm install 24          # o 20 / 22
nvm use 24
```

### Crear el proyecto

```powershell
npx @angular/cli@18 new mi-app --style=scss --routing=false --standalone=false --ssr=false
cd mi-app
```

`--standalone=false` genera `app.module.ts` como en 14/16. Con un proyecto **standalone** existente,
ver [variante standalone para ADF 6/7](#variante-standalone-para-adf-67).

### Instalar ADF

```powershell
"legacy-peer-deps=true" | Out-File -Encoding ascii .npmrc
npx ng add @angular/material@18 --skip-confirmation --defaults
npm install @alfresco/adf-core@7.0.1 @alfresco/adf-extensions@7.0.1 @alfresco/js-api@8.0.1 `
  @ngx-translate/core@15 @mat-datetimepicker/core@14 @angular/material-date-fns-adapter@18 `
  date-fns@2 minimatch@10 pdfjs-dist@3.3.122 ts-morph@20
# Opcional: @alfresco/adf-content-services@7.0.1
```

`skipLibCheck` ya viene en `true` en Angular 18.

### Configurar

`app.module.ts` igual que en Angular 14. En la prueba funcionó incluso sin `TranslateLoaderService`,
pero se recomienda dejarlo. `app.config.json` va en **`public/`**. Luego C4 a C7.

> Sin `AuthModule.forRoot({ useHash: true })` falla con
> `NullInjectorError: No provider for _RedirectAuthService!`.

### Variante standalone para ADF 6/7

En un proyecto standalone (`app.config.ts`), los módulos se registran con `importProvidersFrom`:

```ts
import { ApplicationConfig, importProvidersFrom } from '@angular/core';
import { provideAnimations } from '@angular/platform-browser/animations';
import { provideRouter } from '@angular/router';
import { TranslateLoader, TranslateModule } from '@ngx-translate/core';
import { AuthModule, CoreModule, TranslateLoaderService } from '@alfresco/adf-core';

export const appConfig: ApplicationConfig = {
  providers: [
    provideRouter([]),
    provideAnimations(),
    importProvidersFrom(
      TranslateModule.forRoot({ loader: { provide: TranslateLoader, useClass: TranslateLoaderService } }),
      CoreModule.forRoot(),
      AuthModule.forRoot({ useHash: true })
    )
  ]
};
```

Y en el componente: `imports: [CoreModule]` (en ADF 6/7 `<adf-login>` viene en `CoreModule`). Es el
mismo patrón que usa el template Nx con ADF 8. Esta variante **no se probó** con ADF 7.

---

## Angular 20 → ADF 9.0.0

> **Combinación oficial actual:** ADF 9.0.0 está compilado con Angular 20.3 y es la que usa ACA 8.0.0.

### Requisitos

| Requisito | Versión |
|---|---|
| Node.js | `^20.19 \|\| ^22.12 \|\| >=24`. Probado con **24.19.0** |
| npm | 11.x |
| Angular CLI | 20.3.x (`ng new` instaló 20.3.33) |
| ADF | `9.0.0` (peers `@angular/* >= 20.3.25`) |
| js-api | `10.0.0` |

### Instalar requisitos

```powershell
nvm install 24
nvm use 24
```

### Crear el proyecto

```powershell
npx @angular/cli@20 new mi-app --style=scss --routing=false --standalone=false --ssr=false
cd mi-app
```

En Angular 20 los archivos se llaman `app-module.ts`, `app.ts` y `app.html` (sin `.component`).

### Instalar ADF

```powershell
"legacy-peer-deps=true" | Out-File -Encoding ascii .npmrc
npx ng add @angular/material@20 --skip-confirmation --defaults
npm install @alfresco/adf-core@9.0.0 @alfresco/adf-extensions@9.0.0 @alfresco/js-api@10.0.0 `
  @ngx-translate/core@17 @mat-datetimepicker/core@16 @angular/material-date-fns-adapter@20 `
  @angular/animations@20 date-fns@2 angular-oauth2-oidc@19 minimatch@10 pdfjs-dist cropperjs
# Para documentos, visor, upload, búsqueda:
npm install @alfresco/adf-content-services@9.0.0
```

### Configurar (NgModule)

`src/app/app-module.ts`:

```ts
import { NgModule, provideZoneChangeDetection } from '@angular/core';
import { BrowserModule } from '@angular/platform-browser';
import { provideAnimations } from '@angular/platform-browser/animations';
import { provideRouter } from '@angular/router';
import { LoginComponent, provideAppConfig, provideCoreAuth, provideI18N } from '@alfresco/adf-core';
import { App } from './app';

@NgModule({
  declarations: [App],
  imports: [BrowserModule, LoginComponent],     // ADF 9: componentes standalone, se importan uno a uno
  providers: [
    provideZoneChangeDetection({ eventCoalescing: true }),
    provideAnimations(),
    provideRouter([]),
    provideAppConfig(),
    provideI18N(),
    provideCoreAuth()
  ],
  bootstrap: [App]
})
export class AppModule {}
```

`src/app/app.html`: `<adf-login></adf-login>`. Luego `public/app.config.json` y los pasos C4 a C7.

Para usar `adf-content-services` (document list, visor), agregar
`importProvidersFrom(ContentModule.forRoot())` a los providers. Ver el
[tutorial de la mini app](07-tutorial-mini-app.md), comprobado con Angular 20.

### Configurar (standalone)

`src/app/app.config.ts`:

```ts
import { ApplicationConfig, provideZoneChangeDetection } from '@angular/core';
import { provideRouter } from '@angular/router';
import { provideAnimations } from '@angular/platform-browser/animations';
import { provideAppConfig, provideCoreAuth, provideI18N } from '@alfresco/adf-core';
import { routes } from './app.routes';

export const appConfig: ApplicationConfig = {
  providers: [
    provideZoneChangeDetection({ eventCoalescing: true }),
    provideRouter(routes),
    provideAnimations(),
    provideAppConfig(),
    provideI18N(),
    provideCoreAuth()
  ]
};
```

Componente: `imports: [LoginComponent]`, `template: '<adf-login></adf-login>'`.

---

## Angular 22 (última) → ADF 9.0.0

> No existe ADF compilado con Angular 21 ni 22. Se usa **ADF 9.0.0** (compilado con Angular 20). En la
> prueba con Angular 22.2 funcionó sin errores. ACA `master` usa Angular 21 con ADF 9.2 (prerelease).

### Requisitos

| Requisito | Versión |
|---|---|
| Node.js | `^22.22.3 \|\| ^24.15.0 \|\| >=26`. Probado con **24.19.0** |
| npm | 11.x |
| Angular CLI | `latest` = 22.2.x |
| ADF | `9.0.0` |
| zone.js | Obligatorio agregarlo: Angular 21+ crea proyectos **zoneless** |

### Instalar requisitos

```powershell
nvm install 24
nvm use 24              # debe ser >= 24.15
```

### Crear el proyecto

```powershell
npx @angular/cli@latest new mi-app --style=scss --routing=false --ssr=false --ai-config=none
cd mi-app
```

`--ai-config=none` evita la pregunta sobre archivos de configuración para asistentes de IA. Angular 22
crea el proyecto standalone (`app.config.ts`) y **sin zone.js**.

### Instalar ADF

```powershell
"legacy-peer-deps=true" | Out-File -Encoding ascii .npmrc
npx ng add @angular/material@22 --skip-confirmation --defaults
npm install @alfresco/adf-core@9.0.0 @alfresco/adf-extensions@9.0.0 @alfresco/js-api@10.0.0 `
  @angular/material-date-fns-adapter@22 @angular/animations@22 @ngx-translate/core@17 `
  @mat-datetimepicker/core@12 date-fns@2 angular-oauth2-oidc@19 minimatch@10 pdfjs-dist cropperjs zone.js
```

En la prueba, `@mat-datetimepicker/core@12` funcionó gracias a `legacy-peer-deps`. Para fechas, la
16 (peer `^20`) es la más cercana.

### Configurar

1. `angular.json` → `architect.build.options.polyfills: ["zone.js"]`.
2. `src/app/app.config.ts`: igual que en la [variante standalone de Angular 20](#configurar-standalone),
   con `provideZoneChangeDetection()`.
3. `src/app/app.ts`:

   ```ts
   import { Component } from '@angular/core';
   import { LoginComponent } from '@alfresco/adf-core';

   @Component({
     selector: 'app-root',
     imports: [LoginComponent],
     template: `<adf-login successRoute="/"></adf-login>`
   })
   export class App {}
   ```

4. `public/app.config.json`, y los pasos C4 a C7.
5. Si `ng add` no agregó las fuentes, ponerlas en `src/index.html`:

   ```html
   <link href="https://fonts.googleapis.com/css2?family=Roboto:wght@300;400;500&display=swap" rel="stylesheet">
   <link href="https://fonts.googleapis.com/icon?family=Material+Icons" rel="stylesheet">
   ```

Tema mínimo en `src/styles.scss` (usado en la prueba):

```scss
@use '@angular/material' as mat;
html { @include mat.theme((color: mat.$azure-palette, typography: Roboto, density: 0)); }
```

---

## Otras versiones (15, 17, 19, 21)

No se probaron. Valores deducidos de los paquetes:

| Angular | ADF | js-api | Configuración | Node |
|---|---|---|---|---|
| 15 | 7.0.0-alpha.2 | 8.0.0-alpha.2 | Como 14/16 | 16 o 18 |
| 17 | 7.0.1 | 8.0.1 | Como 18 | 18.13+ o 20 |
| 19 | 8.5.0 (o 8.0.x) | 9.5.x | `importProvidersFrom(AuthModule.forRoot({ useHash: true }), CoreModule.forRoot(), ContentModule.forRoot())`, el patrón del [template Nx](04-generadores-nx.md#estructura-generada) (ADF 8.0, comprobado) | 18.19 / 20.11 / 22+ |
| 21 | 9.0.0 | 10.0.0 | Como 22 (zoneless → agregar zone.js) | 20.19 / 22.12 / 24 |

## Proyecto existente: cómo saber qué instalar

```powershell
npx ng version                       # versión de Angular, CLI y Node
npm ls @angular/core @angular/material
type tsconfig.json                   # ¿skipLibCheck?
type angular.json                    # ¿polyfills: zone.js? ¿carpeta public/?
```

1. Buscar la fila de su versión de Angular en la [matriz](02-matriz-de-versiones.md#1-qué-se-puede-usar-con-cada-versión-de-angular).
2. Si el proyecto ya tiene `@angular/material`, **no** ejecutar `ng add`: comprobar que la versión
   mayor coincide con Angular.
3. Si ya tiene `@ngx-translate/core` en otra versión mayor, ADF puede chocar. Alinear con la tabla.
4. Seguir la sección de su versión desde "Instalar ADF".

## Referencias

- Componentes ADF (docs por versión): <https://github.com/Alfresco/alfresco-ng2-components/tree/develop/docs>
- Guías de actualización de ADF: <https://github.com/Alfresco/alfresco-ng2-components/tree/develop/docs/upgrade-guide>
- Angular, versiones y soporte: <https://angular.dev/reference/versions>
- Angular, zoneless: <https://angular.dev/guide/zoneless>
- Script de verificación: [`scripts/probar-angular-adf.sh`](../scripts/probar-angular-adf.sh)
