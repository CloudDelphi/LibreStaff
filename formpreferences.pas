unit FormPreferences;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, ComCtrls,
  StdCtrls, Buttons, ExtCtrls, FrameClose, LCLType;

type

  { TFrmPreferences }

  TFrmPreferences = class(TForm)
    BtnSaveCompanyName: TBitBtn;
    BtnChangeDtbPath: TBitBtn;
    CboDateFormat: TComboBox;
    CboDateSeparator: TComboBox;
    ChkReportPreview: TCheckBox;
    ChkIDAuto: TCheckBox;
    ChkIDAllowBlank: TCheckBox;
    ChkIDUnique: TCheckBox;
    CboAutoType: TComboBox;
    EdiDtbPath: TEdit;
    EdiCompanyName: TEdit;
    FraClose1: TFraClose;
    Dates: TGroupBox;
    GroupBox1: TGroupBox;
    GrpIDEmployee: TGroupBox;
    ImgLstPreferences: TImageList;
    LblCompanyName: TLabel;
    LblDatabasePath: TLabel;
    LblDateFormat: TLabel;
    LblDateSeparator: TLabel;
    LstViewPreferences: TListView;
    PagPreferences: TPageControl;
    Splitter1: TSplitter;
    TabDatabase: TTabSheet;
    TabLanguage: TTabSheet;
    TabGeneral: TTabSheet;
    TabPrinting: TTabSheet;
    procedure BtnChangeDtbPathClick(Sender: TObject);
    procedure BtnCloseClick(Sender: TObject);
    procedure BtnSaveCompanyNameClick(Sender: TObject);
    procedure CboAutoTypeChange(Sender: TObject);
    procedure CboDateFormatChange(Sender: TObject);
    procedure CboDateSeparatorChange(Sender: TObject);
    procedure ChkIDAllowBlankChange(Sender: TObject);
    procedure ChkIDAutoChange(Sender: TObject);
    procedure ChkIDUniqueChange(Sender: TObject);
    procedure ChkReportPreviewChange(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure LstViewPreferencesSelectItem(Sender: TObject; Item: TListItem;
      Selected: Boolean);
    procedure TabDatabaseShow(Sender: TObject);
    procedure TabGeneralShow(Sender: TObject);
    procedure TabLanguageShow(Sender: TObject);
    procedure TabPrintingShow(Sender: TObject);
  private
    { private declarations }
  public
    { public declarations }
  end;

var
  FrmPreferences: TFrmPreferences;

resourcestring
  lg_LstView_Caption_Item_0= 'Employees';
  lg_LstView_Caption_Item_1= 'Language';
  lg_LstView_Caption_Item_2= 'Database';
  lg_LstView_Caption_Item_3= 'Printing';
	lg_SelectDirDlg_Title= 'Select the path for the database (data.db)';
  lg_SelectDirDlg_Error_Title= 'ERROR!';
  lg_SelectDirDlg_Error_Msg= 'The file "data.db" does not exist in this path.';

implementation

{$R *.lfm}

{ TFrmPreferences }
uses
	FuncDlgs, FormMain, FuncData, DataModule;

procedure TFrmPreferences.LstViewPreferencesSelectItem(Sender: TObject;
  Item: TListItem; Selected: Boolean);
begin
	PagPreferences.ActivePageIndex:= Item.Index;
end;

procedure TFrmPreferences.BtnCloseClick(Sender: TObject);
begin
  Close;
end;

procedure TFrmPreferences.BtnSaveCompanyNameClick(Sender: TObject);
begin
  CompanyName:= EdiCompanyName.Text;
  UpdateRecord(DataMod.QueConfig, 'CompanyName', CompanyName, dtString);
end;

procedure TFrmPreferences.CboAutoTypeChange(Sender: TObject);
begin
  IDAutoType:= CboAutoType.ItemIndex;
  INIFile.WriteString('General', 'IDAutoType', IntToStr(IDAutoType));
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

procedure TFrmPreferences.ChkIDAutoChange(Sender: TObject);
begin
  IDAuto:= not IDAuto;
  CboAutoType.Enabled:= not CboAutoType.Enabled;
  INIFile.WriteString('General', 'IDAuto', BoolToStr(IDAuto));
end;

procedure TFrmPreferences.ChkIDUniqueChange(Sender: TObject);
begin
  IDUnique:= not IDUnique;
  INIFile.WriteString('General', 'IDUnique', BoolToStr(IDUnique));
  ChkIDAuto.Enabled:= ChkIDUnique.Checked;
  ChkIDAllowBlank.Enabled:= ChkIDUnique.Checked;
end;

procedure TFrmPreferences.ChkReportPreviewChange(Sender: TObject);
begin
  ReportPreview:= not ReportPreview;
  INIFile.WriteString('Printing', 'ReportPreview', BoolToStr(ReportPreview));
end;

procedure TFrmPreferences.FormCreate(Sender: TObject);
var
  i: Integer;
  Str: String;
begin
  for i:= 0 to LstViewPreferences.Items.Count-1 do
  	begin
    case i of
    	0: Str:= lg_LstView_Caption_Item_0;
      1: Str:= lg_LstView_Caption_Item_1;
      2: Str:= lg_LstView_Caption_Item_2;
      3: Str:= lg_LstView_Caption_Item_3;
    end; //case
  	LstViewPreferences.Items[i].Caption:= Str;
    end;
  //Load the Glyphs:
  FrmMain.ImgLstBtn.GetBitmap(3, BtnSaveCompanyName.Glyph);
  //Goto the first Tab
  PagPreferences.TabIndex:= 0;
end;

procedure TFrmPreferences.BtnChangeDtbPathClick(Sender: TObject);
var
  ChangePath: Boolean;
  NewPath: String;
begin
  ChangePath:= FuncDlgs.SelectDirDlg(lg_SelectDirDlg_Title, EdiDtbPath.Text);
  if ChangePath=True then
    begin
    NewPath:= FrmMain.SelectDirDlg.FileName+'\';
    if FileExists(NewPath+'data.db') then
    	begin
	    INIFile.WriteString('Database','Path','"'+NewPath+'"');
  	  EdiDtbPath.Text:= NewPath;
      end
    	else Application.MessageBox(PChar(lg_SelectDirDlg_Error_Msg), PChar(lg_SelectDirDlg_Error_Title), MB_OK + MB_ICONERROR);
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
          ChkIDAuto.Enabled:= True;
          ChkIDAllowBlank.Enabled:= True;
			    end;
  end; //case
  case IDAuto of
    False: 	begin
    				ChkIDAuto.State:= cbUnchecked;
            CboAutoType.Enabled:= False;
					  end;
    True: 	begin
    				ChkIDAuto.State:= cbChecked;
            CboAutoType.Enabled:= True;
				    end;
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

procedure TFrmPreferences.TabPrintingShow(Sender: TObject);
begin
  case ReportPreview of
    False:	ChkReportPreview.State:= cbUnchecked;
    True:		ChkReportPreview.State:= cbChecked;
  end; //case
  EdiCompanyName.Text:= CompanyName;
end;

end.

