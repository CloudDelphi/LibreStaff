unit FormReports;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, DBDateTimePicker, DateTimePicker, Forms,
  Controls, Graphics, Dialogs, ExtCtrls, Buttons, ComCtrls, StdCtrls, DBGrids,
  CheckLst, ValEdit;

type

  { TFrmReports }

  TFrmReports = class(TForm)
    BtnClose: TBitBtn;
    BtnQuery: TBitBtn;
    BtnAddField: TBitBtn;
    BtnRemoveField: TBitBtn;
    BtnUpField: TBitBtn;
    BtnDownField: TBitBtn;
    ChkActByName: TCheckBox;
    ChkActByBirthday: TCheckBox;
    DatDateBirthEnd: TDateTimePicker;
    DBGridQueryResult: TDBGrid;
    EdiNameEmployee: TEdit;
    GroupBox1: TGroupBox;
    LblDateBirthEnd: TLabel;
    LblDateBirthInit: TDateTimePicker;
    LblNameEmployee: TLabel;
    LstBoxFields: TListBox;
    LstBoxAvailableFields: TListBox;
    LLblDateBirthInit: TLabel;
    PagCriterion: TPageControl;
    PanBottom2: TPanel;
    PanTop: TPanel;
    TabCriterionPersonalData: TTabSheet;
    TabeCriterionContract: TTabSheet;
    TabFields: TTabSheet;
    procedure BtnCloseClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private

  public

  end;

var
  FrmReports: TFrmReports;

implementation

{$R *.lfm}

uses
  Globals, DataModule;

{ TFrmReports }

procedure TFrmReports.FormCreate(Sender: TObject);
begin
   DataMod.ImgLstBtn.GetBitmap(2, BtnClose.Glyph);
   DataMod.ImgLstBtn.GetBitmap(16, BtnQuery.Glyph);
end;


procedure TFrmReports.BtnCloseClick(Sender: TObject);
begin
  Close;
end;

end.

