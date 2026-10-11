# 02 · Matriz de versiones

[⬅ Preparar el entorno](01-preparar-entorno.md) · [Índice](../README.md) · [Siguiente: Yeoman ➡](03-yeoman.md)

> **Regla de oro:** ADF, Angular, Angular Material, `@alfresco/js-api` y Node tienen que ser
> compatibles entre sí. Si se mezclan versiones, la instalación (`ERESOLVE`), el build o la app en
> tiempo de ejecución se rompen.

## 1. ¿Qué se puede usar con cada versión de Angular?

Respuesta corta a "quiero Angular X":

| Angular | Yeoman | Generadores Nx | ACA | ADF a mano |
|---|---|---|---|---|
| **14** | ✅ `generator-alfresco-adf-app` 5.1.0 / **6.1.1** (ADF 5.1 / 6.1) | ❌ | ✅ ACA **4.0 – 4.4.1** (ADF 6.0 – 6.7) | ✅ ADF **6.9.1** |
| 15 | ❌ | ❌ | ACA 5.0 – 5.1 (ADF 7.0.0-alpha.2/3) | ADF 7.0.0-alpha.2 |
| **16** | ❌ | ❌ | ✅ ACA **5.2 – 5.3.0** (ADF 7.0.0-alpha.6/7) | ✅ ADF **7.0.0-alpha.7** |
| 17 | ❌ | ❌ | ACA 6.0.0 (ADF 7.0.0) | ADF 7.0.1 |
| **18** | ❌ | ❌ | ❌ no hay ACA con Angular 18 | ✅ ADF **7.0.1** (compilado con Angular 17) |
| 19 | ❌ | ✅ `@alfresco/adf-generators` 1.0.x (ADF 8.0) | ACA 7.0 – 7.5 (ADF 8.0 – 8.5) | ADF 8.5.0 |
| **20** | ❌ | ❌ (genera Angular 19) | ✅ ACA **8.0.0** (ADF 9.0) | ✅ ADF **9.0.0** |
| 21 | ❌ | ❌ | ACA `master` (ADF 9.2 prerelease, pnpm) | ADF 9.0.0 |
| **22** (última, 22.2) | ❌ | ❌ | ❌ | ✅ ADF **9.0.0** (compilado con Angular 20) |

Leyenda: ✅ comprobado en este repositorio (fila en negrita) · sin marca = deducido de los paquetes,
no probado · ❌ no existe.

## 2. ADF ↔ Angular (lo que realmente usa cada paquete)

Cada librería Angular publicada guarda la versión del compilador con la que se construyó
(`ɵɵngDeclareComponent({ version: "..." })`). Ese dato es más confiable que `peerDependencies`, que
en ADF 7+ dice `>=16.0.0` para todo.

| ADF (`adf-core`) | Compilado con Angular | `@alfresco/js-api` (peer) | `@ngx-translate/core` (peer) | `@mat-datetimepicker/core` según Angular |
|---|---|---|---|---|
| 6.0.0 – **6.9.1** | 14.1.3 | `>=7.8.1` (6.9.1) | `>=14` | 10.x (peer `^14`) |
| 7.0.0-alpha.2 | 15.2.10 | `>=8.0.0-alpha.2` | `^14` | 11.x (peer `^15`) |
| 7.0.0-alpha.**7** | 16.2.9 | `>=8.0.0-alpha.7` | `^14` | 12.0.1 (peer `^16.2`) |
| 7.0.0 – **7.0.1** | 17.1.3 | `>=8.0.1` | `>=14` | 13.x (Ng 17) · 14.x (Ng 18) |
| 8.0.x | 19.2.6 | `>=9.0.2` | `>=16` | 15.x (peer `^19`) |
| 8.5.0 | 19.2.20 | `>=9.5.0` | `>=17` | 15.x |
| **9.0.0** (`latest`) | 20.3.25 | `>=10.0.0` | `>=17` | 16.x (peer `^20`) |
| 9.2.0-* (prerelease) | 21.x (ACA `master`) | 10.2 | 17 | — |

El mapeo de `@mat-datetimepicker/core` sale de su propio `peerDependencies.@angular/core`.

Comprobarlo uno mismo:

```bash
npm pack @alfresco/adf-core@9.0.0
tar xzf alfresco-adf-core-9.0.0.tgz
grep -oE 'version: "[0-9.]+"' package/fesm2022/adf-core.mjs | sort | uniq -c | sort -rn | head -1
#   → version: "20.3.25"
npm view @alfresco/adf-core dist-tags          # latest, alpha, etc.
npm view @alfresco/adf-core@9.0.0 peerDependencies
```

