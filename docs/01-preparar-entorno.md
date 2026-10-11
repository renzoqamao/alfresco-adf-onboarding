# 01 · Preparar el entorno

[⬅ Qué es ADF](00-que-es-adf.md) · [Índice](../README.md) · [Siguiente: Matriz de versiones ➡](02-matriz-de-versiones.md)

Comprobado en **Windows 11** con PowerShell y Git Bash. En Linux y macOS los comandos son
equivalentes (se indica cuando cambian).

## Resumen: ¿qué necesito para cada camino?

| Herramienta | Yeoman (Ng 14) | Nx generators | ACA | ADF a mano | Instalación |
|---|---|---|---|---|---|
| nvm | ✅ | ✅ | ✅ | ✅ | [1](#1-nvm-varias-versiones-de-node) |
| Node 16.20.2 | ✅ | | | Ng 14 / 16 | [1](#1-nvm-varias-versiones-de-node) |
| Node 18.20.x | | | ACA 4.x / 5.x | | [1](#1-nvm-varias-versiones-de-node) |
| Node 20.x | | | ACA 6.0 | Ng 17 | [1](#1-nvm-varias-versiones-de-node) |
| Node 22.x | | | ACA 7.0–7.4 | Ng 19 | [1](#1-nvm-varias-versiones-de-node) |
| Node 24.x | | ✅ | ACA 7.5 / 8.0 / master | Ng 18 / 20 / 22 | [1](#1-nvm-varias-versiones-de-node) |
| Git | | ✅ | ✅ | | [2](#2-git) |
| pnpm (corepack) | | | Solo ACA `master` | | [3](#3-pnpm-solo-aca-master) |
| VS Build Tools 2022 + Python | ✅ (Windows) | | | | [4](#4-visual-studio-build-tools--python-solo-yeoman-en-windows) |
| Docker + ACS | ✅ | ✅ | ✅ | ✅ | [5](#5-backend-acs-con-docker) |

## ¿Qué puedo hacer con cada versión de Node?

Resultado de cruzar la tabla oficial de Angular, los `engines` y el `.nvmrc` de cada proyecto con las
pruebas realizadas. Detalle por prueba en
[02-matriz-de-versiones.md § 5](02-matriz-de-versiones.md#5-versiones-de-node-compatibles-con-cada-prueba-realizada).
✅ = probado con esa versión de Node.

| Node (última de la línea) | npm | Compatible con | Fuera de lo oficial, pero funciona |
|---|---|---|---|
| **14.21.3** | 6.14 | Yeoman (Angular 14) · ADF a mano Angular 14 | — |
| **16.20.2** | 8.19.4 | ✅ Yeoman (Angular 14) · ✅ ADF a mano Angular 14 · ✅ ADF a mano Angular 16 · ACA 5.3.0 | — |
| **18.20.8** | 10.8.2 | ✅ ACA 4.4.1 · ✅ ACA 5.3.0 · ADF a mano Angular 16 y 18 · Generadores Nx (Angular 19, sin probar con Nx 23) | ACA 4.4.1 con Angular 14 (lo pide su `.nvmrc`) |
| **20.20.2** | 10.8.2 | ADF a mano Angular 18 y 20 · ACA 6.0 (Angular 17) · Angular 19/21 | — |
| **22.23.3** | 10.9.9 | ADF a mano Angular 18, 20 y 22 (necesita 22.22.3+) · Generadores Nx (lo pedía el blog) · ACA 7.0–7.4 | — |
| **24.21.0** (probado 24.19.0) | 11.x | ✅ Generadores Nx · ✅ ACA 8.0.0 · ✅ ACA `master` (24.13.1+) · ✅ ADF a mano Angular 20 y 22 (24.15+) · ✅ tutorial | ✅ ADF a mano Angular 18 (oficial: hasta Node 22) |
| 26.11.1 | 11.20 | ADF a mano Angular 22 | No probado |

**Para un aula** alcanza con instalar tres versiones: **24.x** (todo lo moderno), **18.20.8** (ACA 4/5)
y **16.20.2** (Yeoman, Angular 14/16).

## 1. nvm: varias versiones de Node

Cada versión de Angular, ACA o del generador necesita un Node distinto, así que conviene usar un
gestor de versiones.

**Windows (nvm-windows):**

```powershell
winget install --id CoreyButler.NVMforWindows      # o el instalador de https://github.com/coreybutler/nvm-windows/releases
# Cerrar y abrir la terminal
nvm version

nvm install 16.20.2      # Yeoman, Angular 14/16          → npm 8.19.4
nvm install 18.20.8      # ACA 4.x y 5.x                  → npm 10.8.x
nvm install 20           # ACA 6.0, Angular 17
nvm install 22           # ACA 7.0–7.4, Angular 19
nvm install 24           # Nx generators, ACA 7.5+/8.0, Angular 18/20/22  → npm 11.x
nvm list

nvm use 24
node -v ; npm -v
```

**Linux / macOS (nvm-sh):**

```bash
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.3/install.sh | bash
nvm install 24 && nvm use 24
# Dentro de un proyecto con .nvmrc:
nvm use           # lee la versión del .nvmrc
```

> **Importante en Windows:** nvm-windows cambia el Node **de todo el sistema** (enlace en
> `C:\nvm4w\nodejs`). Además, los paquetes globales (`npm i -g`) se instalan **por versión de Node**:
> si se instala `yo` con Node 16, no existe con Node 24. Antes de cada práctica, ejecutar
> `nvm use <versión>` y comprobar con `node -v`.
>
> nvm-windows **no lee `.nvmrc` automáticamente**. Ver la versión con `type .nvmrc` y luego
> `nvm use <versión>`.

## 2. Git

```powershell
winget install --id Git.Git
git --version
```

Git for Windows trae **Git Bash**, útil para los scripts de este repositorio y para los comandos POSIX
de ACA (`pnpm lint`).

## 3. pnpm (solo ACA `master`)

ACA `master` exige pnpm 11. Node ≥ 16.13 trae **corepack**, que lo activa con la versión exacta que
pide `package.json` → `packageManager`:

```powershell
nvm use 24
corepack enable
pnpm -v
```

## 4. Visual Studio Build Tools + Python (solo Yeoman en Windows)

El generador Yeoman depende de `deasync`, un módulo nativo que **se compila al instalar** (ver
[03-yeoman.md](03-yeoman.md#por-qué-necesita-compilar)).

```powershell
# Python 3 (si no está). Con Python >= 3.12 hay que agregar setuptools (node-gyp 9 usa distutils)
winget install --id Python.Python.3.12
python -m pip install setuptools
python -c "from distutils.version import StrictVersion; print('ok')"     # → ok

# Build Tools 2022 (NO la 2026: el node-gyp de Node 16 solo reconoce VS 2017/2019/2022)
# PowerShell COMO ADMINISTRADOR, descarga varios GB:
winget install --id Microsoft.VisualStudio.2022.BuildTools --override "--wait --passive --add Microsoft.VisualStudio.Workload.VCTools --includeRecommended"

# Terminal nueva:
& "C:\Program Files (x86)\Microsoft Visual Studio\Installer\vswhere.exe" -products * -format value -property displayName
#   → Visual Studio Build Tools 2022
nvm use 16.20.2
npm config set msvs_version 2022
```

Instalación gráfica: "Build Tools for Visual Studio 2022" en
<https://visualstudio.microsoft.com/vs/older-downloads/>, con la carga de trabajo **"Desarrollo para
el escritorio con C++"**.

Linux: `sudo apt install build-essential python3`. macOS: `xcode-select --install`.

## 5. Backend: ACS con Docker

Todas las apps necesitan un **Alfresco Content Services** para iniciar sesión. Sin él, la app compila
y abre, pero el login falla y el proxy responde **504**.

```powershell
winget install --id Docker.DockerDesktop          # asignar 8–12 GB de RAM en Settings → Resources
docker version

git clone --depth 1 https://github.com/Alfresco/acs-deployment.git
cd acs-deployment\docker-compose
docker compose -f community-compose.yaml up -d     # ACS Community 26.x
docker compose -f community-compose.yaml ps
```

- URL: `http://localhost:8080/alfresco`. Share: `http://localhost:8080/share`.
- Usuario: `admin` / `admin`.
- La primera vez tarda varios minutos. Comprobar que está listo:

```powershell
curl http://localhost:8080/alfresco/api/-default-/public/alfresco/versions/1/probes/-ready-
```

- Apagar: `docker compose -f community-compose.yaml down`. Agregando `-v` también se borran los datos.

## 6. Editor (recomendado)

- **VS Code** con las extensiones *Angular Language Service*, *ESLint* y *Prettier*.
- Chrome o Edge con las DevTools: pestaña **Network** para ver las llamadas a `/alfresco/api/...`.

## Lista de comprobación

```powershell
nvm list                 # 16.20.2, 18.20.x, 24.x ...
node -v ; npm -v
git --version
docker version
curl http://localhost:8080/alfresco/api/-default-/public/alfresco/versions/1/probes/-ready-
```
