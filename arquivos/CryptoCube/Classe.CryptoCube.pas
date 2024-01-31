unit Classe.CryptoCube;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes,
  System.Variants,
  System.NetEncoding, IdBaseComponent, IdComponent, IdIOHandler,
  IdIOHandlerSocket,
  IdIOHandlerStack, IdSSL, IdSSLOpenSSL, IdTCPConnection, IdTCPClient, IdHTTP,
  Soap.EncdDecd, IOutils, System.Rtti, System.JSON, System.JSON.Types,
  System.JSON.Writers, System.DateUtils,
  System.JSON.Builders, REST.Client, REST.Types, ADODB, Data.DB,
  REST.Authenticator.Basic, Vcl.Dialogs, Vcl.Clipbrd;

type
  TCryptoCube = class
  private
    restClient: TRESTClient;
    restRequest: TRESTRequest;
    jsonRetorno: TJSONObject;
    jsonResposta: string;
    JSON: string;
    httpAuth: THTTPBasicAuthenticator;
    ThumbPrintPfx: string;
  public
    PasswordPfx: string;
    PinPfx: string;
    AliasesPfx: string;
    FilePfx: string;
    constructor Create;
    destructor Destroy; override;
    function EncodeStringBase64(Value: string): string;
    function DecodeStringBase64(Value: string): string;
    function EncodeFileBase64(FileName : string): string;
    procedure DecodeFileBase64(StringBase64: string);
  end;

implementation

{ CryptoCube }

constructor TCryptoCube.Create;
begin

end;

procedure TCryptoCube.DecodeFileBase64(StringBase64: string);
var
  lStreamDst: TFileStream;
  Input: TStringStream;
  Buffer: string;
begin

  Input := TStringStream.Create(StringBase64);
  lStreamDst := TFileStream.Create('H:\arq.pdf', fmCreate);

  DecodeStream(Input, lStreamDst);
  Buffer:= TNetEncoding.Base64.Decode(StringBase64);;
  //Buffer := PChar(AOutFileName);
  //lStreamDst.Write(Buffer^, Length(AOutFileName));
  lStreamDst.Free();
end;

function TCryptoCube.DecodeStringBase64(Value: string): string;
begin
  Result := TNetEncoding.Base64.Decode(Value);
end;

destructor TCryptoCube.Destroy;
begin

  inherited;
end;

function TCryptoCube.EncodeFileBase64(FileName: string): string;
var
  inStream: TStream;
  outStream: TStream;
  Count: Int64;
begin
  inStream := TFileStream.Create(FileName, fmOpenRead);
  try
    outStream := TFileStream.Create('H:\arq.txt', fmCreate);
    try
      TNetEncoding.Base64.Encode(inStream, outStream);

      outStream.Position := 0;
      Count := outStream.Size;
      SetSize(Count);
      if Count <> 0 then
        outStream.ReadBuffer(FMemory^, Count);
    finally
      outStream.Free;
    end;
  finally
    inStream.Free;
  end;
end;

function TCryptoCube.EncodeStringBase64(Value: string): string;
begin
  Result := TNetEncoding.Base64.Encode(Value);
end;

end.
