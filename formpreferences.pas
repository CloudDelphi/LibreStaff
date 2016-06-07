unit FormPreferences;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, ComCtrls,
  StdCtrls, Buttons, ExtCtrls, FrameClose, LCLType, DbCtrls, BufDataset, db,
  Globals, FormDsoEditor, Types;

type

  { TFrmPreferences }

  TFrmPreferences = class(TForm)
    BtnChangeDtbPath: TBitBtn;
    BtnEditUsers: TSpeedButton;
    BtnPermissions: TSpeedButton;
    BtnSaveCompanyName: TBitBtn;
    BtnSaveMySQLOptions: TBitBtn;
    CboDateFormat: TComboBox;
    CboDateSeparator: TComboBox;
    ChkReportPreview: TCheckBox;
    ChkIDAuto: TCheckBox;
    ChkIDAllowBlank: TCheckBox;
    ChkIDUnique: TCheckBox;
    CboAutoType: TComboBox;
    DBAccessControlEnabled: TDBCheckBox;
    DbLkCboAtomicCommit: TDBLookupComboBox;
    DbLkCboDBEngines: TDBLookupComboBox;
    EdiCompanyName: TEdit;
    EdiDtbPath: TEdit;
    EdiMySQLHostName: TEdit;
    EdiMySQLDatabaseName: TEdit;
    EdiMySQLUserName: TEdit;
    EdiMySQLPassword: TEdit;
    FraClose1: TFraClose;
    Dates: TGroupBox;
    GroupBox1: TGroupBox;
    GrpIDEmployee: TGroupBox;
    GrpIDEmployee1: TGroupBox;
    GrpSQLite: TGroupBox;
    GrpMySQL: TGroupBox;
    ImgLogoMySQL: TImage;
    ImgLogoSQLite: TImage;
    ImgLstPreferences: TImageList;
    LblCompanyName: TLabel;
    LblDatabasePath: TLabel;
    LblHostNameMySQL: TLabel;
    LblDatabaseName: TLabel;
    LblUserNameMySQL: TLabel;
    LblPasswordMySQL: TLabel;
    LblDBEngine: TLabel;
    LblJournalMode: TLabel;
    LblDateFormat: TLabel;
    LblDateSeparator: TLabel;
    LstViewPreferences: TListView;
    PagDBEngine: TPageControl;
    PagPreferences: TPageControl;
    Splitter1: TSplitter;
    TabDatabase: TTabSheet;
    TabLanguage: TTabSheet;
    TabGeneral: TTabSheet;
    TabPrinting: TTabSheet;
    TabAccessControl: TTabSheet;
    TabMySQLOptions: TTabSheet;
    TabSQLiteOptions: TTabSheet;
    procedure BtnChangeDtbPathClick(Sender: TObject);
    procedure BtnCloseClick(Sender: TObject);
    procedure BtnEditUsersClick(Sender: TObject);
    procedure BtnPermissionsClick(Sender: TObject);
    procedure BtnSaveCompanyNameClick(Sender: TObject);
    procedure BtnSaveMySQLOptionsClick(Sender: TObject);
    procedure CboAutoTypeChange(Sender: TObject);
    procedure CboDateFormatChange(Sender: TObject);
    procedure CboDateSeparatorChange(Sender: TObject);
    procedure ChkIDAllowBlankChange(Sender: TObject);
    procedure ChkIDAutoChange(Sender: TObject);
    procedure ChkIDUniqueChange(Sender: TObject);
    procedure ChkReportPreviewChange(Sender: TObject);
    procedure DBAccessControlEnabledChange(Sender: TObject);
    procedure DbLkCboAtomicCommitCloseUp(Sender: TObject);
    procedure DbLkCboDBEnginesCloseUp(Sender: TObject);
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure FormCreate(Sender: TObject);
    procedure LstViewPreferencesSelectItem(Sender: TObject; Item: TListItem;
      Selected: Boolean);
    procedure TabDatabaseShow(Sender: TObject);
    procedure TabGeneralShow(Sender: TObject);
    procedure TabLanguageShow(Sender: TObject);
    procedure TabMySQLOptionsShow(Sender: TObject);
    procedure TabPrintingShow(Sender: TObject);
    procedure TabSQLiteOptionsShow(Sender: TObject);
  private
    { private declarations }
    procedure ChangeDBEngineTab;
  public
    { public declarations }
  end;

