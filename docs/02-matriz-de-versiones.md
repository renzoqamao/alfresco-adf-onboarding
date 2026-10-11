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

## 5. Generadores

| Generador | Versiones | Genera |
|---|---|---|
| `generator-alfresco-adf-app` (Yeoman) | 2.0.0 (2017) → **6.1.1** (2023, última) | 2.6.3: ADF 2.6 / Ng 6 · 3.9.0: ADF 3.9 / Ng 7 · 4.0 – 4.11: ADF 4.x / Ng 10 · 5.1.0: ADF 5.1 / Ng 14 · **6.1.1: ADF 6.1 / Ng 14** |
| `@alfresco/adf-generators` (Nx) | 1.0.0 – **1.0.4** (sep.–oct. 2025) | ADF 8.0.0 / Angular 19.2.6 / js-api 9.0.0 |
| `@alfresco/aca-generators` (Nx) | 1.0.0 – 1.0.4 | Extensiones para ACA |
| `@alfresco/adw-generators` (Nx) | 1.0.0 – 1.0.4 | Extensiones para ADW |
