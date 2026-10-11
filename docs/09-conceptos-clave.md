# 09 · Conceptos clave de ADF

[⬅ ADW](08-adw.md) · [Índice](../README.md) · [Siguiente: Problemas conocidos ➡](10-problemas-conocidos.md)

## 1. `app.config.json`

ADF lo descarga al arrancar desde la raíz de la app (`/app.config.json`). Es la configuración **en
tiempo de ejecución**: se puede cambiar en el servidor sin recompilar.

```json
{
  "$schema": "../node_modules/@alfresco/adf-core/app.config.schema.json",
  "ecmHost": "{protocol}//{hostname}{:port}",
  "bpmHost": "{protocol}//{hostname}{:port}",
  "providers": "ECM",
  "authType": "BASIC",
  "loginRoute": "login",
  "identityHost": "{protocol}//{hostname}{:port}/auth/realms/alfresco",
  "oauth2": {
    "host": "{protocol}//{hostname}{:port}/auth/realms/alfresco",
    "clientId": "alfresco",
    "scope": "openid",
    "implicitFlow": false,
    "codeFlow": true,
    "silentLogin": true,
    "redirectUri": "/",
    "redirectUriLogout": "/logout"
  },
  "application": { "name": "Mi App" },
  "languages": [ { "key": "en", "label": "English" }, { "key": "es", "label": "Español" } ]
}
```

| Clave | Para qué |
|---|---|
| `ecmHost` | Origen de ACS. ADF llama a `{ecmHost}/alfresco/api/...`. Los marcadores `{protocol}//{hostname}{:port}` toman el origen de la app, lo que permite usar el proxy |
| `bpmHost` | Origen de APS (`/activiti-app`) |
| `providers` | `ECM` (solo ACS), `BPM` (solo APS) o `ALL` |
| `authType` | `BASIC` (usuario y contraseña contra ACS/APS) u `OAUTH` (Keycloak / Identity Service) |
| `oauth2` | Configuración OAuth2/OIDC cuando `authType = OAUTH` |
| `loginRoute` | Ruta a la que redirigen los guards sin sesión |
| `$schema` | Autocompletado y validación en VS Code |

El mensaje **"app.config.json contains validation errors"** aparece cuando el archivo no cumple el
esquema. También aparece cuando **no se encuentra** y el servidor devuelve `index.html` (ver
[problemas conocidos](10-problemas-conocidos.md)).

## 2. Proxy de desarrollo

El navegador no deja que `localhost:4200` llame a `localhost:8080` sin CORS. En desarrollo, el
servidor de Angular hace de intermediario:

```js
// proxy.conf.js (forma de Yeoman, Nx y ACA)
module.exports = {
  '/alfresco': {
    target: 'http://localhost:8080',
    secure: false,
    changeOrigin: true
  }
};
```

- Angular CLI: `angular.json` → `serve.options.proxyConfig`.
- ACA: lee `BASE_URL` desde `.env`.
- Nx template: variables `ecmHost` / `bpmHost` dentro de `proxy.conf.js`.
- **Producción:** no hay proxy de Angular. Servir la app y ACS bajo el mismo dominio (Nginx, Traefik,
  Apache) o habilitar CORS en ACS.

## 3. Autenticación

| `authType` | Cómo funciona | Cuándo |
|---|---|---|
| `BASIC` | `<adf-login>` envía usuario y contraseña a ACS, que devuelve un *ticket* (`TICKET_...`) guardado en el navegador | Desarrollo, ACS Community sin SSO |
| `OAUTH` | Redirección a Keycloak / Identity Service (OIDC); ADF gestiona los tokens con `angular-oauth2-oidc` | SSO, Enterprise, APA |

Guards disponibles en `@alfresco/adf-core`:

| Guard | Protege |
|---|---|
| `AuthGuardEcm` | Rutas que necesitan sesión en ACS |
| `AuthGuardBpm` | Rutas que necesitan sesión en APS |
| `AuthGuard` | Cualquier sesión válida |
| `AuthGuardSsoRoleService` | Rutas restringidas por rol (OAuth) |

Configuración según la versión de ADF:

| ADF | Cómo se registra |
|---|---|
| 6.x / 7.x | `CoreModule.forRoot()` + `AuthModule.forRoot({ useHash: true })` |
| 8.x | `importProvidersFrom(AuthModule.forRoot({ useHash: true }), CoreModule.forRoot())` |
| 9.x | `provideAppConfig()` + `provideI18N()` + `provideCoreAuth()` |

