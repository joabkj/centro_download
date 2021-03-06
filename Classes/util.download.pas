unit util.download;
interface
uses
  Classes, IdBaseComponent, IdComponent, IdTCPConnection, IdTCPClient, IdHTTP,
  IdSSLOpenSSL, Math;
{$M+}
type
  TIdHTTPProgress = class(TIdHTTP)
  private
    FProgress       : Integer;
    FBytesToTransfer: Int64;
    FOnChange       : TNotifyEvent;
    IOHndl          : TIdSSLIOHandlerSocketOpenSSL;
    FPausar         : Boolean;
    FTamanhoArquivo : Int64;
    FBaixado        : Int64;
    FConcluido      : Int64;
    Http            : TIdHTTP;
    fFileStream     : TFileStream;
    procedure HTTPWorkBegin(ASender: TObject; AWorkMode: TWorkMode; AWorkCountMax: Int64);
    procedure HTTPWork(ASender: TObject; AWorkMode: TWorkMode; AWorkCount: Int64);
    procedure HTTPWorkEnd(Sender: TObject; AWorkMode: TWorkMode);
    procedure SetProgress(const Value: Integer);
    procedure SetOnChange(const Value: TNotifyEvent);
  public
    constructor Create(AOwner: TComponent);
    function DownloadFile(const aFileUrl: string; const aDestinationFile: String): Boolean;
  published
    property Progress: Integer read FProgress write SetProgress;
    property BytesToTransfer: Int64 read FBytesToTransfer;
    property OnChange: TNotifyEvent read FOnChange write SetOnChange;
  end;
implementation
uses
  Sysutils, RegrasNegocio;
{ TIdHTTPProgress }
constructor TIdHTTPProgress.Create(AOwner: TComponent);
begin
  inherited;
  IOHndl := TIdSSLIOHandlerSocketOpenSSL.Create(nil);
  Request.BasicAuthentication := True;
  Request.Accept := 'text/html, */*';
//  Request.UserAgent := 'Mozilla/5.0 (compatible; JD Thread Demo)';
  Request.ContentType := 'application/x-www-form-urlencoded';
  Request.UserAgent := 'Mozilla/4.0 (compatible; MSIE 7.0; Windows NT 6.0; Acoo Browser; GTB5; Mozilla/4.0 (compatible; MSIE 6.0; Windows NT 5.1; SV1) ; Maxthon; InfoPath.1; .NET CLR 3.5.30729; .NET CLR 3.0.30618)';
  HandleRedirects := True;
  IOHandler := IOHndl;
  ReadTimeout := 30000;
  IOHndl.SSLOptions.SSLVersions := [sslvTLSv1, sslvTLSv1_1, sslvTLSv1_2];
  {$IFDEF FPC}
  OnWork := @HTTPWork;
  OnWorkBegin := @HTTPWorkBegin;
  OnWorkEnd := @HTTPWorkEnd;
  {$ELSE}
  OnWork := HTTPWork;
  OnWorkBegin := HTTPWorkBegin;
  OnWorkEnd := HTTPWorkEnd;
  {$ENDIF}
end;

//procedure TIdHTTPProgress.DownloadFile(const aFileUrl: string; const aDestinationFile: String);
//var
//  terminado:Boolean;
//begin
//  Http  := TIdHTTP.Create(nil);
//  fFileStream:=nil;
//  try
//    try
//      IOHndl := TIdSSLIOHandlerSocketOpenSSL.Create(nil);
//      Http.OnWorkBegin := HTTPWorkBegin;
//      Http.OnWork:= HTTPWork;
//      Http.OnWorkEnd := HTTPWorkEnd;
//
//      Http.Request.BasicAuthentication := True;
//      Http.Request.Accept := 'text/html, */*';

