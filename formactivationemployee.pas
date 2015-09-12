unit FormActivationEmployee;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, DateTimePicker, Forms, Controls, Graphics,
  Dialogs, ExtCtrls, StdCtrls, FraAcceptCancel;

type

  { TFrmActivationEmployee }

  TFrmActivationEmployee = class(TForm)
    DatDateEnd: TDateTimePicker;
    DatDateInit: TDateTimePicker;
    FraAcceptCancel1: TFraAcceptCancel;
    GrpContract: TGroupBox;
    LblDateEnd: TLabel;
    LblDateInit: TLabel;
    LblTitle: TLabel;
    PanTop: TPanel;
    procedure BtnAcceptClick(Sender: TObject);
    procedure BtnCancelClick(Sender: TObject);
  private
    { private declarations }
    Inactivate: Boolean;
  public
    { public declarations }
    function ActivateEmployee: Boolean;
  end;

var
  FrmActivationEmployee: TFrmActivationEmployee;

resourcestring
  lg_Title_Inactivate= 'Do you want to inactivate';
  lg_Title_Activate= 'Do you want to activate';
  lg_CaptionGrpContract_Inactivate= 'Contract to log:';
  lg_CaptionGrpContract_Activate= 'New contract of the employee:';
implementation

{$R *.lfm}

uses
  DataModule, FuncData, FormMain, db;

procedure TFrmActivationEmployee.BtnCancelClick(Sender: TObject);
begin
  Close;
end;

procedure TFrmActivationEmployee.BtnAcceptClick(Sender: TObject);
var
  IDEmployee: String;
  FilterIndex: Integer;
begin
  IDEmployee:= DataMod.QueEmployees.FieldByName('ID_Employee').AsString;
  case Inactivate of
    False:	begin
	          SetLength(WriteFields,5);
  	        WriteFields[0].FieldName:= 'Active_Employee';
					  WriteFields[0].Value:= true;
      	    WriteFields[0].DataFormat:= dtBoolean;
        	  WriteFields[1].FieldName:= 'DateInit_Contract';
				 	 	WriteFields[1].Value:= DatDateInit.DateTime;
				  	WriteFields[1].DataFormat:= dtDate;
          	WriteFields[2].FieldName:= 'DateEnd_Contract';
				  	WriteFields[2].Value:= DatDateEnd.DateTime;
				  	WriteFields[2].DataFormat:= dtDate;
          	WriteFields[3].FieldName:= 'TypeContract_ID';
 				  	WriteFields[3].Value:= -1;
				  	WriteFields[3].DataFormat:= dtNull;
          	WriteFields[4].FieldName:= 'Workplace_ID';
 				  	WriteFields[4].Value:= -1;
				  	WriteFields[4].DataFormat:= dtNull;
          	FuncData.UpdateSQL('Employees', 'ID_Employee', IDEmployee,  WriteFields);
          	end;
		True:	begin
  			  SetLength(WriteFields,5);
          WriteFields[0].FieldName:= 'Employee_ID';
				  WriteFields[0].Value:= IDEmployee;
          WriteFields[0].DataFormat:= dtString;
          WriteFields[1].FieldName:= 'DateInit_Contract';
				  WriteFields[1].Value:= DatDateInit.DateTime;
				  WriteFields[1].DataFormat:= dtDate;
          WriteFields[2].FieldName:= 'DateEnd_Contract';
				  WriteFields[2].Value:= DatDateEnd.DateTime;
				  WriteFields[2].DataFormat:= dtDate;
          WriteFields[3].FieldName:= 'TypeContract_ID';
 				  WriteFields[3].Value:=DataMod.QueEmployees.FieldByName('TypeContract_ID').AsInteger;
        	WriteFields[3].DataFormat:= dtInteger;
    			WriteFields[4].FieldName:= 'Workplace_ID';
				  WriteFields[4].Value:=DataMod.QueEmployees.FieldByName('Workplace_ID').AsInteger;
        	WriteFields[4].DataFormat:= dtInteger;
          FuncData.InsertSQL('ContractsLog', WriteFields);
          SetLength(WriteFields,5);
          WriteFields[0].FieldName:= 'Active_Employee';
				  WriteFields[0].Value:= False;
          WriteFields[0].DataFormat:= dtBoolean;
          WriteFields[1].FieldName:= 'DateInit_Contract';
				  WriteFields[1].Value:= -1;
				  WriteFields[1].DataFormat:= dtNull;
          WriteFields[2].FieldName:= 'DateEnd_Contract';
				  WriteFields[2].Value:= -1;
				  WriteFields[2].DataFormat:= dtNull;
          WriteFields[3].FieldName:= 'TypeContract_ID';
 				  WriteFields[3].Value:= -1;
				  WriteFields[3].DataFormat:= dtNull;
          WriteFields[4].FieldName:= 'Workplace_ID';
 				  WriteFields[4].Value:= -1;
				  WriteFields[4].DataFormat:= dtNull;
          FuncData.UpdateSQL('Employees', 'ID_Employee', IDEmployee,  WriteFields);
          end;
  end; //case
  //Change the filter and go to the record:
  FilterIndex:= FrmMain.CboFilter.ItemIndex;
  if (FilterIndex=0) OR (FilterIndex=1) then //if Filter in Actives or Inactives
  	begin
    case Inactivate of
	    False:	FrmMain.CboFilter.ItemIndex:= 0; //Change filter to Actives
  	  True:	FrmMain.CboFilter.ItemIndex:= 1; //Change filter to Inactives
    end; //case
    FrmMain.CboFilterChange(nil); //Apply the filter
    DataMod.QueEmployees.Locate('ID_Employee',IDEmployee,[loCaseInsensitive,loPartialKey]); //Locate the employee
  	end;
  //Show the proper tab
  case Inactivate of
  	False: if Not(FrmMain.PagEmployees.TabIndex= 2) then FrmMain.PagEmployees.TabIndex:= 2;
    True: if Not(FrmMain.PagEmployees.TabIndex= 3) then FrmMain.PagEmployees.TabIndex:= 3;
  end; //case
  FrmMain.UpdateRecordCount;
  Close;
end;

function TFrmActivationEmployee.ActivateEmployee: Boolean;
var
  Employee_Name: String;
begin
  with TFrmActivationEmployee.Create(Application) do
    try
    Inactivate:= DataMod.QueEmployees.FieldByName('Active_Employee').AsBoolean;
    Employee_Name:= DataMod.QueEmployees.FieldByName('Name_Employee').AsString+' '+
               DataMod.QueEmployees.FieldByName('Surname1_Employee').AsString+' '+
               DataMod.QueEmployees.FieldByName('Surname2_Employee').AsString;
    case Inactivate of
      True:	begin
            LblTitle.Caption:= lg_Title_Inactivate+#13'"'+Employee_Name+'"?';
            GrpContract.Caption:= lg_CaptionGrpContract_Inactivate;
            DatDateInit.Date:= DataMod.QueEmployees.FieldByName('DateInit_Contract').AsDateTime;
				    DatDateEnd.Date:= DataMod.QueEmployees.FieldByName('DateEnd_Contract').AsDateTime;
      			end;
      False:	begin
            	LblTitle.Caption:= lg_Title_Activate+#13'"'+Employee_Name+'"?';
              GrpContract.Caption:= lg_CaptionGrpContract_Activate;
							DatDateInit.Date:= Date;
							DatDateEnd.Date:= Date;
      				end;
    end; //case
 		Result:= ShowModal = mrOK;
    finally
    FrmActivationEmployee.Free;
    FrmActivationEmployee:= nil;
    end;
end;

end.

