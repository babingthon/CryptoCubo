object FrmPrincipal: TFrmPrincipal
  Left = 0
  Top = 0
  Caption = 'Principal'
  ClientHeight = 556
  ClientWidth = 855
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  TextHeight = 15
  object Memo1: TMemo
    Left = 8
    Top = 8
    Width = 281
    Height = 185
    Lines.Strings = (
      '')
    TabOrder = 0
  end
  object Memo2: TMemo
    Left = 304
    Top = 8
    Width = 281
    Height = 185
    Lines.Strings = (
      '')
    ReadOnly = True
    TabOrder = 1
  end
  object Button1: TButton
    Left = 591
    Top = 168
    Width = 138
    Height = 25
    Caption = 'EncodeStringBase64'
    TabOrder = 2
    OnClick = Button1Click
  end
  object Button2: TButton
    Left = 591
    Top = 137
    Width = 138
    Height = 25
    Caption = 'DecodeStringBase64'
    TabOrder = 3
    OnClick = Button2Click
  end
  object Button3: TButton
    Left = 8
    Top = 224
    Width = 145
    Height = 25
    Caption = 'EncodeFileBase64'
    TabOrder = 4
    OnClick = Button3Click
  end
  object Memo3: TMemo
    Left = 8
    Top = 264
    Width = 833
    Height = 225
    Lines.Strings = (
      '')
    TabOrder = 5
  end
  object Edit1: TEdit
    Left = 168
    Top = 225
    Width = 629
    Height = 23
    TabOrder = 6
  end
  object Button4: TButton
    Left = 805
    Top = 224
    Width = 34
    Height = 25
    Caption = '...'
    TabOrder = 7
    OnClick = Button4Click
  end
  object Button5: TButton
    Left = 8
    Top = 512
    Width = 145
    Height = 25
    Caption = 'DecodeFileBase64'
    TabOrder = 8
    OnClick = Button5Click
  end
  object OpenDialog1: TOpenDialog
    Left = 784
    Top = 160
  end
end
