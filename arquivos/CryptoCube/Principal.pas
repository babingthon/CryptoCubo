unit Principal;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, System.NetEncoding;

type
  TFrmPrincipal = class(TForm)
    Memo1: TMemo;
    Memo2: TMemo;
    Button1: TButton;
    Button2: TButton;
    Button3: TButton;
    Memo3: TMemo;
    Edit1: TEdit;
    OpenDialog1: TOpenDialog;
    Button4: TButton;
    Button5: TButton;
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure Button4Click(Sender: TObject);
    procedure Button5Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  FrmPrincipal: TFrmPrincipal;

implementation

uses Classe.CryptoCube;

{$R *.dfm}

procedure TFrmPrincipal.Button1Click(Sender: TObject);
var
  Crypto: TCryptoCube;
begin

  Crypto := TCryptoCube.Create;

  Try
    Memo2.Lines.Add(Crypto.EncodeStringBase64(Memo1.Text));
  Finally
    Crypto.DisposeOf;
  End;

end;

procedure TFrmPrincipal.Button2Click(Sender: TObject);
var
  Crypto: TCryptoCube;
begin

  Crypto := TCryptoCube.Create;

  Try
    Memo1.Lines.Add(Crypto.DecodeStringBase64(Memo2.Text));
  Finally
    Crypto.DisposeOf;
  End;
end;

procedure TFrmPrincipal.Button3Click(Sender: TObject);
var
  Crypto: TCryptoCube;
  inStream: TStream;
  outStream: TStream;
begin
  inStream := TFileStream.Create(Edit1.Text, fmOpenRead);
  try
    outStream := TFileStream.Create('H:\arq.txt', fmCreate);
    try
      TNetEncoding.Base64.Encode(inStream, outStream);
      outStream.Position := 0;
      Memo3.Lines.LoadFromStream(outStream);
    finally
      outStream.Free;
    end;
  finally
    inStream.Free;
  end;


//  Crypto := TCryptoCube.Create;
//
//  Try
//    Memo3.Lines.Add(Crypto.EncodeFileBase64(Edit1.Text, 'teste'));
//  Finally
//    Crypto.DisposeOf;
//  End;
end;

procedure TFrmPrincipal.Button4Click(Sender: TObject);
begin
  if OpenDialog1.Execute then
  begin
    Edit1.Text := OpenDialog1.FileName;
  end;
end;

procedure TFrmPrincipal.Button5Click(Sender: TObject);
begin
  var
    Crypto: TCryptoCube;
  begin

    Crypto := TCryptoCube.Create;

    Try
      Crypto.DecodeFileBase64(Trim(Memo3.Text));
    Finally
      Crypto.DisposeOf;
    End;
  end;

end;

end.
