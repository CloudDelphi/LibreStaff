program librestaff;

{$mode objfpc}{$H+}

uses
  {$IFDEF UNIX}{$IFDEF UseCThreads}
  cthreads,
  {$ENDIF}{$ENDIF}
  Interfaces, // this includes the LCL widgetset
  Forms, FormMain, Classes, DataModule, DefaultTranslator,
  datetimectrls, FormPrgBar, Controls;

{$R *.res}

begin
  Application.Title:='LibreStaff';
  RequireDerivedFormResource:= True;
  Application.Initialize;
  Screen.Cursor:= crHourglass;
  Application.CreateForm(TDataMod, DataMod);
  //The progress bar to show the database load:
  FrmPrgBar:= TFrmPrgBar.Create(nil);
  FrmPrgBar.ShowOnTop;
  Application.CreateForm(TFrmMain, FrmMain);
  Application.Run;
end.

