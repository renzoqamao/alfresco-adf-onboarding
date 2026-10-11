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
    provideRouter(routes, withHashLocation()),
    provideAppConfig(),
    provideI18N(),
    provideCoreAuth(),
    importProvidersFrom(ContentModule.forRoot())
  ],
  bootstrap: [App]
})
export class AppModule {}
