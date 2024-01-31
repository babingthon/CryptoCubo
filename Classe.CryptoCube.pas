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
  REST.Authenticator.Basic, Vcl.Dialogs, Vcl.Clipbrd, IdCoder, IdCoderMIME;

type
  TCryptoCube = class
  private
    restClient: TRESTClient;
    restRequest: TRESTRequest;
    jsonRetorno: TJSONObject;
    jsonObjFilho: TJSONObject;
    jsonResposta: string;
    JSON: string;
    ThumbPrintPfx: string;
  public
    constructor Create(ChaveApi : string);
    destructor Destroy; override;
    function EncodeStringBase64(Value: string): string;
    function DecodeStringBase64(Value: string): string;
    function EncodeFileBase64(FileName: string): string;
    procedure DecodeFileBase64(const Base64, FileName: string);
    function ImportCertificade(PasswordPfx: string; PinPfx: string;
      AliasesPfx: string; FilePfx: string): string;
    function SanatizeBase64(const Base64: string): string;
    function ActiveCertificade(IdCertificade, PinCertificade: string): Boolean;
    function SignDocument(AliasPfx, PinPfx, Base64Document : string) : string;
    function VerifyDocument(OriginalBase64, SignBase64: string) : string;
  end;

CONST
  UrlBase = 'https://api.cryptocubo.com.br/api/eletronic-signatures/';

implementation

{ CryptoCube }

function TCryptoCube.ActiveCertificade(IdCertificade, PinCertificade: string): Boolean;
var
  jsonPrincipal : TJSONObject;
begin

  jsonPrincipal:= TJSONObject.Create;
  restRequest.Method := rmPUT;
  restRequest.Resource := 'management/key/v0/' + IdCertificade + '/activate';

  try

    jsonPrincipal.AddPair('pin', PinCertificade);

    restRequest.Params.Add;
    restRequest.Params[3].ContentType := ctAPPLICATION_JSON;
    restRequest.Params[3].Kind := pkREQUESTBODY;
    restRequest.Params[3].name := 'body';
    restRequest.Params[3].Options := [poDoNotEncode];
    restRequest.Params[3].Value := jsonPrincipal.ToJSON;

    Clipboard.asText := jsonPrincipal.ToString;

    try

      restRequest.Execute;
      jsonResposta := '';

      case restRequest.Response.StatusCode of
        200, 202:
          begin

            Result:= True;

          end;
        400, 402:
          begin
            jsonRetorno := jsonRetorno.ParseJSONValue
              (TEncoding.UTF8.GetBytes(restRequest.Response.Content), 0)
              as TJSONObject;
            jsonObjFilho := jsonRetorno.GetValue('error') as TJSONObject;
            jsonResposta := jsonObjFilho.GetValue<string>('message');

            MessageDlg('Aviso: Status[' + restRequest.Response.StatusCode.
              ToString + '] -  ' + jsonResposta + '.', TMsgDlgType.mtWarning,
              [TMsgDlgBtn.mbOK], 0);

            Result:= False;
          end;
        404:
          begin
            jsonRetorno := jsonRetorno.ParseJSONValue
              (TEncoding.UTF8.GetBytes(restRequest.Response.Content), 0)
              as TJSONObject;

            if jsonRetorno.Count = 1 then
            begin
              jsonObjFilho := jsonRetorno.GetValue('error') as TJSONObject;
              jsonResposta := jsonObjFilho.GetValue<string>('message');
            end
            else
              jsonResposta := jsonRetorno.GetValue<string>('message');

            MessageDlg('Aviso: Status[' + restRequest.Response.StatusCode.
              ToString + '] -  ' + jsonResposta + '.', TMsgDlgType.mtWarning,
              [TMsgDlgBtn.mbOK], 0);

            Result:= False;
          end;
      end;

    except
      on E: Exception do
      begin
        raise Exception.Create('Ocorreu um erro: Status[' +
          restRequest.Response.StatusCode.ToString + '] - ' + E.Message);
        jsonPrincipal.Free;
      end;

    end;

  finally
    jsonPrincipal.Free;
  end;

end;

