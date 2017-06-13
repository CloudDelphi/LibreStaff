unit FormDsoEditor;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, DBGrids,
  Buttons, FrameAddDelEdiSavCan, db, sqldb, FormMain, Globals, LCLType,
  ExtCtrls, StdCtrls, FormInputBox, Crypt, FuncData;

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
  	function EditTable(WhatTable: TIDTable): Boolean;
  end;

var
  FrmDsoEditor: TFrmDsoEditor;
  TableEdit: TTable;

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
  Col_Title_User= 'Name';
  Col_Title_Password= 'Password (encrypted)';
  Col_Title_Usergroup= 'User Group';
  Add_IptBox_Caption_Users= 'Add user';
  Add_IptBox_Prompt_Users= 'Name:';
  Add_IptBox_Caption_Passwords= 'Enter a password for this user';
  Add_IptBox_Prompt_Passwords= 'Password:';
  Edit_IptBox_Caption_Users= 'Change the name of the user';
  Edit_IptBox_Prompt_Users= 'Name:';
  Edit_IptBox_Caption_Passwords= 'Change the password';
  Edit_IptBox_Prompt_Passwords= 'New Password:';
  No_Delete_SUPERUSER= 'This user cannot be deleted!';
  No_Edit_SUPERUSER= 'The name of this user cannot be edited!';
  Blank_Value= 'Blank not allowed!';

implementation

{$R *.lfm}

uses
  DataModule, FormEditAddUser;

{ TFrmDsoEditor }

procedure TFrmDsoEditor.UpdateNavRec;
begin
  CurrentRec:= TableEdit.Table.RecNo;
  FraAddDelEdiSavCan1.LblNavRec.Caption:= IntToStr(CurrentRec) + ' '+ Of_LblNavRec +' '+ IntToStr(TotalRecs);
end;

function TFrmDsoEditor.EditTable(WhatTable: TIDTable): Boolean;
var
  i: Integer;
begin
  with TFrmDsoEditor.Create(Application) do
  try
    Case WhatTable of
    	wtTypeContracts:
        begin
        Caption:= Form_Caption_TypeContracts;
        TableEdit:= Tables[6];
        TableEdit.FieldsToEditCount:= 1;
        SetLength(TableEdit.FieldsToEdit, TableEdit.FieldsToEditCount);
        TableEdit.FieldsToEdit[0]:= 'Name_TypeContract';
     		DBGrd.Columns[0].Title.Caption:= Col_Title_TypeContracts;
				end;
      wtWorkplaces:
        begin
        Caption:= Form_Caption_Workplaces;
        TableEdit:= Tables[7];
        TableEdit.FieldsToEditCount:= 1;
        SetLength(TableEdit.FieldsToEdit, TableEdit.FieldsToEditCount);
        TableEdit.FieldsToEdit[0]:= 'Name_Workplace';
     		DBGrd.Columns[0].Title.Caption:= Col_Title_Workplaces;
        end;
      wtUsers:
        begin
      	Caption:= Form_Caption_Users;
        TableEdit:= Tables[2];
        TableEdit.FieldsToEditCount:= 4;
        SetLength(TableEdit.FieldsToEdit, TableEdit.FieldsToEditCount);
        TableEdit.FieldsToEdit[0]:= 'Name_User';
     		DBGrd.Columns[0].Title.Caption:= Col_Title_User;
        DBGrd.Columns.Add;
        TableEdit.FieldsToEdit[1]:= 'Hash_User';
        DBGrd.Columns[1].Title.Caption:= Col_Title_Password;
        DBGrd.Columns.Add;
 	      TableEdit.FieldsToEdit[2]:= 'Name_Usergroup';
        DBGrd.Columns[2].Title.Caption:= Col_Title_Usergroup;
        //Put the fields do not shown in column below here:
        TableEdit.FieldsToEdit[3]:= 'Salt_User';
        end;
    end; //case
  	DBGrd.Datasource:= TableEdit.DataSource;
    for i:=0 to (DBGrd.Columns.Count-1) do
    	begin
	    DBGrd.Columns[i].FieldName:= TableEdit.FieldsToEdit[i];
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
  Cancel: Boolean= FALSE;
  ErrorMsg: String;
  MaxLength: Integer;
  WriteFieldsCount: Integer;
