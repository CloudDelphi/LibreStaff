unit FormAbout;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, IpHtml, Ipfilebroker, RichMemo, Forms, Controls,
  Graphics, Dialogs, ComCtrls, StdCtrls, ExtCtrls, FrameClose, Globals;

type
  TSimpleIpHtml = class(TIpHtml)
  public
    property OnGetImageX;
  end;

type

  { TFrmAbout }

  TFrmAbout = class(TForm)
    FraClose1: TFraClose;
    GrpVersion: TGroupBox;
    GrpDBVersions: TGroupBox;
    ImgLibreStaff: TImage;
    LblSQLiteVersion: TLabel;
    LblVersion: TLabel;
    LblMySQLVersion: TLabel;
    TitleLibreStaff: TLabel;
    PagAbout: TPageControl;
    RchMmoLicense: TRichMemo;
    TabAbout: TTabSheet;
    TabLicense: TTabSheet;
    procedure BtnCloseClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure TabLicenseShow(Sender: TObject);
  private
    { private declarations }
  public
    { public declarations }
  end;

var
  FrmAbout: TFrmAbout;

implementation

{$R *.lfm}

uses
  FuncApp;

{ TFrmAbout }

procedure TFrmAbout.TabLicenseShow(Sender: TObject);
var
  LicenseFile: TMemoryStream;
begin
 LicenseFile:= TMemoryStream.Create;
 LicenseFile.LoadFromFile(PathApp+'lic'+PATH_SEPARATOR+'License-GPL-3.rtf');
 RchMmoLicense.LoadRichText(LicenseFile);
 FreeAndNil(LicenseFile);
end;

procedure TFrmAbout.BtnCloseClick(Sender: TObject);
begin
  Close;
end;

procedure TFrmAbout.FormCreate(Sender: TObject);
begin
	LblVersion.Caption:= LblVersion.Caption+' '+FuncApp.GetAppVersion;
  LblSQLiteVersion.Caption:= LblSQLiteVersion.Caption+' '+SQLITE_ENGINE_VERSION;
	LblMySQLVersion.Caption:= LblMySQLVersion.Caption+' '+MySQL_ENGINE_VERSION;
end;

{ TFrmAbout }



{ TFrmAbout }


end.

