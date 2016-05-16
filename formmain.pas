unit FormMain;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, sqlite3conn, sqldb, FileUtil, DBDateTimePicker, LR_Class,
  LR_DBSet, Forms, Controls, Graphics, Dialogs, ExtCtrls, ComCtrls, DbCtrls,
  StdCtrls, Buttons, DataModule, FormPicEmployee, INIfiles, PopupNotifier,
  gettext, LCLType, DBGrids, FormPrgBar, UniqueInstance, Types;

type
	TCboListType= (cblStates);
type
	TWhatTable= (wtEmployees, wtTypeContracts, wtWorkplaces, wtUsers);
type
  { TFrmMain }
  TFrmMain = class(TForm)
    BtnDelContractLog: TBitBtn;
    BtnPrint: TBitBtn;
    BtnDelTypeContract: TBitBtn;
    BtnDelWorkplace: TBitBtn;
    BtnEditTypeContracts: TBitBtn;
    BtnEditWorkplaces: TBitBtn;
    BtnActivate: TBitBtn;
    BtnSearch: TBitBtn;
    BtnEditStateList: TBitBtn;
    BtnSave: TBitBtn;
    BtnDelete: TBitBtn;
    BtnNew: TBitBtn;
    CboFilter: TComboBox;
    DBCboState: TDBComboBox;
    DBDatDateBirth: TDBDateTimePicker;
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
    DBGrdLogContracts: TDBGrid;
    DBLkCboTypeContract: TDBLookupComboBox;
    DBLkCboWorkplace: TDBLookupComboBox;
    DBRadGenre: TDBRadioGroup;
    DBRadMaritalStatus: TDBRadioGroup;
    frDBDataSet: TfrDBDataSet;
    frReport: TfrReport;
    GroupBox1: TGroupBox;
    GrpMisc: TGroupBox;
    Img16: TImageList;
    ImgAbout: TImage;
    ImgPreferences: TImage;
    ImgProfile: TImage;
    Label1: TLabel;
    LblSidebar: TLabel;
    LblInactive: TLabel;
    LblDateBirth: TLabel;
    LblBirthday1: TLabel;
    LblBirthday2: TLabel;
    LblBirthday3: TLabel;
    LblBirthday4: TLabel;
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
    DbMmoRemarkEmployee: TDBMemo;
    OpenDlg: TOpenDialog;
    PopNot: TPopupNotifier;
    Sidebar: TPageControl;
    PagMain: TPageControl;
    PagEmployees: TPageControl;
    PanBottom: TPanel;
    PanRight: TPanel;
    PanTop: TPanel;
    PanSep: TPanel;
    PanPicEmployee: TPanel;
    PanNavRec: TPanel;
    PanMain: TPanel;
    PanSep1: TPanel;
    PicEmployee: TDBImage;
    SaveDlg: TSaveDialog;
    SelectDirDlg: TSelectDirectoryDialog;
    SplMain: TSplitter;
    StBarMain: TStatusBar;
    TabEmployees: TTabSheet;
    TabAddress: TTabSheet;
    TabPersonalData: TTabSheet;
    TabContract: TTabSheet;
    TabContractsLog: TTabSheet;
    TabMnuContractsLog: TTabSheet;
    TabRemarks: TTabSheet;
    UniqueInstance: TUniqueInstance;
    procedure BtnDelContractLogClick(Sender: TObject);
    procedure BtnDeleteClick(Sender: TObject);
    procedure BtnDelTypeContractClick(Sender: TObject);
    procedure BtnDelWorkplaceClick(Sender: TObject);
    procedure BtnEditStateListClick(Sender: TObject);
    procedure BtnEditTypeContractsClick(Sender: TObject);
    procedure BtnEditWorkplacesClick(Sender: TObject);
    procedure BtnActivateClick(Sender: TObject);
    procedure BtnNewClick(Sender: TObject);
    procedure BtnPrintClick(Sender: TObject);
    procedure BtnSaveClick(Sender: TObject);
    procedure BtnSearchClick(Sender: TObject);
    procedure CboFilterChange(Sender: TObject);
    procedure DBEIDEmployeeExit(Sender: TObject);
    procedure DBNavBeforeAction(Sender: TObject; Button: TDBNavButtonType);
    procedure DBNavClick(Sender: TObject; Button: TDBNavButtonType);
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure ImgAboutClick(Sender: TObject);
    procedure ImgProfileClick(Sender: TObject);
    procedure ImgPreferencesClick(Sender: TObject);
    procedure ImgExitClick(Sender: TObject);
    procedure PicEmployeeClick(Sender: TObject);
    procedure TabContractsLogHide(Sender: TObject);
    procedure TabContractsLogShow(Sender: TObject);
    procedure TabMnuContractsLogContextPopup(Sender: TObject; MousePos: TPoint;
      var Handled: Boolean);
  private
    { private declarations }
    CurrentRec, TotalRecs: Integer;
    function AutoIncID: String;
    procedure DisableEmployees;
    procedure EnableEmployees;
    procedure HideSidebar;
    function IDIsUnique: Boolean;
    function RandomID(IDLen: Integer): String;
    procedure ShowSidebar;
  public
    { public declarations }
    procedure CheckPermissions;
    procedure CheckTabPermissions;
    procedure UpdateNavRec;
    procedure UpdateRecordCount;
  end;

