unit FormMain;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, sqlite3conn, sqldb, db, FileUtil, Forms, Controls,
  Graphics, Dialogs, ExtCtrls, ComCtrls, DbCtrls, StdCtrls, DBGrids, Buttons,
  DataModule, types, FormPicEmployee, FormPreferences, INIfiles, Translations,
  gettext;

type
	TCboListType= (cblStates);
type
  { TFrmMain }
  TFrmMain = class(TForm)
    BtnEditStateList: TBitBtn;
    BtnSave: TBitBtn;
    BtnDelete: TBitBtn;
    BtnNew: TBitBtn;
    DBCboState: TDBComboBox;
    DBENameEmployee: TDBEdit;
    DBESurname1: TDBEdit;
    DBENameEmployee2: TDBEdit;
    DBENameEmployee3: TDBEdit;
    DBESSN: TDBEdit;
    DBENameEmployee5: TDBEdit;
    DBECity: TDBEdit;
    DBEPhone: TDBEdit;
    DBECell: TDBEdit;
    DBEEmail: TDBEdit;
    ImGPreferences: TImage;
    MmoAddress: TDBMemo;
    DBNav: TDBNavigator;
    GrpAddressEmployee: TGroupBox;
    GrprContactEmployee: TGroupBox;
    ImgLstBtn: TImageList;
    ImgExit: TImage;
    LblNameEmployee: TLabel;
    LblNameEmployee1: TLabel;
    LblPhone: TLabel;
    LblCell: TLabel;
    LblEMail: TLabel;
    LblSurname2: TLabel;
    LblIDCard: TLabel;
    LblSSE: TLabel;
    LblAddress: TLabel;
    LblZipCode: TLabel;
    LblCity: TLabel;
    LblState: TLabel;
    LblNavRec: TLabel;
    OpenDlg: TOpenDialog;
    PagMain: TPageControl;
    PagEmployees: TPageControl;
    Panel1: TPanel;
    Pan: TPanel;
    PanSep: TPanel;
    PanPicEmployee: TPanel;
    PanNavRec: TPanel;
    PanMain: TPanel;
    PicEmployee: TDBImage;
    SaveDlg: TSaveDialog;
    SelectDirDlg: TSelectDirectoryDialog;
    StatusBar1: TStatusBar;
    TabEmployees: TTabSheet;
    TabPersonalData: TTabSheet;
    procedure BtnDeleteClick(Sender: TObject);
    procedure BtnEditStateListClick(Sender: TObject);
    procedure BtnNewClick(Sender: TObject);
    procedure BtnSaveClick(Sender: TObject);
    procedure DBNavClick(Sender: TObject; Button: TDBNavButtonType);
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure FormCreate(Sender: TObject);
    procedure ImGPreferencesClick(Sender: TObject);
    procedure ImgExitClick(Sender: TObject);
    procedure PicEmployeeClick(Sender: TObject);
  private
    { private declarations }
    CurrentRec, TotalRecs: Integer;
    procedure UpdateNavRec;
  public
    { public declarations }
  end;

var
  FrmMain: TFrmMain;
  PathApp, 	DatabasePath: String;
  SentenceSQL: TStringList;
  IniFile: TINIFile;
  Lang, FallBacklang: String;
  StatesFilename: String;

resourcestring
	LblNavRecOf= 'of';
  FrmStatesTitle= 'States';

implementation

{$R *.lfm}

{ TFrmMain }

uses
    FuncData, FormListEditor;
//------------------------------------------------------------------------------
//Private functions & procedures
//------------------------------------------------------------------------------
procedure TFrmMain.UpdateNavRec;
begin
  CurrentRec:= DataMod.DsoEmployees.DataSet.RecNo;
  LblNavRec.Caption:= IntToStr(CurrentRec) + ' '+LblNavRecOf +' '+ IntToStr(TotalRecs);
end;
//------------------------------------------------------------------------------
procedure TFrmMain.FormCreate(Sender: TObject);
var
  tfOut: TextFile;
