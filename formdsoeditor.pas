unit FormDsoEditor;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, DBGrids,
  Buttons, FrameAddDelEdiSavCan, db, sqldb, FormMain;

type TTableEdit = record
    What: TWhatTable;
    Table: TSQLQuery;
    Datasource: TDatasource;
    FieldName: String;
end;
type
  { TFrmDsoEditor }
  TFrmDsoEditor = class(TForm)
    DBGrdTypeContracts: TDBGrid;
    FraAddDelEdiSavCan1: TFraAddDelEdiSavCan;
    procedure BtnAddClick(Sender: TObject);
    procedure BtnCancelClick(Sender: TObject);
    procedure BtnDeleteClick(Sender: TObject);
    procedure BtnEditClick(Sender: TObject);
    procedure BtnSaveClick(Sender: TObject);
    procedure DBGrdTypeContractsCellClick(Column: TColumn);
    procedure PanBottomClick(Sender: TObject);
  private
    { private declarations }
    CurrentRec, TotalRecs: Integer;
    procedure UpdateNavRec;
  public
    { public declarations }
  	function EditTable(WhatTable: TWhatTable): Boolean;
  end;

var
  FrmDsoEditor: TFrmDsoEditor;
  TableEdit: TTableEdit;

resourcestring
  Form_Caption_TypeContracts= 'Type of Contract';
  Col_Title_TypeContracts= 'Name';
  Add_IptBox_Caption_TypeContracts= 'Add type of contract';
  Add_IptBox_Prompt_TypeContracts= 'Name:';
  Edit_IptBox_Caption_TypeContracts= 'Change the name of contract';
  Edit_IptBox_Prompt_TypeContracts= 'Name:';
  Form_Caption_Workplaces= 'Workplace';
  Col_Title_Workplaces= 'Name';
  Add_IptBox_Caption_Workplaces= 'Add workplace';
  Add_IptBox_Prompt_Workplaces= 'Name:';
  Edit_IptBox_Caption_Workplaces= 'Change the name of workplace';
  Edit_IptBox_Prompt_Workplaces= 'Name:';

implementation

{$R *.lfm}

uses
  FuncData, DataModule;

{ TFrmDsoEditor }

procedure TFrmDsoEditor.UpdateNavRec;
begin
  CurrentRec:= TableEdit.Table.RecNo;
  FraAddDelEdiSavCan1.LblNavRec.Caption:= IntToStr(CurrentRec) + ' '+'of' +' '+ IntToStr(TotalRecs);
  TableEdit.Table.Edit;
end;

function TFrmDsoEditor.EditTable(WhatTable: TWhatTable): Boolean;
begin
  with TFrmDsoEditor.Create(Application) do
  try
    Case WhatTable of
    	wtTypeContracts:
        begin
        Caption:= Form_Caption_TypeContracts;
     		DBGrdTypeContracts.Columns[0].Title.Caption:= Col_Title_TypeContracts;
        TableEdit.What:= wtTypeContracts;
        TableEdit.Datasource:= DataMod.DsoTypeContracts;
        TableEdit.Table:= DataMod.QueTypeContracts;
        TableEdit.FieldName:= 'Name_TypeContract';
				end;
      wtWorkplaces:
        begin
        Caption:= Form_Caption_Workplaces;
     		DBGrdTypeContracts.Columns[0].Title.Caption:= Col_Title_Workplaces;
        TableEdit.What:= wtWorkplaces;
        TableEdit.Datasource:= DataMod.DsoWorkplaces;
        TableEdit.Table:= DataMod.QueWorkplaces;
        TableEdit.FieldName:= 'Name_Workplace';
        end;
    end; //case
  	DBGrdTypeContracts.Datasource:= TableEdit.Datasource;
    DBGrdTypeContracts.Columns[0].FieldName:= TableEdit.FieldName;
    //Grab the total amount of records:
		TotalRecs:= TableEdit.Table.RecordCount;
    UpdateNavRec;
		Result:= ShowModal = mrOK;
  finally
    FrmDsoEditor.Free;
    FrmDsoEditor:= nil;
  end;
end;

procedure TFrmDsoEditor.BtnCancelClick(Sender: TObject);
begin
  Close;
end;

procedure TFrmDsoEditor.BtnAddClick(Sender: TObject);
var
  FieldValue: String;
  InpBox_Caption, InpBox_Prompt: String;
const
  WriteFieldsCount= 1;
begin
  case TableEdit.What of
    wtTypeContracts:
      begin
      InpBox_Caption:= Add_IptBox_Caption_TypeContracts;
      InpBox_Prompt:= Add_IptBox_Prompt_TypeContracts;
      end;
    wtWorkplaces:
      begin
      InpBox_Caption:= Add_IptBox_Caption_Workplaces;
      InpBox_Prompt:= Add_IptBox_Prompt_Workplaces;
      end;
  end; //case
  FieldValue:= InputBox (InpBox_Caption, InpBox_Prompt, '');
  if FieldValue<>'' then
  	begin
    SetLength(WriteFields, WriteFieldsCount);
   	WriteFields[0].FieldName:= TableEdit.FieldName;
   	WriteFields[0].Value:= FieldValue;
  	WriteFields[0].DataFormat:= dtString;
	  FuncData.AppendTableRecord(TableEdit.Table, WriteFields);
    Inc(TotalRecs);
    UpdateNavRec;
    WriteFields:= nil;
    end;
end;

procedure TFrmDsoEditor.BtnDeleteClick(Sender: TObject);
var
  FieldValue: String;
begin
  FieldValue:= TableEdit.Table.FieldByName(TableEdit.FieldName).AsString;
	FuncData.DeleteTableRecord(TableEdit.Table, True, FieldValue);
  Dec(TotalRecs);
  UpdateNavRec;
end;

procedure TFrmDsoEditor.BtnEditClick(Sender: TObject);
var
  FieldValue: String;
  InpBox_Caption, InpBox_Prompt: String;
const
  WriteFieldsCount= 1;
begin
  case TableEdit.What of
    wtTypeContracts:
      begin
      InpBox_Caption:= Edit_IptBox_Caption_TypeContracts;
      InpBox_Prompt:= Edit_IptBox_Prompt_TypeContracts;
      end;
    wtWorkplaces:
      begin
      InpBox_Caption:= Edit_IptBox_Caption_Workplaces;
      InpBox_Prompt:= Edit_IptBox_Prompt_Workplaces;
      end;
  end; //case
  FieldValue:= InputBox (InpBox_Caption, InpBox_Prompt, TableEdit.Table.FieldByName(TableEdit.FieldName).AsString);
  if FieldValue<>'' then
  	begin
    SetLength(WriteFields, WriteFieldsCount);
   	WriteFields[0].FieldName:= TableEdit.FieldName;
  	WriteFields[0].Value:= FieldValue;
	  WriteFields[0].DataFormat:= dtString;
  	FuncData.EditTableRecord(TableEdit.Table, WriteFields);
    end;
end;

procedure TFrmDsoEditor.BtnSaveClick(Sender: TObject);
begin
  FuncData.SaveTable(TableEdit.Table);
  Close;
end;

procedure TFrmDsoEditor.DBGrdTypeContractsCellClick(Column: TColumn);
begin
  UpdateNavRec;
end;

procedure TFrmDsoEditor.PanBottomClick(Sender: TObject);
begin

end;

end.