Más detalle: receta [Authentication](https://github.com/Alfresco/alfresco-front-end-generators/blob/main/docs/recipes/authentication.md).

## 4. Traducciones (i18n)

ADF usa `@ngx-translate/core`. Cada librería trae sus JSON en `bundles/assets/<lib>/i18n/*.json`, que
se copian a `/assets` con la configuración de `angular.json`.

Traducciones propias:

```ts
// ADF 9
provideTranslations('app', 'assets/app')        // carga assets/app/i18n/<lang>.json
```

```ts
// ADF 6/7 (Yeoman)
{ provide: TRANSLATION_PROVIDER, multi: true, useValue: { name: 'app', source: 'resources' } }
```

En plantillas: `{{ 'APP.TITLE' | translate }}`. Más: receta
[Internationalization](https://github.com/Alfresco/alfresco-front-end-generators/blob/main/docs/recipes/internationalization.md).

## 5. Tema (theming)

ADF se apoya en **Angular Material**. Cada versión de ADF sigue la API de temas de su Material:

- ADF 6/7 (Material 14–17): `mat.define-light-theme(...)` + `@import '@alfresco/adf-core/theming'`
  (ver `src/custom-style.scss` del template Yeoman).
- ADF 9 (Material 20+): `@use '@angular/material' as mat;` con la API nueva de Material
  (`mat.theme(...)`, `mat.*-overrides(...)`). ADF publica sus mixins en
  `@alfresco/adf-core/lib/theming/_index.scss`. Como referencia, ver el tema de ACA 8 en
  `projects/aca-content/src/lib/ui/` (`application.scss`, `theme.scss`, `custom-theme.scss`).

Más: receta [Theming](https://github.com/Alfresco/alfresco-front-end-generators/blob/main/docs/recipes/theming.md).

## 6. Componentes más usados

| Componente | Paquete | Uso |
|---|---|---|
| `<adf-login>` | core | Pantalla de login |
| `<adf-document-list>` | content-services | Lista de nodos de una carpeta |
| `<adf-breadcrumb>` | content-services | Ruta de carpetas |
| `<adf-upload-button>` / `adf-upload-drag-area` | content-services | Subir archivos |
| `<adf-alfresco-viewer>` (ADF 9) / `<adf-viewer>` | content-services / core | Visor de documentos |
| `<adf-search-control>` | content-services | Búsqueda con autocompletado |
| `<adf-content-metadata-card>` | content-services | Ver y editar propiedades |
| `<adf-datatable>` | core | Tabla genérica |
| `<adf-sidenav-layout>` | core | Layout con menú lateral |
| `<adf-toolbar>` | core | Barra de herramientas |

Documentación de cada componente:
<https://github.com/Alfresco/alfresco-ng2-components/tree/develop/docs>

## 7. `@alfresco/js-api`

Cliente de las APIs REST. ADF lo usa por dentro, y también sirve para llamadas propias (nodos,
búsqueda, personas, sitios...). Cada versión mayor de ADF exige una de js-api (ADF 9 → js-api 10). Ver
la [matriz](02-matriz-de-versiones.md#2-adf--angular-lo-que-realmente-usa-cada-paquete).

## 8. Extensiones (ACA / ADW)

`@alfresco/adf-extensions` permite declarar en **JSON** rutas, ítems de menú, acciones, columnas,
reglas de visibilidad y componentes, sin tocar el código de la app. ACA define las suyas en
`projects/aca-content/assets/app.extensions.json` y carga plugins de `app/src/assets/plugins/`.
Ver la documentación de ACA: `docs/extending/` y `docs/tutorials/`.

## 9. Standalone vs NgModule

| Época | Estilo | Cómo se usan los componentes ADF |
|---|---|---|
| Angular 14–16 / ADF 6–7 | NgModule | Importar `CoreModule`, `ContentModule` |
| Angular 17–19 / ADF 7–8 | Mixto | `importProvidersFrom(...)` en `app.config.ts` |
| Angular 20+ / ADF 9 | Standalone | Importar cada componente (`LoginComponent`, `DocumentListComponent`...) y `provide*()` |

## 10. Zone.js

ADF está pensado para trabajar con **zone.js** (detección de cambios clásica). Angular 21+ crea los
proyectos **sin zone.js** (zoneless): hay que agregarlo en `polyfills` y usar
`provideZoneChangeDetection()`.
