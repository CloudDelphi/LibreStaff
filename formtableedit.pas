unit FormTableEdit;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, DBGrids,
  Buttons, FrameAddDelEdiSavCan, db;

type

  { TFrmTableEdit }

  TFrmTableEdit = class(TForm)
    DBGrdTypeContracts: TDBGrid;
    FraAddDelEdiSavCan1: TFraAddDelEdiSavCan;
    procedure BtnAddClick(Sender: TObject);
    procedure BtnCancelClick(Sender: TObject);
    procedure BtnDeleteClick(Sender: TObject);
    procedure BtnEditClick(Sender: TObject);
    procedure BtnSaveClick(Sender: TObject);
  private
    { private declarations }
  public
    { public declarations }
    function EditTable(FormTitle, Title, FieldName: String; Datasource: TDatasource): Boolean;
  end;

var
  FrmTableEdit: TFrmTableEdit;

implementation

{$R *.lfm}

uses
  FuncData, DataModule, FormMain;

{ TFrmTableEdit }

function TFrmTableEdit.EditTable(FormTitle, Title, FieldName: String; Datasource: TDatasource): Boolean;
begin
  with TFrmTableEdit.Create(Application) do
  try
    Caption:= FormTitle;
    DBGrdTypeContracts.Datasource:= Datasource;
    DBGrdTypeContracts.Columns[0].Title.Caption:= Title;
    DBGrdTypeContracts.Columns[0].FieldName:= FieldName;
    Result:= ShowModal = mrOK;
  finally
    FrmTableEdit.Free;
    FrmTableEdit:= nil;
  end;
end;

procedure TFrmTableEdit.BtnCancelClick(Sender: TObject);
begin
  Close;
end;

procedure TFrmTableEdit.BtnAddClick(Sender: TObject);
var
  NameTypeContract: String;
const
  WriteFieldsCount= 1;
begin
  NameTypeContract:= InputBox ('Add type of contract', 'Name:', '');
  if NameTypeContract<>'' then
  	begin
    SetLength(WriteFields, WriteFieldsCount);
   	WriteFields[0].FieldName:= 'Name_TypeContract';
   	WriteFields[0].Value:= NameTypeContract;
  	WriteFields[0].DataFormat:= dtString;
	  FuncData.AppendTableRecord(DataMod.QueTypeContracts, WriteFields);
    WriteFields:= nil;
    end;
end;

procedure TFrmTableEdit.BtnDeleteClick(Sender: TObject);
var
  NameTypeContract: String;
begin
  NameTypeContract:= DataMod.QueTypeContracts.FieldByName('Name_TypeContract').AsString;
	FuncData.DeleteTableRecord(DataMod.QueTypeContracts, True, NameTypeContract);
end;

procedure TFrmTableEdit.BtnEditClick(Sender: TObject);
var
  NameTypeContract: String;
const
  WriteFieldsCount= 1;
begin
  NameTypeContract:= InputBox ('Change the name of contract', 'Name:', DataMod.QueTypeContracts.FieldByName('Name_TypeContract').AsString);
  if NameTypeContract<>'' then
  	begin
    SetLength(WriteFields, WriteFieldsCount);
   	WriteFields[0].FieldName:= 'Name_TypeContract';
  	WriteFields[0].Value:= NameTypeContract;
	  WriteFields[0].DataFormat:= dtString;
  	FuncData.EditTableRecord(DataMod.QueTypeContracts, WriteFields);
    end;
end;

procedure TFrmTableEdit.BtnSaveClick(Sender: TObject);
begin
  FuncData.SaveTable(DataMod.QueTypeContracts);
  Close;
end;

end.