var
  FrmPreferences: TFrmPreferences;
  LstAtomicCommit: TBufDataset;
  DsoLstAtomicCommit: TDatasource;
  LstDBEngines: TBufDataset;
  DsoLstDBEngines: TDatasource;

resourcestring
  lg_LstView_Caption_Item_0= 'Employees';
  lg_LstView_Caption_Item_1= 'Language';
  lg_LstView_Caption_Item_2= 'Database';
  lg_LstView_Caption_Item_3= 'Printing';
  lg_LstView_Caption_Item_4= 'Access Control';
	lg_SelectDirDlg_Title= 'Select the path for the database (xxx.db)';
  lg_SelectDirDlg_Error_Title= 'ERROR!';
  lg_SelectDirDlg_Error_Msg= 'The file "xxx.db" does not exist in this path.';

implementation

{$R *.lfm}

{ TFrmPreferences }
uses
	FuncDlgs, FormMain, FuncData, DataModule, FormPermissions;

procedure TFrmPreferences.LstViewPreferencesSelectItem(Sender: TObject;
  Item: TListItem; Selected: Boolean);
begin
	PagPreferences.ActivePageIndex:= Item.Index;
end;

procedure TFrmPreferences.BtnCloseClick(Sender: TObject);
begin
  Close;
end;

procedure TFrmPreferences.BtnEditUsersClick(Sender: TObject);
begin
	FrmDsoEditor.EditTable(wtUsers);
end;

procedure TFrmPreferences.BtnPermissionsClick(Sender: TObject);
begin
  Application.CreateForm(TFrmPermissions, FrmPermissions);
	FrmPermissions.ShowModal;
end;

procedure TFrmPreferences.BtnSaveCompanyNameClick(Sender: TObject);
begin
  CompanyName:= EdiCompanyName.Text;
  UpdateRecord(DataMod.QueConfig, 'CompanyName', CompanyName, dtString);
end;

procedure TFrmPreferences.BtnSaveMySQLOptionsClick(Sender: TObject);
begin
  INIFile.WriteString('MySQL', 'DatabaseName', QuotedStr(EdiMySQLDatabaseName.Text));
	INIFile.WriteString('MySQL', 'HostName', QuotedStr(EdiMySQLHostName.Text));
	INIFile.WriteString('MySQL', 'UserName', QuotedStr(EdiMySQLUserName.Text));
	INIFile.WriteString('MySQL', 'Password', QuotedStr(EdiMySQLPassword.Text));
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

procedure TFrmPreferences.DBAccessControlEnabledChange(Sender: TObject);
begin
  FuncData.SaveTable(DataMod.QueConfig);
end;

procedure TFrmPreferences.DbLkCboAtomicCommitCloseUp(Sender: TObject);
begin
	FuncData.SaveTable(DataMod.QueConfig);
end;

procedure TFrmPreferences.DbLkCboDBEnginesCloseUp(Sender: TObject);
begin
  FuncData.SaveTable(DataMod.QueConfig);
  INIFile.WriteInteger('Database', 'DBEngine', DbLkCboDBEngines.ItemIndex);
  ChangeDBEngineTab;
end;

procedure TFrmPreferences.ChangeDBEngineTab;
begin
  case (DbLkCboDBEngines.ItemIndex) of
    0: PagDBEngine.ActivePageIndex:= 0;
    1: PagDBEngine.ActivePageIndex:= 1;
  end;
end;

procedure TFrmPreferences.FormClose(Sender: TObject;
  var CloseAction: TCloseAction);
