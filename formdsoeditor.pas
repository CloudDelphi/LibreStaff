unit FormDsoEditor;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, DBGrids,
  Buttons, FrameAddDelEdiSavCan, db, sqldb, FormMain, Globals, LCLType;

type TTableEdit = record
    What: TWhatTable;
    Table: TSQLQuery;
    Datasource: TDatasource;
    FieldCount: Integer;
    FieldNames: array of String;
end;
type
  { TFrmDsoEditor }
  TFrmDsoEditor = class(TForm)
    DBGrd: TDBGrid;
    FraAddDelEdiSavCan1: TFraAddDelEdiSavCan;
    procedure BtnAddClick(Sender: TObject);
    procedure BtnCancelClick(Sender: TObject);
    procedure BtnDeleteClick(Sender: TObject);
    procedure BtnEditClick(Sender: TObject);
    procedure BtnSaveClick(Sender: TObject);
    procedure DBGrdCellClick(Column: TColumn);
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
  Of_LblNavRec= 'of';
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
  Form_Caption_Users= 'User';
  Col_Title_Users= 'Name';
  Col_Title_Passwords= 'Password';
  Add_IptBox_Caption_Users= 'Add user';
  Add_IptBox_Prompt_Users= 'Name:';
  Add_IptBox_Caption_Passwords= 'Enter a password for this user';
  Add_IptBox_Prompt_Passwords= 'Password:';
  Edit_IptBox_Caption_Users= 'Change the name of the user';
  Edit_IptBox_Prompt_Users= 'Name:';
  Edit_IptBox_Caption_Passwords= 'Change the password';
  Edit_IptBox_Prompt_Passwords= 'Password:';
  No_Delete_SUPERUSER= 'This user cannot be deleted!';
  No_Edit_SUPERUSER= 'The name of this user cannot be edited!';
  User_Exists= 'This user already exists!';
  Blank_Value= 'Blank not allowed!';

implementation

{$R *.lfm}

uses
  FuncData, DataModule;

{ TFrmDsoEditor }

procedure TFrmDsoEditor.UpdateNavRec;
begin
  CurrentRec:= TableEdit.Table.RecNo;
  FraAddDelEdiSavCan1.LblNavRec.Caption:= IntToStr(CurrentRec) + ' '+ Of_LblNavRec +' '+ IntToStr(TotalRecs);
  TableEdit.Table.Edit;
end;

function TFrmDsoEditor.EditTable(WhatTable: TWhatTable): Boolean;
var
  i: Integer;
begin
  with TFrmDsoEditor.Create(Application) do
  try
    Case WhatTable of
    	wtTypeContracts:
        begin
        Caption:= Form_Caption_TypeContracts;
        TableEdit.What:= wtTypeContracts;
        TableEdit.Datasource:= DataMod.DsoTypeContracts;
        TableEdit.FieldCount:= 1;
        TableEdit.Table:= DataMod.QueTypeContracts;
        SetLength(TableEdit.FieldNames, TableEdit.FieldCount);
        TableEdit.FieldNames[0]:= 'Name_TypeContract';
     		DBGrd.Columns[0].Title.Caption:= Col_Title_TypeContracts;
				end;
      wtWorkplaces:
        begin
        Caption:= Form_Caption_Workplaces;
        TableEdit.What:= wtWorkplaces;
        TableEdit.Datasource:= DataMod.DsoWorkplaces;
        TableEdit.FieldCount:= 1;
        TableEdit.Table:= DataMod.QueWorkplaces;
        SetLength(TableEdit.FieldNames, TableEdit.FieldCount);
        TableEdit.FieldNames[0]:= 'Name_Workplace';
     		DBGrd.Columns[0].Title.Caption:= Col_Title_Workplaces;
        end;
      wtUsers:
        begin
      	Caption:= Form_Caption_Users;
        TableEdit.What:= wtUsers;
        TableEdit.Datasource:= DataMod.DsoUsers;
        TableEdit.FieldCount:= 2;
        TableEdit.Table:= DataMod.QueUsers;
        SetLength(TableEdit.FieldNames, TableEdit.FieldCount);
        TableEdit.FieldNames[0]:= 'Name_User';
     		DBGrd.Columns[0].Title.Caption:= Col_Title_Users;
        DBGrd.Columns.Add;
        TableEdit.FieldNames[1]:= 'Password_User';
        DBGrd.Columns[1].Title.Caption:= Col_Title_Passwords;
        end;
    end; //case
  	DBGrd.Datasource:= TableEdit.Datasource;
    for i:=0 to (TableEdit.FieldCount-1) do
    	begin
	    DBGrd.Columns[i].FieldName:= TableEdit.FieldNames[i];
      end;
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
  i: Integer;
  Error: Boolean= FALSE;
  ErrorMsg: String;
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
  SetLength(WriteFields, TableEdit.FieldCount);
  for i:=0 to (TableEdit.FieldCount-1) do
    begin
	  if (TableEdit.What= wtUsers) then
	  	begin
  	  case i of
    		0:	begin
						InpBox_Caption:= Add_IptBox_Caption_Users;
      			InpBox_Prompt:= Add_IptBox_Prompt_Users;
		      	end;
	      1:	begin
				    InpBox_Caption:= Add_IptBox_Caption_Passwords;
    	  		InpBox_Prompt:= Add_IptBox_Prompt_Passwords;
		  	    end;
	    end; //case
  		end;
	  FieldValue:= InputBox(InpBox_Caption, InpBox_Prompt, '');
    if FieldValue='' then
    	begin
	    Error:= TRUE;
  	  ErrorMsg:= Blank_Value;
      break; //terminate the 'for' loop
    	end
		else if (TableEdit.What= wtUsers) then
   		begin
	    if FuncData.CheckValueExists('Users','Name_User',FieldValue)= TRUE then
  	    begin
			  Error:= TRUE;
	   		ErrorMsg:= User_Exists;
        break; //terminate the 'for' loop
	      end;
  	  end;
   	WriteFields[i].FieldName:= TableEdit.FieldNames[i];
 	 	WriteFields[i].Value:= FieldValue;
 		WriteFields[i].DataFormat:= dtString;
    end;
  if (Error= FALSE) then
  	begin
 		FuncData.AppendTableRecord(TableEdit.Table, WriteFields);
	  Inc(TotalRecs);
 		UpdateNavRec;
  	end
	else
		begin
		Application.MessageBox(PChar(ErrorMsg), 'Error!', MB_OK);
    end;
	WriteFields:= nil;
