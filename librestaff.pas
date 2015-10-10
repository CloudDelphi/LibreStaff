program librestaff;

{$mode objfpc}{$H+}

uses
  {$IFDEF UNIX}{$IFDEF UseCThreads}
  cthreads,
  {$ENDIF}{$ENDIF}
  Interfaces, // this includes the LCL widgetset
  Forms, Classes, DataModule, DefaultTranslator,
  Controls, FormMain, FormPrgBar, uniqueinstance_package;

{$R *.res}

begin
  Application.Title:='LibreStaff';
  RequireDerivedFormResource:= True;
  Application.Initialize;
  Screen.Cursor:= crHourglass;
  //The progress bar to show the database load:
  FrmPrgBar:= TFrmPrgBar.Create(Application);
  FrmPrgBar.ShowOnTop;
  //DataMod must be created first than the Main Form!
  Application.CreateForm(TDataMod, DataMod);
  Application.CreateForm(TFrmMain, FrmMain);
  Application.Run;
end.

