unit FormProfile;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, ComCtrls,
  StdCtrls, ExtCtrls, Spin, Buttons, FrameClose;

type

  { TFrmProfile }

  TFrmProfile = class(TForm)
    BtnSaveAvatar: TBitBtn;
    ChkRememberUsername: TCheckBox;
    FraClose1: TFraClose;
    GrpAccessControlOptions: TGroupBox;
    ImgAvatar: TImage;
    Lbl_Username: TLabel;
    LblUsername: TLabel;
    PagProfile: TPageControl;
    ShpAvatar: TShape;
    SpiAvatar: TSpinEdit;
    TabAccount: TTabSheet;
    TabAvatar: TTabSheet;
    procedure BtnCloseClick(Sender: TObject);
    procedure BtnSaveAvatarClick(Sender: TObject);
    procedure ChkRememberUsernameChange(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure SpiAvatarChange(Sender: TObject);
    procedure TabAvatarShow(Sender: TObject);
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
  Globals, FormMain;

{ TFrmProfile }

procedure TFrmProfile.FormCreate(Sender: TObject);
begin
  LblUsername.Caption:= User.Name;
	case RememberUsername of
  	False:	ChkRememberUsername.State:= cbUnchecked;
    True: 	ChkRememberUsername.State:= cbChecked;
  end; //case
  //Load the Glyphs:
  FrmMain.ImgLstBtn.GetBitmap(3, BtnSaveAvatar.Glyph);
  SpiAvatar.MaxValue:= AVATARS_COUNT+1;
end;

procedure TFrmProfile.SpiAvatarChange(Sender: TObject);
var
  IDAvatar, FilenameAvatar, PathAvatar: String;
  AvatarExists: Boolean= FALSE;
begin
  Case SpiAvatar.Value of
    -1: SpiAvatar.Value:= AVATARS_COUNT;
    0: begin
       ImgAvatar.Picture:= Nil;
       end;
    1..AVATARS_COUNT:
      begin
      Str(SpiAvatar.Value, IDAvatar);
      if (Length(IDAvatar)<4) then
        begin
        repeat
          IDAvatar:= '0'+IDAvatar;
        until Length(IDAvatar)=4;
        end;
      PathAvatar:= PathApp+'Avatars\'+IDAvatar;
      if FileExists(PathAvatar+'.jpg') then
        begin
        AvatarExists:= TRUE;
        FilenameAvatar:= PathAvatar+'.jpg';
        end
      else if FileExists(PathAvatar+'.png') then
        begin
        FilenameAvatar:= PathAvatar+'.png';
        AvatarExists:= TRUE;
        end
      else if FileExists(PathAvatar+'.gig') then
        begin
        FilenameAvatar:= PathAvatar+'.png';
        AvatarExists:= TRUE;
        end;
      if AvatarExists= TRUE then
        ImgAvatar.Picture.LoadFromFile(FilenameAvatar);
      end;
    AVATARS_COUNT+1: SpiAvatar.Value:=0;
  end;
end;

procedure TFrmProfile.TabAvatarShow(Sender: TObject);
begin
  SpiAvatar.Value:= StrToInt(INIFile.ReadString('Access Control', 'Avatar', '0'));
end;

procedure TFrmProfile.BtnCloseClick(Sender: TObject);
begin
  Close;
end;

procedure TFrmProfile.BtnSaveAvatarClick(Sender: TObject);
begin
  INIFile.WriteString('Access Control', 'Avatar', IntToStr(SpiAvatar.Value));
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