begin
  PathApp:= ExtractFilePath(Paramstr(0));
  SQLiteLibraryName:= PathApp+'sqlite3.dll';
  GetLanguageIDs(Lang, FallbackLang);
  SentenceSQL:= TStringList.Create;
  //INI File Section:
  INIFile:= TINIFile.Create(PathApp+'config.ini', True);
	if not FileExists(PathApp+'config.ini') then
  	begin
    INIFile.WriteString('Database', 'Path', PathApp+'data\');
    end;
	//Connect & Load to database
  DatabasePath:= INIFile.ReadString('Database', 'Path', PathApp+'data\');
  FuncData.ConnectDatabase(DatabasePath+'data.db');
  FuncData.ExecSQL(DataMod.QueEmployees, 'SELECT * from Employees;');
  if (DataMod.QueEmployees.IsEmpty= True) then
  	begin
    BtnSave.Enabled:= False;
    BtnDelete.Enabled:= False;
		end;
	FuncData.ExecSQL(DataMod.QuePicsEmployees, 'SELECT * from PicsEmployees WHERE PicsEmployees.Employee_ID=:ID_Employee;');
	ImgLstBtn.GetBitmap(0, BtnNew.Glyph);
	ImgLstBtn.GetBitmap(2, BtnDelete.Glyph);
	ImgLstBtn.GetBitmap(3, BtnSave.Glyph);
	TotalRecs:= DataMod.QueEmployees.RecordCount;
	UpdateNavRec;
	//Load the combos:
  StatesFilename:= DatabasePath+'states_'+Lang+'.txt';
  if not FileExists(StatesFilename) then
      begin
	    AssignFile(tfOut, StatesFilename);
      ReWrite(tfOut);
      CloseFile(tfOut);
      end;
  DBCboState.Items.LoadFromFile(StatesFilename);
end;

procedure TFrmMain.ImGPreferencesClick(Sender: TObject);
begin
  Application.CreateForm(TFrmPreferences, FrmPreferences);
	FrmPreferences.ShowModal;
end;

procedure TFrmMain.BtnSaveClick(Sender: TObject);
begin
  FuncData.SaveTable(DataMod.QueEmployees);
end;

procedure TFrmMain.DBNavClick(Sender: TObject; Button: TDBNavButtonType);
begin
  inherited; //<-- to execute the default onclick event
	UpdateNavRec;
end;
procedure TFrmMain.FormClose(Sender: TObject; var CloseAction: TCloseAction);
begin
  DataMod.Transaction.Active:= False;
  DataMod.Connection.Connected:= False;
end;
procedure TFrmMain.BtnNewClick(Sender: TObject);
begin
   if FuncData.AppendTableRecord(DataMod.QueEmployees)= True then
	   begin
		 Inc(TotalRecs, 1);
     UpdateNavRec;
  	 if (BtnSave.Enabled= False) then
         begin
         BtnSave.Enabled:= True;
         BtnDelete.Enabled:= True;
         end;
	   end;
end;
procedure TFrmMain.BtnDeleteClick(Sender: TObject);
var
  NameEmployee: String;
begin
  NameEmployee:= DataMod.QueEmployees.FieldByName('Name_employee').AsString;
	if FuncData.DeleteTableRecord(DataMod.QueEmployees, True, NameEmployee)= True then
  	begin
    Dec(TotalRecs, 1);
    UpdateNavRec;
    if (DataMod.QueEmployees.IsEmpty= True) then
    	begin
      BtnSave.Enabled:= False;
      BtnDelete.Enabled:= False;
      end;
    end;
end;

procedure TFrmMain.BtnEditStateListClick(Sender: TObject);
begin
	FrmListEditor.EditList(FrmStatesTitle, StatesFilename, cblStates);
  FrmListEditor.Free;
  FrmListEditor:= nil;
end;

procedure TFrmMain.ImgExitClick(Sender: TObject);
begin
  Close;
end;
procedure TFrmMain.PicEmployeeClick(Sender: TObject);
begin
	if (DataMod.QueEmployees.IsEmpty= False) then
  	begin
    Application.CreateForm(TFrmPicEmployee, FrmPicEmployee);
    FrmPicEmployee.ShowModal;
    end;
end;

end.