## 3. Angular ↔ Node

Del campo `engines` de `@angular/cli` en npm:

| Angular CLI | Node soportado | Probado aquí con |
|---|---|---|
| 14.2 | `^14.15.0 \|\| >=16.10.0` (oficial: 14 y 16) | 16.20.2 |
| 15.2 | `^14.20 \|\| ^16.13 \|\| >=18.10` | — |
| 16.2 | `^16.14 \|\| >=18.10` | 16.20.2 |
| 17.3 | `^18.13 \|\| >=20.9` | — |
| 18.2 | `^18.19.1 \|\| ^20.11.1 \|\| >=22.0.0` | 24.19.0 |
| 19.2 | `^18.19.1 \|\| ^20.11.1 \|\| >=22.0.0` | 24.19.0 (Nx template) |
| 20.3 | `^20.19 \|\| ^22.12 \|\| >=24` | 24.19.0 |
| 21.2 | `^20.19 \|\| ^22.12 \|\| >=24` | 24.19.0 (ACA master) |
| 22.2 (`latest`) | `^22.22.3 \|\| ^24.15 \|\| >=26` | 24.19.0 |

```bash
npm view @angular/cli dist-tags                 # latest, v20-lts, ...
npm view @angular/cli@20 engines.node
```

## 4. ACA: versiones publicadas

Datos del `package.json` y `.nvmrc` de cada tag de <https://github.com/Alfresco/alfresco-content-app>:

| Tag ACA | Angular | ADF | js-api | `.nvmrc` | Gestor | ACS |
|---|---|---|---|---|---|---|
| 4.0.0 | 14.1.2 | 6.0.0 | 6.0.0 | 14 | npm | 7.4 |
| **4.4.1** | 14.1.3 | 6.7.1 | 7.6.1 | 18 | npm | 23.2 |
| 5.0.1 | 15.2.10 | 7.0.0-alpha.2 | 8.0.0-alpha.2 | 18 | npm | 23.3 |
| 5.1.1 | 15.2.10 | 7.0.0-alpha.3 | 8.0.0-alpha.3 | 18 | npm | 23.3 |
| 5.2.0 | 16.2.9 | 7.0.0-alpha.6 | 8.0.0-alpha.6 | 18 | npm | 23.4 |
| **5.3.0** | 16.2.9 | 7.0.0-alpha.7 | 8.0.0-alpha.7 | 18 | npm | 23.4 |
| 6.0.0 | 17.1.3 | 7.0.0 | 8.0.0 | 20.18.1 | npm | 25.1 |
| 7.0.1 | 19.2.6 | 8.0.1 | 9.0.1 | 22.14.0 | npm | 25.2 |
| 7.5.0 | 19.2.20 | 8.5.0 | 9.5.0 | 24.13.0 | npm | 26.x |
| **8.0.0** | 20.3.25 | 9.0.0 | 10.0.0 | 24.13.1 | npm | 26.x |
| `master` (oct. 2026) | 21.2 | 9.2.0 (prerelease) | 10.2 | 24.13.1 | **pnpm 11** | 26.x |

## 5. Versiones de Node compatibles con cada prueba realizada

Para cada prueba se cruzaron cuatro fuentes:

- **Oficial:** la tabla de soporte de Angular en <https://angular.dev/reference/versions>.
- **`engines`:** lo que aceptan `@angular/cli`, `@angular/core` y `@angular/build` instalados en el
  proyecto. Suele ser un rango abierto (`>=`), más amplio que el oficial.
- **Proyecto:** `.nvmrc`, `engines` del `package.json` o README del proyecto o generador.
- **Probado:** la versión con la que se ejecutó la prueba en este repositorio.

Nx (17, 21 y 23), ADF y `@alfresco/js-api` **no declaran `engines`**, así que el límite lo pone
Angular, el proyecto o el gestor de paquetes.

