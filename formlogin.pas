unit FormLogin;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, StdCtrls,
  DbCtrls, Buttons, ExtCtrls, Globals;

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
    procedure FormCreate(Sender: TObject);
  private
    { private declarations }
  public
    { public declarations }
  end;

var
  FrmLogin: TFrmLogin;

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
  EdiUser.MaxLength:= USERNAME_LENGHT;
  EdiPassword.MaxLength:= PASSWORD_LENGHT;
end;

end.

