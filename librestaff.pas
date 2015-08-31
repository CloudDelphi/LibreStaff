program librestaff;

{$mode objfpc}{$H+}

uses
  {$IFDEF UNIX}{$IFDEF UseCThreads}
  cthreads,
  {$ENDIF}{$ENDIF}
  Interfaces, // this includes the LCL widgetset
  Forms, formmain, funcdata, Classes, DataModule, DefaultTranslator,
  FormPreferences, frameclose;

{$R *.res}

begin
  Application.Title:='LibreStaff';
  RequireDerivedFormResource:= True;
  Application.Initialize;
  Application.CreateForm(TDataMod, DataMod);
  Application.CreateForm(TFrmMain, FrmMain);
  Application.Run;
end.