var
  FrmMain: TFrmMain;
  StatesFilename: String;
  IDUnique, IDAuto, IDAllowBlank: Boolean;
  IDAutoType: Integer;
  FilterIndex: Integer;
  ReportPreview: Boolean;
  CompanyName: String;
  AtomicCommmit: Integer;

const
  DATABASEVERSION='0.0.0';
  SELECT_ALL_EMPLOYEES_SQL= 'SELECT * from Employees;';
  SELECT_ACTIVE_EMPLOYEES_SQL= 'SELECT * from Employees WHERE Active_Employee;';
  SELECT_INACTIVE_EMPLOYEES_SQL= 'SELECT * from Employees WHERE NOT(Active_Employee);';
  SELECT_CONTRACTSLOG_SQL= 'SELECT ContractsLog.*, TypeContracts.*, Workplaces.* FROM ContractsLog'+
  	' LEFT JOIN TypeContracts ON (ID_TypeContract=TypeContract_ID)'+
    ' LEFT JOIN Workplaces ON (ID_Workplace=Workplace_ID)'+
    ' WHERE (ContractsLog.Employee_ID=:ID_Employee)'+
    ' ORDER BY ContractsLog.DateEnd_Contract DESC;';
  SELECT_PICSEMPLOYEES_SQL= 'SELECT * from PicsEmployees WHERE PicsEmployees.Employee_ID=:ID_Employee;';
  SELECT_ALL_USERS_SQL= 'SELECT Users.*, Usergroups.Name_Usergroup from Users'+
    '  LEFT JOIN Usergroups ON (Users.Usergroup_ID=Usergroups.ID_Usergroup);';
  SELECT_ALL_USERGROUPS_SQL= 'SELECT * from Usergroups;';
  SELECT_PERMISSIONSUSERGROUPS_SQL= 'SELECT * from Permissions WHERE Permissions.Usergroup_ID=:ID_Usergroup;';

resourcestring
  lg_CaptionBtn_Activate= 'Activate';
  lg_CaptionBtn_Inactivate= 'Inactivate';
  lg_IDIsBlank= 'This ID# cannot be in blank'#13'It should be UNIQUE!';
  lg_IDIsNotUnique= 'This ID# is in use by another Employee'#13'It should be UNIQUE!';
  lg_BtnDelTypeContract_Hint= 'Delete the type of contract of this employee';
  lg_BtnDelWorkplace_Hint= 'Delete the workplace of this employee';
  lg_DelContractLogTarget= 'the selected contract in the log';
	lg_LblNavRecOf= 'of';
  lg_FrmStatesTitle= 'States';
  lg_Filter_Active= 'Actives';
  lg_Filter_Inactive= 'Inactives';
  lg_Filter_All= 'All';
  lg_Male= 'Male';
  lg_Female= 'Female';
  lg_Single= 'Single';
  lg_Married= 'Married';
  lg_Employee_Still_Not_Saved= 'You have to save the employee first.';

