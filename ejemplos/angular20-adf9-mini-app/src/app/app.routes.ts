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
