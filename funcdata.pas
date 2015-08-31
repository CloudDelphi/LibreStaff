unit FuncData;

{$mode objfpc}{$H+}

interface

uses
  Forms, Controls, Classes, SysUtils, FormMain, Dialogs, DataModule,
  db, sqldb, LCLType;

procedure ConnectDatabase(DatabasePath: String);
function DeleteTableRecord(Query: TSQLQuery; Confirm: Boolean=False;
         Target: String=''): Boolean;
procedure ExecSQL(Query: TSQLQuery; SQL: String);
function AppendTableRecord(Query: TSQLQuery): Boolean;
procedure SaveTable(Query: TSQLQuery);

resourcestring
  DelRec_Title= 'Deletion';
	DelRec_Msg_01= 'Are you sure you want to DELETE';
  DelRec_Msg_02= 'It cannot revert!';

implementation

procedure ConnectDatabase(DatabasePath: String);
var
  newDatabase: Boolean;
begin
  DataMod.Connection.Databasename:= DatabasePath;
  // check whether the database already exists
  newDatabase:= not FileExists(DataMod.Connection.Databasename);
	if newDatabase then begin //Create the database and the tables
  	try
    DataMod.Connection.Open;
    DataMod.Transaction.Active:= TRUE;
    // Here we're setting up a table named "DATA" in the new database
    DataMod.Connection.ExecuteDirect('CREATE TABLE PicsEmployees('+
          ' ID_PicEmployee INTEGER NOT NULL PRIMARY KEY DEFAULT "",'+
          ' Employee_ID INTEGER REFERENCES Employees(ID_Employee) ON DELETE CASCADE,'+
          ' Pic_Employee BLOB);');
    DataMod.Connection.ExecuteDirect('CREATE UNIQUE INDEX "Pic_id_idx" ON "PicsEmployees"("ID_PicEmployee");');
    DataMod.Connection.ExecuteDirect('CREATE TABLE Employees('+
          ' ID_Employee INTEGER NOT NULL PRIMARY KEY DEFAULT "",'+
          ' Name_Employee CHAR(256) NOT NULL DEFAULT "",'+
          ' Surname1_Employee CHAR(256) NOT NULL DEFAULT "",'+
          ' Surname2_Employee CHAR(256) NOT NULL DEFAULT "",'+
          ' IDCard_Employee CHAR(256) NOT NULL DEFAULT "",'+
          ' SSN_Employee CHAR(256) NOT NULL DEFAULT "",'+
    			' Address_Employee MEMO(512) NOT NULL DEFAULT "",'+
       		' City_Employee CHAR(256) NOT NULL DEFAULT "",'+
       		' State_Employee CHAR(256) NOT NULL DEFAULT "",'+
       		' ZIPCode_Employee CHAR(256) NOT NULL DEFAULT "",'+
       		' Phone_Employee CHAR(256) NOT NULL DEFAULT "",'+
       		' Cell_Employee CHAR(256) NOT NULL DEFAULT "",'+
			    ' EMail_Employee CHAR(256) NOT NULL DEFAULT "");');

    //Creating an index based upon id in the DATA Table
    DataMod.Connection.ExecuteDirect('CREATE UNIQUE INDEX "Employee_id_idx" ON "Employees"("ID_Employee");');
    DataMod.Transaction.Commit;
    except
    ShowMessage('Unable to create new database');
    end;
  end;
end;
function DeleteTableRecord(Query: TSQLQuery; Confirm: Boolean=False; Target: String=''): Boolean;
var
  ConfirmDel, Style: Integer;
  Msg: PChar;
begin
  if Confirm= True then
    begin
    Style:= MB_OKCANCEL + MB_ICONEXCLAMATION;
    Msg:= PChar(DelRec_Msg_01+' '+Target+'?'#13+DelRec_Msg_02);
    ConfirmDel:= Application.MessageBox(Msg, PChar(DelRec_Title), Style);
    end
  	else ConfirmDel:= IDOK;
  case ConfirmDel of
   	IDOK: begin
    			try
   				Query.Delete;
       	  Query.ApplyUpdates;
         	DataMod.Transaction.CommitRetaining;
					Result:= True;
          except
					Result:= False;
          end;
          end;
    IDCANCEL: begin
     					Result:= False;
          		Exit;
              end;
  end; //case
end;

procedure ExecSQL(Query: TSQLQuery; SQL: String);
begin
  Query.Close;
  Query.SQL.Clear;
  Query.SQL.Add(SQL);
	Query.Open;
end;

function AppendTableRecord(Query: TSQLQuery): Boolean;
begin
  try
  Query.Append;
  Query.FieldByName('Name_employee').AsString:= '';
  Query.Post;
  Query.ApplyUpdates;
  DataMod.Transaction.CommitRetaining;
  Query.Refresh;
  Query.Last;
  Result:= True;
	except
  Result:= False;
  end;
end;
procedure SaveTable(Query: TSQLQuery);
begin
  Screen.Cursor:= crHourGlass;
  Query.ApplyUpdates;
  DataMod.Transaction.CommitRetaining;
  Screen.Cursor:= crDefault;
end;

end.