implementation

{$R *.lfm}

{ TFrmMain }

uses
    FuncData, FormListEditor, FormSearch, DateTimePicker, FormDsoEditor,
    FormAbout, FormActivationEmployee, FuncPrint, FormPreferences, Globals,
    FormProfile;

//------------------------------------------------------------------------------
//Private functions & procedures
//------------------------------------------------------------------------------
function TFrmMain.AutoIncID: String;
var
  ID: Integer;
begin
  FuncData.ExecSQL(DataMod.QueSearch, 'SELECT MAX(CAST(IDN_Employee AS INTEGER)) FROM Employees WHERE (NOT IDN_Employee IS NULL);');
  if Not(DataMod.QueSearch.Fields[0].AsString= '') then
    begin
    ID:= DataMod.QueSearch.Fields[0].AsInteger;
	  Inc(ID, 1);
  	Result:= IntToStr(ID);
    end;
end;

procedure TFrmMain.CheckPermissions;
begin
  if (AccessControl= TRUE) then
    begin
    if (User.Permissions.EditEmployee= TRUE) then
      begin
      BtnSave.Enabled:= True;
      BtnActivate.Enabled:= True;
      end
    else
      begin
      BtnSave.Enabled:= False;
      BtnActivate.Enabled:= False;
      end;
    if (User.Permissions.DeleteEmployee= TRUE) then
      BtnDelete.Enabled:= True
    else
      BtnDelete.Enabled:= False;
    if (User.Permissions.AddEmployee= TRUE) then
      BtnNew.Enabled:= True
    else
      BtnNew.Enabled:= False;
    end;
end;

procedure TFrmMain.DisableEmployees;
begin
  BtnSave.Enabled:= False;
  BtnDelete.Enabled:= False;
  BtnSearch.Enabled:= False;
  BtnActivate.Enabled:= False;
  BtnEditStateList.Enabled:= False;
  BtnEditTypeContracts.Enabled:= False;
  BtnEditWorkplaces.Enabled:= False;
  BtnPrint.Enabled:= False;
  LblInactive.Visible:= False;
end;

procedure TFrmMain.EnableEmployees;
begin
  BtnSave.Enabled:= True;
  BtnDelete.Enabled:= True;
	BtnSearch.Enabled:= True;
  BtnActivate.Enabled:= True;
  BtnEditStateList.Enabled:= True;
  BtnEditTypeContracts.Enabled:= True;
  BtnPrint.Enabled:= True;
  BtnEditWorkplaces.Enabled:= True;
end;

procedure TFrmMain.HideSidebar;
begin
  SplMain.Visible:= False;
	PanRight.Visible:= False;
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
	  Msg:= lg_IDIsBlank;
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
      	Msg:= lg_IDIsNotUnique;
	      end;
  	  end;
    end;
  if Unique= False then
  	begin
   	DBEIDEmployee.Color:= EDIT_ERROR_COLOR;
    Application.MessageBox(PChar(Msg), 'Error!', MB_OK);
    DBEIDEmployee.SetFocus;
    DBEIDEmployee.Color:= clDefault;
    Result:= False;
    end
  else
  	Result:= True;
end;

procedure TFrmMain.UpdateNavRec;
begin
  if DataMod.QueEmployees.FieldByName('Active_Employee').AsBoolean= True then
    begin
    BtnActivate.Caption:= lg_CaptionBtn_Inactivate;
    LblInactive.Visible:= False;
    ImgLstBtn.GetBitmap(13, BtnActivate.Glyph)
    end
  else
  	begin
    BtnActivate.Caption:= lg_CaptionBtn_Activate;
    LblInactive.Visible:= True;
    ImgLstBtn.GetBitmap(14, BtnActivate.Glyph)
    end;
  CurrentRec:= DataMod.DsoEmployees.DataSet.RecNo;
  LblNavRec.Caption:= IntToStr(CurrentRec) + ' '+lg_LblNavRecOf +' '+ IntToStr(TotalRecs);
  DataMod.QueEmployees.Edit;
  if (TotalRecs=0) then
    DisableEmployees
  else
    CheckPermissions;
