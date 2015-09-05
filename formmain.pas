unit FormMain;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, sqlite3conn, sqldb, FileUtil, DBDateTimePicker, Forms,
  Controls, Graphics, Dialogs, ExtCtrls, ComCtrls, DbCtrls, StdCtrls,
  Buttons, DataModule, FormPicEmployee, FormPreferences, INIfiles,
  PopupNotifier, gettext, LCLType, FormPrgBar;

type
	TDataFormat= (dtString, dtInteger, dtDate);
type
	TCboListType= (cblStates);
type
	TWhatSearch= (wsEmployees);
type
  { TFrmMain }
  TFrmMain = class(TForm)
    BtnEditTypeContracts: TBitBtn;
    BtnInactive: TBitBtn;
    BtnSearch: TBitBtn;
    BtnEditStateList: TBitBtn;
    BtnSave: TBitBtn;
    BtnDelete: TBitBtn;
    BtnNew: TBitBtn;
    CboFilter: TComboBox;
    DBCboState: TDBComboBox;
    DBDatBirthday: TDBDateTimePicker;
    DBDatInitContract: TDBDateTimePicker;
    DBDatEndContract: TDBDateTimePicker;
    DBENameEmployee: TDBEdit;
    DBEIDEmployee: TDBEdit;
    DBESurname1: TDBEdit;
    DBENameEmployee2: TDBEdit;
    DBENameEmployee3: TDBEdit;
    DBESSN: TDBEdit;
    DBENameEmployee5: TDBEdit;
    DBECity: TDBEdit;
    DBEPhone: TDBEdit;
    DBECell: TDBEdit;
    DBEEmail: TDBEdit;
    DBLkCboTypeContract: TDBLookupComboBox;
    GroupBox1: TGroupBox;
    GrpMisc: TGroupBox;
    ImGPreferences: TImage;
    Label1: TLabel;
    LblBirthday: TLabel;
    LblBirthday1: TLabel;
    LblBirthday2: TLabel;
    LblBirthday3: TLabel;
    LblIDEmployee: TLabel;
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
    PopNot: TPopupNotifier;
    SaveDlg: TSaveDialog;
    SelectDirDlg: TSelectDirectoryDialog;
    StatusBar1: TStatusBar;
    TabEmployees: TTabSheet;
    TabAddress: TTabSheet;
    TabPersonalData: TTabSheet;
    TabContract: TTabSheet;
    TabHistoricContracts: TTabSheet;
    procedure BtnDeleteClick(Sender: TObject);
    procedure BtnEditStateListClick(Sender: TObject);
    procedure BtnEditTypeContractsClick(Sender: TObject);
    procedure BtnNewClick(Sender: TObject);
    procedure BtnSaveClick(Sender: TObject);
    procedure BtnSearchClick(Sender: TObject);
    procedure CboFilterChange(Sender: TObject);
    procedure DBEIDEmployeeExit(Sender: TObject);
    procedure DBNavBeforeAction(Sender: TObject; Button: TDBNavButtonType);
    procedure DBNavClick(Sender: TObject; Button: TDBNavButtonType);
    procedure FormActivate(Sender: TObject);
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure ImGPreferencesClick(Sender: TObject);
    procedure ImgExitClick(Sender: TObject);
    procedure PicEmployeeClick(Sender: TObject);
  private
    { private declarations }
    CurrentRec, TotalRecs: Integer;
    procedure DisableEmployees;
    procedure EnableEmployees;
    function IDIsUnique: Boolean;
    function RandomID(PLen: Integer): String;
  public
    { public declarations }
    procedure UpdateNavRec;
  end;

var
  FrmMain: TFrmMain;
  PathApp, DatabasePath, Databasename: String;
  IniFile: TINIFile;
  Lang, FallBacklang: String;
  StatesFilename: String;
  IDUnique, IDAutoRandom, IDAllowBlank: Boolean;

