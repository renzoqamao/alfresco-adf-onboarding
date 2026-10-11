# 08 · Extender ADW (Alfresco Digital Workspace) — solo Enterprise

[⬅ Tutorial mini app](07-tutorial-mini-app.md) · [Índice](../README.md) · [Siguiente: Conceptos clave ➡](09-conceptos-clave.md)

ADW es la versión **Enterprise** de ACA. Su código fuente **no es público**: se descarga desde el
portal de Hyland con una cuenta de cliente Enterprise.

> **No comprobado** en este repositorio, porque requiere credenciales Enterprise. Los pasos vienen del
> blog de Hyland (que usa **ADW 7.1.0**) y del README de `alfresco-front-end-generators`.

## Requisitos

| Requisito | Versión |
|---|---|
| Licencia / cuenta Hyland Enterprise | Para descargar el código de ADW |
| Node.js | El del `.nvmrc` del código descargado (para ADW 8.x, previsiblemente 24.x como ACA 8) |
| npm | El que trae ese Node |
| ACS Enterprise | Compatible con la versión de ADW |

## Pasos

```powershell
# 1. Descargar y extraer el código fuente de ADW (portal de Hyland)
cd adw
type .nvmrc ; nvm use <versión>

# 2. .env en la raíz
#    BASE_URL="http://localhost:8080"
#    APP_CONFIG_PROVIDER="ECM"
#    APP_CONFIG_AUTH_TYPE="BASIC"
#    BASE_PATH="./"
#    APP_CONFIG_PLUGIN_PROCESS_SERVICE=false
#    APP_CONFIG_PLUGIN_MICROSOFT_ONLINE=false
#    Si no se aplica, editar directamente app.config.json.

# 3. Dependencias + plugin
npm install
npx nx add @alfresco/adw-generators

# 4. Generar una extensión
npx nx g @alfresco/adw-generators:adw-extension
#   ? What name would you like to use?                         → ext
#   ? What should be the directory name for the new library?   → ext

# 5. Ejecutar
npm install
npm start content-ee            # → http://localhost:4200
```

El generador crea `libs/content-ee/ext/...` y actualiza
`apps/content-ee/src/app/extensions.module.ts`, `apps/content-ee/project.json` y
`tsconfig.base.json`. Al iniciar sesión aparece un ítem nuevo en el menú que lleva a `#/ext`.

## ADW frente a ACA

| | ACA | ADW |
|---|---|---|
| Licencia | Open source (LGPL) | Enterprise |
| Código | GitHub público | Portal de Hyland |
| Proyecto Nx | `content-ce` | `content-ee` |
| Extensiones | `projects/<ext>` | `libs/content-ee/<ext>` |
| Generador | `@alfresco/aca-generators:aca-extension` | `@alfresco/adw-generators:adw-extension` |

Para practicar el modelo de extensiones sin licencia, usar [ACA](05-aca.md#crear-una-extensión-de-aca-con-nx).

## Referencias

- Blog Hyland, sección "Extending ADW": <https://connect.hyland.com/t5/alfresco-blog/modernizing-your-alfresco-front-end-development-with-nx/ba-p/493363>
- docs.hyland.com:
  - [Installing the ADW Generators Plugin](https://docs.hyland.com/r/Alfresco/Alfresco-Digital-Workspace/8.0/Alfresco-Digital-Workspace/Develop/Deploy-front-end-applications/Generate-and-Deploy-an-ADF-App/Installing-the-ADW-Generators-Plugin)
  - [Generating the ADW Extension](https://docs.hyland.com/r/Alfresco/Alfresco-Digital-Workspace/8.0/Alfresco-Digital-Workspace/Develop/Deploy-front-end-applications/Generate-and-Deploy-an-ADF-App/Installing-the-ADW-Generators-Plugin/Generating-the-ADW-Extension)
- Generadores: <https://github.com/Alfresco/alfresco-front-end-generators>