constructor TCryptoCube.Create(ChaveAPI : string);
begin

  FormatSettings.DecimalSeparator := '.';

  restClient := TRESTClient.Create(nil);
  restRequest := TRESTRequest.Create(nil);

  restClient.ResetToDefaults;
  restClient.Accept := '';
  restClient.AcceptCharset := '';
  restClient.AcceptEncoding := '';

  restClient.AllowCookies := True;
  restClient.AutoCreateParams := True;

  restClient.BaseURL := UrlBase;

  restClient.ConnectTimeout := 30000;
  restClient.ContentType := '';
  restClient.FallbackCharsetEncoding := 'utf-8';
  restClient.HandleRedirects := True;
  restClient.RaiseExceptionOn500 := True;
  restClient.ReadTimeout := 30000;
  restClient.SynchronizedEvents := True;
  restClient.UserAgent := 'Embarcadero RESTClient/1.0';

  restRequest.Client := restClient;
  restRequest.Accept := 'application/json, text/plain; q=0.9, text/html;q=0.8,';
  restRequest.AcceptCharset := 'utf-8, *;q=0.8';

  restRequest.Params.Clear;

  restRequest.Params.Add;
  restRequest.Params[0].ContentType := ctNone;
  restRequest.Params[0].Kind := pkHTTPHEADER;
  restRequest.Params[0].name := 'Ocp-Apim-Subscription-Key';
  restRequest.Params[0].Options := [poDoNotEncode];
  restRequest.Params[0].Value := ChaveAPI;

  restRequest.Params.Add;
  restRequest.Params[1].ContentType := ctNone;
  restRequest.Params[1].Kind := pkHTTPHEADER;
  restRequest.Params[1].name := 'Content-Type';
  restRequest.Params[1].Options := [poDoNotEncode];
  restRequest.Params[1].Value := 'application/json';

  restRequest.Params.Add;
  restRequest.Params[2].ContentType := ctNone;
  restRequest.Params[2].Kind := pkHTTPHEADER;
  restRequest.Params[2].name := 'Cache-Control';
  restRequest.Params[2].Options := [poDoNotEncode];
  restRequest.Params[2].Value := 'no-cache';

  jsonObjFilho := TJSONObject.Create;
  jsonRetorno := TJSONObject.Create;

end;

procedure TCryptoCube.DecodeFileBase64(const Base64, FileName: string);
var
  FS: TFileStream;
  Coder: TIdDecoderMIME;
begin
  FS := TFileStream.Create(FileName, fmCreate);
  try
    Coder := TIdDecoderMIME.Create(nil);
    try
      Coder.DecodeStream(Base64, FS);
    finally
      Coder.Free;
    end;
  finally
    FS.Free;
  end;
end;

function TCryptoCube.DecodeStringBase64(Value: string): string;
begin
  Result := TNetEncoding.Base64.Decode(Value);
end;

destructor TCryptoCube.Destroy;
begin
  jsonRetorno.Free;
  restRequest.Free;
  restClient.Free;
  inherited;
end;

function TCryptoCube.EncodeFileBase64(FileName: string): string;
var
  FS: TFileStream;
  Coder: TIdEncoderMIME;
begin
  FS := TFileStream.Create(FileName, fmOpenRead or fmShareDenyWrite);
  try
    Coder := TIdEncoderMIME.Create(nil);
    try
      Result := Coder.EncodeStream(FS);
    finally
      Coder.Free;
    end;
  finally
    FS.Free;
  end;
end;

function TCryptoCube.EncodeStringBase64(Value: string): string;
begin
  Result := TNetEncoding.Base64.Encode(Value);
end;

function TCryptoCube.ImportCertificade(PasswordPfx, PinPfx, AliasesPfx,
  FilePfx: string): string;
var
  jsonPrincipal : TJSONObject;