begin
  case TableEdit.ID of
    wtUsers:
      begin
      Cancel:= Not(FrmEditAddUser.EditAddUser(acAdd, TableEdit));
      end;
    wtWorkplaces, WtTypeContracts:
      begin
	  	case TableEdit.ID of
    			wtWorkplaces:
          	begin
		    	  InpBox_Caption:= Add_IptBox_Caption_Workplaces;
    		  	InpBox_Prompt:= Add_IptBox_Prompt_Workplaces;
	      		WriteFieldsCount:= 1;
		  	    end;
    			wtTypeContracts:
    	  		begin
            InpBox_Caption:= Add_IptBox_Caption_TypeContracts;
            InpBox_Prompt:= Add_IptBox_Prompt_TypeContracts;
            WriteFieldsCount:= 1;
      			end;
      end; //case
			SetLength(WriteFields, WriteFieldsCount);
		  for i:=0 to (TableEdit.FieldsToEditCount-1) do
		    begin
	      MaxLength:= 255;
		  	if FrmInputBox.CustomInputBox(InpBox_Caption, InpBox_Prompt, '', MaxLength, FieldValue)= TRUE then
    	  	begin
	      	if FieldValue='' then
  	    		begin
			      Error:= TRUE;
  			    ErrorMsg:= Blank_Value;
    	  	  break; //terminate the 'for' loop
      			end;
     			WriteFields[i].FieldName:= TableEdit.FieldsToEdit[i];
 	 	  		WriteFields[i].Value:= FieldValue;
   				WriteFields[i].DataFormat:= dtString;
      		end
	    	else
  	    	begin
	  	    Cancel:= TRUE;
  	  	  break; //terminate the 'for' loop
    	 		end;
    	end; //for
	  	end;
	end; //case TableEdit.What
 	if (Error= FALSE) and (Cancel=FALSE) then
  	begin
	 	FuncData.InsertSQL(TableEdit.Table, TableEdit.Name, WriteFields); //Not use AppendTableRecord, because the users Table is selected with another tables with join clause!!!!
	  WriteFields:= nil;
		Inc(TotalRecs);
	 	UpdateNavRec;
  	end
	else if (Error= TRUE) then
		begin
		Application.MessageBox(PChar(ErrorMsg), 'Error!', MB_OK);
  	end;
end;

procedure TFrmDsoEditor.BtnDeleteClick(Sender: TObject);
var
  FieldValue: String;
begin
  FieldValue:= TableEdit.Table.FieldByName(TableEdit.FieldsToEdit[0]).AsString;
  if (TableEdit.ID= wtUsers) then //Don't delete SUPERUSER
    begin
    if (FieldValue= SUPERUSER_NAME) then
      begin
      Application.MessageBox(PChar(No_Delete_SUPERUSER), 'Error!', MB_OK);
      Exit;
      end;
    end;
  if FuncData.DeleteRecordSQL(TableEdit.Table, TableEdit.Name, TableEdit.FieldsToEdit[0], FieldValue, FieldValue, True)= TRUE then
  	begin
	  Dec(TotalRecs);
  	UpdateNavRec;
    end;
end;

procedure TFrmDsoEditor.BtnEditClick(Sender: TObject);
var
  FieldValue, FirstFieldValue, DefaultValue: String;
  InpBox_Caption, InpBox_Prompt: String;
  ColIdx: Integer;
  Error: Boolean= FALSE;
  Cancel: Boolean= FALSE;
  ErrorMsg: String;
  MaxLength: Integer;
  WriteFieldsCount: Integer;
  Salt: String;
begin
  case TableEdit.ID of
    wtTypeContracts:
      begin
      InpBox_Caption:= Edit_IptBox_Caption_TypeContracts;
      InpBox_Prompt:= Edit_IptBox_Prompt_TypeContracts;
      WriteFieldsCount:= 1;
      MaxLength:= 255;
      end;
    wtWorkplaces:
      begin
      InpBox_Caption:= Edit_IptBox_Caption_Workplaces;
      InpBox_Prompt:= Edit_IptBox_Prompt_Workplaces;
      WriteFieldsCount:= 1;
      MaxLength:= 255;
      end;
    wtUsers:
      begin
			Cancel:= Not(FrmEditAddUser.EditAddUser(acEdit, TableEdit));
      end;
  end; //case
	if (TableEdit.ID= wtTypeContracts) OR (TableEdit.ID= wtWorkplaces) then
    begin
    ColIdx:= DBGrd.SelectedColumn.Index;
    DefaultValue:= TableEdit.Table.FieldByName(TableEdit.FieldsToEdit[ColIdx]).AsString;
  	if FrmInputBox.CustomInputBox(InpBox_Caption, InpBox_Prompt, DefaultValue, MaxLength, FieldValue)= TRUE then
    	begin
	    if FieldValue='' then
  	    begin
    	  Error:= TRUE;
      	ErrorMsg:= Blank_Value;
	      end
  	  end
	  else
  	  begin
    	Cancel:= True;
	    end;
    end;
  if (Error= FALSE) and (Cancel= False) then
  	begin
    if (TableEdit.ID= wtTypeContracts) OR (TableEdit.ID= wtWorkplaces) then
      begin
		  SetLength(WriteFields, WriteFieldsCount);
  		WriteFields[0].FieldName:= TableEdit.FieldsToEdit[ColIdx];
	  	WriteFields[0].Value:= FieldValue;
			WriteFields[0].DataFormat:= dtString;
      end;
    FuncData.UpdateSQL(TableEdit.Table, TableEdit.Name, TableEdit.KeyField,
    	TableEdit.Table.FieldByName(TableEdit.KeyField).AsString, WriteFields, TRUE);
    TableEdit.Datasource.DataSet.Close;
    TableEdit.Datasource.DataSet.Open;
    WriteFields:= nil;
  	end
	else if (Error= TRUE) then
		begin
		Application.MessageBox(PChar(ErrorMsg), 'Error!', MB_OK);
    end;
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

