unit RegrasNegocio;

interface

uses
   Classes,
   Types,
   Dialogs,
   Contnrs,
   Vcl.Forms,
   IdComponent,
   Vcl.ComCtrls,
   Vcl.StdCtrls,
   Vcl.ExtCtrls,
   System.SysUtils,
   IdHTTP,
   IdSSLOpenSSL,
   Math;

type

  TDownloadDoneEvent = procedure(Sender: TObject; const vResult: Boolean) of object;
  TObserver = class;
  TSubject = class;

  TObserver = class
  public
    FSubject: TSubject;
    procedure Update; virtual; abstract;
  end;

  TSubject = class
  public
    FObservers: TObjectList;
    procedure Attach(const Observer: TObserver);
    procedure Detach(const Observer: TObserver);
    procedure DetachAll;
    procedure Notify;
  end;

  TComponentesDownload = class
  private
    FTFileStream: TFileStream;
    FlabelURL   : Tlabel;
    FdadosDonw  : Tlabel;
    FdadosPorc  : Tlabel;
    FprogressBar: TProgressbar;
    FBotao01    : TImage;
    FBotao02    : TImage;
    FBotao03    : TImage;
    FCodigo: Integer;
    procedure SetCodigo(const Value: Integer);
    procedure SetLabelUrl(const Value: TLabel);
    procedure SetLabelDadosDonw(const Value: TLabel);
    procedure SetLabelDadosPorc(const Value: TLabel);
    procedure SetProgressBar(const Value: TProgressbar);
    procedure SetFileStream(const Value: TFileStream);
    procedure SetBotao01(const Value: TImage);
    procedure SetBotao02(const Value: TImage);
    procedure SetBotao03(const Value: TImage);
  public
    property Codigo         : Integer read FCodigo write SetCodigo;
    property FileStream     : TFileStream read FTFileStream write SetFileStream;
    property LabelURL       : Tlabel read FlabelURL write SetLabelUrl;
    property LabelDadosDown : Tlabel read FdadosDonw write SetLabelDadosDonw;
    property LabelDadosPorc : Tlabel read FdadosPorc write SetLabelDadosPorc;
    property ProgressBar    : TProgressbar read FprogressBar write SetProgressBar;
    property Botao01        : TImage read FBotao01 write SetBotao01;
    property Botao02        : TImage read FBotao02 write SetBotao02;
    property Botao03        : TImage read FBotao03 write SetBotao03;
  end;

  TDadosDownload = class
  private
    FURL          : String;
    FPathSave     : String;
    FDataInicio   : TDateTime;
    FDataFim      : TDateTime;
    procedure SetURL(const Value: string);
    procedure SetPathSave(const Value: string);

    procedure SetDataInicio(const Value: TDateTime);
    procedure SetDataFim(const Value: TDateTime);
  public
    property PathSave       : String read FPathSave write SetPathSave;
    property URL            : String read FURL write SetURL;
    property DataInicio     : TDateTime read FDataInicio write SetDataInicio;
    property DataFim        : TDateTime read FDataFim write SetDataFim;
  end;

  TDownload = class(TSubject)
  private
    FDadosDonwload  : TDadosDownload;
    FLinhaGrid      : TComponentesDownload;
    FExecutando     : Boolean;
    FId             : Integer;
    FPausar         : Boolean;
    Http            : TIdHTTP;
    FConcluido      : Integer;
    FTamanhoArquivo : Integer;
    fFileStream     : TFileStream;
    function  DownloadFileThread(const OnFinished: TDownloadDoneEvent): Boolean;
    function  GravaDownloadDB: Boolean;
    function  GravaDownloadDBFinal: Boolean;
    function  ConvertePorcentagem(ATotal, AvalorAtual: real): string;
    procedure SetDadosDownloads(const Value: TDadosDownload);
    procedure SetPausar(const Value: Boolean);
    procedure SetExecutando(const Value: Boolean);
    procedure SetComponentesDownload(const Value: TComponentesDownload);
    procedure SetID(const Value: Integer);
    procedure DownloadFinished(Sender: TObject; const Success: Boolean);
    procedure WorkEnd(ASender: TObject; AWorkMode: TWorkMode);
    procedure IdHTTPWork(ASender: TObject; AWorkMode: TWorkMode;
      AWorkCount: Int64);
    procedure IdHTTPWorkBegin(ASender: TObject; AWorkMode: TWorkMode;
      AWorkCountMax: Int64);
    procedure ControleBotoes;
    procedure img_exibirClick(Sender: TObject);
    procedure img_pausarClick(Sender: TObject);
    procedure img_iniciarClick(Sender: TObject);
  public
    constructor Create;
    destructor Destroy; override;
    property   DadosDownloads: TDadosDownload read FDadosDonwload write SetDadosDownloads;
    property   Componente: TComponentesDownload read FLinhaGrid write SetComponentesDownload;
    property   Executando: Boolean read FExecutando write SetExecutando;
    property   ID : Integer  read FID write SetID;
    property   PAUSAR : Boolean  read FPausar write SetPausar;
    procedure   Baixar;
  end;

  TConfirmacao = class(TObserver)
  public
    procedure Update; override;
  end;

