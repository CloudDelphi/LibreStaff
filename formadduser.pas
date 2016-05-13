unit FormAddUser;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, StdCtrls,
  DbCtrls, FrameSaveCancel, FormDsoEditor, FuncData, Globals, PopupNotifier,
  LCLType, ExtCtrls;

type

  { TFrmAddUser }

  TFrmAddUser = class(TForm)
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
    procedure BtnSaveClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    { private declarations }
  public
    { public declarations }
    function AddUser(TableEdit: TTableEdit): Boolean;
  end;

var
  FrmAddUser: TFrmAddUser;

resourcestring
  User_Exists= 'This user already exists!';
  Blank_Name= 'The name cannot be blank';
  Blank_Password= 'The password cannot be blank';
  Blank_Usergroup= 'The group of the user cannot be blank';

implementation

{$R *.lfm}
uses
	FormMain, Crypt;

procedure TFrmAddUser.BtnSaveClick(Sender: TObject);
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
  else if FuncData.CheckValueExists('Users', 'Name_User', EdiName.Text, TRUE)= TRUE then
  	begin
    Error:= TRUE;
	  ErrorMsg:= User_Exists;
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

procedure TFrmAddUser.FormCreate(Sender: TObject);
begin
  //Get bitmaps
	FrmMain.ImgLstBtn.GetBitmap(19, ImgUser.Picture.Bitmap);
	FrmMain.ImgLstBtn.GetBitmap(20, ImgPassword.Picture.Bitmap);
  FrmMain.ImgLstBtn.GetBitmap(23, ImgUsergroup.Picture.Bitmap);
end;

procedure TFrmAddUser.BtnCancelClick(Sender: TObject);
begin
  ModalResult:= mrCancel;
end;

function TFrmAddUser.AddUser(TableEdit: TTableEdit): Boolean;
var
  Salt: String;
begin
  with TFrmAddUser.Create(Application) do
  try
    if (ShowModal= mrOk) then
      begin
      EdiName.MaxLength:= USERNAME_LENGTH;
      EdiPassword.MaxLength:= PASSWORD_LENGTH;
      SetLength(WriteFields, 4);
 	    WriteFields[0].FieldName:= TableEdit.FieldNames[0];
 			WriteFields[0].Value:= EdiName.Text;
			WriteFields[0].DataFormat:= dtString;
      Salt:= GenerateSalt(SALT_LENGTH);
 	    WriteFields[1].FieldName:= TableEdit.FieldNames[1];
 			WriteFields[1].Value:= Crypt.HashString(Salt+EdiPassword.Text);
			WriteFields[1].DataFormat:= dtString;
 	    WriteFields[2].FieldName:= 'Usergroup_ID';
 			WriteFields[2].Value:= DBLkCboUsergroup.KeyValue;
			WriteFields[2].DataFormat:= dtInteger;
 	    WriteFields[3].FieldName:= TableEdit.FieldNames[3];
 			WriteFields[3].Value:= Salt;
			WriteFields[3].DataFormat:= dtString;
      Result:= TRUE;
      end
    else
      begin
      Result:= FALSE;
      end;
  finally
    FrmAddUser.Free;
    FrmAddUser:= nil;
  end;
end;
end.

