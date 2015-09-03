unit FormPreferences;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, ComCtrls,
  StdCtrls, Buttons, ExtCtrls, FrameClose, LCLType;

type

  { TFrmPreferences }

  TFrmPreferences = class(TForm)
    BtnChangeDtbPath: TBitBtn;
    CboDateFormat: TComboBox;
    CboDateSeparator: TComboBox;
    ChkIDAutoRandom: TCheckBox;
    ChkIDAllowBlank: TCheckBox;
    ChkIDUnique: TCheckBox;
    EdiDtbPath: TEdit;
    FraClose1: TFraClose;
    Dates: TGroupBox;
    GrpIDEmployee: TGroupBox;
    ImgLstPreferences: TImageList;
    LblDatabasePath: TLabel;
    LblDateFormat: TLabel;
    LblDateSeparator: TLabel;
    LstViewPreferences: TListView;
    PagPreferences: TPageControl;
    Splitter1: TSplitter;
    TabDatabase: TTabSheet;
    TabLanguage: TTabSheet;
    TabGeneral: TTabSheet;
    procedure BtnChangeDtbPathClick(Sender: TObject);
    procedure BtnCloseClick(Sender: TObject);
    procedure CboDateFormatChange(Sender: TObject);
    procedure CboDateSeparatorChange(Sender: TObject);
    procedure ChkIDAllowBlankChange(Sender: TObject);
    procedure ChkIDAutoRandomChange(Sender: TObject);
    procedure ChkIDUniqueChange(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure LstViewPreferencesSelectItem(Sender: TObject; Item: TListItem;
      Selected: Boolean);
    procedure TabDatabaseShow(Sender: TObject);
    procedure TabGeneralShow(Sender: TObject);
    procedure TabLanguageShow(Sender: TObject);
  private
    { private declarations }
  public
    { public declarations }
  end;

var
  FrmPreferences: TFrmPreferences;

resourcestring
  LstView_Caption_Item_0= 'General';
  LstView_Caption_Item_1= 'Language';
  LstView_Caption_Item_2= 'Database';
	SelectDirDlg_Title= 'Select the path for the database (data.db)';
  SelectDirDlg_Error_Title= 'ERROR!';
  SelectDirDlg_Error_Msg= 'The file "data.db" does not exist in this path.';

implementation

{$R *.lfm}

{ TFrmPreferences }
uses
    FormMain, FuncDlgs;

procedure TFrmPreferences.LstViewPreferencesSelectItem(Sender: TObject;
  Item: TListItem; Selected: Boolean);
begin
	PagPreferences.ActivePageIndex:= Item.Index;
end;


procedure TFrmPreferences.BtnCloseClick(Sender: TObject);
begin
  Close;
end;

procedure TFrmPreferences.CboDateFormatChange(Sender: TObject);
begin
	INIFile.WriteString('Lang', 'ShortDateFormat', CboDateFormat.Text);
end;

procedure TFrmPreferences.CboDateSeparatorChange(Sender: TObject);
begin
	INIFile.WriteString('Lang', 'DateSeparator', CboDateSeparator.Text);
end;

procedure TFrmPreferences.ChkIDAllowBlankChange(Sender: TObject);
begin
  IDAllowBlank:= not IDAllowBlank;
  INIFile.WriteString('General', 'IDAllowBlank', BoolToStr(IDAllowBlank));
end;

procedure TFrmPreferences.ChkIDAutoRandomChange(Sender: TObject);
begin
  IDAutoRandom:= not IDAutoRandom;
  INIFile.WriteString('General', 'IDAutoRandom', BoolToStr(IDAutoRandom));
end;

procedure TFrmPreferences.ChkIDUniqueChange(Sender: TObject);
begin
  IDUnique:= not IDUnique;
  INIFile.WriteString('General', 'IDUnique', BoolToStr(IDUnique));
  ChkIDAutoRandom.Enabled:= ChkIDUnique.Checked;
  ChkIDAllowBlank.Enabled:= ChkIDUnique.Checked;
end;

procedure TFrmPreferences.FormCreate(Sender: TObject);
var
  i: Integer;
  Str: String;
begin
  for i:= 0 to LstViewPreferences.Items.Count-1 do
  	begin
    case i of
    	0: Str:= LstView_Caption_Item_0;
      1: Str:= LstView_Caption_Item_1;
      2: Str:= LstView_Caption_Item_2;
    end; //case
  	LstViewPreferences.Items[i].Caption:= Str;
    end;
end;

procedure TFrmPreferences.BtnChangeDtbPathClick(Sender: TObject);
var
  ChangePath: Boolean;
  NewPath: String;
begin
  ChangePath:= FuncDlgs.SelectDirDlg(SelectDirDlg_Title, EdiDtbPath.Text);
  if ChangePath=True then
    begin
    NewPath:= FrmMain.SelectDirDlg.FileName+'\';
    if FileExists(NewPath+'data.db') then
    	begin
	    INIFile.WriteString('Database','Path','"'+NewPath+'"');
  	  EdiDtbPath.Text:= NewPath;
      end
    	else Application.MessageBox(PChar(SelectDirDlg_Error_Msg), PChar(SelectDirDlg_Error_Title), MB_OK + MB_ICONERROR);
    end;
  FrmPreferences.Show;
end;

procedure TFrmPreferences.TabDatabaseShow(Sender: TObject);
begin
	EdiDtbPath.Text:= INIFile.ReadString('Database','Path',PathApp+'data\');
end;

procedure TFrmPreferences.TabGeneralShow(Sender: TObject);
begin
  case IDUnique of
    False: ChkIDUnique.State:= cbUnchecked;
    True: begin
    			ChkIDUnique.State:= cbChecked;
          ChkIDAutoRandom.Enabled:= True;
          ChkIDAllowBlank.Enabled:= True;
			    end;
  end; //case
  case IDAutoRandom of
    False: ChkIDAutoRandom.State:= cbUnchecked;
    True: ChkIDAutoRandom.State:= cbChecked;
  end; //case
  case IDAllowBlank of
    False: ChkIDAllowBlank.State:= cbUnchecked;
    True: ChkIDAllowBlank.State:= cbChecked;
  end; //case
end;

procedure TFrmPreferences.TabLanguageShow(Sender: TObject);
begin
  CboDateFormat.ItemIndex:= CboDateFormat.Items.IndexOf(INIFile.ReadString('Lang', 'ShortDateFormat', 'dd.mm.yyyy'));
  CboDateSeparator.ItemIndex:= CboDateSeparator.Items.IndexOf(INIFile.ReadString('Lang', 'DateSeparator', '/'));
end;

end.