implementation
uses u_admPrincipal;

{ TSubject }

procedure TSubject.Attach(const Observer: TObserver);
begin

  if FObservers = nil then
    FObservers := TObjectList.Create;

  Observer.FSubject := Self;
  fObservers.Add(Observer);

end;

procedure TSubject.Detach(const Observer: TObserver);
begin

  if fObservers <> nil then
  begin
    fObservers.Remove(Observer);
    if FObservers.Count = 0 then
      FObservers := nil;
  end;

end;

procedure TSubject.DetachAll;
var
  i, k: Integer;
begin

  if FObservers <> nil then begin
    k := FObservers.Count;
    for i := Pred(k) downto 0 do
      Detach(FObservers[i] as TObserver);
  end;

end;

procedure TSubject.Notify;
var
  i: Integer;
begin
  if FObservers <> nil then
    for i := 0 to FObservers.Count -1 do
      (fObservers[i] as TObserver).Update;
end;


{ TDadosDonwload }


procedure TDadosDownload.SetDataFim(const Value: TDateTime);
begin
  FDataFim:= Value;
end;

procedure TDadosDownload.SetDataInicio(const Value: TDateTime);
begin
  FDataInicio:= Value;
end;

procedure TDadosDownload.SetPathSave(const Value: string);
begin
  FPathSave:= Value;
end;

procedure TDadosDownload.SetURL(const Value: string);
begin
  FURL:= Value;
end;

{ TDonwload }

constructor TDownload.Create;
begin
  inherited Create;
end;

destructor TDownload.Destroy;
begin

  inherited;
end;

procedure TDownload.Baixar;
begin
  DownloadFileThread(DownloadFinished);
end;


procedure TDownload.DownloadFinished(Sender: TObject; const Success: Boolean);
begin
  if Success then
    Componente.LabelDadosDown.Caption:= 'Download Completo!'
  else
    Componente.LabelDadosDown.Caption:= 'Falha no Download!';
  Notify;
end;

function TDownload.ConvertePorcentagem(ATotal, AvalorAtual: real): string;
var
  resultado: Real;
begin
    resultado := ((AvalorAtual * 100) / ATotal);
    Result    := FormatFloat('000%', resultado);
end;

procedure TDownload.WorkEnd(ASender: TObject; AWorkMode: TWorkMode);
begin
  componente.ProgressBar.Position := componente.ProgressBar.Max;
end;

procedure TDownload.IdHTTPWork(ASender: TObject; AWorkMode: TWorkMode;
  AWorkCount: Int64);
begin
   componente.ProgressBar.Position  := Trunc((FConcluido/FTamanhoArquivo)*101);
   componente.LabelDadosDown.Caption:= inttostr(trunc(FConcluido/1024))+' de '+inttostr(trunc(FTamanhoArquivo/1024))+' kb';
   componente.LabelDadosPorc.Caption:= ConvertePorcentagem(componente.ProgressBar.Max, trunc(FConcluido/1024));
   componente.LabelDadosDown.Refresh;
   componente.LabelDadosPorc.Refresh;