| # | Prueba | Angular instalado | Node oficial (Angular) | Node aceptado por `engines` | Pide el proyecto | ✅ Probado |
|---|---|---|---|---|---|---|
| 1 | **Yeoman**: instalar `yo` + generador 6.1.1 | — | — | `yo@4.3.1`: `>=12.10.0` · `yeoman-generator@4`: `>=10` | — | 16.20.2 / npm 8.19.4 (+ VS Build Tools 2022) |
| 2 | **Yeoman**: app generada (`adf-cli-acs-template`) | 14.3.0 (CLI 14.2.13) | `^14.15.0 \|\| ^16.10.0` | `^14.15.0 \|\| >=16.10.0` | — | 16.20.2 / npm 8.19.4 |
| 3 | **Generadores Nx**: workspace (`create-nx-workspace`, Nx 23.2) | — | — | Nx sin `engines` | `.nvmrc` del repo de generadores: **24.11.1**; blog: 22.x | 24.19.0 / npm 11.17.0 |
| 4 | **Generadores Nx**: app `template` (Nx 21.2) | 19.2.6 (CLI 19.2.27) | `^18.19.1 \|\| ^20.11.1 \|\| ^22.0.0` | `^18.19.1 \|\| ^20.11.1 \|\| >=22.0.0` | — | 24.19.0 / npm 11.17.0 |
| 5 | **ACA 4.4.1** (Nx 17.3) | 14.1.3 | `^14.15.0 \|\| ^16.10.0` | `^14.15.0 \|\| >=16.10.0` | `.nvmrc` **18** · README: 18.x | 18.20.8 / npm 10.8.2 |
| 6 | **ACA 5.3.0** (Nx 17.3) | 16.2.9 | `^16.14.0 \|\| ^18.10.0` | `^16.14.0 \|\| >=18.10.0` | `.nvmrc` **18** · README: 18.x | 18.20.8 / npm 10.8.2 |
| 7 | **ACA 8.0.0** (Nx 23.0) | 20.3.25 | `^20.19.0 \|\| ^22.12.0 \|\| ^24.0.0` | `^20.19.0 \|\| ^22.12.0 \|\| >=24.0.0` | `.nvmrc` **24.13.1** | 24.19.0 / npm 11.17.0 |
| 8 | **ACA `master`** (`adf-test`, Nx 23.2, pnpm 11.17) | 21.2.22 | `^20.19.0 \|\| ^22.12.0 \|\| ^24.0.0` | `^20.19.0 \|\| ^22.12.0 \|\| >=24.0.0` · pnpm 11.17: `>=22.13` | `engines` **`>=24.13.1`** · `.nvmrc` 24.13.1 | 24.19.0 / pnpm 11.17.0 |
| 9 | **ADF a mano, Angular 14** (ADF 6.9.1) | 14.3.0 (CLI 14.2.13) | `^14.15.0 \|\| ^16.10.0` | `^14.15.0 \|\| >=16.10.0` | — | 16.20.2 / npm 8.19.4 |
| 10 | **ADF a mano, Angular 16** (ADF 7.0.0-alpha.7) | 16.2.12 (CLI 16.2.16) | `^16.14.0 \|\| ^18.10.0` | `^16.14.0 \|\| >=18.10.0` | — | 16.20.2 / npm 8.19.4 |
| 11 | **ADF a mano, Angular 18** (ADF 7.0.1) | 18.2.14 (CLI 18.2.21) | `^18.19.1 \|\| ^20.11.1 \|\| ^22.0.0` | `^18.19.1 \|\| ^20.11.1 \|\| >=22.0.0` | — | 24.19.0 / npm 11.17.0 ⚠️ fuera del rango oficial |
| 12 | **ADF a mano, Angular 20** (ADF 9.0.0) | 20.3.33 (CLI 20.3.39) | `^20.19.0 \|\| ^22.12.0 \|\| ^24.0.0` | `^20.19.0 \|\| ^22.12.0 \|\| >=24.0.0` | — | 24.19.0 / npm 11.17.0 |
| 13 | **Tutorial mini app** (Angular 20 + ADF 9 + content-services) | 20.3.33 | `^20.19.0 \|\| ^22.12.0 \|\| ^24.0.0` | `^20.19.0 \|\| ^22.12.0 \|\| >=24.0.0` | — | 24.19.0 / npm 11.17.0 |
| 14 | **ADF a mano, Angular 22** (ADF 9.0.0) | 22.2.2 | `^22.22.3 \|\| ^24.15.0 \|\| ^26.0.0` | `^22.22.3 \|\| ^24.15.0 \|\| >=26.0.0` | — | 24.19.0 / npm 11.17.0 |

### Resultado: qué versiones de Node instalar para cada prueba

Las versiones concretas son las últimas de cada línea en <https://nodejs.org/dist/index.json>
(octubre 2026). **Negrita** = probada.