end;

procedure TFrmDsoEditor.BtnDeleteClick(Sender: TObject);
var
  FieldValue: String;
begin
  FieldValue:= TableEdit.Table.FieldByName(TableEdit.FieldNames[0]).AsString;
  if (TableEdit.What= wtUsers) then //Don't delete SUPERUSER
    begin
    if FieldValue= SUPERUSER_NAME then
      begin
      Application.MessageBox(PChar(No_Delete_SUPERUSER), 'Error!', MB_OK);
      Exit;
      end;
    end;
  FuncData.DeleteTableRecord(TableEdit.Table, True, FieldValue);
  Dec(TotalRecs);
  UpdateNavRec;
end;

procedure TFrmDsoEditor.BtnEditClick(Sender: TObject);
var
  FieldValue, FirstFieldValue: String;
  InpBox_Caption, InpBox_Prompt: String;
  ColIdx: Integer;
  Error: Boolean= FALSE;
  ErrorMsg: String;
const
  WriteFieldsCount= 1;
begin
  ColIdx:= DBGrd.SelectedColumn.Index;
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
    wtUsers:
      begin
      case ColIdx of
        0:	begin
      			InpBox_Caption:= Edit_IptBox_Caption_Users;
	      		InpBox_Prompt:= Edit_IptBox_Prompt_Users;
		        end;
        1:	begin
      			InpBox_Caption:= Edit_IptBox_Caption_Passwords;
	      		InpBox_Prompt:= Edit_IptBox_Prompt_Passwords;
		        end;
      end;
      end;
  end; //case
  if (TableEdit.What= wtUsers) and (ColIdx=0) then //Don't edit SUPERUSER
    begin
  	FirstFieldValue:= TableEdit.Table.FieldByName(TableEdit.FieldNames[0]).AsString;
    if FirstFieldValue= SUPERUSER_NAME then
      begin
      Error:= TRUE;
      ErrorMsg:= No_Edit_SUPERUSER;
      Application.MessageBox(PChar(ErrorMsg), 'Error!', MB_OK);
      Exit;
      end;
    end;
  FieldValue:= InputBox(InpBox_Caption, InpBox_Prompt, TableEdit.Table.FieldByName(TableEdit.FieldNames[ColIdx]).AsString);
  if FieldValue='' then
    begin
    Error:= TRUE;
    ErrorMsg:= Blank_Value;
    end
  else if (TableEdit.What= wtUsers) then
   	begin
    if FuncData.CheckValueExists('Users','Name_User',FieldValue,'ID_User',DataMod.DsoUsers.DataSet.FieldByName('ID_User').AsString)= TRUE then
      begin
		  Error:= TRUE;
	   	ErrorMsg:= User_Exists;
      end;
    end;
	if (Error= FALSE) then
  	begin
	  SetLength(WriteFields, WriteFieldsCount);
  	WriteFields[0].FieldName:= TableEdit.FieldNames[ColIdx];
	  WriteFields[0].Value:= FieldValue;
		WriteFields[0].DataFormat:= dtString;
	  FuncData.EditTableRecord(TableEdit.Table, WriteFields);
  	end
	else
		begin
		Application.MessageBox(PChar(ErrorMsg), 'Error!', MB_OK);
    end;
	WriteFields:= nil;
end;

procedure TFrmDsoEditor.BtnSaveClick(Sender: TObject);
begin
  FuncData.SaveTable(TableEdit.Table);
  Close;
end;

procedure TFrmDsoEditor.DBGrdCellClick(Column: TColumn);
begin
  UpdateNavRec;
end;

end.

