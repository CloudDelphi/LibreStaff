unit FrameAddDelEdiSavCan;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, ExtCtrls, Buttons, StdCtrls;

type

  { TFraAddDelEdiSavCan }

  TFraAddDelEdiSavCan = class(TFrame)
    BtnEdit: TBitBtn;
    BtnDelete: TBitBtn;
    BtnAdd: TBitBtn;
    BtnCancel: TBitBtn;
    BtnSave: TBitBtn;
    BtnSortList: TSpeedButton;
    LblNavRec: TLabel;
    PanBottom: TPanel;
    PanNavRec: TPanel;
  private
    { private declarations }
  public
    { public declarations }
  protected
		procedure Loaded; override;
  end;

implementation

{$R *.lfm}

uses
  DataModule;

procedure TFraAddDelEdiSavCan.Loaded;
begin
  inherited;
  DataMod.ImgLstBtn.GetBitmap(3, BtnSave.Glyph);
  DataMod.ImgLstBtn.GetBitmap(2, BtnCancel.Glyph);
  DataMod.ImgLstBtn.GetBitmap(11, BtnAdd.Glyph);
  DataMod.ImgLstBtn.GetBitmap(10, BtnDelete.Glyph);
  DataMod.ImgLstBtn.GetBitmap(12, BtnEdit.Glyph);
  DataMod.ImgLstBtn.GetBitmap(7, BtnSortList.Glyph);
end;
end.

