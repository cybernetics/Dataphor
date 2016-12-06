import { NgModule } from '@angular/core';
import { RouterModule } from '@angular/router';
import { FormsModule} from '@angular/forms';
import { UniversalModule } from 'angular2-universal';
import { AceEditorDirective } from 'ng2-ace-editor';
import { AppComponent } from './components/app/app.component'
import { HomeComponent } from './components/home/home.component';
import { SharedModule } from './shared/shared.module';

@NgModule({
    bootstrap: [ AppComponent ],
    declarations: [
        AppComponent,
        HomeComponent,
        AceEditorDirective
    ],
    imports: [
        UniversalModule, // Must be first import. This automatically imports BrowserModule, HttpModule, and JsonpModule too.
        FormsModule,
        RouterModule.forRoot([
            { path: '', redirectTo: 'home', pathMatch: 'full' },
            { path: 'home', component: HomeComponent },
            { path: '**', redirectTo: 'home' }
        ]),
        SharedModule.forRoot()
    ]
})
export class AppModule {
}