end;
function TFrmMain.RandomID(IDLen: Integer): string;
var
  Str: string;
  Unique: Boolean;
begin
  Randomize;
  //string with all possible chars
  Str:= '1234567890';
  Result:= '';
  repeat
	  repeat
  	  Result:= Result + Str[Random(Length(Str)) + 1];
	  until (Length(Result) = IDLen);
    //Check If Random Generate Number Is Unique:
  	FuncData.ExecSQL(DataMod.QueSearch, 'SELECT Employees.IDN_Employee from Employees WHERE Employees.IDN_Employee="'+Result+'";');
		if DataMod.QueSearch.RecordCount>0 then
  	    Unique:= False
    else
				Unique:= True;
  until Unique= True;
end;

procedure TFrmMain.UpdateRecordCount;
begin
  TotalRecs:= DataMod.QueEmployees.RecordCount;
  UpdateNavRec;
end;
procedure TFrmMain.ShowSidebar;
begin
  SplMain.Visible:= True;
  PanRight.Visible:= True;
end;

//------------------------------------------------------------------------------

procedure TFrmMain.FormCreate(Sender: TObject);
var
  tfOut: TextFile;
  DateFormat: TDateDisplayOrder;
  DateSeparator: Char;
begin
  GetLanguageIDs(Lang, FallbackLang);
  //The mode of database Atomic Commit
  AtomicCommmit:= INIFile.ReadInteger('Database', 'AtomicCommit', 1);
  //Format the CboDat's
	DefaultFormatSettings.ShortDateFormat:= INIFile.ReadString('Lang', 'ShortDateFormat', 'dd.mm.yyyy');
	Case DefaultFormatSettings.ShortDateFormat of
  	'dd.mm.yyyy': DateFormat:= ddoDMY;
   	'mm.dd.yyyy': DateFormat:= ddoMDY;
   	'yyyy.mm.dd': DateFormat:= ddoYMD;
  end; //case
  DateSeparator:= INIFile.ReadString('Lang', 'DateSeparator', '/')[1];
  case DateFormat of
  	ddoDMY: DefaultFormatSettings.ShortDateFormat:= 'dd'+DateSeparator+'mm'+DateSeparator+'yyyy';
  	ddoMDY: DefaultFormatSettings.ShortDateFormat:= 'mm'+DateSeparator+'dd'+DateSeparator+'yyyy';
   	ddoYMD: DefaultFormatSettings.ShortDateFormat:= 'yyyy'+DateSeparator+'mm'+DateSeparator+'dd';
  end; //case
  DefaultFormatSettings.DateSeparator:= DateSeparator;
  DBDatDateBirth.DateDisplayOrder:= DateFormat;
  DBDatDateBirth.DateSeparator:= DateSeparator;
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
  IDAuto:= StrToBool(INIFile.ReadString('General','IDAuto','False'));
  IDAutoType:= StrToInt(INIFile.ReadString('General','IDAutoType','0'));
  IDAllowBlank:= StrToBool(INIFile.ReadString('General','IDAllowBlank','False'));
  //Get bitmaps for the buttons
  ImgLstBtn.GetBitmap(0, BtnNew.Glyph);
	ImgLstBtn.GetBitmap(10, BtnDelete.Glyph);
	ImgLstBtn.GetBitmap(3, BtnSave.Glyph);
  ImgLstBtn.GetBitmap(8, BtnSearch.Glyph);
  ImgLstBtn.GetBitmap(15, BtnPrint.Glyph);
  ImgLstBtn.GetBitmap(10, BtnDelTypeContract.Glyph);
  ImgLstBtn.GetBitmap(10, BtnDelWorkplace.Glyph);
	ImgLstBtn.GetBitmap(10, BtnDelContractLog.Glyph);
  //Load the Hints:
  BtnDelTypeContract.Hint:= lg_BtnDelTypeContract_Hint;
  BtnDelWorkplace.Hint:= lg_BtnDelWorkplace_Hint;
  //Load the Filter Items
  CboFilter.Items.Clear;
  CboFilter.Items.Add(lg_Filter_Active);
  CboFilter.Items.Add(lg_Filter_Inactive);
  CboFilter.Items.Add(lg_Filter_All);
  DBRadGenre.Items.Clear;
  DBRadGenre.Items.Add(lg_Male);
  DBRadGenre.Items.Add(lg_Female);
  DBRadMaritalStatus.Items.Clear;
  DBRadMaritalStatus.Items.Add(lg_Single);
  DBRadMaritalStatus.Items.Add(lg_Married);
  //Load Printing preferences
  ReportPreview:= StrToBool(INIFile.ReadString('Printing', 'ReportPreview', 'True'));
  //Show Image of Profile to click by user
  if (AccessControl= TRUE) then
      ImgProfile.Visible:= TRUE;