begin

  jsonPrincipal := TJSONObject.Create;
  restRequest.Method := rmPOST;
  restRequest.Resource := 'management/keys/v0/' + AliasesPfx + '/import';

  try

    jsonPrincipal.AddPair('activationType', 'None');
    jsonPrincipal.AddPair('password', PasswordPfx);
    jsonPrincipal.AddPair('pfx', FilePfx);
    jsonPrincipal.AddPair('pin', PinPfx);

    restRequest.Params.Add;
    restRequest.Params[3].ContentType := ctAPPLICATION_JSON;
    restRequest.Params[3].Kind := pkREQUESTBODY;
    restRequest.Params[3].name := 'body';
    restRequest.Params[3].Options := [poDoNotEncode];
    restRequest.Params[3].Value := jsonPrincipal.ToJSON;

    Clipboard.asText := jsonPrincipal.ToString;

    try

      restRequest.Execute;
      jsonResposta := '';

      case restRequest.Response.StatusCode of
        200, 202:
          begin
            jsonRetorno := jsonRetorno.ParseJSONValue
              (TEncoding.UTF8.GetBytes(restRequest.Response.Content), 0)
              as TJSONObject;
            jsonResposta := jsonRetorno.GetValue<string>('thumbprint');

            Result := jsonResposta;
          end;
        400, 402:
          begin
            jsonRetorno := jsonRetorno.ParseJSONValue
              (TEncoding.UTF8.GetBytes(restRequest.Response.Content), 0)
              as TJSONObject;
            jsonObjFilho := jsonRetorno.GetValue('error') as TJSONObject;
            jsonResposta := jsonObjFilho.GetValue<string>('message');

            MessageDlg('Aviso: Status[' + restRequest.Response.StatusCode.
              ToString + '] -  ' + jsonResposta + '.', TMsgDlgType.mtWarning,
              [TMsgDlgBtn.mbOK], 0);
          end;
        404:
          begin
            jsonRetorno := jsonRetorno.ParseJSONValue
              (TEncoding.UTF8.GetBytes(restRequest.Response.Content), 0)
              as TJSONObject;

            if jsonRetorno.Count = 1 then
            begin
              jsonObjFilho := jsonRetorno.GetValue('error') as TJSONObject;
              jsonResposta := jsonObjFilho.GetValue<string>('message');
            end
            else
              jsonResposta := jsonRetorno.GetValue<string>('message');

            MessageDlg('Aviso: Status[' + restRequest.Response.StatusCode.
              ToString + '] -  ' + jsonResposta + '.', TMsgDlgType.mtWarning,
              [TMsgDlgBtn.mbOK], 0);
          end;
      end;

    except
      on E: Exception do
      begin
        raise Exception.Create('Ocorreu um erro: Status[' +
          restRequest.Response.StatusCode.ToString + '] - ' + E.Message);
        jsonPrincipal.Free;
      end;

    end;

  finally
    jsonPrincipal.Free;
  end;

end;

function TCryptoCube.SanatizeBase64(const Base64: string): string;
var
  Aux: string;
