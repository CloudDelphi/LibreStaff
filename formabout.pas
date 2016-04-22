unit FormAbout;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, IpHtml, Ipfilebroker, RichMemo, Forms, Controls,
  Graphics, Dialogs, ComCtrls, StdCtrls, ExtCtrls, FrameClose, types, Globals;

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
    ImgLibreStaff: TImage;
    LblVersion: TLabel;
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
  FormMain, FuncApp;

{ TFrmAbout }

procedure TFrmAbout.TabLicenseShow(Sender: TObject);
var
  LicenseFile: TMemoryStream;
begin
 LicenseFile:= TMemoryStream.Create;
 LicenseFile.LoadFromFile(PathApp+'lic\License-GPL-3.rtf');
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
end;

{ TFrmAbout }



{ TFrmAbout }


end.

