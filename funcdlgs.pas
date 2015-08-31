unit FuncDlgs;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FormMain;

function OpenDlg(Title:string; Filter:string; InitPath: String; Filename:string):
         Boolean;
function SaveDlg(Title:string; Filter:string; InitPath: String; Filename:string):
         Boolean;

implementation

function OpenDlg(Title:string; Filter:string; InitPath: String; Filename:string):
         Boolean;
begin
  FrmMain.OpenDlg.Title:= Title;
  FrmMain.OpenDlg.Filter := Filter;
  FrmMain.OpenDlg.FileName:= Filename;
  FrmMain.OpenDlg.InitialDir:= InitPath;
  Result:= FrmMain.OpenDlg.Execute;
end;
 function SaveDlg(Title:string; Filter:string; InitPath: String; Filename:string):
         Boolean;
begin
  FrmMain.SaveDlg.Title:= Title;
  FrmMain.SaveDlg.Filter := Filter;
  FrmMain.SaveDlg.FileName:= Filename;
  FrmMain.SaveDlg.InitialDir:= InitPath;
  Result:= FrmMain.SaveDlg.Execute;
end;

end.

