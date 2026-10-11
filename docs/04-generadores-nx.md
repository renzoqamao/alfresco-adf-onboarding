# 04 · Template ADF con los generadores Nx (`@alfresco/adf-generators`)

[⬅ Yeoman](03-yeoman.md) · [Índice](../README.md) · [Siguiente: ACA ➡](05-aca.md)

> **Estado: forma oficial actual** para crear una app ADF nueva. Reemplaza a Yeoman. Repositorio:
> <https://github.com/Alfresco/alfresco-front-end-generators>

## Generadores Nx según la versión de Angular

Todas las versiones publicadas de `@alfresco/adf-generators` (1.0.0 a 1.0.4, sep.–oct. 2025) generan
**ADF 8.0.0 + Angular 19.2.6 + `@alfresco/js-api` 9.0.0**. No tienen ninguna opción para elegir otra
versión de Angular.

| Angular | ¿Lo genera? | Qué hacer |
|---|---|---|
| 14 | ❌ | [Yeoman](03-yeoman.md), [ACA 4.4.1](05-aca.md#angular-14--aca-441) o [ADF a mano](06-adf-manual.md#angular-14--adf-691) |
| 16 | ❌ | [ACA 5.3.0](05-aca.md#angular-16--aca-530) o [ADF a mano](06-adf-manual.md#angular-16--adf-700-alpha7) |
| 18 | ❌ | [ADF a mano](06-adf-manual.md#angular-18--adf-701) |
| **19** | ✅ **Siempre genera Angular 19** | Esta guía. **Comprobado.** |
| 20 | ❌ (genera 19) | [ACA 8.0.0](05-aca.md#angular-20--aca-800) o [ADF a mano](06-adf-manual.md#angular-20--adf-900). También se puede generar en 19 y actualizar (ver [Actualizar a Angular 20](#actualizar-el-template-a-angular-20--adf-9-no-probado)) |
| 22 (última) | ❌ | [ADF a mano](06-adf-manual.md#angular-22-última--adf-900) |

---

## Angular 19 con generadores Nx (paso a paso)

> **Comprobado el 2026-10-10:** workspace Nx 23 creado, plugin agregado, app `template` (ACS + Basic
> auth + ECM) generada, `npm install` y `nx build template` terminados ("Successfully ran target build").

### Requisitos

| Requisito | Versión | Notas |
|---|---|---|
| Node.js | **24.x** (`.nvmrc` del repo = 24.11.1; probado con 24.19.0) | El blog de Hyland (sep. 2025) decía 22.x; Angular 19 también funciona con 22 |
| npm | **11.x** | El que trae Node 24 |
| Nx | Global opcional (`npm i -g nx`). Si no, usar `npx nx`. | El workspace se creó con Nx 23.x; el template trae su propio Nx 21 |
| Workspace Nx | Obligatorio | Los generadores Nx solo funcionan dentro de un workspace |
| ACS | 25.x / 26.x | Para iniciar sesión |

### 1. Instalar los requisitos

```powershell
nvm install 24
nvm use 24
node -v ; npm -v                 # v24.x ; 11.x
npm install -g nx                # opcional
```

### 2. Crear el workspace Nx

```powershell
npx create-nx-workspace@latest adf-workspace
#   Prompts del blog de Hyland: Workspace: empty · Stack: none · Prettier: No · CI: skip · Remote caching: skip
```

Sin preguntas (comprobado):

```powershell
npx create-nx-workspace@latest adf-workspace --preset=apps --nxCloud=skip --packageManager=npm --no-interactive
cd adf-workspace
```

### 3. Agregar el plugin y generar la app

```powershell
npx nx add @alfresco/adf-generators
npx nx g @alfresco/adf-generators:template-app
#   ? What name would you like to use?                  → template
#   ? Which template would you like to use?             → Basic ACS functionalities integrated
#   ? Which authentication type would you like to use?  → Basic auth
#   ? Which providers would you like to use?            → ECM
```

Sin preguntas (comprobado):

```powershell
npx nx g @alfresco/adf-generators:template-app --name=template --template=acs --authType=BASIC --provider=ECM --no-interactive
```

| Opción | Valores |
|---|---|
| `--template` | `empty`, `acs`, `aps`, `acs-aps`, `automate`, `apa`, `acs-apa` |
| `--authType` | `BASIC`, `OAUTH` |
| `--provider` | `ECM`, `BPM`, `ALL` |

App mínima, sin componentes:

```powershell
npx nx g @alfresco/adf-generators:empty-app      # ? What name would you like to use? → empty
```

### 4. Configurar el backend

Editar `template\proxy.conf.js`. El template sale con las URLs vacías:

```js
const ecmHost = 'http://localhost:8080';   // ACS
const bpmHost = '';                        // APS, si se eligió BPM/ALL
```

Con el template `automate`, completar además en `src/app.config.json`: `APP_CONFIG_OAUTH2_HOST`,
`APP_CONFIG_OAUTH2_CLIENTID`, `APP_CONFIG_OAUTH2_SCOPE` y `APP_CONFIG_APPS_DEPLOYED`.

### 5. Instalar y ejecutar

La app generada es un **proyecto npm propio** dentro del workspace, con su `package.json` y su
`node_modules`:

```powershell
cd template
npm install          # ~2 min; aviso "ERESOLVE overriding peer dependency" (no bloquea)
npm start            # = nx serve template → http://localhost:4200
npm run build        # = nx build template
```

### Estructura generada

```
adf-workspace/
├── nx.json, package.json          # workspace (Nx 23 + @alfresco/adf-generators)
└── template/                      # la app (Nx 21 + Angular 19 + ADF 8)
    ├── proxy.conf.js              # ecmHost / bpmHost
    ├── project.json               # targets nx: serve, build, test, lint
    ├── assets/i18n, assets/fonts
    └── src/
        ├── app.config.json        # configuración de ADF
        ├── theme.scss, colors.scss, variables.scss
        └── app/
            ├── app.config.ts      # providers (standalone)
            ├── app.routes.ts      # login, home, documents, files/:nodeId/view
            ├── app-layout/        # menú lateral (adf-sidenav-layout)
            ├── login/ home/ documents/ file-view/
            └── services/          # app.service.ts, preview.service.ts
```

`app.config.ts` (ADF 8, standalone) muestra el patrón de configuración de esta versión:

```ts
providers: [
  importProvidersFrom(AuthModule.forRoot({ useHash: true })),
  importProvidersFrom(CoreModule.forRoot()),
  importProvidersFrom(ContentModule.forRoot()),
  provideRouter(APP_ROUTES, withHashLocation()),
  provideAnimations(),
  { provide: SHELL_APP_SERVICE, useClass: AppService },
  { provide: SHELL_AUTH_TOKEN, useValue: AuthGuard },
  ...
]
```

### Diferencias con la documentación oficial

1. El blog y docs.hyland.com muestran `nx generate /adf-generators:...`. Al publicar se perdió el
   `@alfresco`. El comando correcto es `nx generate @alfresco/adf-generators:...`.
2. Indican `npm i -D @angular-devkit/build-angular` antes de `npm install`. **No hace falta**: el
   template ya trae `@angular-devkit/build-angular@19.2.15`. Sin versión instalaría la última
   (Angular 22) y rompería las dependencias.
3. El blog pide Node 22; el `.nvmrc` del repositorio pide 24.11.1. Ambos funcionan con Angular 19.

### Recetas oficiales (para seguir aprendiendo)

En `docs/recipes` del repositorio de generadores:

| Receta | Qué enseña |
|---|---|
| [Authentication](https://github.com/Alfresco/alfresco-front-end-generators/blob/main/docs/recipes/authentication.md) | Basic vs OAuth2, configuración de IdP (Keycloak, etc.), guards (`AuthGuardEcm`, `AuthGuardBpm`, `AuthGuard`) |
| [Internationalization](https://github.com/Alfresco/alfresco-front-end-generators/blob/main/docs/recipes/internationalization.md) | Varios idiomas, traducciones dinámicas, cambio de idioma en ejecución, formatos de fecha |
| [Theming](https://github.com/Alfresco/alfresco-front-end-generators/blob/main/docs/recipes/theming.md) | Modificar el tema, varios temas, variables reutilizables |
| [How to add new custom page](https://github.com/Alfresco/alfresco-front-end-generators/blob/main/docs/recipes/how-to-add-custom-page.md) | `nx g @nx/angular:component`, ruta nueva, ítem de menú, layout, document list + preview |
| [Login component](https://github.com/Alfresco/alfresco-ng2-components/blob/master/docs/core/components/login.component.md) | Personalizar el login |

### Actualizar el template a Angular 20 / ADF 9 (no probado)

No hay generador para ADF 9. El camino sería `npx nx migrate` o `npx ng update @angular/core@20
@angular/cli@20 @angular/material@20` y luego pasar a `@alfresco/adf-*@9.0.0` y `@alfresco/js-api@10`,
siguiendo la [guía de actualización de ADF](https://github.com/Alfresco/alfresco-ng2-components/tree/develop/docs/upgrade-guide).
Para un onboarding es más simple usar [ACA 8.0.0](05-aca.md#angular-20--aca-800) o
[ADF a mano con Angular 20](06-adf-manual.md#angular-20--adf-900).

## Extensiones de ACA y ADW con Nx

Los mismos generadores tienen plugins para extender ACA y ADW. Ver
[05-aca.md → Crear una extensión](05-aca.md#crear-una-extensión-de-aca-con-nx) y [08-adw.md](08-adw.md).

## Referencias

- Repositorio: <https://github.com/Alfresco/alfresco-front-end-generators>
- npm: <https://www.npmjs.com/package/@alfresco/adf-generators>
- Blog Hyland, "Modernizing Your Alfresco Front-End Development with Nx" (sep. 2025):
  <https://connect.hyland.com/t5/alfresco-blog/modernizing-your-alfresco-front-end-development-with-nx/ba-p/493363>
- docs.hyland.com, Generate and Deploy an ADF App:
  - [Prerequisites](https://docs.hyland.com/r/Alfresco/Alfresco-Digital-Workspace/8.0/Alfresco-Digital-Workspace/Develop/Deploy-front-end-applications/Generate-and-Deploy-an-ADF-App/Prerequisites)
  - [Installing the ADF Generators Plugin](https://docs.hyland.com/r/Alfresco/Alfresco-Digital-Workspace/8.0/Alfresco-Digital-Workspace/Develop/Deploy-front-end-applications/Generate-and-Deploy-an-ADF-App/Installing-the-ADF-Generators-Plugin)
  - [Generating an Angular Application Using the Template App](https://docs.hyland.com/r/Alfresco/Alfresco-Digital-Workspace/8.0/Alfresco-Digital-Workspace/Develop/Deploy-front-end-applications/Generate-and-Deploy-an-ADF-App/Installing-the-ADF-Generators-Plugin/Generating-an-Angular-Application-Using-the-Template-App)
- Nx: <https://nx.dev/getting-started/intro>
