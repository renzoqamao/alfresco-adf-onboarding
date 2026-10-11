import { Component, ViewChild } from '@angular/core';
import { Router } from '@angular/router';
import { NodeEntityEvent } from '@alfresco/adf-content-services';
import { BreadcrumbComponent, DocumentListComponent, UploadButtonComponent } from '@alfresco/adf-content-services';

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
