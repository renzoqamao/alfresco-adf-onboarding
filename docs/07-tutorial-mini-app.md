# 07 · Tutorial: mini app de documentos (Angular 20 + ADF 9)

[⬅ ADF a mano](06-adf-manual.md) · [Índice](../README.md) · [Siguiente: ADW ➡](08-adw.md)

Construimos paso a paso una app con **login → lista de documentos (con breadcrumb y subida) → visor**.
El resultado final está en [`ejemplos/angular20-adf9-mini-app`](../ejemplos/angular20-adf9-mini-app).

> **Comprobado:** el ejemplo compila desde cero (`npm install` + `ng build`), y al abrir
> `/#/documents` sin sesión el guard redirige a `/#/login?redirectUrl=%2Fdocuments` sin errores en
> consola. La lista de documentos y el visor necesitan un ACS levantado para ver datos reales.

## Requisitos

- Node 24 (`nvm use 24`), npm 11.
- ACS en `http://localhost:8080` ([01-preparar-entorno.md](01-preparar-entorno.md#5-backend-acs-con-docker)).
- Haber hecho [ADF a mano con Angular 20](06-adf-manual.md#angular-20--adf-900), o partir del ejemplo.

## Opción rápida: ejecutar el ejemplo

```powershell
cd ejemplos\angular20-adf9-mini-app
nvm use 24
npm install
npm start          # http://localhost:4200 → login con admin / admin
```

## Paso a paso

### 1. Proyecto base

Seguir [Angular 20 → ADF 9.0.0](06-adf-manual.md#angular-20--adf-900) y agregar los componentes de
contenido:

```powershell
npm install @alfresco/adf-content-services@9.0.0
```

En `angular.json`, junto a los assets de `adf-core`:

```json
{ "glob": "**/*", "input": "node_modules/@alfresco/adf-content-services/bundles/assets", "output": "/assets" }
```

### 2. Rutas protegidas

`src/app/app.routes.ts`:

```ts
import { Routes } from '@angular/router';
import { AuthGuardEcm } from '@alfresco/adf-core';
import { LoginPage } from './login/login.page';
import { DocumentsPage } from './documents/documents.page';
import { FileViewPage } from './file-view/file-view.page';

export const routes: Routes = [
  { path: '', redirectTo: 'documents', pathMatch: 'full' },
  { path: 'login', component: LoginPage },
  { path: 'documents', component: DocumentsPage, canActivate: [AuthGuardEcm] },
  { path: 'view/:nodeId', component: FileViewPage, canActivate: [AuthGuardEcm] }
];
```

- **`AuthGuardEcm`**: si no hay sesión en ACS, redirige a la ruta `loginRoute` de `app.config.json`
  (`login`) y agrega `?redirectUrl=...`.
- Otros guards: `AuthGuardBpm` (APS), `AuthGuard` (cualquiera), `AuthGuardSsoRoleService` (roles).

### 3. Providers

`src/app/app-module.ts`:

```ts
import { NgModule, importProvidersFrom, provideZoneChangeDetection } from '@angular/core';
import { BrowserModule } from '@angular/platform-browser';
import { provideAnimations } from '@angular/platform-browser/animations';
import { RouterOutlet, provideRouter, withHashLocation } from '@angular/router';
import { provideAppConfig, provideCoreAuth, provideI18N } from '@alfresco/adf-core';
import { ContentModule } from '@alfresco/adf-content-services';
import { App } from './app';
import { routes } from './app.routes';

@NgModule({
  declarations: [App],
  imports: [BrowserModule, RouterOutlet],
  providers: [
    provideZoneChangeDetection({ eventCoalescing: true }),
    provideAnimations(),
    provideRouter(routes, withHashLocation()),   // URLs con # como ACA (evita configurar el servidor)
    provideAppConfig(),                          // carga /app.config.json
    provideI18N(),                               // traducciones de ADF
    provideCoreAuth(),                           // autenticación BASIC/OAuth según app.config.json
    importProvidersFrom(ContentModule.forRoot()) // servicios de adf-content-services
  ],
  bootstrap: [App]
})
export class AppModule {}
```

`src/app/app.html`: `<router-outlet />`

### 4. Login

`src/app/login/login.page.ts`:

```ts
import { Component } from '@angular/core';
import { LoginComponent } from '@alfresco/adf-core';

@Component({
  selector: 'app-login-page',
  imports: [LoginComponent],
  template: `<adf-login successRoute="/documents" copyrightText="Onboarding ADF"></adf-login>`
})
export class LoginPage {}
```

Propiedades útiles de `<adf-login>`: `successRoute`, `logoImageUrl`, `backgroundImageUrl`,
`showRememberMe`, `showLoginActions`, `copyrightText`, y los eventos `(success)` y `(error)`. Ver la
[documentación del componente](https://github.com/Alfresco/alfresco-ng2-components/blob/develop/docs/core/components/login.component.md).

### 5. Lista de documentos

`src/app/documents/documents.page.ts`:

```ts
import { Component, ViewChild } from '@angular/core';
import { Router } from '@angular/router';
import {
  BreadcrumbComponent, DocumentListComponent, NodeEntityEvent, UploadButtonComponent
} from '@alfresco/adf-content-services';

@Component({
  selector: 'app-documents-page',
  imports: [BreadcrumbComponent, DocumentListComponent, UploadButtonComponent],
  template: `
    <adf-breadcrumb [folderNode]="documentList.folderNode" [target]="documentList" />
    <adf-upload-button [rootFolderId]="documentList.currentFolderId" (success)="documentList.reload()" />
    <adf-document-list
      #documentList
      currentFolderId="-my-"
      [navigate]="true"
      (preview)="showPreview($event)" />
  `
})
export class DocumentsPage {
  @ViewChild('documentList', { static: true }) documentList!: DocumentListComponent;

  constructor(private router: Router) {}

  showPreview(event: NodeEntityEvent) {
    const entry = event.value.entry;
    if (entry?.isFile) {
      this.router.navigate(['/view', entry.id]);
    }
  }
}
```

- `currentFolderId`: `-my-` (Mis archivos), `-root-` (Company Home), `-shared-`, o el ID de un nodo.
- `[navigate]="true"`: doble clic en una carpeta entra en ella.
- `(preview)`: doble clic en un archivo; aquí navegamos al visor.
- `<adf-breadcrumb>` se sincroniza con la lista a través de `[target]`.
- `<adf-upload-button>` sube a la carpeta actual y al terminar recargamos la lista.

### 6. Visor

`src/app/file-view/file-view.page.ts`:

```ts
import { Component, inject } from '@angular/core';
import { ActivatedRoute, Router } from '@angular/router';
import { AlfrescoViewerComponent } from '@alfresco/adf-content-services';

@Component({
  selector: 'app-file-view-page',
  imports: [AlfrescoViewerComponent],
  template: `<adf-alfresco-viewer [nodeId]="nodeId" [showViewer]="true" [overlayMode]="true"
                                  (showViewerChange)="close()" />`
})
export class FileViewPage {
  private router = inject(Router);
  nodeId = inject(ActivatedRoute).snapshot.paramMap.get('nodeId') ?? '';

  close() {
    this.router.navigate(['/documents']);
  }
}
```

`<adf-alfresco-viewer>` descarga el contenido o el renditionado del nodo y elige el visor adecuado
(PDF, imagen, texto, media).

### 7. Probar

```powershell
npm start
```

1. `http://localhost:4200` → redirige a `/#/login?redirectUrl=%2Fdocuments`.
2. Login con `admin` / `admin` → lista de "Mis archivos".
3. Subir un PDF con el botón de upload → aparece en la lista.
4. Doble clic en el PDF → se abre el visor; al cerrarlo vuelve a la lista.
5. En DevTools → Network se ven las llamadas `/alfresco/api/-default-/public/alfresco/versions/1/nodes/...`.

## Ejercicios

1. Agregar una ruta `search` con `<adf-search-control>` y mostrar los resultados.
2. Cambiar `currentFolderId` por `-root-` y comparar.
3. Agregar columnas propias a la lista con `<data-columns>` (por ejemplo, `modifiedByUser.displayName`).
4. Agregar un menú lateral con `<adf-sidenav-layout>` (ver la receta
   [How to add new custom page](https://github.com/Alfresco/alfresco-front-end-generators/blob/main/docs/recipes/how-to-add-custom-page.md)).
5. Traducir los textos propios con `provideTranslations('app', 'assets/app')` y un `assets/app/i18n/es.json`.

## Referencias

- Componentes de contenido: <https://github.com/Alfresco/alfresco-ng2-components/tree/develop/docs/content-services/components>
- Componentes core: <https://github.com/Alfresco/alfresco-ng2-components/tree/develop/docs/core/components>
- API REST de ACS: <https://support.hyland.com/r/Alfresco/Alfresco-Content-Services-Community-Edition/25.2/Alfresco-Content-Services-Community-Edition/Develop/REST-API-Guide>
  y el explorador de la API: <https://github.com/Alfresco/rest-api-explorer>.