end;

procedure TFrmMain.FormShow(Sender: TObject);
type TLoadQueries = record
	Query: TSQLQuery;
  SQL: String;
end;
var
  LoadQueries: array of TLoadQueries;
  i: Integer; JournalMode: Integer;
  Bookmark: String;
  BookmarkInt: Integer;
  SQL: String;
  LoadQueriesCount: Integer;
begin
  //Connect & Load to database
  //Open Tables
  //Note: The order is important! First the detailed tables.
  LoadQueriesCount:= 7;
  if (AccessControl= FALSE) then
    LoadQueriesCount:= 8
  else LoadQueriesCount:= 7;
  SetLength(LoadQueries, LoadQueriesCount);
  LoadQueries[0].Query:= DataMod.QueTypeContracts;
  LoadQueries[0].SQL:= 'SELECT * from TypeContracts;';
	LoadQueries[1].Query:= DataMod.QueWorkplaces;
  LoadQueries[1].SQL:= 'SELECT * from Workplaces;';
  LoadQueries[2].Query:= DataMod.QueEmployees;
  FilterIndex:= StrToInt(INIFile.ReadString('TableEmployees','Filter','0'));
  CboFilter.ItemIndex:= FilterIndex;
  case FilterIndex of
    0: 	SQL:= SELECT_ACTIVE_EMPLOYEES_SQL;
  	1: 	SQL:= SELECT_INACTIVE_EMPLOYEES_SQL;
	  2: 	SQL:= SELECT_ALL_EMPLOYEES_SQL;
  end; //case
  LoadQueries[2].SQL:= SQL;
  LoadQueries[3].Query:= DataMod.QuePicsEmployees;
  LoadQueries[3].SQL:= SELECT_PICSEMPLOYEES_SQL;
	LoadQueries[4].Query:= DataMod.QueContractsLog;
  LoadQueries[4].SQL:= SELECT_CONTRACTSLOG_SQL;
	LoadQueries[5].Query:= DataMod.QueUsergroups;
  LoadQueries[5].SQL:= SELECT_ALL_USERGROUPS_SQL;
 	LoadQueries[6].Query:= DataMod.QuePermissions;
  LoadQueries[6].SQL:= SELECT_PERMISSIONSUSERGROUPS_SQL;
  if (AccessControl= FALSE) then
    begin
		LoadQueries[7].Query:= DataMod.QueUsers;
  	LoadQueries[7].SQL:= SELECT_ALL_USERS_SQL;
    end;
  FrmPrgBar.Caption:= 'Loading Tables...';
	for i:= Low(LoadQueries) to High(LoadQueries) do
  	begin
		FuncData.ExecSQL(LoadQueries[i].Query, LoadQueries[i].SQL);
    end;
  //Load the Configuration from the database
  CompanyName:= DataMod.QueConfig.FieldByName('CompanyName').AsString;
  //Save the type of commit in the INI if differs from the database one
  JournalMode:= DataMod.QueConfig.FieldByName('AtomicCommit').AsInteger;
  if (AtomicCommmit<>JournalMode) then
    begin
    INIFile.WriteInteger('Database', 'AtomicCommit', JournalMode);
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
  //Close the Progress Bar
	FrmPrgBar.Close;
 	Screen.Cursor:=crDefault;
  //Check Tab permissions
  CheckTabPermissions;
