# Onboarding Alfresco ADF / ACA / ADW

Guía práctica para empezar con **Alfresco ADF** (Application Development Framework): cómo crear un
proyecto de cada forma posible (Yeoman, generadores Nx, ACA o a mano), con **Angular 14, 16, 18, 20 y
el más actual (22)**, y con los requisitos, versiones de Node/npm, comandos y problemas reales de cada
caso.

> Todo lo marcado como **comprobado** se ejecutó en Windows 11 (nvm-windows, Git Bash) entre el
> 10 y el 11 de octubre de 2026: se instalaron las dependencias, se compiló y se abrió la pantalla de
> login en Chrome sin errores. Lo que no se pudo probar está indicado explícitamente.

## Índice

| # | Documento | Contenido |
|---|---|---|
| 00 | [¿Qué es ADF?](docs/00-que-es-adf.md) | ACS, ADF, ACA, ADW, paquetes, arquitectura, ruta de aprendizaje |
| 01 | [Preparar el entorno](docs/01-preparar-entorno.md) | nvm y versiones de Node, Git, pnpm, VS Build Tools + Python, Docker + ACS |
| 02 | [Matriz de versiones](docs/02-matriz-de-versiones.md) | Angular ↔ ADF ↔ js-api ↔ Node ↔ ACA ↔ generadores |
| 03 | [Template con **Yeoman**](docs/03-yeoman.md) | `generator-alfresco-adf-app` por versión de Angular (solo existe para 14) |
| 04 | [Template con **generadores Nx**](docs/04-generadores-nx.md) | `@alfresco/adf-generators` por versión de Angular (solo genera 19) |
| 05 | [**ACA**](docs/05-aca.md) | Alfresco Content App por versión de Angular, estructura, extensiones |
| 06 | [**ADF a mano**](docs/06-adf-manual.md) | Agregar ADF a un proyecto Angular 14 / 16 / 18 / 20 / 22 |
| 07 | [Tutorial: mini app](docs/07-tutorial-mini-app.md) | Login → documentos → visor con Angular 20 + ADF 9, paso a paso |
| 08 | [ADW (Enterprise)](docs/08-adw.md) | Extender Alfresco Digital Workspace |
| 09 | [Conceptos clave](docs/09-conceptos-clave.md) | `app.config.json`, proxy, autenticación, i18n, temas, componentes, extensiones |
| 10 | [Problemas conocidos](docs/10-problemas-conocidos.md) | Errores reales y su solución |
| 11 | [Referencias](docs/11-referencias.md) | Repositorios, documentación oficial, blogs, npm |

Recursos:

- [`ejemplos/angular20-adf9-mini-app`](ejemplos/angular20-adf9-mini-app): app del tutorial, lista para `npm install && npm start`.
- [`scripts/`](scripts): scripts que reproducen las pruebas (Angular + ADF por versión, ACA por tag).

## Respuesta rápida: ¿qué uso con mi versión de Angular?

| Angular | Yeoman | Generadores Nx | ACA | ADF a mano |
|---|---|---|---|---|
| **14** | ✅ [6.1.1](docs/03-yeoman.md#angular-14-con-yeoman-paso-a-paso) · Node 16.20.2 | ❌ | ✅ [4.4.1](docs/05-aca.md#angular-14--aca-441) · Node 18 | ✅ [ADF 6.9.1](docs/06-adf-manual.md#angular-14--adf-691) · Node 16.20.2 |
| **16** | ❌ | ❌ | ✅ [5.3.0](docs/05-aca.md#angular-16--aca-530) · Node 18 | ✅ [ADF 7.0.0-alpha.7](docs/06-adf-manual.md#angular-16--adf-700-alpha7) · Node 16.20.2 |
| **18** | ❌ | ❌ | ❌ ([alternativas](docs/05-aca.md#angular-18--no-hay-aca)) | ✅ [ADF 7.0.1](docs/06-adf-manual.md#angular-18--adf-701) · Node 24 |
| 19 | ❌ | ✅ [1.0.4](docs/04-generadores-nx.md#angular-19-con-generadores-nx-paso-a-paso) · Node 24 | ACA 7.x | ADF 8.5 (no probado) |
| **20** | ❌ | ❌ (genera 19) | ✅ [8.0.0](docs/05-aca.md#angular-20--aca-800) · Node 24 | ✅ [ADF 9.0.0](docs/06-adf-manual.md#angular-20--adf-900) · Node 24 |
| 21 | ❌ | ❌ | ✅ [`master`](docs/05-aca.md#angular-21--aca-master-lo-más-reciente) · Node 24 + pnpm | ADF 9.0.0 |
| **22** (última) | ❌ | ❌ | ❌ | ✅ [ADF 9.0.0](docs/06-adf-manual.md#angular-22-última--adf-900) · Node 24.15+ |

✅ = comprobado en este repositorio · ❌ = no existe esa combinación.

## Ruta de aprendizaje

1. **Conceptos:** [00](docs/00-que-es-adf.md) y [09](docs/09-conceptos-clave.md).
2. **Entorno:** [01](docs/01-preparar-entorno.md), con ACS levantado en Docker.
3. **Primera app oficial:** [04 · generadores Nx](docs/04-generadores-nx.md) con la plantilla `acs`;
   recorrer su código (login, documents, file-view).
4. **Construir desde cero:** [07 · tutorial](docs/07-tutorial-mini-app.md) y sus ejercicios.
5. **App de referencia:** [05 · ACA 8.0.0](docs/05-aca.md#angular-20--aca-800) y una extensión.
6. **Proyectos reales:** [06 · ADF a mano](docs/06-adf-manual.md) en la versión de Angular del proyecto.
7. **Mantenimiento de proyectos antiguos:** [03 · Yeoman](docs/03-yeoman.md) y ACA 4.x/5.x.

## Hallazgos principales

- La **guía oficial "Deploy Alfresco Content App"** de Hyland está desactualizada: pide Node 18, npm y
  variables `APP_CONFIG_*`. ACA 8 usa Node 24, ACA `master` usa pnpm, y todas las versiones solo usan
  `BASE_URL`.
- En el blog de Nx y en docs.hyland.com los comandos dicen `nx generate /adf-generators:...`: al
  publicar se perdió `@alfresco`.
- El generador **Yeoman** compila un módulo nativo (`deasync`). En Windows necesita **VS Build Tools
  2022** (no la 2026) y, con Python ≥ 3.12, `setuptools`. Hay una
  [alternativa sin compilar](docs/03-yeoman.md#alternativa-sin-visual-studio-ni-yo-comprobada).
- **No hay ADF compilado** con Angular 18, 21 ni 22. Se usan ADF 7.0.1 (para 18) y ADF 9.0.0 (para
  21/22), y funcionan.
- La versión de Angular con la que se compiló cada ADF se averigua leyendo
  `ɵɵngDeclareComponent({ version })` dentro del paquete ([02](docs/02-matriz-de-versiones.md#2-adf--angular-lo-que-realmente-usa-cada-paquete)).

## Licencia

Documentación de uso interno para onboarding. ADF tiene licencia Apache 2.0 y ACA, LGPL-3.
