unit FuncDlgs;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, DataModule;

function OpenDlg(Title:string; Filter:string; InitPath: String; Filename:string):
         Boolean;
function SelectDirDlg(Title:string; InitPath: String):
        Boolean;
function SaveDlg(Title:string; Filter:string; InitPath: String; Filename:string):
         Boolean;

implementation

function OpenDlg(Title:string; Filter:string; InitPath: String; Filename:string):
         Boolean;
begin
  DataMod.OpenDlg.Title:= Title;
  DataMod.OpenDlg.Filter:= Filter;
  DataMod.OpenDlg.FileName:= Filename;
  DataMod.OpenDlg.InitialDir:= InitPath;
  Result:= DataMod.OpenDlg.Execute;
end;
function SelectDirDlg(Title:string; InitPath: String):
        Boolean;
begin
 DataMod.SelectDirDlg.Title:= Title;
 DataMod.SelectDirDlg.InitialDir:= InitPath;
 Result:= DataMod.SelectDirDlg.Execute;
end;
 function SaveDlg(Title:string; Filter:string; InitPath: String; Filename:string):
         Boolean;
begin
  DataMod.SaveDlg.Title:= Title;
  DataMod.SaveDlg.Filter := Filter;
  DataMod.SaveDlg.FileName:= Filename;
  DataMod.SaveDlg.InitialDir:= InitPath;
  Result:= DataMod.SaveDlg.Execute;
end;

end.

