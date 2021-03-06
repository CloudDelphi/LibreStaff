unit FormLogin;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, StdCtrls,
  DbCtrls, Buttons, ExtCtrls, PopupNotifier, Globals, FuncData, DataModule,
  FormMain, Crypt;

type
  { TFrmLogin }
  TFrmLogin = class(TForm)
    BtnEnter: TBitBtn;
    BtnExit: TBitBtn;
    EdiUser: TEdit;
    EdiPassword: TEdit;
    ImgUser: TImage;
    ImgPassword: TImage;
    Img22: TImageList;
    LblPassword: TLabel;
    LblUser: TLabel;
    LblLibreStaff: TLabel;
    procedure BtnEnterClick(Sender: TObject);
    procedure BtnExitClick(Sender: TObject);
    procedure EdiPasswordKeyPress(Sender: TObject; var Key: char);
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure FormCloseQuery(Sender: TObject; var CanClose: boolean);
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private
    { private declarations }
  public
    { public declarations }
  end;

var
  FrmLogin: TFrmLogin;
  PopLogin: TPopupNotifier;

resourcestring
  lg_UserNotExistsTitle= 'Error!';
  lg_UserNotExistsText= 'Username does not exist.';
  lg_PasswordDoesNotMatchTitle= 'Error!';
  lg_PasswordDoesNotMatchText= 'Password does not match.';

implementation

{$R *.lfm}

{ TFrmLogin }

procedure TFrmLogin.FormCreate(Sender: TObject);
begin
  //Get bitmaps
  Img22.GetBitmap(0, ImgUser.Picture.Bitmap);
	Img22.GetBitmap(1, ImgPassword.Picture.Bitmap);
  Img22.GetBitmap(2, BtnEnter.Glyph);
  Img22.GetBitmap(3, BtnExit.Glyph);
  //Set lenght for the input boxes
  EdiUser.MaxLength:= USERNAME_LENGTH;
  EdiPassword.MaxLength:= PASSWORD_LENGTH;
  FuncData.ExecSQL(DataMod.QueUsers, SELECT_ALL_USERS_SQL); //Open User's table
end;

procedure TFrmLogin.FormShow(Sender: TObject);
var
  Username: String;
begin
	//Remember the username?
  RememberUsername:= StrToBool(INIFile.ReadString('Access Control','RememberUsername','False'));
  if (RememberUsername= TRUE) then
  	begin
    Username:= INIFile.ReadString('Access Control','Username','');
    Username:= AnsiDequotedStr(Username, '''');
    if Not(Username= '') then
      begin
      EdiUser.Text:= Username;
      EdiPassword.SetFocus;
      end;
    end;
end;

procedure TFrmLogin.BtnEnterClick(Sender: TObject);
var
  LoginUser, LoginPassword, HashLoginPassword, HashUser, SaltUser, IDUser: String;
begin
  LoginUser:= EdiUser.Text;
  LoginPassword:= EdiPassword.Text;
  PopLogin:= TCustomPopupNotifier.Create(2);
  //Search the user name, password and salt
  FuncData.ExecSQL(DataMod.QueVirtual, 'SELECT ID_User, Hash_User, Salt_User FROM Users WHERE Name_User='''+LoginUser+''' LIMIT 1');
  if (DataMod.QueVirtual.IsEmpty= FALSE) then
    begin
    SaltUser:= DataMod.QueVirtual.FieldByName('Salt_User').AsString;
    HashLoginPassword:= Crypt.HashString(SaltUser+LoginPassword);
    HashUser:= DataMod.QueVirtual.FieldByName('Hash_User').AsString;
    if (HashLoginPassword= HashUser) then
      begin
      if (RememberUsername= TRUE) then
        begin
	      INIFile.WriteString('Access Control', 'Username', QuotedStr(LoginUser));
        end;
      //Create User
      User:= TUser.Create;
      User.Name:= LoginUser;
      IDUser:= DataMod.QueVirtual.FieldByName('ID_User').AsString;
      //Read & save permissions in the User variable
      FuncData.ExecSQL(DataMod.QueVirtual, 'SELECT * from Permissions LEFT JOIN Users ON (Permissions.Usergroup_ID=Users.Usergroup_ID) WHERE (Users.ID_User='+IDUser+');'); //Open Permissions's table
      User.Permissions.EditEmployee:= DataMod.QueVirtual.FieldByName('EditEmployee_Permission').AsBoolean;
      User.Permissions.AddEmployee:= DataMod.QueVirtual.FieldByName('AddEmployee_Permission').AsBoolean;
      User.Permissions.DeleteEmployee:= DataMod.QueVirtual.FieldByName('DeleteEmployee_Permission').AsBoolean;
      User.Permissions.ShowTabAddress:= DataMod.QueVirtual.FieldByName('ShowTabAddress_Permission').AsBoolean;
      User.Permissions.AdminControlAccess:= DataMod.QueVirtual.FieldByName('AdminControlAccess_Permission').AsBoolean;
      User.Permissions.AdminDatabase:= DataMod.QueVirtual.FieldByName('AdminDatabase_Permission').AsBoolean;
      ModalResult:= mrOK;
      end
    else
    	begin
      PopLogin.Title:= lg_PasswordDoesNotMatchTitle;
  	  PopLogin.Text:= lg_PasswordDoesNotMatchText;
			PopLogin.ShowAtPos(Left+EdiPassword.Left, Top+EdiPassword.Top);
      end;
    end
  else
    begin
		PopLogin.Title:= lg_UserNotExistsTitle;
		PopLogin.Text:= lg_UserNotExistsText;
		PopLogin.ShowAtPos(Left+EdiUser.Left, Top+EdiUser.Top);
    end;
  //Get the user
end;

procedure TFrmLogin.BtnExitClick(Sender: TObject);
begin
  //Free DBEngine
  FreeAndNil(DBEngine);
end;

procedure TFrmLogin.EdiPasswordKeyPress(Sender: TObject; var Key: char);
begin
	if (Key= #13) then
    begin
    BtnEnter.Click;
    end
end;

procedure TFrmLogin.FormClose(Sender: TObject; var CloseAction: TCloseAction);
begin

end;

procedure TFrmLogin.FormCloseQuery(Sender: TObject; var CanClose: boolean);
begin

end;

end.