| # | Prueba | Compatibles (oficial ∩ proyecto) | Versiones concretas | Funciona pero fuera de lo oficial |
|---|---|---|---|---|
| 1–2 | Yeoman (Angular 14) | Node **14.15+** o **16.10+** | 14.21.3 · **16.20.2** | Node 18+ lo acepta `engines`, pero Angular 14 no lo soporta oficialmente (no probado) |
| 3–4 | Generadores Nx (Angular 19) | Angular 19: 18.19.1+, 20.11.1+, 22.x. Repo: 24.11.1 | 22.23.3 · **24.19.0** (24.21.0 es la última 24) | 18 / 20: los acepta Angular 19, pero el workspace Nx 23 no se probó con ellos |
| 5 | ACA 4.4.1 (Angular 14) | `.nvmrc` 18; Angular 14 oficial: 14 / 16 | **18.20.8** (lo que pide ACA) · 16.20.2 | ACA usa Node 18 aunque Angular 14 solo soporta oficialmente 14/16. Probado con 18 y funciona |
| 6 | ACA 5.3.0 (Angular 16) | 16.14+ o 18.10+ (`.nvmrc` 18) | **18.20.8** · 16.20.2 | — |
| 7 | ACA 8.0.0 (Angular 20) | 24.13.1+ (Angular admite 20.19+ / 22.12+, pero el `.nvmrc` pide 24.13.1) | **24.19.0** · 24.21.0 | 20.20.2 / 22.23.3: los admite Angular 20, no los pide ACA (no probado) |
| 8 | ACA `master` (Angular 21) | **24.13.1+** (impuesto por `engines`) | **24.19.0** · 24.21.0 | — (20 y 22 no cumplen `engines`) |
| 9 | ADF a mano, Angular 14 | 14.15+ o 16.10+ | 14.21.3 · **16.20.2** | 18+ (no probado) |
| 10 | ADF a mano, Angular 16 | 16.14+ o 18.10+ | **16.20.2** · 18.20.8 | 20+ (no probado) |
| 11 | ADF a mano, Angular 18 | 18.19.1+, 20.11.1+ o 22.x | 18.20.8 · 20.20.2 · 22.23.3 | **24.19.0**: lo permite `engines`, pero no está en la tabla oficial. Probado y funciona |
| 12–13 | ADF a mano, Angular 20 / mini app | 20.19+, 22.12+ o 24.x | 20.20.2 · 22.23.3 · **24.19.0** | — |
| 14 | ADF a mano, Angular 22 | **22.22.3+**, **24.15+** o 26.x | 22.23.3 · **24.19.0** · 24.21.0 · 26.11.1 | — (22.0–22.22.2 y 24.0–24.14 **no** sirven) |

Cosas a tener en cuenta:

- **Node 14 y 16** ya no reciben actualizaciones de seguridad. Úsalos solo para proyectos antiguos
  (Yeoman, Angular 14/16) y en equipos de prueba.
- **Node 18** es la versión que pide ACA 4.x y 5.x, aunque Angular 14 no la soporte oficialmente.
- **Node 24 (24.15+)** cubre por sí solo los generadores Nx, ACA 8.0, ACA `master` y ADF a mano con
  Angular 18, 20 y 22. Es la mejor opción para un aula moderna.
- Con nvm-windows: `nvm install 24.21.0`, `nvm install 18.20.8`, `nvm install 16.20.2`.

Para verlo desde el lado de Node ("tengo Node X, ¿qué puedo hacer?"), ver
[01-preparar-entorno.md](01-preparar-entorno.md#qué-puedo-hacer-con-cada-versión-de-node).

## 6. Generadores

| Generador | Versiones | Genera |
|---|---|---|
| `generator-alfresco-adf-app` (Yeoman) | 2.0.0 (2017) → **6.1.1** (2023, última) | 2.6.3: ADF 2.6 / Ng 6 · 3.9.0: ADF 3.9 / Ng 7 · 4.0 – 4.11: ADF 4.x / Ng 10 · 5.1.0: ADF 5.1 / Ng 14 · **6.1.1: ADF 6.1 / Ng 14** |
| `@alfresco/adf-generators` (Nx) | 1.0.0 – **1.0.4** (sep.–oct. 2025) | ADF 8.0.0 / Angular 19.2.6 / js-api 9.0.0 |
| `@alfresco/aca-generators` (Nx) | 1.0.0 – 1.0.4 | Extensiones para ACA |
| `@alfresco/adw-generators` (Nx) | 1.0.0 – 1.0.4 | Extensiones para ADW |
