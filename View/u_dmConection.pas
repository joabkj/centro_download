unit u_dmConection;

interface

uses
  System.SysUtils, System.Classes, FireDAC.Stan.Intf, FireDAC.Stan.Option,
  FireDAC.Stan.Error, FireDAC.UI.Intf, FireDAC.Phys.Intf, FireDAC.Stan.Def,
  FireDAC.Stan.Pool, FireDAC.Stan.Async, FireDAC.Phys, FireDAC.Phys.SQLite,
  FireDAC.Phys.SQLiteDef, FireDAC.Stan.ExprFuncs,
  FireDAC.Phys.SQLiteWrapper.Stat, FireDAC.VCLUI.Wait, Data.DB,
  FireDAC.Comp.Client, Vcl.Forms, FireDAC.Stan.Param, FireDAC.DatS,
  FireDAC.DApt.Intf, FireDAC.DApt, FireDAC.Comp.DataSet;

type
  TdmConection = class(TDataModule)
    Connection: TFDConnection;
    Qry_Downloads: TFDQuery;
    ds_Downloads: TDataSource;
  private
    { Private declarations }
  public
    { Public declarations }
    function ConectaDB: Boolean;
  end;

var
  dmConection: TdmConection;

implementation

{%CLASSGROUP 'Vcl.Controls.TControl'}

{$R *.dfm}

function TdmConection.ConectaDB: Boolean;
begin
  try
    Connection.Params.Values['Database']:= ExtractFilePath(Application.ExeName)+ PathDelim+'DB_Donwload.db';
    Connection.Connected:= true;
    Result:= Connection.Connected;
  except on E:Exception do
    begin
      Result:= False;
    end;
  end;
end;

end.