begin
  FrmPreferences.Release;
  if Assigned(LstAtomicCommit) then
  	begin
    FreeAndNil(DsoLstAtomicCommit);
	  FreeAndNil(LstAtomicCommit);
    end;
	if Assigned(LstDBEngines) then
    begin
    FreeAndNil(DsoLstDBEngines);
	  FreeAndNil(LstDBEngines);
    end;
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
      4: Str:= lg_LstView_Caption_Item_4;
    end; //case
  	LstViewPreferences.Items[i].Caption:= Str;
    end;
  //Load the Glyphs:
  FrmMain.ImgLstBtn.GetBitmap(3, BtnSaveCompanyName.Glyph);
  FrmMain.ImgLstBtn.GetBitmap(21, BtnEditUsers.Glyph);
  FrmMain.ImgLstBtn.GetBitmap(22, BtnPermissions.Glyph);
  FrmMain.ImgLstBtn.GetBitmap(3, BtnSaveMySQLOptions.Glyph);
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
    if FileExists(NewPath+DATABASE_NAME) then
    	begin
	    INIFile.WriteString('Database','Path',QuotedStr(NewPath));
  	  EdiDtbPath.Text:= NewPath;
      end
    	else Application.MessageBox(PChar(lg_SelectDirDlg_Error_Msg), PChar(lg_SelectDirDlg_Error_Title), MB_OK + MB_ICONERROR);
    end;
  FrmPreferences.Show;
end;

procedure TFrmPreferences.TabDatabaseShow(Sender: TObject);
begin
   if Not(Assigned(LstDBEngines)) then //only it create the first time tab is selected
    begin
 		LstDBEngines:= TBufDataset.Create(self);
		LstDBEngines.FieldDefs.Add('ID_DBEngine', ftInteger);
		LstDBEngines.FieldDefs.Add('DBEngine', ftString, 20);
		LstDBEngines.CreateDataset;
		LstDBEngines.Open;
    LstDBEngines.Insert;
    LstDBEngines.FieldByName('ID_DBEngine').AsInteger:= 1;
    LstDBEngines.FieldByName('DBEngine').AsString:= 'MySQL 5.6';
    LstDBEngines.Insert;
    LstDBEngines.FieldByName('ID_DBEngine').AsInteger:= 0;
    LstDBEngines.FieldByName('DBEngine').AsString:= 'SQLite';
    LstDBEngines.Post;
    DsoLstDBEngines:= TDatasource.Create(self);
    DsoLstDBEngines.DataSet:= LstDBEngines;
    end;
  DbLkCboDBEngines.ListSource:= DsoLstDBEngines;
  DbLkCboDBEngines.ItemIndex:= DBEngine.ID;
  ChangeDBEngineTab;
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

procedure TFrmPreferences.TabMySQLOptionsShow(Sender: TObject);
begin
	EdiMySQLHostName.Text:= INIFile.ReadString('MySQL', 'HostName', '');
  EdiMySQLUserName.Text:= INIFile.ReadString('MySQL', 'UserName', '');
  EdiMySQLPassword.Text:= INIFile.ReadString('MySQL', 'Password', '');
end;

procedure TFrmPreferences.TabPrintingShow(Sender: TObject);
begin
  case ReportPreview of
    False:	ChkReportPreview.State:= cbUnchecked;
    True:		ChkReportPreview.State:= cbChecked;
  end; //case
  EdiCompanyName.Text:= CompanyName;
end;

procedure TFrmPreferences.TabSQLiteOptionsShow(Sender: TObject);
begin
	EdiDtbPath.Text:= INIFile.ReadString('Database','Path',PathApp+'data\');
  if Not(Assigned(LstAtomicCommit)) then //only it create the first time tab is selected
    begin
 		LstAtomicCommit:= TBufDataset.Create(self);
		LstAtomicCommit.FieldDefs.Add('ID_AtomicCommit', ftInteger);
		LstAtomicCommit.FieldDefs.Add('AtomicCommit', ftString, 20);
		LstAtomicCommit.CreateDataset;
		LstAtomicCommit.Open;
    LstAtomicCommit.Insert;
    LstAtomicCommit.FieldByName('ID_AtomicCommit').AsInteger:= 0;
    LstAtomicCommit.FieldByName('AtomicCommit').AsString:= 'Rollback journal';
    LstAtomicCommit.Insert;
    LstAtomicCommit.FieldByName('ID_AtomicCommit').AsInteger:= 1;
    LstAtomicCommit.FieldByName('AtomicCommit').AsString:= 'Write-Ahead Logging (WAL)';
    LstAtomicCommit.Post;
    DsoLstAtomicCommit:= TDatasource.Create(self);
    DsoLstAtomicCommit.DataSet:= LstAtomicCommit;
    end;
  DbLkCboAtomicCommit.ListSource:= DsoLstAtomicCommit;
end;

end.

