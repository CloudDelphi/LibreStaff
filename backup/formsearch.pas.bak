unit FormSearch;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, DBGrids,
  StdCtrls, ExtCtrls, Buttons, FormMain;

type

  { TFrmSearch }

  TFrmSearch = class(TForm)
    BtnClose: TBitBtn;
    BtnViewAll: TBitBtn;
    BtnSearch: TBitBtn;
    DBGridSearchResult: TDBGrid;
    EditSearch: TEdit;
    Label1: TLabel;
    PanLeft: TPanel;
    PanRight: TPanel;
    Splitter: TSplitter;
    procedure BtnCloseClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    { private declarations }
  public
    { public declarations }
    function Search: Boolean;
  end;

var
  FrmSearch: TFrmSearch;

implementation

{$R *.lfm}

{ TFrmSearch }

function TFrmSearch.Search: Boolean;
begin
  with TFrmSearch.Create(Application) do
  try
  Result:= ShowModal = mrOK;
  finally
  FrmSearch.Free;
  FrmSearch:= nil;
  end;
end;

procedure TFrmSearch.BtnCloseClick(Sender: TObject);
begin
  Close;
end;

procedure TFrmSearch.FormCreate(Sender: TObject);
begin
  FrmMain.ImgLstBtn.GetBitmap(8, BtnSearch.Glyph);
	FrmMain.ImgLstBtn.GetBitmap(2, BtnClose.Glyph);
  FrmMain.ImgLstBtn.GetBitmap(9, BtnViewAll.Glyph);
end;

end.

