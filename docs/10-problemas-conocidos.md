# 10 · Problemas conocidos y soluciones

[⬅ Conceptos clave](09-conceptos-clave.md) · [Índice](../README.md) · [Siguiente: Referencias ➡](11-referencias.md)

Todos estos errores aparecieron en las pruebas de este repositorio, salvo los marcados como "(doc.)",
que vienen de la documentación oficial.

## Instalación de herramientas

| Síntoma | Causa | Solución |
|---|---|---|
| `gyp ERR! find VS ... You need to install the latest version of Visual Studio` | Generador Yeoman: `deasync` se compila y no hay Build Tools (o es VS 2026) | Build Tools **2022** + C++ y `npm config set msvs_version 2022` ([03](03-yeoman.md)) |
| `ModuleNotFoundError: No module named 'distutils'` | Python ≥ 3.12 con node-gyp 9 (Node 16) | `python -m pip install setuptools` |
| `Could not locate the bindings file` (deasync) | `deasync` sin compilar | Corregir lo anterior y reinstalar el generador, o usar la [alternativa con `npm pack`](03-yeoman.md#alternativa-sin-visual-studio-ni-yo-comprobada) |
| `yo` / `ng` / `nx`: *command not found* tras `nvm use` | Los globales son por versión de Node | Reinstalar el global con ese Node, o usar `npx` |
| `npm install` en ACA `master` aborta con `only-allow pnpm` | `preinstall` exige pnpm | `corepack enable` y `pnpm install` |
| `pnpm lint` falla en PowerShell | Sintaxis POSIX `NODE_OPTIONS=... nx` | Ejecutarlo desde Git Bash |
| Cambió el Node de todo el sistema | nvm-windows usa un enlace global | `nvm use <versión>` antes de cada práctica |

## Instalación de dependencias

| Síntoma | Causa | Solución |
|---|---|---|
| `npm ERR! ERESOLVE could not resolve` | Peers de ADF desalineados (`@mat-datetimepicker/core`, `@angular/*` exactos en ADF 7 alpha) | `legacy-peer-deps=true` en `.npmrc` |
| `npm warn ERESOLVE overriding peer dependency` (template Nx) | Igual | Aviso, no bloquea |
| Muchas vulnerabilidades en `npm audit` (Yeoman, ACA 4/5) | Dependencias de 2022–2023 | Normal en proyectos antiguos; no ejecutar `npm audit fix --force` (rompe versiones) |
| `npm warn allow-scripts ... lmdb / msgpackr-extract` (npm 11) | npm 11 pide aprobar scripts de instalación | Aviso; `npm approve-scripts` si hace falta |

## Build

| Síntoma | Causa | Solución |
|---|---|---|
| `Can't resolve 'date-fns'` / `'@angular/material-date-fns-adapter'` (ADF 6.9.1) | ADF 6.9 los importa pero no los declara | `npm i date-fns@2 @angular/material-date-fns-adapter@14` |
| `error TS1139 ... node_modules/@types/node/ffi.d.ts` (Angular 14) | `@types/node` reciente con TypeScript 4.7 | `npm i -D @types/node@16` |
| Errores TS dentro de `node_modules` (`pdfjs-dist`, `event-emitter`, `adf-extensions`) | Proyecto Angular 14/16 sin `skipLibCheck` | `"skipLibCheck": true` en `tsconfig.json` |
| `bundle initial exceeded maximum budget` | ADF pesa más de 1 MB | Subir los budgets en `angular.json` ([06 · C6](06-adf-manual.md#c6-budget-de-producción)) |
| `Module not found: Can't resolve 'path'` en `minimatch` | webpack 5 no incluye polyfills de Node | Aviso, no bloquea |
| `Module 'cropperjs' ... is not ESM` / `'eventemitter3' ... is not ESM` | Dependencias CommonJS | Aviso; se puede silenciar con `allowedCommonJsDependencies` |
| `npm i -D @angular-devkit/build-angular` rompe el template Nx | Instala la última versión, distinta del Angular de la plantilla | No ejecutarlo: el template ya lo trae |
| `nx generate /adf-generators:...` no existe (doc.) | En el blog y en docs.hyland.com se perdió `@alfresco` al publicar | `nx generate @alfresco/adf-generators:...` |

## Ejecución

| Síntoma | Causa | Solución |
|---|---|---|
| Página en blanco + **"app.config.json contains validation errors"** | `app.config.json` no está en la raíz servida: el servidor devuelve `index.html` | Angular 14–17: `src/app.config.json` + registrarlo en `assets`. Angular 18+: `public/` |
| `NullInjectorError: No provider for RedirectAuthService` | ADF 6/7 sin `AuthModule.forRoot()` | Importar `AuthModule.forRoot({ useHash: true })` |
| Texto `visibility` en vez del ícono del ojo | Falta la fuente Material Icons | `ng add @angular/material` o el `<link>` en `index.html` |
| Login falla, el proxy responde **504** | ACS no está en `BASE_URL` / `target` | Levantar ACS ([01 · 5](01-preparar-entorno.md#5-backend-acs-con-docker)) y comprobar el endpoint `-ready-` |
| `error loading discovery document` / `OAuthErrorEvent` en ACA | ACA intenta leer la config OIDC de un Identity Service que no existe | Normal con `authType: BASIC`; con OAuth, revisar `oauth2.host` |
| Angular 21+: ADF no refresca la vista | Proyecto zoneless | `zone.js` en `polyfills` + `provideZoneChangeDetection()` |
| CORS en producción | No hay proxy de Angular | Mismo dominio con un reverse proxy, o CORS en ACS (ver `docs/getting-started/cors.md` de ACA) |

## Particularidades del generador Yeoman

- El `package.json` generado conserva `"name": "adf-cli-acs-template"`.
- El archivo `LICENSE` se crea en la carpeta **padre**.
- El subgenerador de licencia pregunta nombre, email y web incluso en modo no interactivo.
