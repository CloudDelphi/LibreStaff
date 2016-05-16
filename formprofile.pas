unit FormProfile;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, ComCtrls,
  StdCtrls, FrameClose;

type

  { TFrmProfile }

  TFrmProfile = class(TForm)
    ChkRememberUsername: TCheckBox;
    FraClose1: TFraClose;
    GrpAccessControlOptions: TGroupBox;
    Lbl_Username: TLabel;
    LblUsername: TLabel;
    PagProfile: TPageControl;
    TabAccount: TTabSheet;
    procedure BtnCloseClick(Sender: TObject);
    procedure ChkRememberUsernameChange(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    { private declarations }
  public
    { public declarations }
  end;

var
  FrmProfile: TFrmProfile;

implementation

{$R *.lfm}

uses
  Globals;

{ TFrmProfile }

procedure TFrmProfile.FormCreate(Sender: TObject);
begin
  LblUsername.Caption:= User.Name;
	case RememberUsername of
  	False:	ChkRememberUsername.State:= cbUnchecked;
    True: 	ChkRememberUsername.State:= cbChecked;
  end; //case
end;

procedure TFrmProfile.BtnCloseClick(Sender: TObject);
begin
  Close;
end;

procedure TFrmProfile.ChkRememberUsernameChange(Sender: TObject);
begin
  RememberUsername:= not RememberUsername;
  INIFile.WriteString('Access Control', 'RememberUsername', BoolToStr(RememberUsername));
  if (RememberUsername= FALSE) then
    begin
    INIFile.WriteString('Access Control', 'Username', '');
    end;
end;


end.

