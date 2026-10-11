import { Component, inject } from '@angular/core';
import { ActivatedRoute, Router } from '@angular/router';
import { AlfrescoViewerComponent } from '@alfresco/adf-content-services';

@Component({
  selector: 'app-file-view-page',
  imports: [AlfrescoViewerComponent],
  template: `<adf-alfresco-viewer [nodeId]="nodeId" [showViewer]="true" [overlayMode]="true" (showViewerChange)="close()" />`
})
export class FileViewPage {
  private router = inject(Router);
  nodeId = inject(ActivatedRoute).snapshot.paramMap.get('nodeId') ?? '';

  close() {
    this.router.navigate(['/documents']);
  }
}
