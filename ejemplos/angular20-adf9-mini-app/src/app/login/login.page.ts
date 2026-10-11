import { Component } from '@angular/core';
import { LoginComponent } from '@alfresco/adf-core';

@Component({
  selector: 'app-login-page',
  imports: [LoginComponent],
  template: `<adf-login successRoute="/documents" copyrightText="Onboarding ADF"></adf-login>`
})
export class LoginPage {}
