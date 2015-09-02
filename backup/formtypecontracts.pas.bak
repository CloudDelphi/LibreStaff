unit FormTypeContracts;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, DBGrids,
  Buttons, FrameAddDelEdiSavCan;

type

  { TFrmTypeContracts }

  TFrmTypeContracts = class(TForm)
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
  end;

var
  FrmTypeContracts: TFrmTypeContracts;

implementation

{$R *.lfm}

uses
  FuncData, DataModule, FormMain;

{ TFrmTypeContracts }

procedure TFrmTypeContracts.BtnCancelClick(Sender: TObject);
begin
  Close;
end;

procedure TFrmTypeContracts.BtnAddClick(Sender: TObject);
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
    end;
end;

procedure TFrmTypeContracts.BtnDeleteClick(Sender: TObject);
var
  NameTypeContract: String;
begin
  NameTypeContract:= DataMod.QueTypeContracts.FieldByName('Name_TypeContract').AsString;
	FuncData.DeleteTableRecord(DataMod.QueTypeContracts, True, NameTypeContract);
end;

procedure TFrmTypeContracts.BtnEditClick(Sender: TObject);
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

procedure TFrmTypeContracts.BtnSaveClick(Sender: TObject);
begin
  FuncData.SaveTable(DataMod.QueTypeContracts);
  Close;
end;

end.

