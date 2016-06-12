unit FrameClose;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, ExtCtrls, Buttons;

type

  { TFraClose }

  TFraClose = class(TFrame)
    BtnClose: TBitBtn;
    PanClose: TPanel;
  private
    { private declarations }
  public
    { public declarations }
  protected
    procedure Loaded; override;
  end;

implementation

{$R *.lfm}

{ TFraClose }
uses
  DataModule;

procedure TFraClose.Loaded;
begin
  inherited;
  DataMod.ImgLstBtn.GetBitmap(2, BtnClose.Glyph);
end;

end.

