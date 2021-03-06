unit u_admPrincipal;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, FireDAC.Stan.Intf, FireDAC.Stan.Option,
  FireDAC.Stan.Param, FireDAC.Stan.Error, FireDAC.DatS, FireDAC.Phys.Intf,
  FireDAC.DApt.Intf, Data.DB, FireDAC.Comp.DataSet, FireDAC.Comp.Client,
  Vcl.ExtCtrls, Vcl.DBCGrids, Vcl.StdCtrls, RegrasNegocio, FireDAC.UI.Intf,
  FireDAC.Stan.Def, FireDAC.Stan.Pool, FireDAC.Stan.Async, FireDAC.Phys,
  FireDAC.Phys.SQLite, FireDAC.Phys.SQLiteDef, FireDAC.Stan.ExprFuncs,
  FireDAC.Phys.SQLiteWrapper.Stat, FireDAC.VCLUI.Wait, FireDAC.DApt, Vcl.DBCtrls,
  Vcl.ComCtrls, dxGDIPlusClasses, IdBaseComponent, IdComponent, IdTCPConnection,
  IdTCPClient, IdHTTP, Vcl.Buttons;

const
  SQL_01 = 'CREATE TABLE IF NOT EXISTS "LOGDOWNLOAD" (                     '+
                                      ' "CODIGO"	NUMBER(22,0) NOT NULL,   '+
	                                    ' "URL"	VARCHAR (600) NOT NULL,      '+
	                                    ' "DATAINICIO"	TEXT NOT NULL,       '+
                                      ' "DATAFIM" TEXT,                    '+
                                      ' PRIMARY KEY("CODIGO"))             ';

type
  TadmPrincipal = class(TForm)
    Panel1: TPanel;
    sc_principal: TScrollBox;
    edt_url: TEdit;
    btn_baixar: TButton;
    ExecutaSql: TFDQuery;
    dlgSave: TSaveDialog;
    BitBtn1: TBitBtn;
    Label3: TLabel;
    edt_path: TEdit;
    img_exibir: TImage;
    img_pausar: TImage;
    img_reiniciar: TImage;
    Label1: TLabel;
    procedure FormCreate(Sender: TObject);
    procedure btn_baixarClick(Sender: TObject);
    procedure BitBtn1Click(Sender: TObject);
  private
    { Private declarations }
    FAvisaUsuario  : TConfirmacao;
    FContador      : Integer;
    FProgressBar   : TProgressBar;
    function Valida: Boolean;
    procedure CriaTabela;
    procedure MontaTemplate(ADadosDownload: TDownload);
  public
    { Public declarations }
  end;

var
  admPrincipal: TadmPrincipal;

implementation
uses
  u_frmHistorico, u_dmConection;

{$R *.dfm}


procedure TadmPrincipal.BitBtn1Click(Sender: TObject);
begin
  try
    frmHistorico:= TfrmHistorico.Create(Self);
    frmHistorico.ShowModal;
  finally
    frmHistorico.Free;
  end;
end;

procedure TadmPrincipal.btn_baixarClick(Sender: TObject);
var
  vDadosDownloads: TDadosDownload;
  vDownloads     : TDownload;
begin
  if valida then
  begin
    try
      vDadosDownloads           := TDadosDownload.Create;
      vDadosDownloads.URL       := trim(edt_url.Text);
      vDadosDownloads.DataInicio:= date;
      vDadosDownloads.PATHSAVE  := edt_path.Text;
    except
      Showmessage('N?o foi possivel baixar o arquivo !');
      exit;
    end;

    vDownloads:=  TDownload.Create;
    vDownloads.Attach(FAvisaUsuario);
    vDownloads.DadosDownloads := vDadosDownloads;
    MontaTemplate(vDownloads);

    vDownloads.Baixar;
   end;
end;

procedure TadmPrincipal.CriaTabela;
begin
  ExecutaSQL.Close;
  ExecutaSQL.SQL.Clear;
  ExecutaSQL.SQL.Add(SQL_01);
  ExecutaSQL.ExecSQL;
end;

procedure TadmPrincipal.FormCreate(Sender: TObject);
begin
  FContador     := 0;
  FAvisaUsuario := TConfirmacao.Create;
  Application.CreateForm(TdmConection, dmConection);
  if dmConection.ConectaDB then
  begin
    CriaTabela;
    dmConection.Qry_Downloads.Open('select * from LOGDOWNLOAD ');
  end
  else
    Showmessage('N?o foi poss?vel conectar ao Banco de Dados.');