end;

procedure TFrmMain.ImgAboutClick(Sender: TObject);
begin
  Application.CreateForm(TFrmAbout, FrmAbout);
	FrmAbout.ShowModal;
end;

procedure TFrmMain.CheckTabPermissions;
begin
  if (AccessControl= TRUE) then
    begin
    if (User.Permissions.ShowTabAddress= FALSE) then
      TabAddress.TabVisible:= FALSE;
  end;
end;

procedure TFrmMain.ImgProfileClick(Sender: TObject);
begin
  Application.CreateForm(TFrmProfile, FrmProfile);
	FrmProfile.ShowModal;
end;

procedure TFrmMain.ImgPreferencesClick(Sender: TObject);
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
	FrmSearch.Search(wtEmployees);
end;

procedure TFrmMain.CboFilterChange(Sender: TObject);
var
  SQL: String;
begin
  FilterIndex:= CboFilter.ItemIndex;
  case FilterIndex of
  	0: 	SQL:= SELECT_ACTIVE_EMPLOYEES_SQL;
  	1: 	SQL:= SELECT_INACTIVE_EMPLOYEES_SQL;
  	2: 	SQL:= SELECT_ALL_EMPLOYEES_SQL;
  end;
  FuncData.ExecSQL(DataMod.QueEmployees, SQL);
  FuncData.ExecSQL(DataMod.QueContractsLog,SELECT_CONTRACTSLOG_SQL);
  FuncData.ExecSQL(DataMod.QuePicsEmployees,SELECT_PICSEMPLOYEES_SQL);
  {Updating the recordcount-->}
  UpdateRecordCount;
  INIFile.WriteString('TableEmployees', 'Filter', IntToStr(CboFilter.ItemIndex));
end;

procedure TFrmMain.DBEIDEmployeeExit(Sender: TObject);
begin
	if (IDUnique= True) AND (TotalRecs>0) then
    begin
    IDIsUnique;
    end;
end;

procedure TFrmMain.DBNavBeforeAction(Sender: TObject; Button: TDBNavButtonType);
begin
  if (IDUnique= True) AND (DBEIDEmployee.Focused= True) then
    	begin
  		if IDIsUnique= False then
        begin
        Abort;
        end;
      end;
end;

procedure TFrmMain.DBNavClick(Sender: TObject; Button: TDBNavButtonType);
begin
	inherited; //<-- to execute the default onclick event
	UpdateNavRec;
end;
procedure TFrmMain.FormClose(Sender: TObject; var CloseAction: TCloseAction);
var
  RecNo: Integer;
begin
  //Save the position in the table Employees:
  RecNo:= DataMod.QueEmployees.RecNo;
  INIFile.WriteString('TableEmployees', 'Bookmark', IntToStr(RecNo));
  //Close database
  DataMod.Connection.CloseTransactions;
  DataMod.Connection.CloseDataSets;
  DataMod.Connection.Connected:= False;
  //Free memory
  if (AccessControl= TRUE) then
    begin
    FreeAndNil(User);
    end;
  FreeAndNil(INIFile);
end;
procedure TFrmMain.BtnNewClick(Sender: TObject);
const
  WriteFieldsCount= 2;
  RandomIDLenght= 12;
begin
  if FilterIndex=1 then
  	begin
		FilterIndex:= 0;
    CboFilter.ItemIndex:= 0;
    CboFilterChange(nil);
    end;
  SetLength(WriteFields, WriteFieldsCount);
  WriteFields[0].FieldName:= 'IDN_Employee';
  if (IDUnique= True) AND (IDAuto= True) then
    begin
    case IDAutoType of
			0: WriteFields[0].Value:= AutoIncID;
      1: WriteFields[0].Value:= RandomID(RandomIDLenght);
    end; //case
    end
    else WriteFields[0].Value:= '';
  WriteFields[0].DataFormat:= dtString;
  WriteFields[1].FieldName:= 'Active_Employee';
  WriteFields[1].Value:= True;
  WriteFields[1].DataFormat:= dtBoolean;
  if FuncData.AppendTableRecord(DataMod.QueEmployees, WriteFields)= True then
	  begin
	 	Inc(TotalRecs, 1);
    UpdateNavRec;
		end;
  WriteFields:= nil;
  if (TotalRecs=1) then
    EnableEmployees;