begin
  Aux := Base64;
  Aux := StringReplace(Aux, '/', '', [rfReplaceAll]);
  Aux := StringReplace(Aux, ',', '', [rfReplaceAll]);
  Aux := StringReplace(Aux, '.', '', [rfReplaceAll]);
  Aux := StringReplace(Aux, ':', '', [rfReplaceAll]);
  Aux := StringReplace(Aux, '-', '', [rfReplaceAll]);
  Aux := StringReplace(Aux, '(', '', [rfReplaceAll]);
  Aux := StringReplace(Aux, ')', '', [rfReplaceAll]);
  Aux := StringReplace(Aux, 'º', '', [rfReplaceAll]);
  Aux := StringReplace(Aux, 'ª', '', [rfReplaceAll]);
  Aux := StringReplace(Aux, '°', '', [rfReplaceAll]);
  Aux := StringReplace(Aux, '-', '', [rfReplaceAll]);
  Aux := StringReplace(Aux, '*', '', [rfReplaceAll]);
  Aux := StringReplace(Aux, '&', '', [rfReplaceAll]);
  Aux := StringReplace(Aux, '¨', '', [rfReplaceAll]);
  Aux := StringReplace(Aux, '%', '', [rfReplaceAll]);
  Aux := StringReplace(Aux, '$', '', [rfReplaceAll]);
  Aux := StringReplace(Aux, '#', '', [rfReplaceAll]);
  Aux := StringReplace(Aux, '@', '', [rfReplaceAll]);
  Aux := StringReplace(Aux, '!', '', [rfReplaceAll]);
  Aux := StringReplace(Aux, '_', '', [rfReplaceAll]);
  Aux := StringReplace(Aux, '=', '', [rfReplaceAll]);
  Aux := StringReplace(Aux, '+', '', [rfReplaceAll]);
  Aux := StringReplace(Aux, '''', '', [rfReplaceAll]);
  Aux := StringReplace(Aux, '´', '', [rfReplaceAll]);
  Aux := StringReplace(Aux, '`', '', [rfReplaceAll]);
  Aux := StringReplace(Aux, '§', '', [rfReplaceAll]);
  Aux := StringReplace(Aux, ';', '', [rfReplaceAll]);
  Aux := StringReplace(Aux, '<', '', [rfReplaceAll]);
  Aux := StringReplace(Aux, '>', '', [rfReplaceAll]);
  Aux := StringReplace(Aux, ',', '', [rfReplaceAll]);
  Aux := StringReplace(Aux, '{', '', [rfReplaceAll]);
  Aux := StringReplace(Aux, '}', '', [rfReplaceAll]);
  Aux := StringReplace(Aux, '[', '', [rfReplaceAll]);
  Aux := StringReplace(Aux, ']', '', [rfReplaceAll]);
  Aux := StringReplace(Aux, '\', '', [rfReplaceAll]);

  Result := Aux;
end;

function TCryptoCube.SignDocument(AliasPfx, PinPfx,
  Base64Document: string): string;
var
  jsonPrincipal, jsonContent, jsonValue : TJSONObject;
  jsonDocuments, jsonSignature : TJSONArray;
  json: TJSONObject;
  documents: TJSONArray;
  signatures: TJSONArray;
  signers: TJSONArray;
  cpf, signingTime, value: string;
  i, j, k: Integer;
begin

  jsonPrincipal:= TJSONObject.Create;
  jsonDocuments := TJSONArray.Create;
  jsonContent := TJSONObject.Create;
  jsonValue := TJSONObject.Create;
  jsonSignature := TJSONArray.Create;
  restRequest.Method := rmPOST;
  restRequest.Resource := '/v0/sign/qualified/pdf?icpbr=true';

  try

    jsonPrincipal.AddPair('alias', AliasPfx);
    jsonPrincipal.AddPair('pin', PinPfx);
    jsonContent.AddPair('content', Base64Document);
    jsonDocuments.Add(jsonContent);
    jsonPrincipal.AddPair('documents', jsonDocuments);

    restRequest.Params.Add;
    restRequest.Params[3].ContentType := ctNone;
    restRequest.Params[3].Kind := pkREQUESTBODY;
    restRequest.Params[3].name := 'body';
    restRequest.Params[3].Options := [poDoNotEncode];
    restRequest.Params[3].Value := jsonPrincipal.ToJSON;

    Clipboard.asText := jsonPrincipal.ToString;

    try

      restRequest.Execute;
      jsonResposta := '';

      case restRequest.Response.StatusCode of
        200, 202:
          begin

           JSON := TJSONObject.ParseJSONValue(TEncoding.UTF8.GetBytes(restRequest.Response.Content), 0) as TJSONObject;
            try
              documents := JSON.GetValue('documents') as TJSONArray;
              for i := 0 to documents.Count - 1 do
              begin
                signatures := (documents.Items[i] as TJSONObject).GetValue('signatures') as TJSONArray;
                for j := 0 to signatures.Count - 1 do
                begin
                  Value := (signatures.Items[j] as TJSONObject).GetValue('value').Value;

                  Result:= SanatizeBase64(Value);

                  signers := (signatures.Items[j] as TJSONObject).GetValue('signers') as TJSONArray;
                  for k := 0 to signers.Count - 1 do
                  begin
                    cpf := (signers.Items[k] as TJSONObject).GetValue('cpf').Value;
                    signingTime := (signers.Items[k] as TJSONObject).GetValue('signingTime').Value;
                  end;
                end;
              end;
            finally
              JSON.Free;
            end;

          end;
        400, 402:
          begin

            jsonRetorno := jsonRetorno.ParseJSONValue(TEncoding.UTF8.GetBytes(restRequest.Response.Content), 0) as TJSONObject;
            jsonObjFilho := jsonRetorno.GetValue('error') as TJSONObject;
            jsonResposta := jsonObjFilho.GetValue<string>('message');

            MessageDlg('Aviso: Status[' + restRequest.Response.StatusCode.ToString + '] -  ' + jsonResposta + '.', TMsgDlgType.mtWarning, [TMsgDlgBtn.mbOK], 0);

          end;
        404:
          begin

            jsonRetorno := jsonRetorno.ParseJSONValue
              (TEncoding.UTF8.GetBytes(restRequest.Response.Content), 0)
              as TJSONObject;

            if jsonRetorno.Count = 1 then
            begin
              jsonObjFilho := jsonRetorno.GetValue('error') as TJSONObject;
              jsonResposta := jsonObjFilho.GetValue<string>('message');
            end
            else
              jsonResposta := jsonRetorno.GetValue<string>('message');

            MessageDlg('Aviso: Status[' + restRequest.Response.StatusCode.
              ToString + '] -  ' + jsonResposta + '.', TMsgDlgType.mtWarning,
              [TMsgDlgBtn.mbOK], 0);

          end;
      end;

    except
      on E: Exception do
      begin
        raise Exception.Create('Ocorreu um erro: Status[' +
          restRequest.Response.StatusCode.ToString + '] - ' + E.Message);
        jsonPrincipal.Free;
      end;

    end;

  finally
    jsonPrincipal.Free;
  end;
end;

function TCryptoCube.VerifyDocument(OriginalBase64, SignBase64: string): string;
var
  jsonPrincipal, jsondocuments, jsonsignatures, jsonsignature: TJSONObject;
  jsondocumentsArr, jsonsignaturesArr: TJSONArray;
  jsonContent, jsonValue : TJSONObject;
  json: TJSONObject;
  documents: TJSONArray;
  signatures: TJSONArray;
  signers: TJSONArray;
  cpf, signingTime, value: string;
  i, j, k: Integer;
begin

  jsonPrincipal := TJSONObject.Create;
  restRequest.Method := rmPOST;
  restRequest.Resource := '/v0/verify/qualified/pdf?icpbr=true';

  try

    jsondocumentsArr := TJSONArray.Create;
    jsondocuments := TJSONObject.Create;
    jsondocuments.AddPair('content', OriginalBase64);
    jsonsignaturesArr := TJSONArray.Create;
    jsonsignature := TJSONObject.Create;
    jsonsignature.AddPair('value', SignBase64);
    jsonsignaturesArr.Add(jsonsignature);
    jsondocuments.AddPair('signatures', jsonsignaturesArr);

    jsondocumentsArr.Add(jsondocuments);
    jsonPrincipal.AddPair('documents', jsondocumentsArr);

    restRequest.Params.Add;
    restRequest.Params[3].ContentType := ctNone;
    restRequest.Params[3].Kind := pkREQUESTBODY;
    restRequest.Params[3].name := 'body';
    restRequest.Params[3].Options := [poDoNotEncode];
    restRequest.Params[3].Value := jsonPrincipal.ToJSON;

    Clipboard.asText := jsonPrincipal.ToString;

    try

      restRequest.Execute;
      jsonResposta := '';

      case restRequest.Response.StatusCode of
        200, 202:
          begin

           JSON := TJSONObject.ParseJSONValue(TEncoding.UTF8.GetBytes(restRequest.Response.Content), 0) as TJSONObject;
            try
              documents := JSON.GetValue('documents') as TJSONArray;
              for i := 0 to documents.Count - 1 do
              begin
                signatures := (documents.Items[i] as TJSONObject).GetValue('signatures') as TJSONArray;
                for j := 0 to signatures.Count - 1 do
                begin
                  Value := (signatures.Items[j] as TJSONObject).GetValue('value').Value;

                  Result:= SanatizeBase64(Value);

                  signers := (signatures.Items[j] as TJSONObject).GetValue('signers') as TJSONArray;
                  for k := 0 to signers.Count - 1 do
                  begin
                    cpf := (signers.Items[k] as TJSONObject).GetValue('cpf').Value;
                    signingTime := (signers.Items[k] as TJSONObject).GetValue('signingTime').Value;
                  end;
                end;
              end;
            finally
              JSON.Free;
            end;

          end;
        400, 402:
          begin

            jsonRetorno := jsonRetorno.ParseJSONValue(TEncoding.UTF8.GetBytes(restRequest.Response.Content), 0) as TJSONObject;
            jsonObjFilho := jsonRetorno.GetValue('error') as TJSONObject;
            jsonResposta := jsonObjFilho.GetValue<string>('message');

            MessageDlg('Aviso: Status[' + restRequest.Response.StatusCode.ToString + '] -  ' + jsonResposta + '.', TMsgDlgType.mtWarning, [TMsgDlgBtn.mbOK], 0);

          end;
        404:
          begin

            jsonRetorno := jsonRetorno.ParseJSONValue
              (TEncoding.UTF8.GetBytes(restRequest.Response.Content), 0)
              as TJSONObject;

            if jsonRetorno.Count = 1 then
            begin
              jsonObjFilho := jsonRetorno.GetValue('error') as TJSONObject;
              jsonResposta := jsonObjFilho.GetValue<string>('message');
            end
            else
              jsonResposta := jsonRetorno.GetValue<string>('message');

            MessageDlg('Aviso: Status[' + restRequest.Response.StatusCode.
              ToString + '] -  ' + jsonResposta + '.', TMsgDlgType.mtWarning,
              [TMsgDlgBtn.mbOK], 0);

          end;
      end;

    except
      on E: Exception do
      begin
        raise Exception.Create('Ocorreu um erro: Status[' +
          restRequest.Response.StatusCode.ToString + '] - ' + E.Message);
        jsonPrincipal.Free;
      end;

    end;

  finally
    jsonPrincipal.Free;
  end;
end;

end.
