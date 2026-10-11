# 05 · Alfresco Content App (ACA)

[⬅ Generadores Nx](04-generadores-nx.md) · [Índice](../README.md) · [Siguiente: ADF a mano ➡](06-adf-manual.md)

ACA es la **aplicación de referencia** de Alfresco, hecha con ADF: un gestor documental completo
(navegar, subir, ver, buscar, compartir, favoritos, papelera...). En la práctica se usa como
"template" oficial y se **extiende** con plugins en lugar de modificar su código.

- **A favor:** login, navegador de documentos, visor y búsqueda ya resueltos. Sistema de extensiones
  por JSON.
- **En contra:** es un monorepo grande con Nx (`app/`, `projects/aca-content`, `projects/aca-shared`...).
- Repositorio: <https://github.com/Alfresco/alfresco-content-app> · Documentación:
  <https://alfresco-content-app.netlify.app/>

## ACA según la versión de Angular

| Angular | Tag ACA | ADF | Node (`.nvmrc`) | Gestor | ACS | Estado |
|---|---|---|---|---|---|---|
| **14** | **4.4.1** (también 4.0 – 4.4) | 6.7.1 | 18 | npm | 23.2 | ✅ probado |
| 15 | 5.0.1 / 5.1.1 | 7.0.0-alpha.2 / .3 | 18 | npm | 23.3 | no probado |
| **16** | **5.3.0** (también 5.2.0) | 7.0.0-alpha.7 | 18 | npm | 23.4 | ✅ probado |
| 17 | 6.0.0 | 7.0.0 | 20.18.1 | npm | 25.1 | no probado |
| **18** | ❌ **no existe** | — | — | — | — | Saltar de 6.0.0 (Ng 17) a 7.0.1 (Ng 19) |
| 19 | 7.0.1 – 7.5.0 | 8.0.1 – 8.5.0 | 22.14 / 24.13.0 | npm | 25.2 / 26.x | no probado |
| **20** | **8.0.0** | 9.0.0 | 24.13.1 | npm | 26.x | ✅ probado |
| 21 | `master` (oct. 2026) | 9.2.0 (prerelease) | 24.13.1 | **pnpm 11** | 26.x | ✅ probado (`adf-test`) |
| **22** (última) | ❌ **no existe** (`master` va por la 21) | — | — | — | — | Usar [ADF a mano](06-adf-manual.md#angular-22-última--adf-900) |

"Probado" significa que se ejecutó `npm install`, `nx build content-ce` y `nx serve`, y que la
pantalla de login se abrió en Chrome.

## Pasos comunes

En todas las versiones el procedimiento es el mismo; cambian el Node y el tag:

```powershell
nvm use <node>
git clone --depth 1 --branch <tag> https://github.com/Alfresco/alfresco-content-app.git mi-aca
cd mi-aca
Set-Content .env 'BASE_URL="http://localhost:8080"' -Encoding utf8     # URL de ACS
npm install
npm start                      # = nx serve content-ce → http://localhost:4200
```

- **`.env` → `BASE_URL`** es la única variable necesaria en desarrollo. `app/proxy.conf.js` la lee y
  reenvía `/alfresco` a esa URL.
- `app/src/app.config.json` trae `ecmHost: "{protocol}//{hostname}{:port}"`: la app llama a su propio
  origen y el proxy hace el resto. Viene con `"authType": "BASIC"` y `"providers": "ECM"`.
- Build de producción: `npx nx build content-ce` → `dist/content-ce`.
- En la consola del navegador aparece **`error loading discovery document`**. Es normal: ACA intenta
  leer la configuración OAuth de un Identity Service (Keycloak) que no existe. Con `BASIC` no afecta.
- Si ACS no está levantado, el login responde **504**.

---

## Angular 14 → ACA 4.4.1

> **Comprobado:** `npm install` 1 min 30 s, `nx build content-ce` 1 min, login abierto con Angular 14.1.3.

### Requisitos

| Requisito | Versión |
|---|---|
| Node.js | **18.20.8** (`.nvmrc` = 18) |
| npm | 10.8.2 |
| Git | cualquiera |
| ACS | 23.2 (compatible con el docker-compose actual para pruebas) |

### Instalar requisitos

```powershell
nvm install 18.20.8
nvm use 18.20.8
```

### Pasos

```powershell
git clone --depth 1 --branch 4.4.1 https://github.com/Alfresco/alfresco-content-app.git aca-ng14
cd aca-ng14
Set-Content .env 'BASE_URL="http://localhost:8080"' -Encoding utf8
npm install
npm start
```

---

## Angular 16 → ACA 5.3.0

> **Comprobado:** `npm install` 1 min, `nx build content-ce` 1 min, login abierto con Angular 16.2.9.

### Requisitos

| Requisito | Versión |
|---|---|
| Node.js | **18.20.8** (`.nvmrc` = 18) |
| npm | 10.8.2 |
| ACS | 23.4 |

### Instalar requisitos

```powershell
nvm install 18.20.8
nvm use 18.20.8
```

### Pasos

```powershell
git clone --depth 1 --branch 5.3.0 https://github.com/Alfresco/alfresco-content-app.git aca-ng16
cd aca-ng16
Set-Content .env 'BASE_URL="http://localhost:8080"' -Encoding utf8
npm install
npm start
```

---

## Angular 18 → no hay ACA

ACA pasó de **6.0.0 (Angular 17)** a **7.0.x (Angular 19)** sin ninguna versión con Angular 18.
Opciones:

- **Angular 17:** ACA 6.0.0 con Node 20.18.1 (no probado):

  ```powershell
  nvm install 20.18.1 ; nvm use 20.18.1
  git clone --depth 1 --branch 6.0.0 https://github.com/Alfresco/alfresco-content-app.git aca-ng17
  cd aca-ng17 ; Set-Content .env 'BASE_URL="http://localhost:8080"' -Encoding utf8
  npm install ; npm start
  ```

- **Angular 19:** ACA 7.5.0 con Node 24.13 (no probado). Mismos pasos con `--branch 7.5.0`.
- **Angular 18 sí o sí:** [ADF a mano con Angular 18](06-adf-manual.md#angular-18--adf-701).

---

## Angular 20 → ACA 8.0.0

> **Comprobado:** `npm install` 40 s, `nx build content-ce` 40 s, login abierto con Angular 20.3.25
> ("Sign in - Workspace"). **Versión estable recomendada para onboarding.**

### Requisitos

| Requisito | Versión |
|---|---|
| Node.js | **24.13.1+** (`.nvmrc`); probado con 24.19.0 |
| npm | 11.x |
| ACS | 26.x (el docker-compose Community actual) |

### Instalar requisitos

```powershell
nvm install 24
nvm use 24
```

### Pasos

```powershell
git clone --depth 1 --branch 8.0.0 https://github.com/Alfresco/alfresco-content-app.git aca-ng20
cd aca-ng20
Set-Content .env 'BASE_URL="http://localhost:8080"' -Encoding utf8
npm install
npm start
```

---

## Angular 21 → ACA `master` (lo más reciente)

> **Comprobado** (proyecto `adf-test`, commit `ad0ba10`, 2026-10-10): `pnpm install` 15 s (con caché),
> "Compiled successfully".

### Requisitos

| Requisito | Versión |
|---|---|
| Node.js | **≥ 24.13.1** (`engines`) |
| Gestor | **pnpm 11.17.0** (`packageManager`). `preinstall: npx only-allow pnpm` **bloquea npm** |

### Pasos

```powershell
nvm use 24
corepack enable                  # activa pnpm según packageManager
git clone --depth 1 https://github.com/Alfresco/alfresco-content-app.git aca-master
cd aca-master
Set-Content .env 'BASE_URL="http://localhost:8080"' -Encoding utf8
pnpm install
pnpm start
```

`pnpm lint` usa sintaxis POSIX (`NODE_OPTIONS=... nx`) y falla en PowerShell: ejecutarlo desde Git Bash.

## Angular 22 (última) → no hay ACA

`master` usa Angular 21 (oct. 2026). Para Angular 22, ver
[ADF a mano](06-adf-manual.md#angular-22-última--adf-900).

---

## La guía oficial de Hyland está desactualizada

[docs.hyland.com — Deploy Alfresco Content App (ADW 8.0)](https://docs.hyland.com/r/Alfresco/Alfresco-Digital-Workspace/8.0/Alfresco-Digital-Workspace/Develop/Deploy-front-end-applications/Deploy-Alfresco-Content-App):

| | Guía | Realidad |
|---|---|---|
| Node | 18.x | 18 sirve para ACA 4.x/5.x; ACA 8.0 pide 24.13.1 |
| Gestor | npm | npm hasta 8.0.0; **pnpm** en `master` |
| `.env` | `APP_CONFIG_ECM_HOST`, `APP_CONFIG_PLUGIN_AOS`, `APP_CONFIG_PLUGIN_CONTENT_SERVICE` | Solo **`BASE_URL`** en todas las versiones probadas (4.4.1, 5.3.0, 8.0.0, master) |

---

## Estructura de ACA

```
alfresco-content-app/
├── .env                         # BASE_URL (no versionado)
├── app/                         # la aplicación "content-ce"
│   ├── proxy.conf.js            # /alfresco → BASE_URL
│   ├── project.json             # targets nx: serve, build, test, lint
│   └── src/
│       ├── app.config.json      # configuración ADF (ecmHost, authType, providers, plugins...)
│       ├── assets/plugins/      # JSON de extensiones adicionales
│       └── app/
│           ├── app.config.ts    # providers de la app
│           ├── app.routes.ts
│           └── extensions.module.ts     # registro de librerías de extensión
├── projects/
│   ├── aca-content/             # funcionalidades principales (librería)
│   │   └── assets/app.extensions.json   # menús, rutas, acciones y reglas por defecto
│   ├── aca-shared/              # utilidades compartidas
│   └── aca-playwright-shared/   # tests e2e
└── docs/                        # documentación (extending, tutorials, getting-started)
```

## Crear una extensión de ACA con Nx

Con `@alfresco/aca-generators`, desde la raíz de un ACA ya instalado (no probado en este repositorio;
pasos del README del generador y del blog de Hyland):

```powershell
# ACA 8.0.0 (npm)
npx nx add @alfresco/aca-generators
npx nx g @alfresco/aca-generators:aca-extension
#   ? What name would you like to use?                         → ext
#   ? What should be the directory name for the new library?   → ext
npm install
npm start

# ACA master (pnpm)
pnpm nx add @alfresco/aca-generators
pnpm nx g @alfresco/aca-generators:aca-extension
pnpm install ; pnpm start
```

Crea `projects/ext/` (componente, módulo, `assets/ext.json`, i18n) y actualiza
`app/src/app/extensions.module.ts`, `app/project.json` y `tsconfig.json`. Al iniciar sesión aparece un
nuevo ítem en el menú lateral que lleva a `http://localhost:4200/#/ext`.

### Aprender a extender ACA (documentación del repositorio, carpeta `docs/`)

| Tema | Archivo |
|---|---|
| Primera extensión | `docs/tutorials/how-to-create-your-first-extension.md` |
| Instalar una extensión existente | `docs/tutorials/how-to-install-an-existing-extension.md` |
| Formato del JSON de extensiones | `docs/extending/extension-format.md` |
| Rutas, acciones, componentes, reglas | `docs/extending/routes.md`, `actions.md`, `components.md`, `rules.md` |
| Visor personalizado | `docs/tutorials/custom-viewer.md` |
| Listas de archivos y preview | `docs/tutorials/file-lists.md`, `file-preview.md` |
| Formulario de búsqueda | `docs/tutorials/search-form.md` |
| CORS, Docker, SSO, Windows, nvm | `docs/getting-started/*.md` |
| Usar un ADF local (desarrollo de ADF) | `docs/getting-started/using-local-adf.md` |

Versión web: <https://alfresco-content-app.netlify.app/>

## Referencias

- Repositorio: <https://github.com/Alfresco/alfresco-content-app> (tags = versiones)
- Documentación: <https://alfresco-content-app.netlify.app/>
- Generador de extensiones: <https://github.com/Alfresco/alfresco-front-end-generators>
- Blog Hyland, sección "Extending ACA": <https://connect.hyland.com/t5/alfresco-blog/modernizing-your-alfresco-front-end-development-with-nx/ba-p/493363>
- docs.hyland.com:
  - [Deploy Alfresco Content App](https://docs.hyland.com/r/Alfresco/Alfresco-Digital-Workspace/8.0/Alfresco-Digital-Workspace/Develop/Deploy-front-end-applications/Deploy-Alfresco-Content-App) (desactualizada)
  - [Installing the ACA Generators Plugin](https://docs.hyland.com/r/Alfresco/Alfresco-Digital-Workspace/8.0/Alfresco-Digital-Workspace/Develop/Deploy-front-end-applications/Generate-and-Deploy-an-ADF-App/Installing-the-ACA-Generators-Plugin)
- Script de verificación: [`scripts/probar-aca.sh`](../scripts/probar-aca.sh)
