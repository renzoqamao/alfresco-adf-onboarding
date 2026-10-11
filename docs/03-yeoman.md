# 03 · Template ADF con Yeoman (`generator-alfresco-adf-app`)

[⬅ Matriz de versiones](02-matriz-de-versiones.md) · [Índice](../README.md) · [Siguiente: Generadores Nx ➡](04-generadores-nx.md)

> **Estado: obsoleto.** La última versión es la **6.1.1** (junio 2023) y genera **ADF 6.1 + Angular
> 14**. Alfresco la reemplazó por los [generadores Nx](04-generadores-nx.md). Sirve para mantener
> proyectos antiguos o para mostrar en un onboarding cómo se trabajaba antes.

## Yeoman según la versión de Angular

| Angular | ¿Hay template Yeoman? | Qué hacer |
|---|---|---|
| **14** | ✅ `generator-alfresco-adf-app@6.1.1` (ADF 6.1) o `@5.1.0` (ADF 5.1) | Seguir esta guía. **Comprobado.** |
| 16 | ❌ No existe | Usar [ACA 5.3.0](05-aca.md#angular-16--aca-530) o [ADF a mano](06-adf-manual.md#angular-16--adf-700-alpha7) |
| 18 | ❌ No existe | Usar [ADF a mano](06-adf-manual.md#angular-18--adf-701) |
| 20 | ❌ No existe | Usar [ACA 8.0.0](05-aca.md#angular-20--aca-800), [ADF a mano](06-adf-manual.md#angular-20--adf-900) o los [generadores Nx](04-generadores-nx.md) (Angular 19) |
| 22 (última) | ❌ No existe | Usar [ADF a mano](06-adf-manual.md#angular-22-última--adf-900) |

Versiones anteriores del generador, por si hay que mantener algo muy antiguo:

| Generador | Genera |
|---|---|
| 2.6.3 (2018) | ADF 2.6 / Angular 6 / TS 2.9 |
| 3.9.0 (2020) | ADF 3.9 / Angular 7 / TS 3.1 |
| 4.0.0 – 4.11.0 (2020–2022) | ADF 4.x / Angular 10 / TS 3.9 |
| 5.1.0 (dic. 2022) | ADF 5.1 / Angular 14 / TS 4.6 |
| **6.1.1** (jun. 2023) | **ADF 6.1 / Angular 14 / TS 4.6** |

`ng update` no sirve para pasar un proyecto Yeoman de Angular 14 a una versión posterior: ADF 6 no
funciona con Angular 15+, y saltar de ADF 6 a 7, 8 o 9 implica cambios grandes de API (por ejemplo,
`CoreModule.forRoot()` pasa a `provideCoreAuth()` / `provideI18N()`). Conviene empezar de nuevo con
otra opción.

---

## Angular 14 con Yeoman (paso a paso)

> **Comprobado el 2026-10-10** en Windows 11: `yo` generó el proyecto, `npm install` terminó bien y
> `ng serve` respondió "Compiled successfully".

### Requisitos

| Requisito | Versión | Por qué |
|---|---|---|
| Node.js | Compatibles: **14.15+ o 16.10+** (14.21.3, 16.20.2). Probado: **16.20.2** | Angular 14 soporta oficialmente `^14.15.0 \|\| ^16.10.0`; `yo@4.3.1` pide `>=12.10.0`. [detalle](02-matriz-de-versiones.md#5-versiones-de-node-compatibles-con-cada-prueba-realizada) |
| npm | **8.19.4** | El que trae Node 16.20.2 |
| yo | **4.3.1** | `yo@7` exige Node `^20.17 \|\| >=22.9` y no funciona con este generador |
| generator-alfresco-adf-app | **6.1.1** | Última versión |
| **Visual Studio Build Tools 2022** con "Desarrollo para el escritorio con C++" | 2022, **no 2026** | Para compilar `deasync` (ver abajo). El node-gyp de Node 16 (9.1.0) solo reconoce VS 2017/2019/2022 |
| **Python 3** y, si es ≥ 3.12, **`setuptools`** | Probado con 3.14.7 | node-gyp 9.1.0 importa `distutils` (`gyp/pylib/gyp/input.py`), que Python eliminó en la 3.12 |
| ACS | 7.3 – 7.4 (época de ADF 6) o más reciente | Para iniciar sesión |

### Por qué necesita compilar

El generador depende de `generator-alfresco-common`, que usa **`deasync`**, un módulo nativo de C++.
`deasync` solo trae binarios precompilados para Node antiguos; con cualquier otro hay que compilarlo
con node-gyp, y en Windows eso exige Visual Studio.

| Versión del generador | `deasync` | Binarios precompilados hasta | ¿Compila en Windows? |
|---|---|---|---|
| 2.0.0 | no lo usa | — | No |
| 2.1.0 – 2.6.3 | 0.1.12 | Node 9 | Sí, con Node ≥ 10 |
| 3.0.0 – **6.1.1** | 0.1.14 | Node 11 | **Siempre**: `yo@4` ya exige Node ≥ 12.10 |

En Linux y macOS también compila, pero normalmente las herramientas ya están instaladas
(`build-essential` + Python, o Xcode Command Line Tools).

### 1. Instalar los requisitos (una sola vez)

Ver el detalle en [01-preparar-entorno.md](01-preparar-entorno.md#4-visual-studio-build-tools--python-solo-yeoman-en-windows).

```powershell
nvm install 16.20.2
python -m pip install setuptools                       # solo si Python >= 3.12
# PowerShell como administrador:
winget install --id Microsoft.VisualStudio.2022.BuildTools --override "--wait --passive --add Microsoft.VisualStudio.Workload.VCTools --includeRecommended"
```

### 2. Instalar Yeoman y el generador

```powershell
nvm use 16.20.2                 # node -v → v16.20.2 ; npm -v → 8.19.4
npm config set msvs_version 2022
npm install -g yo@4.3.1 generator-alfresco-adf-app@6.1.1
#   Si termina sin "gyp ERR!", deasync se compiló bien
npm ls -g --depth=0             # → yo@4.3.1, generator-alfresco-adf-app@6.1.1
```

### 3. Generar el proyecto

```powershell
cd C:\ruta\de\trabajo
yo alfresco-adf-app
#   ? Your project name                             → mi-app
#   ? Application blueprint                         → ACS ADF Application with Angular CLI
#   ? Would you like to install dependencies now?   → No  (se instala en el paso 4)
#   Subgenerador de licencia:
#   ? What's your name / email / website            → datos del autor (Enter acepta lo sugerido)
#   ? Which license do you want to use?             → MIT
```

Semi-automático (igual pregunta los datos de la licencia):

```powershell
yo alfresco-adf-app --name=mi-app --blueprint=adf-cli-acs-template --no-install
```

| `--blueprint` | Texto del menú | Backend |
|---|---|---|
| `adf-cli-acs-template` | ACS ADF Application with Angular CLI | Content Services |
| `adf-cli-aps-template` | APS ADF Application with Angular CLI | Process Services |
| `adf-cli-acs-aps-template` | ACS APS ADF Application with Angular CLI | ACS + APS |
| `adf-cli-activiti-cloud-template` | APS ADF Application with Angular CLI | Activiti Cloud |
| `adf-cli-activiti-cloud-acs-template` | APS ADF Application with Angular CLI | Activiti Cloud + ACS |
| `adf-cli-apa-template` | APA ADF Application with Angular CLI | Process Automation |
| `adf-cli-apa-acs-template` | AP ADF Application with Angular CLI | APA + ACS |

El valor de `--blueprint` es el `name` del `package.json` de cada plantilla, **no** el nombre de la
carpeta: las carpetas `adf-cli-activiti-community-*` se llaman `adf-cli-activiti-cloud-*`.

Particularidades:
- El generador solo **copia** la plantilla. El `package.json` conserva
  `"name": "adf-cli-acs-template"`; renombrarlo a mano si hace falta.
- El archivo `LICENSE` se crea en la **carpeta padre** (`..\LICENSE`).

### 4. Instalar dependencias e iniciar

```powershell
cd mi-app
npm install          # ~2–3 min; avisa de vulnerabilidades (dependencias de 2023), no bloquea
npm start            # = ng serve app --open → http://localhost:4200
npm run build        # = ng build app → dist/
```

- `proxy.conf.js` ya apunta `/alfresco` a `http://localhost:8080` (y `/activiti-app` a `:9999` en
  las plantillas APS).
- `src/app.config.json` usa `ecmHost: "{protocol}//{hostname}{:port}"`: la app llama a su propio
  origen y el proxy reenvía.
- Aviso esperado que no bloquea: `minimatch ... Can't resolve 'path'`.

### Estructura generada (ACS)

```
mi-app/
├── proxy.conf.js              # /alfresco → http://localhost:8080
├── angular.json               # proyecto "app"
├── resources/i18n/en.json     # traducciones propias de la app (TRANSLATION_PROVIDER "app")
├── src/
│   ├── app.config.json        # configuración de ADF
│   ├── custom-style.scss      # tema Alfresco (Material + ADF)
│   └── app/
│       ├── app.module.ts      # CoreModule.forRoot(), ContentModule.forRoot(), TranslateModule
│       ├── app.routes.ts      # login, home, documents y files/:nodeId/view (AuthGuardEcm)
│       ├── app-layout/        # layout con menú lateral
│       ├── login/             # <adf-login>
│       ├── home/
│       ├── documents/         # <adf-document-list>
│       ├── file-view/         # visor (outlet "overlay")
│       └── services/preview.service.ts
```

### Alternativa sin Visual Studio ni `yo` (comprobada)

Como el generador solo copia la carpeta de la plantilla, se puede extraer directamente del paquete npm.
Útil en un aula, para no instalar varios GB de herramientas en cada equipo:

```powershell
nvm use 16.20.2
mkdir yeoman-tmp ; cd yeoman-tmp
npm pack generator-alfresco-adf-app@6.1.1
tar xzf generator-alfresco-adf-app-6.1.1.tgz
Copy-Item -Recurse package\app\templates\adf-cli-acs-template ..\mi-app
cd ..\mi-app
npm install
npm start
```

### Errores frecuentes

| Error | Causa | Solución |
|---|---|---|
| `gyp ERR! find VS ... You need to install the latest version of Visual Studio` | No hay Build Tools, o es la versión 2026 | Build Tools **2022** con C++ y `npm config set msvs_version 2022` |
| `ModuleNotFoundError: No module named 'distutils'` | Python ≥ 3.12 con node-gyp 9 | `python -m pip install setuptools` |
| `Could not locate the bindings file` (`deasync`) al ejecutar `yo` | `deasync` sin compilar | Corregir lo anterior y reinstalar el generador |
| `yo: command not found` | Los paquetes globales son por versión de Node | `nvm use 16.20.2` |
| `yo` se queda esperando sin preguntar | El subgenerador de licencia pide datos | Responder en una terminal interactiva |

## Referencias

- npm: <https://www.npmjs.com/package/generator-alfresco-adf-app>
- Yeoman: <https://yeoman.io>
- node-gyp en Windows: <https://github.com/nodejs/node-gyp#on-windows>
- deasync: <https://github.com/abbr/deasync>
