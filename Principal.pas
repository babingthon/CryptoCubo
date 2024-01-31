unit Principal;

interface

  uses
    Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
    System.Classes, Vcl.Graphics,
    Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, System.NetEncoding,
    IdCoder, IdCoderMIME, IdBaseComponent, IdComponent, IdTCPConnection,
    IdTCPClient, IdHTTP, Data.Bind.Components, Data.Bind.ObjectScope,
    REST.Client,
    REST.Types, Vcl.ExtCtrls, Vcl.Mask, Vcl.Buttons, Vcl.Imaging.pngimage;

  type
    TFrmPrincipal = class(TForm)
      OpenDialogFile: TOpenDialog;
      CategoryPanelGroup1: TCategoryPanelGroup;
      CategoryPanel1: TCategoryPanel;
      CategoryPanel2: TCategoryPanel;
      CategoryPanel3: TCategoryPanel;
      Panel1: TPanel;
      Panel2: TPanel;
      LabeledEditSenha: TLabeledEdit;
      LabeledEditPin: TLabeledEdit;
      LabeledEditAliase: TLabeledEdit;
      BtnImportar: TButton;
      LabeledEditIdCertificado: TLabeledEdit;
      ButtonAtivarCert: TButton;
      Panel5: TPanel;
      Panel6: TPanel;
      LabeledEditAliaseDoc: TLabeledEdit;
      LabeledEditPinDoc: TLabeledEdit;
      Panel7: TPanel;
      MemoRetorno: TMemo;
      Panel9: TPanel;
      Image1: TImage;
      Image2: TImage;
      EditArquivo: TEdit;
      ButtonLoadFile: TButton;
      Panel8: TPanel;
      MemoRetornoFinal: TMemo;
      Panel4: TPanel;
      Button4: TButton;
      MemoBase64Certificado: TMemo;
      Button6: TButton;
      Button3: TButton;
      Button2: TButton;
      Button1: TButton;
      BtnVerifcarDoc: TButton;
      MemoBase64: TMemo;
    LabelEditChaveAPI: TLabeledEdit;
      procedure Button1Click(Sender: TObject);
      procedure Button2Click(Sender: TObject);
      procedure Button3Click(Sender: TObject);
      procedure ButtonLoadFileClick(Sender: TObject);
      procedure BtnImportarClick(Sender: TObject);
      procedure ButtonAtivarCertClick(Sender: TObject);
      procedure Button4Click(Sender: TObject);
      procedure Button6Click(Sender: TObject);
      procedure BtnVerifcarDocClick(Sender: TObject);
      procedure MemoBase64Click(Sender: TObject);
      procedure FormCreate(Sender: TObject);
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

  procedure TFrmPrincipal.BtnVerifcarDocClick(Sender: TObject);
    var
      Crypto: TCryptoCube;
    begin

      Crypto := TCryptoCube.Create(LabelEditChaveAPI.Text);

      try

        MemoRetornoFinal.Lines.Clear;

        MemoRetornoFinal.Text := Crypto.VerifyDocument(MemoBase64.Text,
          MemoRetorno.Text);

      finally
        Crypto.Destroy;
      end;

    end;

  procedure TFrmPrincipal.Button1Click(Sender: TObject);
    var
      Crypto: TCryptoCube;
    begin

      Crypto := TCryptoCube.Create(LabelEditChaveAPI.Text);

      Try
        LabeledEditSenha.Text := Crypto.EncodeStringBase64
        (LabeledEditSenha.Text);
        LabeledEditPin.Text := Crypto.EncodeStringBase64(LabeledEditPin.Text);
      Finally
        Crypto.DisposeOf;
      End;

    end;

  procedure TFrmPrincipal.Button2Click(Sender: TObject);
    var
      Crypto: TCryptoCube;
    begin

      Crypto := TCryptoCube.Create(LabelEditChaveAPI.Text);

      Try
        LabeledEditSenha.Text := Crypto.DecodeStringBase64
        (LabeledEditSenha.Text);
        LabeledEditPin.Text := Crypto.DecodeStringBase64(LabeledEditPin.Text);
      Finally
        Crypto.DisposeOf;
      End;
    end;

  procedure TFrmPrincipal.Button3Click(Sender: TObject);
    var
      FS: TFileStream;
      Coder: TIdEncoderMIME;
    begin
      FS := TFileStream.Create(EditArquivo.Text, fmOpenRead or
        fmShareDenyWrite);
      try
        Coder := TIdEncoderMIME.Create(nil);
        try
          MemoBase64.Lines.Clear;
          MemoBase64.Lines.Add(Coder.EncodeStream(FS));
        finally
          Coder.Free;
        end;
      finally
        FS.Free;
      end;
    end;

  procedure TFrmPrincipal.Button4Click(Sender: TObject);
    var
      FS: TFileStream;
      Coder: TIdDecoderMIME;
      CaminhoArquivo, NomeArquivo: string;
    begin

      CaminhoArquivo := '';
      CaminhoArquivo := ExtractFilePath(Application.ExeName);
      NomeArquivo := '';
      NomeArquivo := FormatDateTime('hh:mm:ss', Now());

      FS := TFileStream.Create(CaminhoArquivo + NomeArquivo + '.pdf', fmCreate);
      try
        Coder := TIdDecoderMIME.Create(nil);
        try
          Coder.DecodeStream(Trim(MemoRetornoFinal.Text), FS);
        finally
          Coder.Free;
        end;
      finally
        FS.Free;
      end;
    end;

  procedure TFrmPrincipal.ButtonLoadFileClick(Sender: TObject);
    begin
      if OpenDialogFile.Execute then
        begin
          EditArquivo.Text := OpenDialogFile.FileName;
        end;
    end;

  procedure TFrmPrincipal.FormCreate(Sender: TObject);
    begin
      CategoryPanelGroup1.CollapseAll;
    end;

  procedure TFrmPrincipal.MemoBase64Click(Sender: TObject);
    var
      TextoVerificacao: TStringList;
    begin

      TextoVerificacao := TStringList.Create;

      try
        TextoVerificacao.Add(' base64 do arquivo a ser assinado.');

        if MemoBase64.Lines.Equals(TextoVerificacao) then
          begin
            MemoBase64.Lines.Clear;
          end;

      finally
        TextoVerificacao.Destroy;
      end;

    end;

  procedure TFrmPrincipal.Button6Click(Sender: TObject);
    begin
      var
        Crypto: TCryptoCube;
      begin

        Crypto := TCryptoCube.Create(LabelEditChaveAPI.Text);

        try

          if Trim(LabeledEditPinDoc.Text) = '' then
            begin
              MessageDlg('Informe a o PIN (em base64).', TMsgDlgType.mtWarning,
                [TMsgDlgBtn.mbOK], 0);
              LabeledEditPinDoc.SetFocus;
              Exit;
            end;

          if Trim(LabeledEditAliaseDoc.Text) = '' then
            begin
              MessageDlg('Informe o apelido do certificado.',
                TMsgDlgType.mtWarning, [TMsgDlgBtn.mbOK], 0);
              LabeledEditAliaseDoc.SetFocus;
              Exit;
            end;

          if OpenDialogFile.Files.Count = 0 then
            begin
              MessageDlg('Informe o arquivo a ser assinado.',
                TMsgDlgType.mtWarning, [TMsgDlgBtn.mbOK], 0);
              Exit;
            end;

          if Trim(MemoBase64.Text) = '' then
            begin
              MessageDlg('Informe o base64 do do arquivo.',
                TMsgDlgType.mtWarning, [TMsgDlgBtn.mbOK], 0);
              MemoBase64.SetFocus;
              Exit;
            end;

          MemoRetorno.Lines.Clear;

          MemoRetorno.Text := Crypto.SignDocument(LabeledEditAliaseDoc.Text,
            Crypto.EncodeStringBase64(LabeledEditPinDoc.Text), MemoBase64.Text);

        finally
          Crypto.Destroy;
        end;

      end;
    end;

  procedure TFrmPrincipal.ButtonAtivarCertClick(Sender: TObject);
    var
      Crypto: TCryptoCube;
    begin

      try
        Crypto := TCryptoCube.Create(LabelEditChaveAPI.Text);
        if Crypto.ActiveCertificade(LabeledEditIdCertificado.Text,
          LabeledEditPin.Text) then
          begin
            MessageDlg('Certificado Ativado com Sucesso.',
              TMsgDlgType.mtConfirmation, [TMsgDlgBtn.mbOK], 0);
          end;

      finally
        Crypto.Destroy;
      end;
    end;

  procedure TFrmPrincipal.BtnImportarClick(Sender: TObject);
    var
      Crypto: TCryptoCube;
      retorno: string;
    begin

      if Trim(LabeledEditSenha.Text) = '' then
        begin
          MessageDlg('Informe a senha.', TMsgDlgType.mtWarning,
            [TMsgDlgBtn.mbOK], 0);
          LabeledEditSenha.SetFocus;
          Exit;
        end;

      if Trim(LabeledEditPin.Text) = '' then
        begin
          MessageDlg('Informe o PIN.', TMsgDlgType.mtWarning,
            [TMsgDlgBtn.mbOK], 0);
          LabeledEditPin.SetFocus;
          Exit;
        end;

      if Trim(LabeledEditAliase.Text) = '' then
        begin
          MessageDlg('Informe o apelido.', TMsgDlgType.mtWarning,
            [TMsgDlgBtn.mbOK], 0);
          LabeledEditAliase.SetFocus;
          Exit;
        end;

      if Trim(MemoBase64Certificado.Text) = '' then
        begin
          MessageDlg('Informe o base64 do certificado.', TMsgDlgType.mtWarning,
            [TMsgDlgBtn.mbOK], 0);
          MemoBase64Certificado.SetFocus;
          Exit;
        end;

      try
        Crypto := TCryptoCube.Create(LabelEditChaveAPI.Text);
        retorno := Crypto.ImportCertificade(LabeledEditSenha.Text,
          LabeledEditPin.Text, LabeledEditAliase.Text,
          MemoBase64Certificado.Text);

        LabeledEditIdCertificado.Text := retorno;
      finally
        Crypto.Destroy;
      end;

    end;

end.