resourcestring
	LblNavRecOf= 'of';
  FrmStatesTitle= 'States';

implementation

{$R *.lfm}

{ TFrmMain }

uses
    FuncData, FormListEditor, FormSearch, DateTimePicker, FormSimpleTableEdit,
    Math, db;
//------------------------------------------------------------------------------
//Private functions & procedures
//------------------------------------------------------------------------------
procedure TFrmMain.DisableEmployees;
begin
  BtnSave.Enabled:= False;
  BtnDelete.Enabled:= False;
  BtnSearch.Enabled:= False;
  BtnEditStateList.Enabled:= False;
  BtnEditTypeContracts.Enabled:= False;
end;
procedure TFrmMain.EnableEmployees;
begin
  BtnSave.Enabled:= True;
  BtnDelete.Enabled:= True;
	BtnSearch.Enabled:= True;
  BtnEditStateList.Enabled:= True;
  BtnEditTypeContracts.Enabled:= True;
end;

procedure TFrmMain.UpdateNavRec;
begin
  CurrentRec:= DataMod.DsoEmployees.DataSet.RecNo;
  LblNavRec.Caption:= IntToStr(CurrentRec) + ' '+LblNavRecOf +' '+ IntToStr(TotalRecs);
  DataMod.QueEmployees.Edit;
end;
function TFrmMain.RandomID(PLen: Integer): string;
var
  str: string;
begin
  Randomize;
  //string with all possible chars
  str:= 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890-?%$_:!'+
  			'/&()';
  Result:= '';
  repeat
    Result:= Result + str[Random(Length(str)) + 1];
  until (Length(Result) = PLen)
end;
//------------------------------------------------------------------------------
procedure TFrmMain.FormCreate(Sender: TObject);
var
  tfOut: TextFile;
  DateFormat: TDateDisplayOrder;
  DateSeparator: String;
begin
  PathApp:= ExtractFilePath(Paramstr(0));
  SQLiteLibraryName:= PathApp+'sqlite3.dll';
  GetLanguageIDs(Lang, FallbackLang);
  //INI File Section:
  INIFile:= TINIFile.Create(PathApp+'config.ini', True);
	if not FileExists(PathApp+'config.ini') then
    INIFile.WriteString('Database', 'Path', '"'+PathApp+'data\"');
  //Format the CboDat's
	ShortDateFormat:= INIFile.ReadString('Lang', 'ShortDateFormat', 'dd.mm.yyyy');
	Case ShortDateFormat of
  	'dd.mm.yyyy': DateFormat:= ddoDMY;
   	'mm.dd.yyyy': DateFormat:= ddoMDY;
   	'yyyy.mm.dd': DateFormat:= ddoYMD;
  end; //case
  DateSeparator:= INIFile.ReadString('Lang', 'DateSeparator', '/');
  DBDatBirthday.DateDisplayOrder:= DateFormat;
  DBDatBirthday.DateSeparator:= DateSeparator;
  DBDatInitContract.DateDisplayOrder:= DateFormat;
  DBDatInitContract.DateSeparator:= DateSeparator;
  DBDatEndContract.DateDisplayOrder:= DateFormat;
  DBDatEndContract.DateSeparator:= DateSeparator;
	//Load the combos:
  StatesFilename:= DatabasePath+'states_'+Lang+'.txt';
  if not FileExists(StatesFilename) then
      begin
	    AssignFile(tfOut, StatesFilename);
      ReWrite(tfOut);
      CloseFile(tfOut);
      end;
  DBCboState.Items.LoadFromFile(StatesFilename);
  //Read the ID Employee field
  IDUnique:= StrToBool(INIFile.ReadString('General','IDUnique','False'));
  IDAutoRandom:= StrToBool(INIFile.ReadString('General','IDAutoRandom','False'));
  IDAllowBlank:= StrToBool(INIFile.ReadString('General','IDAllowBlank','False'));
  //get bitmaps for the buttons
  ImgLstBtn.GetBitmap(0, BtnNew.Glyph);
	ImgLstBtn.GetBitmap(10, BtnDelete.Glyph);
	ImgLstBtn.GetBitmap(3, BtnSave.Glyph);
  ImgLstBtn.GetBitmap(8, BtnSearch.Glyph);
