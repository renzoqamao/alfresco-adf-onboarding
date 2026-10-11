# 11 · Referencias

[⬅ Problemas conocidos](10-problemas-conocidos.md) · [Índice](../README.md)

## Repositorios oficiales

| Repositorio | Contenido |
|---|---|
| <https://github.com/Alfresco/alfresco-ng2-components> | Código y **documentación de ADF** (`docs/`), guías de actualización (`docs/upgrade-guide`). Licencia Apache 2.0 |
| <https://github.com/Alfresco/alfresco-content-app> | **ACA**. Los tags son las versiones; documentación en `docs/`. Licencia LGPL-3 |
| <https://github.com/Alfresco/alfresco-front-end-generators> | **Generadores Nx** (ADF, ACA, ADW) y recetas (`docs/recipes`) |
| <https://github.com/Alfresco/alfresco-js-api> | Cliente JS de las APIs REST (`@alfresco/js-api`) |
| <https://github.com/Alfresco/acs-deployment> | Docker Compose y Helm de ACS (`docker-compose/community-compose.yaml`) |
| <https://github.com/Alfresco/rest-api-explorer> | Explorador de la API REST de ACS |

## Documentación

- ACA (web): <https://alfresco-content-app.netlify.app/>
- Componentes ADF:
  - Core: <https://github.com/Alfresco/alfresco-ng2-components/tree/develop/docs/core/components>
  - Content services: <https://github.com/Alfresco/alfresco-ng2-components/tree/develop/docs/content-services/components>
- docs.hyland.com (ADW 8.0, sección *Develop → Deploy front-end applications*):
  - [Deploy Alfresco Content App](https://docs.hyland.com/r/Alfresco/Alfresco-Digital-Workspace/8.0/Alfresco-Digital-Workspace/Develop/Deploy-front-end-applications/Deploy-Alfresco-Content-App) (**desactualizada**, ver [05](05-aca.md#la-guía-oficial-de-hyland-está-desactualizada))
  - [Generate and Deploy an ADF App → Prerequisites](https://docs.hyland.com/r/Alfresco/Alfresco-Digital-Workspace/8.0/Alfresco-Digital-Workspace/Develop/Deploy-front-end-applications/Generate-and-Deploy-an-ADF-App/Prerequisites)
  - [Installing the ADF Generators Plugin](https://docs.hyland.com/r/Alfresco/Alfresco-Digital-Workspace/8.0/Alfresco-Digital-Workspace/Develop/Deploy-front-end-applications/Generate-and-Deploy-an-ADF-App/Installing-the-ADF-Generators-Plugin)
  - [Generating an Angular Application Using the Template App](https://docs.hyland.com/r/Alfresco/Alfresco-Digital-Workspace/8.0/Alfresco-Digital-Workspace/Develop/Deploy-front-end-applications/Generate-and-Deploy-an-ADF-App/Installing-the-ADF-Generators-Plugin/Generating-an-Angular-Application-Using-the-Template-App)
  - [Installing the ACA Generators Plugin](https://docs.hyland.com/r/Alfresco/Alfresco-Digital-Workspace/8.0/Alfresco-Digital-Workspace/Develop/Deploy-front-end-applications/Generate-and-Deploy-an-ADF-App/Installing-the-ACA-Generators-Plugin)
  - [Installing the ADW Generators Plugin](https://docs.hyland.com/r/Alfresco/Alfresco-Digital-Workspace/8.0/Alfresco-Digital-Workspace/Develop/Deploy-front-end-applications/Generate-and-Deploy-an-ADF-App/Installing-the-ADW-Generators-Plugin)
- API REST de ACS: <https://support.hyland.com/r/Alfresco/Alfresco-Content-Services-Community-Edition/25.2/Alfresco-Content-Services-Community-Edition/Develop/REST-API-Guide>

## Blogs y comunidad

- Hyland Connect, "Modernizing Your Alfresco Front-End Development with Nx" (29-09-2025):
  <https://connect.hyland.com/t5/alfresco-blog/modernizing-your-alfresco-front-end-development-with-nx/ba-p/493363>.
  Cubre app vacía, template app, extensión de ACA, extensión de ADW y recetas. Ojo: en sus comandos
  falta `@alfresco` en `nx generate /adf-generators:...`.
- Comunidad de Alfresco (foros y blog): <https://connect.hyland.com> → sección Alfresco.

## Paquetes npm

- `@alfresco/adf-core`, `@alfresco/adf-content-services`, `@alfresco/adf-process-services`,
  `@alfresco/adf-process-services-cloud`, `@alfresco/adf-extensions`, `@alfresco/adf-insights`
- `@alfresco/js-api`
- `@alfresco/adf-generators`, `@alfresco/aca-generators`, `@alfresco/adw-generators`
- `generator-alfresco-adf-app` (Yeoman, obsoleto)

Consultas útiles:

```bash
npm view @alfresco/adf-core dist-tags
npm view @alfresco/adf-core versions --json
npm view @alfresco/adf-core@9.0.0 peerDependencies
npm view @angular/cli dist-tags
npm view @angular/cli@20 engines.node
```

## Herramientas

- Angular, versiones y soporte: <https://angular.dev/reference/versions>
- Angular, guía de actualización: <https://angular.dev/update-guide>
- Nx: <https://nx.dev/getting-started/intro>
- nvm-windows: <https://github.com/coreybutler/nvm-windows> · nvm-sh: <https://github.com/nvm-sh/nvm>
- node-gyp en Windows: <https://github.com/nodejs/node-gyp#on-windows>
- Yeoman: <https://yeoman.io>
- Docker Desktop: <https://docs.docker.com/desktop/>