end;


procedure TadmPrincipal.MontaTemplate(ADadosDownload: TDownload);
var
  vPanel, vPanelSeparador : TPanel;
  vLabelUrl, vLabelDescUrl, vlabelDadosBaixados, vlabelDadosPorcentagem: TLabel;
  vImage01, vImage02, vImage03: Timage;
  vShape: Tshape;
  vProgressBar: TProgressBar;
  vComponenteGrid: TComponentesDownload;
  vCodigo: integer;
begin
  dmConection.Qry_Downloads.Refresh;

  vCodigo:= dmConection.Qry_Downloads.RecordCount + 1;

  if Assigned(FindComponent('pnl_pricipal_'+ FormatFloat('0000',vCodigo))) then
  begin
    Showmessage('Donwload j? existe !');
    exit;
  end;


  vComponenteGrid:= TComponentesDownload.Create;
  vComponenteGrid.Codigo:= vCodigo ;

  vPanel           :=TPanel.Create(self);
  vPanel.Parent    := sc_principal;
  vPanel.Width     := 829;
  vPanel.Height    := 66;
  vPanel.Align     := alNone;
  vPanel.BevelOuter:= bvNone;
  vPanel.Name      := 'pnl_pricipal_'+ FormatFloat('0000',vCodigo);
  vPanel.Caption   := '';

  vPanelSeparador        :=TPanel.Create(self);
  vPanelSeparador.Left   := 0;
  vPanelSeparador.Top    := 58;
  vPanelSeparador.Width  := 829;
  vPanelSeparador.Height := 8;
  vPanelSeparador.Parent := vPanel;
  vPanelSeparador.Align  := alBottom;
  vPanelSeparador.Name   := 'pnl_separador_'+ FormatFloat('0000',vCodigo);
  vPanelSeparador.Caption:= '';

  vShape               := TShape.Create(self);
  vShape.Align         := alClient;
  vShape.Parent        := vPanel;
  vShape.Brush.Color   := 16382457;

  vLabelUrl        := TLabel.Create(self);
  vLabelUrl.Parent := vPanel;
  vLabelUrl.Left   := 24;
  vLabelUrl.Top    := 4;
  vLabelUrl.Width  := 27;
  vLabelUrl.Height := 15;
  vLabelUrl.Caption:= 'URL: ';
  vLabelUrl.Name   := 'lbl_'+FormatFloat('0000',vCodigo);

  vLabelDescUrl             := TLabel.Create(Self);
  vLabelDescUrl.Parent      := vPanel;
  vLabelDescUrl.Left        := 24;
  vLabelDescUrl.Top         := 4;
  vLabelDescUrl.Width       := 27;
  vLabelDescUrl.Height      := 15;
  vLabelDescUrl.Font.Charset:= DEFAULT_CHARSET;
  vLabelDescUrl.Font.Color  := clBlue;
  vLabelDescUrl.Font.Height := -12;
  vLabelDescUrl.Font.Name   := 'Segoe UI';
  vLabelDescUrl.Font.Style  := [fsUnderline];
  vLabelDescUrl.ParentFont  := False;
  vLabelDescUrl.Name        := 'lbl_desc_'+FormatFloat('0000',vCodigo);
  vLabelDescUrl.Caption     := 'URL: '+ ADadosDownload.DadosDownloads.URL ;

  vComponenteGrid.LabelURL  := vLabelDescUrl;

  vlabelDadosBaixados             := TLabel.Create(Self);
  vlabelDadosBaixados.Parent      := vPanel;
  vlabelDadosBaixados.Left        := 24;
  vlabelDadosBaixados.Top         := 41;
  vlabelDadosBaixados.Width       := 129;
  vlabelDadosBaixados.Height      := 15;
  vlabelDadosBaixados.Font.Charset:= DEFAULT_CHARSET;
  vlabelDadosBaixados.ParentFont  := False;
  vlabelDadosBaixados.caption     := '000 de 000 kb - Baixados';
  vlabelDadosBaixados.Name        := 'lbl_dados_baixados_'+FormatFloat('0000',vCodigo);

  vComponenteGrid.LabelDadosDown  := vlabelDadosBaixados;

  vLabelDescUrl             := TLabel.Create(Self);
  vLabelDescUrl.Parent      := vPanel;
  vLabelDescUrl.Left        := 24;
  vLabelDescUrl.Top         := 4;
  vLabelDescUrl.Width       := 27;
  vLabelDescUrl.Height      := 15;
  vLabelDescUrl.Font.Charset:= DEFAULT_CHARSET;
  vLabelDescUrl.Font.Color  := clBlue;
  vLabelDescUrl.Font.Height := -12;
  vLabelDescUrl.Font.Name   := 'Segoe UI';
  vLabelDescUrl.Font.Style  := [fsUnderline];
  vLabelDescUrl.ParentFont  := False;
  vLabelDescUrl.Name        := 'lbl_desc_url_'+FormatFloat('0000',vCodigo);
  vLabelDescUrl.Caption     := '';

  vlabelDadosPorcentagem             := TLabel.Create(vPanel);
  vlabelDadosPorcentagem.Parent      := vPanel;
  vlabelDadosPorcentagem.Left        := 716;
  vlabelDadosPorcentagem.Top         := 25;
  vlabelDadosPorcentagem.Width       := 31;
  vlabelDadosPorcentagem.Height      := 15;
  vlabelDadosPorcentagem.Font.Charset:= DEFAULT_CHARSET;
  vlabelDadosPorcentagem.Font.Color  := clWindowText;
  vlabelDadosPorcentagem.Font.Height := -12;
  vlabelDadosPorcentagem.Font.Name   := 'Segoe UI';
  vlabelDadosPorcentagem.Font.Style  := [fsBold];
  vlabelDadosPorcentagem.ParentFont  := False;
  vlabelDadosPorcentagem.Name        := 'lbl_dados_porce_'+FormatFloat('0000',vCodigo);
  vlabelDadosPorcentagem.Caption     := '000%';
  vlabelDadosPorcentagem.Visible     := false;

  vComponenteGrid.LabelDadosPorc     := vlabelDadosPorcentagem;

  vImage01             := TImage.Create(Self);
  vImage01.Parent      := vPanel;
  vImage01.Left        := 777;
  vImage01.Top         := 23;
  vImage01.Width       := 19;
  vImage01.Height      := 17;
  vImage01.Cursor      := crHandPoint;
  vImage01.Hint        := 'Pausar Download';
  vImage01.Stretch     := True;
  vImage01.ShowHint    := True;
  vImage01.Name        := 'img_pausar_'+FormatFloat('0000',vCodigo);
  vImage01.Picture.Assign(img_pausar.Picture) ;

  vComponenteGrid.Botao01:= vImage01;

  vImage02         := TImage.Create(Self);
  vImage02.Parent  := vPanel;
  vImage02.Left    := 802;
  vImage02.Top     := 23;
  vImage02.Width   := 19;
  vImage02.Height  := 17;
  vImage02.Cursor  := crHandPoint;
  vImage02.Hint    := 'Reiniciar Download';
  vImage02.Stretch := True;
  vImage02.ShowHint:= True;
  vImage02.Name    := 'img_reiniciar_'+FormatFloat('0000',vCodigo);
  vImage02.Picture.Assign(img_reiniciar.Picture) ;

  vComponenteGrid.Botao02:= vImage02;

  vImage03         := TImage.Create(Self);
  vImage03.Parent  := vPanel;
  vImage03.Left    := 752;
  vImage03.Top     := 23;
  vImage03.Width   := 19;
  vImage03.Height  := 17;
  vImage03.Cursor  := crHandPoint;
  vImage03.Hint    := 'Exibir Porcentagem do Download';
  vImage03.Stretch := True;
  vImage03.ShowHint:= True;
  vImage03.Name    := 'img_porcentagem_'+FormatFloat('0000',vCodigo);
  vImage03.Picture.Assign(img_exibir.Picture) ;

  vComponenteGrid.Botao03:= vImage03;

  vProgressBar       := TProgressBar.Create(Self);
  vProgressBar.Parent:= vPanel;
  vProgressBar.Left  := 24;
  vProgressBar.Top   := 23;
  vProgressBar.Width := 685;
  vProgressBar.Height:= 17;

  FProgressBar := vProgressBar;

  vComponenteGrid.ProgressBar   := vProgressBar;
  ADadosDownload.Componente     := vComponenteGrid;

  vPanel.Align     := alTop;
end;

function TadmPrincipal.Valida: Boolean;
begin
  result:= True;
  if trim(edt_url.Text) = '' then
  begin
    Result:= False;
    showmessage('Informe a URL para realizar o Download !');
    exit;
  end;

  if trim(edt_path.Text) = '' then
  begin
    Result:= False;
    showmessage('Informe o caminho onde ser? salvo o arquivo.');
    exit;
  end;
end;

end.