end;

procedure TFrmMain.FormShow(Sender: TObject);
type TLoadQueries = record
	Query: TSQLQuery;
  SQL: String;
end;
var
  LoadQueries: array of TLoadQueries;
  i: Integer;
  Bookmark: String;
  BookmarkInt: Integer;
const
  LoadQueriesCount= 3;
begin
  //Connect & Load to database
  DatabasePath:= INIFile.ReadString('Database', 'Path', PathApp+'data\');
  Databasename:= DatabasePath + 'data.db';
  FuncData.ConnectDatabase(Databasename);
  //Open Tables
  //Note: The order is important! First the detailed tables.
  SetLength(LoadQueries, 3);
  LoadQueries[0].Query:= DataMod.QueTypeContracts;
  LoadQueries[0].SQL:= 'SELECT * from TypeContracts;';
  LoadQueries[1].Query:= DataMod.QueEmployees;
  LoadQueries[1].SQL:= 'SELECT * from Employees;';
  LoadQueries[2].Query:= DataMod.QuePicsEmployees;
  LoadQueries[2].SQL:= 'SELECT * from PicsEmployees WHERE PicsEmployees.Employee_ID=:ID_Employee;';
	for i:= Low(LoadQueries) to High(LoadQueries) do
  	begin
		FuncData.ExecSQL(LoadQueries[i].Query, LoadQueries[i].SQL);
	  FrmPrgBar.PrgBar.Position:= Round(100/(LoadQueriesCount-i));
    end;
  //Mark the table for edition:
  DataMod.QueEmployees.Edit;
  //Grab the total amount of records:
	TotalRecs:= DataMod.QueEmployees.RecordCount;
  //Get the bookmark and then apply it:
  Bookmark:= INIFile.ReadString('TableEmployees', 'Bookmark', '0');
  BookmarkInt:= StrToInt(Bookmark);
  if (BookmarkInt>0) AND (BookmarkInt<=TotalRecs) then
		DataMod.QueEmployees.RecNo:= BookmarkInt;
	//Update the Navigator lavel of current record & total records
	UpdateNavRec;
  if TotalRecs=0 then
    DisableEmployees;
  //Close the Progress Bar
	FrmPrgBar.Close;
 	Screen.Cursor:=crDefault;
end;

procedure TFrmMain.ImGPreferencesClick(Sender: TObject);
begin
  Application.CreateForm(TFrmPreferences, FrmPreferences);
	FrmPreferences.ShowModal;
end;

procedure TFrmMain.BtnSaveClick(Sender: TObject);
begin
  FuncData.SaveTable(DataMod.QueEmployees);
  DataMod.QueEmployees.Edit;
end;
procedure TFrmMain.BtnSearchClick(Sender: TObject);
begin
	FrmSearch.Search(wsEmployees);
  FrmSearch.Free;
  FrmSearch:= nil;
end;

procedure TFrmMain.CboFilterChange(Sender: TObject);
begin
  Case CboFilter.ItemIndex of
  0: begin

     end;
  1: begin

     end;
  2: begin

     end;
  3: begin

     end;
  end;
  {Changing the recordcount-->}
  TotalRecs:= DataMod.QueEmployees.RecordCount;
  UpdateNavRec;
end;

procedure TFrmMain.DBEIDEmployeeExit(Sender: TObject);
begin
	if (IDUnique= True) AND (TotalRecs>0) then IDIsUnique;
end;

procedure TFrmMain.DBNavBeforeAction(Sender: TObject; Button: TDBNavButtonType);
begin
  if (IDUnique= True) AND (DBEIDEmployee.Focused= True) then
  		if IDIsUnique= False then Abort;
end;

function TFrmMain.IDIsUnique: Boolean;
var
  Unique: Boolean;
  Msg: String;
begin
  //Check if is unique
  Unique:= True;
  if (IDAllowBlank= False) AND (DBEIDEmployee.Text='') then
  	begin
    Unique:= False;
	  Msg:= 'This ID# cannot be in blank'#13'It should be UNIQUE!'
  	end;
  if (Unique= True)then
    begin
    if (IDAllowBlank= False) OR ((IDAllowBlank= True) AND (DBEIDEmployee.Text<>'')) then
	    begin
		  FuncData.ExecSQL(DataMod.QueSearch, 'SELECT Employees.IDN_Employee from Employees WHERE Employees.IDN_Employee="'+
  				DBEIDEmployee.Text+'" AND Employees.ID_Employee!='+DataMod.QueEmployees.FieldByName('ID_Employee').AsString+';');
		  if DataMod.QueSearch.RecordCount>0 then
  	    begin
    	  Unique:= False;
      	Msg:= 'This ID# is in use by another Employee'#13'It should be UNIQUE!'
	      end;
  	  end;
    end;
  if Unique= False then
  	begin
   	DBEIDEmployee.Color:= clRed;
    Application.MessageBox(PChar(Msg), 'Error!', MB_OK);
    DBEIDEmployee.SetFocus;
    DBEIDEmployee.Color:= clDefault;
    Result:= False;
    end
  else
  	Result:= True;
end;

procedure TFrmMain.DBNavClick(Sender: TObject; Button: TDBNavButtonType);
begin
	inherited; //<-- to execute the default onclick event
	UpdateNavRec;
end;

procedure TFrmMain.FormActivate(Sender: TObject);
begin

end;

procedure TFrmMain.FormClose(Sender: TObject; var CloseAction: TCloseAction);
var
  RecNo: Integer;
begin
  RecNo:= DataMod.QueEmployees.RecNo;
  INIFile.WriteString('TableEmployees', 'Bookmark', IntToStr(RecNo));
  DataMod.Connection.CloseTransactions;
  DataMod.Connection.CloseDataSets;
  DataMod.Connection.Connected:= False;
  INIFile.Free;
end;
procedure TFrmMain.BtnNewClick(Sender: TObject);
const
  WriteFieldsCount= 1;
var
  RandomInt: Integer;
begin
	SetLength(WriteFields, WriteFieldsCount);
  WriteFields[0].FieldName:= 'IDN_Employee';
  if (IDUnique= True) AND (IDAutoRandom= True) then
		WriteFields[0].Value:= RandomID(12)
    else WriteFields[0].Value:= '';
  WriteFields[0].DataFormat:= dtString;
  if FuncData.AppendTableRecord(DataMod.QueEmployees, WriteFields)= True then
	  begin
	 	Inc(TotalRecs, 1);
    UpdateNavRec;
  	if (BtnSave.Enabled= False) then
			EnableEmployees;
		end;
  WriteFields:= nil;
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
    if TotalRecs=0 then
			DisableEmployees;
    end;
end;

procedure TFrmMain.BtnEditStateListClick(Sender: TObject);
begin
	FrmListEditor.EditList(FrmStatesTitle, StatesFilename, cblStates);
  FrmListEditor.Free;
	FrmListEditor:= nil;
end;

procedure TFrmMain.BtnEditTypeContractsClick(Sender: TObject);
begin
  Application.CreateForm(TFrmSimpleTableEdit, FrmSimpleTableEdit);
  FrmSimpleTableEdit.ShowModal;
end;

procedure TFrmMain.ImgExitClick(Sender: TObject);
begin
  Close;
end;
procedure TFrmMain.PicEmployeeClick(Sender: TObject);
begin
	if TotalRecs>0 then
  	begin
    Application.CreateForm(TFrmPicEmployee, FrmPicEmployee);
    FrmPicEmployee.ShowModal;
    end;
end;

end.
