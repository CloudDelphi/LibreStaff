unit FormEditAddUser;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, StdCtrls,
  DbCtrls, FrameSaveCancel, FormDsoEditor, FuncData, Globals, LCLType,
  ExtCtrls, Buttons;

type

  { TFrmEditAddUser }

  TFrmEditAddUser = class(TForm)
    BtnChangePasswordUser: TBitBtn;
    DbLkCboUsergroup: TDBLookupComboBox;
    EdiName: TEdit;
    EdiPassword: TEdit;
    FraSaveCancel1: TFraSaveCancel;
    ImgPassword: TImage;
    ImgUser: TImage;
    ImgUsergroup: TImage;
    LblName: TLabel;
    LblUserGroup: TLabel;
    LblPassword: TLabel;
    procedure BtnCancelClick(Sender: TObject);
    procedure BtnChangePasswordUserClick(Sender: TObject);
    procedure BtnSaveClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    { private declarations }
  public
    { public declarations }
    function EditAddUser(WhatAction: TAction; TableEdit: TTable): Boolean;
  end;

var
  FrmEditAddUser: TFrmEditAddUser;

resourcestring
  lg_FrmAddCaption= 'Add User';
  lg_FrmEditCaption= 'Edit User';
  lg_Edit_IptBox_Caption_Passwords= 'Change the password';
  lg_Edit_IptBox_Prompt_Passwords= 'New Password:';
  User_Exists= 'This user already exists!';
  Blank_Name= 'The name cannot be blank';
  Blank_Password= 'The password cannot be blank';
  Blank_Usergroup= 'The group of the user cannot be blank';

implementation

{$R *.lfm}
uses
	FormMain, Crypt, DataModule, FormInputBox;

var
  WhatActionIs: TAction;

procedure TFrmEditAddUser.BtnSaveClick(Sender: TObject);
var
  Error: Boolean= FALSE;
  ErrorMsg: String;
begin
  if (EdiName.Text= '') then
  	begin
    Error:= TRUE;
    ErrorMsg:= Blank_Name;
		end
  else if (DbLkCboUsergroup.KeyValue= null) then
    begin
    Error:= TRUE;
    ErrorMsg:= Blank_Usergroup;
    end
	else if (EdiPassword.Text= '') then
  	begin
    Error:= TRUE;
    ErrorMsg:= Blank_Password;
    end
  else if (WhatActionIs= acAdd) then
    begin
  	if FuncData.CheckValueExists('Users', 'Name_User', EdiName.Text, TRUE)= TRUE then
	  	begin
  	  Error:= TRUE;
	  	ErrorMsg:= User_Exists;
	    end;
    end
  else if (WhatActionIs= acEdit) then
    begin
  	if FuncData.CheckValueExists('Users', 'Name_User', EdiName.Text, TRUE, 'ID_User',
    	 DataMod.QueUsers.FieldByName('ID_User').AsString)= TRUE then
	  	begin
  	  Error:= TRUE;
	  	ErrorMsg:= User_Exists;
	    end;
    end;
  if (Error= TRUE) then
    begin
	  Application.MessageBox(PChar(ErrorMsg), 'Error!', MB_OK);
    Exit;
    end
  else
  	begin
	  ModalResult:= mrOK;
    end;
end;

procedure TFrmEditAddUser.FormCreate(Sender: TObject);
begin
  //Get bitmaps
	FrmMain.ImgLstBtn.GetBitmap(19, ImgUser.Picture.Bitmap);
	FrmMain.ImgLstBtn.GetBitmap(20, ImgPassword.Picture.Bitmap);
  FrmMain.ImgLstBtn.GetBitmap(23, ImgUsergroup.Picture.Bitmap);
end;

procedure TFrmEditAddUser.BtnCancelClick(Sender: TObject);
begin
  ModalResult:= mrCancel;
end;

procedure TFrmEditAddUser.BtnChangePasswordUserClick(Sender: TObject);
var
  FieldValue, Salt: String;
begin
	if FrmInputBox.CustomInputBox(lg_Edit_IptBox_Caption_Passwords, lg_Edit_IptBox_Prompt_Passwords, '', PASSWORD_LENGTH, FieldValue)= TRUE then
    	begin
      if (FieldValue='') then
      	Application.MessageBox(PChar(Blank_Password), 'Error!', MB_OK)
      else
      	begin
	      Salt:= GenerateSalt(SALT_LENGTH);
  	    FieldValue:= Crypt.HashString(Salt+FieldValue);
    	  EdiPassword.Text:= FieldValue;
        end;
      end;
end;

function TFrmEditAddUser.EditAddUser(WhatAction: TAction; TableEdit: TTable): Boolean;
var
  Salt: String;
begin
  with TFrmEditAddUser.Create(Application) do
  try
    EdiName.MaxLength:= USERNAME_LENGTH;
    EdiPassword.MaxLength:= 255;
    WhatActionIs:= WhatAction;
    case WhatAction of
    	acEdit: begin
				      EdiPassWord.Enabled:= FALSE;
              BtnChangePasswordUser.Visible:= TRUE;
      				EdiName.Text:= DataMod.QueUsers.FieldByName('Name_User').AsString;
              DbLkCboUsergroup.KeyValue:= DataMod.QueUsers.FieldByName('Usergroup_ID').AsInteger;
              if (EdiName.Text= SUPERUSER_NAME) then
                begin
              	EdiName.Enabled:= FALSE;
                DbLkCboUsergroup.Enabled:= FALSE;
                end;
              EdiPassWord.Text:= DataMod.QueUsers.FieldByName('Hash_User').AsString;
              end;
    end; //case
    if (ShowModal= mrOk) then
      begin
      SetLength(WriteFields, 4);
 	    WriteFields[0].FieldName:= TableEdit.FieldsToEdit[0];
 			WriteFields[0].Value:= EdiName.Text;
			WriteFields[0].DataFormat:= dtString;
 	    WriteFields[1].FieldName:= TableEdit.FieldsToEdit[1];
      case WhatAction of
        acAdd:	begin
					      Salt:= GenerateSalt(SALT_LENGTH);
 								WriteFields[1].Value:= Crypt.HashString(Salt+EdiPassword.Text);
				        end;
        acEdit: WriteFields[1].Value:= EdiPassword.Text;
      end; //case
      WriteFields[1].DataFormat:= dtString;
 	    WriteFields[2].FieldName:= 'Usergroup_ID';
 			WriteFields[2].Value:= DBLkCboUsergroup.KeyValue;
			WriteFields[2].DataFormat:= dtInteger;
 	    WriteFields[3].FieldName:= TableEdit.FieldsToEdit[3];
 			WriteFields[3].Value:= Salt;
			WriteFields[3].DataFormat:= dtString;
      Result:= TRUE;
      end
    else
      begin
      Result:= FALSE;
      end;
  finally
    FrmEditAddUser.Free;
    FrmEditAddUser:= nil;
  end;
end;
end.

