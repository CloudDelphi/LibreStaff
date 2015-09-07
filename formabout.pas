unit FormAbout;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, IpHtml, Ipfilebroker, RichMemo, Forms, Controls,
  Graphics, Dialogs, ComCtrls, StdCtrls, ExtCtrls, FrameClose, types;

type
  TSimpleIpHtml = class(TIpHtml)
  public
    property OnGetImageX;
  end;

type

  { TFrmAbout }

  TFrmAbout = class(TForm)
    FraClose1: TFraClose;
    ImgLibreStaff: TImage;
    TitleLibreStaff: TLabel;
    PagAbout: TPageControl;
    RchMmoLicense: TRichMemo;
    TabAbout: TTabSheet;
    TabLicense: TTabSheet;
    procedure BtnCloseClick(Sender: TObject);
    procedure TabLicenseContextPopup(Sender: TObject; MousePos: TPoint;
      var Handled: Boolean);
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
  FormMain;

{ TFrmAbout }

procedure TFrmAbout.TabLicenseShow(Sender: TObject);
var
  LicenseFile: TMemoryStream;
begin
 LicenseFile:= TMemoryStream.Create;
 LicenseFile.LoadFromFile(PathApp+'License-GPL-3.rtf');
 RchMmoLicense.LoadRichText(LicenseFile);
 LicenseFile.Free;
end;

procedure TFrmAbout.TabLicenseContextPopup(Sender: TObject; MousePos: TPoint;
  var Handled: Boolean);
begin

end;

procedure TFrmAbout.BtnCloseClick(Sender: TObject);
begin
  Close;
end;

{ TFrmAbout }



{ TFrmAbout }


end.

