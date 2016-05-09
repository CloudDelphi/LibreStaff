unit FormDsoEditor;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, DBGrids,
  Buttons, FrameAddDelEdiSavCan, db, sqldb, FormMain, Globals, LCLType,
  ExtCtrls, StdCtrls, FormInputBox, Crypt;

type TTableEdit = record
    What: TWhatTable;
    TableName: String;
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
  FuncData, DataModule, FormAddUser;

{ TFrmDsoEditor }

procedure TFrmDsoEditor.UpdateNavRec;
begin
  CurrentRec:= TableEdit.Table.RecNo;
  FraAddDelEdiSavCan1.LblNavRec.Caption:= IntToStr(CurrentRec) + ' '+ Of_LblNavRec +' '+ IntToStr(TotalRecs);
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
        TableEdit.TableName:= 'TypeContracts';
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
        TableEdit.TableName:= 'Workplaces';
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
        TableEdit.TableName:= 'Users';
        TableEdit.Datasource:= DataMod.DsoUsers;
        TableEdit.FieldCount:= 4;
        TableEdit.Table:= DataMod.QueUsers;
        SetLength(TableEdit.FieldNames, TableEdit.FieldCount);
        TableEdit.FieldNames[0]:= 'Name_User';
     		DBGrd.Columns[0].Title.Caption:= Col_Title_User;
        DBGrd.Columns.Add;
        TableEdit.FieldNames[1]:= 'Hash_User';
        DBGrd.Columns[1].Title.Caption:= Col_Title_Password;
        DBGrd.Columns.Add;
 	      TableEdit.FieldNames[2]:= 'Name_Usergroup';
        DBGrd.Columns[2].Title.Caption:= Col_Title_Usergroup;
        //Put the fields do not shown in column below here:
        TableEdit.FieldNames[3]:= 'Salt_User';
        end;
    end; //case
  	DBGrd.Datasource:= TableEdit.Datasource;
    for i:=0 to (DBGrd.Columns.Count-1) do
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
  Cancel: Boolean= FALSE;
  ErrorMsg: String;
  MaxLength: Integer;
  WriteFieldsCount: Integer;
begin
  case TableEdit.What of
    wtUsers:
      begin
      Cancel:= Not(FrmAddUser.AddUser(TableEdit));
      end;
    wtWorkplaces, WtTypeContracts:
      begin
	  	case TableEdit.What of
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
		  for i:=0 to (TableEdit.FieldCount-1) do
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
     			WriteFields[i].FieldName:= TableEdit.FieldNames[i];
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
	 	FuncData.InsertSQL(TableEdit.Table, TableEdit.TableName, WriteFields); //Not use AppendTableRecord, because the users Table is selected with another tables with join clause!!!!
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
  FieldValue:= TableEdit.Table.FieldByName(TableEdit.FieldNames[0]).AsString;
  if (TableEdit.What= wtUsers) then //Don't delete SUPERUSER
    begin
    if (FieldValue= SUPERUSER_NAME) then
      begin
      Application.MessageBox(PChar(No_Delete_SUPERUSER), 'Error!', MB_OK);
      Exit;
      end;
    end;
  if FuncData.DeleteRecordSQL(TableEdit.Table, TableEdit.TableName, TableEdit.FieldNames[0], FieldValue, FieldValue, True)= TRUE then
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
  ColIdx:= DBGrd.SelectedColumn.Index;
  case TableEdit.What of
    wtTypeContracts:
      begin
      InpBox_Caption:= Edit_IptBox_Caption_TypeContracts;
      InpBox_Prompt:= Edit_IptBox_Prompt_TypeContracts;
      WriteFieldsCount:= 1;
      end;
    wtWorkplaces:
      begin
      InpBox_Caption:= Edit_IptBox_Caption_Workplaces;
      InpBox_Prompt:= Edit_IptBox_Prompt_Workplaces;
      WriteFieldsCount:= 1;
      end;
    wtUsers:
      begin
      case ColIdx of
        0:	begin
      			InpBox_Caption:= Edit_IptBox_Caption_Users;
	      		InpBox_Prompt:= Edit_IptBox_Prompt_Users;
            MaxLength:= USERNAME_LENGTH;
            WriteFieldsCount:= 1;
		        end;
        1:	begin
      			InpBox_Caption:= Edit_IptBox_Caption_Passwords;
	      		InpBox_Prompt:= Edit_IptBox_Prompt_Passwords;
            MaxLength:= PASSWORD_LENGTH;
            WriteFieldsCount:= 2;
		        end;
      end;
      end;
  end; //case
  if (TableEdit.What= wtUsers) and (ColIdx=0) then //Don't edit SUPERUSER
    begin
  	FirstFieldValue:= TableEdit.Table.FieldByName(TableEdit.FieldNames[0]).AsString;
    if (FirstFieldValue= SUPERUSER_NAME) then
      begin
      Error:= TRUE;
      ErrorMsg:= No_Edit_SUPERUSER;
      Application.MessageBox(PChar(ErrorMsg), 'Error!', MB_OK);
      Exit;
      end;
    end;
  if (TableEdit.What= wtUsers) AND (ColIdx=1) then //if editing a password
    begin
    DefaultValue:= '';
    end
  else
  	begin
 		DefaultValue:= TableEdit.Table.FieldByName(TableEdit.FieldNames[ColIdx]).AsString;
    end;
  if FrmInputBox.CustomInputBox(InpBox_Caption, InpBox_Prompt, DefaultValue, MaxLength, FieldValue)= TRUE then
    begin
    if FieldValue='' then
      begin
      Error:= TRUE;
      ErrorMsg:= Blank_Value;
      end
    else if (TableEdit.What= wtUsers) AND (ColIdx=0) then
   	  begin
      if FuncData.CheckValueExists('Users','Name_User',FieldValue,TRUE,'ID_User',DataMod.DsoUsers.DataSet.FieldByName('ID_User').AsString)= TRUE then
        begin
		    Error:= TRUE;
	   	  ErrorMsg:= User_Exists;
        end;
      end
    else if (TableEdit.What= wtUsers) AND (ColIdx=1) then //if editing a password
      begin
      Salt:= GenerateSalt(SALT_LENGTH);
      FieldValue:= Crypt.HashString(Salt+FieldValue);
      end
    end
  else
    begin
    Cancel:= True;
    end;
  if (Error= FALSE) and (Cancel= False) then
  	begin
	  SetLength(WriteFields, WriteFieldsCount);
  	WriteFields[0].FieldName:= TableEdit.FieldNames[ColIdx];
	  WriteFields[0].Value:= FieldValue;
		WriteFields[0].DataFormat:= dtString;
    if (TableEdit.What= wtUsers) AND (ColIdx=1) then //if editing a password
      begin
      WriteFields[1].FieldName:= 'Salt_User';
	    WriteFields[1].Value:= Salt;
   		WriteFields[1].DataFormat:= dtString;
      end;
    FuncData.UpdateSQL(TableEdit.Table, TableEdit.TableName, TableEdit.FieldNames[ColIdx], DefaultValue, WriteFields);
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