end;

procedure TDownload.IdHTTPWorkBegin(ASender: TObject; AWorkMode: TWorkMode;
  AWorkCountMax: Int64);
begin
  componente.ProgressBar.Max := trunc(FTamanhoArquivo/1024);
end;

procedure TDownload.img_exibirClick(Sender: TObject);
begin
  componente.LabelDadosPorc.Visible:= not componente.LabelDadosPorc.Visible;
end;

procedure TDownload.img_pausarClick(Sender: TObject);
begin
  FPausar:= false;
end;

procedure TDownload.img_iniciarClick(Sender: TObject);
begin
  FPausar:= true;
end;

procedure TDownload.ControleBotoes;
begin
  componente.Botao01.OnClick:= img_pausarClick;
  componente.Botao02.OnClick:= img_iniciarClick;
  componente.Botao03.OnClick:= img_exibirClick;
end;


function TDownload.DownloadFileThread(const OnFinished: TDownloadDoneEvent): Boolean;
var
  Success: Boolean;
begin
  TThread.CreateAnonymousThread(
    procedure
  var
    IOHndl           : TIdSSLIOHandlerSocketOpenSSL;
    terminado        : Boolean;
    quant_baixada_arq: Int64;
  begin
    Executando:= true;
    ControleBotoes;
    Http  := TIdHTTP.Create(nil);
    fFileStream:=nil;
         try
            try
              IOHndl := TIdSSLIOHandlerSocketOpenSSL.Create(nil);
              Http.OnWorkBegin := IdHTTPWorkBegin;
              Http.OnWork      := IdHTTPWork;
              Http.OnWorkEnd   := WorkEnd;

              Http.Request.BasicAuthentication := True;
              Http.Request.Accept := 'text/html, */*';

              Http.Request.ContentType := 'application/x-www-form-urlencoded';
              Http.Request.UserAgent := 'Mozilla/4.0 (compatible; MSIE 7.0; Windows NT 6.0; Acoo Browser; GTB5; Mozilla/4.0 (compatible; MSIE 6.0; Windows NT 5.1; SV1) ; Maxthon; InfoPath.1; .NET CLR 3.5.30729; .NET CLR 3.0.30618)';
              Http.HandleRedirects := True;
              Http.IOHandler := IOHndl;
              Http.ReadTimeout := 30000;
              IOHndl.SSLOptions.SSLVersions := [sslvTLSv1, sslvTLSv1_1, sslvTLSv1_2];

              HTTP.Request.UserAgent :='Mozilla/5.0 (Windows NT 6.1; WOW64; rv:12.0) Gecko/20100101 Firefox/12.0';
              Http.Request.CacheControl := 'no-cache';

              Http.Head(DadosDownloads.URL);
              FTamanhoArquivo := Http.Response.ContentLength;
              terminado:=false;
             repeat
               if FPausar then
                 Http.Free;

             if not FileExists(DadosDownloads.PathSave) then
             begin
               fFileStream := TFileStream.Create(DadosDownloads.PathSave, fmCreate);
               FConcluido  := fFileStream.Size;
             end
             else
             begin
               try
                 fFileStream := TFileStream.Create(DadosDownloads.PathSave, fmOpenReadWrite);
                 terminado   := fFileStream.Size >= FTamanhoArquivo;
                 FConcluido  := fFileStream.Size;
                 if not terminado then
                   fFileStream.Seek(Max(0, fFileStream.Size-4096), soFromBeginning);
               except
                 Success:= False;
                 Http.Disconnect;
                 exit;
               end;
             end;
             try
               quant_baixada_arq  :=fFileStream.Size + 50000;
               if quant_baixada_arq < FTamanhoArquivo then begin
                 Http.Request.Range := IntToStr(fFileStream.Position) + '-'+  IntToStr(FConcluido);
            end
            else begin
              Http.Request.Range := IntToStr(fFileStream.Position) + '-';
              FConcluido:= FTamanhoArquivo;
              terminado:=true;
            end;
              Http.Get(DadosDownloads.URL, fFileStream);
          finally
            fFileStream.Free;
          end;
          until terminado;
            Http.Disconnect;
        except
        on E : Exception do
        Begin
          Success:= False;
        end;
      end;
      finally
        GravaDownloadDB;
        Success:= true;
        Http.Free;
      end;

      TThread.Synchronize(nil,
        procedure
        begin
          if Assigned(OnFinished) then
            OnFinished(nil, Success);
        end
      );
    end
  ).Start;
  Result:= Success;