end;

procedure TFrmMain.BtnPrintClick(Sender: TObject);
var
  Employee_ID, SQL: String;
begin
  Employee_ID:= DataMod.QueEmployees.FieldByName('ID_Employee').AsString;
  SQL:= 'SELECT Employees.*, TypeContracts.Name_TypeContract, Workplaces.Name_Workplace FROM Employees'+
  	' LEFT JOIN TypeContracts ON (ID_TypeContract=TypeContract_ID) LEFT JOIN Workplaces'+
    ' ON (ID_Workplace=Workplace_ID) WHERE (ID_Employee="'+Employee_ID+'");';
  FuncData.ExecSQL(DataMod.QuePrint, SQL);
  FuncPrint.Print('employee_card.lrf', FrmMain.frReport, True);
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
    end;
end;

procedure TFrmMain.BtnDelContractLogClick(Sender: TObject);
var
  ID_Contract: String;
begin
  ID_Contract:= DataMod.DsoContractsLog.DataSet.FieldByName('ID_Contract').AsString;
  FuncData.DeleteRecordSQL(DataMod.QueContractsLog,'ContractsLog','ID_Contract',ID_Contract, lg_DelContractLogTarget, True);
end;

procedure TFrmMain.BtnDelTypeContractClick(Sender: TObject);
begin
  if (TotalRecs>0) then
    begin
	  DataMod.QueEmployees.Edit;
  	DataMod.QueEmployees.FieldValues['TypeContract_ID']:= null;
    end;
end;

procedure TFrmMain.BtnDelWorkplaceClick(Sender: TObject);
begin
  if (TotalRecs>0) then
    begin
	  DataMod.QueEmployees.Edit;
  	DataMod.QueEmployees.FieldValues['Workplace_ID']:= null;
    end;
end;

procedure TFrmMain.BtnEditStateListClick(Sender: TObject);
begin
	FrmListEditor.EditList(lg_FrmStatesTitle, StatesFilename, cblStates);
end;

procedure TFrmMain.BtnEditTypeContractsClick(Sender: TObject);
begin
	FrmDsoEditor.EditTable(wtTypeContracts);
end;

procedure TFrmMain.BtnEditWorkplacesClick(Sender: TObject);
begin
	FrmDsoEditor.EditTable(wtWorkplaces);
end;

procedure TFrmMain.BtnActivateClick(Sender: TObject);
begin
  if (FuncData.CheckQueryEmpty(DataMod.QueEmployees)= FALSE) then
    begin
	 	FrmActivationEmployee.ActivateEmployee;
    end
  else
  	begin
    Application.MessageBox(PChar(lg_Employee_Still_Not_Saved), 'Error!', MB_OK);
    end;
end;

procedure TFrmMain.ImgExitClick(Sender: TObject);
begin
  Close;
end;
procedure TFrmMain.PicEmployeeClick(Sender: TObject);
begin
	if (TotalRecs>0) then
  	begin
    Application.CreateForm(TFrmPicEmployee, FrmPicEmployee);
    FrmPicEmployee.ShowModal;
    end;
end;

procedure TFrmMain.TabContractsLogHide(Sender: TObject);
begin
	HideSidebar;
end;

procedure TFrmMain.TabContractsLogShow(Sender: TObject);
begin
  ShowSidebar;
  Sidebar.TabIndex:= 0;
end;

procedure TFrmMain.TabMnuContractsLogContextPopup(Sender: TObject;
  MousePos: TPoint; var Handled: Boolean);
begin

end;

end.
