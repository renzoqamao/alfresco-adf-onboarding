# 00 · ¿Qué es Alfresco ADF?

[⬅ Índice](../README.md) · [Siguiente: Preparar el entorno ➡](01-preparar-entorno.md)

## Las piezas

| Pieza | Qué es | ¿Código abierto? |
|---|---|---|
| **ACS** (Alfresco Content Services) | El **backend**: repositorio documental con API REST (`/alfresco/api/...`). Se ejecuta en Java/Tomcat, normalmente con Docker. | Community: sí · Enterprise: no |
| **APS** (Alfresco Process Services) | Motor de procesos BPM (Activiti), backend `/activiti-app`. | Enterprise |
| **APA** (Alfresco Process Automation) | Procesos en la nube (Activiti Cloud) con OAuth / Keycloak. | Enterprise |
| **ADF** (Application Development Framework) | **Librerías Angular** con componentes listos (login, lista de documentos, visor, búsqueda, formularios...) que hablan con ACS/APS. Paquetes `@alfresco/adf-*`. | Sí (Apache 2.0) |
| **`@alfresco/js-api`** | Cliente JavaScript/TypeScript de las APIs REST de ACS/APS. ADF lo usa por dentro; también se puede usar directamente. | Sí |
| **ACA** (Alfresco Content App) | **Aplicación de referencia** hecha con ADF: un gestor documental completo, extensible con plugins. | Sí |
| **ADW** (Alfresco Digital Workspace) | Versión **Enterprise** de ACA, con más funciones. | No (requiere licencia) |

## Paquetes de ADF

| Paquete | Para qué |
|---|---|
| `@alfresco/adf-core` | Base: configuración (`app.config.json`), autenticación, traducciones, login, datatable, visor genérico, formularios, tema |
| `@alfresco/adf-content-services` | Componentes de **contenido** (ACS): document list, breadcrumb, upload, búsqueda, permisos, versiones, visor de nodos |
| `@alfresco/adf-process-services` | Componentes de **procesos** (APS): tareas, procesos, formularios |
| `@alfresco/adf-process-services-cloud` | Componentes para **APA** (cloud) |
| `@alfresco/adf-extensions` | Sistema de **extensiones** (plugins por JSON), lo usan ACA y ADW |
| `@alfresco/adf-insights` | Reportes y analítica de APS |

## Cómo se conectan

```
 Navegador                    Servidor de desarrollo (ng serve)        Backend
┌──────────────┐  /alfresco/... ┌──────────────────────────────┐  /alfresco/... ┌─────────────┐
│ App Angular  │ ─────────────▶ │ http://localhost:4200        │ ─────────────▶ │ ACS :8080   │
│ + ADF        │                │  proxy.conf.(js|json)        │                │ (Docker)    │
└──────────────┘ ◀───────────── └──────────────────────────────┘ ◀───────────── └─────────────┘
   app.config.json:  ecmHost = http://localhost:4200  (la app llama a su propio origen)
```

- ADF lee **`app.config.json`** al arrancar: ahí va la URL del backend (`ecmHost` / `bpmHost`), el
  tipo de autenticación (`BASIC` / `OAUTH`) y los proveedores (`ECM`, `BPM`, `ALL`).
- En desarrollo, el **proxy** de Angular reenvía `/alfresco` a ACS para evitar problemas de CORS.
- En producción, la app y ACS suelen estar detrás del mismo dominio (Nginx/Traefik) o con CORS
  habilitado en ACS.

## Cuatro formas de empezar un proyecto

| # | Forma | Cuándo usarla | Guía |
|---|---|---|---|
| 1 | Generador **Yeoman** (`yo alfresco-adf-app`) | Proyectos antiguos (ADF 6 / Angular 14). Obsoleto. | [03-yeoman.md](03-yeoman.md) |
| 2 | **Generadores Nx** (`@alfresco/adf-generators`) | Forma oficial actual para una app ADF nueva | [04-generadores-nx.md](04-generadores-nx.md) |
| 3 | **ACA** (clonar Alfresco Content App) | Necesito un gestor documental completo y extenderlo | [05-aca.md](05-aca.md) |
| 4 | **A mano** sobre Angular CLI | Agregar ADF a un proyecto Angular existente, o una app mínima | [06-adf-manual.md](06-adf-manual.md) |

La regla más importante: **la versión de ADF tiene que corresponder a la versión de Angular**. Ver
[02-matriz-de-versiones.md](02-matriz-de-versiones.md).

## Ruta de aprendizaje sugerida

1. Leer este documento y [09-conceptos-clave.md](09-conceptos-clave.md).
2. [Preparar el entorno](01-preparar-entorno.md) y levantar ACS con Docker.
3. Crear una app con los [generadores Nx](04-generadores-nx.md) y entender su estructura.
4. Hacer el [tutorial de la mini app](07-tutorial-mini-app.md): login → documentos → visor.
5. Clonar [ACA](05-aca.md) y crear una extensión.
6. Practicar [agregar ADF a mano](06-adf-manual.md) en un proyecto Angular existente.