end;


function TDownload.GravaDownloadDB: Boolean;
begin
  try
    admPrincipal.ExecutaSql.Close;
    admPrincipal.ExecutaSql.SQL.Clear;
    admPrincipal.ExecutaSql.SQL.add(' INSERT INTO LOGDOWNLOAD (CODIGO, URL, DATAINICIO) VALUES (');
    admPrincipal.ExecutaSql.SQL.add(IntToStr(componente.Codigo)+','+QuotedStr(DadosDownloads.URL)+','+QuotedStr(FormatDateTime('dd/mm/yyyy', now))+')');
    admPrincipal.ExecutaSql.ExecSQL;
    Result:= true;
  except
    Result:= false;
  end;

end;

function TDownload.GravaDownloadDBFinal: Boolean;
begin
  try
    admPrincipal.ExecutaSql.Close;
    admPrincipal.ExecutaSql.SQL.Clear;
    admPrincipal.ExecutaSql.SQL.add(' UPDATE LOGDOWNLOAD  SET DATAFIM = '+  QuotedStr(FormatDateTime('dd/mm/yyyy', now)));
    admPrincipal.ExecutaSql.SQL.add(' WHERE CODIGO = '+ IntToStr(Componente.Codigo));
    admPrincipal.ExecutaSql.ExecSQL;
    Result:= true;
  except
    Result:= false;
  end;
end;

procedure TDownload.SetComponentesDownload(const Value: TComponentesDownload);
begin
  FLinhaGrid:= Value;
end;

procedure TDownload.SetDadosDownloads(const Value: TDadosDownload);
begin
  FDadosDonwload:= Value;
end;

procedure TDownload.SetExecutando(const Value: Boolean);
begin
  FExecutando:= Value;
end;

procedure TDownload.SetID(const Value: Integer);
begin
  FID:= Value;
end;

procedure TDownload.SetPausar(const Value: Boolean);
begin
  FPausar:= Value;
end;

{ TConfirmacao }

procedure TConfirmacao.Update;
begin
  if FSubject is TDownload then
    TDownload(FSubject).GravaDownloadDBFinal;
end;

{ TComponentesDownload }

procedure TComponentesDownload.SetBotao01(const Value: TImage);
begin
  FBotao01:= Value;
end;

procedure TComponentesDownload.SetBotao02(const Value: TImage);
begin
  FBotao02:= Value;
end;

procedure TComponentesDownload.SetBotao03(const Value: TImage);
begin
  FBotao03:= Value;
end;

procedure TComponentesDownload.SetCodigo(const Value: Integer);
begin
  FCodigo:= Value;
end;

procedure TComponentesDownload.SetFileStream(const Value: TFileStream);
begin
  FTFileStream:= Value;
end;

procedure TComponentesDownload.SetLabelDadosDonw(const Value: TLabel);
begin
  FdadosDonw:= Value;
end;

procedure TComponentesDownload.SetLabelDadosPorc(const Value: TLabel);
begin
  FdadosPorc:= Value;
end;

procedure TComponentesDownload.SetLabelUrl(const Value: TLabel);
begin
  FlabelURL:= Value;
end;

procedure TComponentesDownload.SetProgressBar(const Value: TProgressbar);
begin
  FprogressBar:= Value;
end;

end.