//
//      Http.Request.ContentType := 'application/x-www-form-urlencoded';
//      Http.Request.UserAgent := 'Mozilla/4.0 (compatible; MSIE 7.0; Windows NT 6.0; Acoo Browser; GTB5; Mozilla/4.0 (compatible; MSIE 6.0; Windows NT 5.1; SV1) ; Maxthon; InfoPath.1; .NET CLR 3.5.30729; .NET CLR 3.0.30618)';
//      Http.HandleRedirects := True;
//      Http.IOHandler := IOHndl;
//      Http.ReadTimeout := 30000;
//      IOHndl.SSLOptions.SSLVersions := [sslvTLSv1, sslvTLSv1_1, sslvTLSv1_2];
//
//
//      // * * * * * * * * * * * * * *  NOVO * * * * * * * * * * * * * *
//      //dava erro 403 forbidden, porque haviam mudado de 'Mozilla/4.0 (compatible; MSIE 7.0; Windows NT 6.0; SLCC1';
//      HTTP.Request.UserAgent :='Mozilla/5.0 (Windows NT 6.1; WOW64; rv:12.0) Gecko/20100101 Firefox/12.0';
//      Http.Request.CacheControl := 'no-cache'; //Para n?o utilizar o cache, sempre baixar do site
//  // * * * * * * * * * * * * * *  FIM  * * * * * * * * * * * * * *
//
//
//      Http.Head(aFileUrl); //Arquivo ? baixar
//      FTamanhoArquivo := Http.Response.ContentLength;//tamanho total do arquivo
//      terminado:=false;
//      repeat //Vai continuar tentando... ( until abaixo )
//        if FPausar then
//          Http.Free;
//
//        if not FileExists(aDestinationFile) then begin
//          fFileStream := TFileStream.Create(aDestinationFile, fmCreate);
//        end
//        else begin
//          fFileStream := TFileStream.Create(aDestinationFile, fmOpenReadWrite);
//          terminado   := fFileStream.Size >= FTamanhoArquivo; //se quantidade baixada = tam do arquivo do serv
//          FConcluido  :=fFileStream.Size;
//          if not terminado then
//            fFileStream.Seek(Max(0, fFileStream.Size-4096), soFromBeginning);
//        end;
//        try
//          FConcluido  :=fFileStream.Size + 50000;//Acrescido em 50kb para garantir chegar ao fim
//          if FConcluido < FTamanhoArquivo then begin
//            Http.Request.Range := IntToStr(fFileStream.Position) + '-'+  IntToStr(FConcluido);
//          end
//          else begin
//            Http.Request.Range := IntToStr(fFileStream.Position) + '-';
//            terminado:=true;
//          end;
//          Http.Get(aDestinationFile, fFileStream);//Ajusta nome do arquivo ? baixar
//        finally
//          fFileStream.Free;
//        end;
//     until terminado; //At? que a vari?vel Exit seja true (veja variavel exit acima)
//     Http.Disconnect;
//    except
//      on E : Exception do
//      Begin
//       //AddLog(E.Message);  //Voc? pode criar uma rotina de arquivo.log e colocar os erros
//      end;
//    end;
//  finally
//    Http.Free;
//  end;
//end;

function TIdHTTPProgress.DownloadFile(const aFileUrl: string; const aDestinationFile: String): Boolean;
var
  aPath: String;
  vTerminado: Boolean;
  fFileStream: TFileStream;
begin
  Result:= true;
  Progress := 0;
  FBytesToTransfer := 0;
  aPath := ExtractFilePath(aDestinationFile);
  if ExtractFilePath(aDestinationFile) <> '' then
    ForceDirectories(aPath);
  try
    try
      Head(aFileUrl);
      FTamanhoArquivo := Response.ContentLength;
      vTerminado:= False;
      repeat
        if FPausar then
          Free;

        begin
          fFileStream := TFileStream.Create(aDestinationFile, fmOpenReadWrite);
          vTerminado  := fFileStream.Size >= FTamanhoArquivo;
          FBaixado    := fFileStream.Size;
          if not vTerminado then
            fFileStream.Seek(Max(0, fFileStream.Size-4096), soFromBeginning);
        end;
        try
          FConcluido:= fFileStream.Size + 50000;
          if FConcluido < FTamanhoArquivo then begin
             Request.Range := IntToStr(fFileStream.Position) + '-'+  IntToStr(FConcluido);
          end
          else begin
            Request.Range := IntToStr(fFileStream.Position) + '-';
            vTerminado:=true;
          end;
          Get(aFileUrl, fFileStream);
        finally
          fFileStream.Free;
        end;
     until vTerminado;
       Disconnect;
    except
      on E : Exception do
      Begin
        Result:= False;

      end;
    end;
  finally

  end;
end;
procedure TIdHTTPProgress.HTTPWork(ASender: TObject; AWorkMode: TWorkMode; AWorkCount: Int64);
begin
  if BytesToTransfer = 0 then // No Update File
    Exit;
  Progress := Round((AWorkCount / BytesToTransfer) * 100);
end;
procedure TIdHTTPProgress.HTTPWorkBegin(ASender: TObject; AWorkMode: TWorkMode; AWorkCountMax: Int64);
begin
  FBytesToTransfer := AWorkCountMax;
end;
procedure TIdHTTPProgress.HTTPWorkEnd(Sender: TObject; AWorkMode: TWorkMode);
begin
  FBytesToTransfer := 0;
  Progress := 100;
end;
procedure TIdHTTPProgress.SetOnChange(const Value: TNotifyEvent);
begin
  FOnChange := Value;
end;
procedure TIdHTTPProgress.SetProgress(const Value: Integer);
begin
  FProgress := Value;
  if Assigned(FOnChange) then
    FOnChange(Self);
end;
end.
