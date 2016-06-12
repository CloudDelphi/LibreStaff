unit FormListEditor;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, ExtCtrls,
  StdCtrls, Buttons, DbCtrls, FormMain;

type

  { TFrmListEditor }

  TFrmListEditor = class(TForm)
    BtnSaveList: TBitBtn;
    MmoList: TMemo;
    Panel1: TPanel;
    BtnClose: TSpeedButton;
    BtnSortList: TSpeedButton;
    procedure BtnCloseClick(Sender: TObject);
    procedure BtnSortListClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    { private declarations }
  public
    { public declarations }
    function EditList(const Title, Filename: string; Combo: TCboListType): Boolean;
  end;

var
  FrmListEditor: TFrmListEditor;

implementation

{$R *.lfm}

uses
  DataModule;

function TFrmListEditor.EditList(const Title, Filename: string; Combo: TCboListType): Boolean;
begin
  with TFrmListEditor.Create(Application) do
  try
    Caption:= Title;
    {Cargo la lista-->}
    MmoList.Lines.LoadFromFile(Filename);
    Result:= ShowModal = mrOK;
    if Result then
      begin
      MmoList.Lines.SaveToFile(Filename);
      Case Combo of
        cblStates: FrmMain.DBCboState.Items.LoadFromFile(Filename);
      end;
      end;
  finally
    FrmListEditor.Free;
    FrmListEditor:= nil;
  end;
end;
//------------------------------------------------------------------------------
procedure TFrmListEditor.FormCreate(Sender: TObject);
begin
  DataMod.ImgLstBtn.GetBitmap(3, BtnSaveList.Glyph);
  DataMod.ImgLstBtn.GetBitmap(2, BtnClose.Glyph);
  DataMod.ImgLstBtn.GetBitmap(7, BtnSortList.Glyph);
end;
//------------------------------------------------------------------------------
procedure TFrmListEditor.BtnSortListClick(Sender: TObject);
var
  List: TStringList;
begin
  List:= TStringList.Create;
  List.Assign(MmoList.Lines);
  List.Sort;
  MmoList.Lines.Assign(List);
  List.Free;
end;
procedure TFrmListEditor.BtnCloseClick(Sender: TObject);
begin
  Close;
end;

end.

