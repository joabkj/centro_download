object frmHistorico: TfrmHistorico
  Left = 0
  Top = 0
  BorderStyle = bsSizeToolWin
  Caption = 'Centro de Downloads'
  ClientHeight = 441
  ClientWidth = 857
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  Position = poMainFormCenter
  OnCreate = FormCreate
  TextHeight = 15
  object Panel1: TPanel
    Left = 0
    Top = 0
    Width = 857
    Height = 41
    Align = alTop
    Caption = 'Hist'#243'rico'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -21
    Font.Name = 'Segoe UI'
    Font.Style = [fsBold]
    ParentFont = False
    TabOrder = 0
    ExplicitLeft = -241
    ExplicitWidth = 865
  end
  object DBGrid1: TDBGrid
    Left = 0
    Top = 41
    Width = 857
    Height = 400
    Align = alClient
    DataSource = dmConection.ds_Downloads
    Options = [dgTitles, dgIndicator, dgColumnResize, dgColLines, dgRowLines, dgTabs, dgConfirmDelete, dgCancelOnExit, dgTitleClick, dgTitleHotTrack]
    TabOrder = 1
    TitleFont.Charset = DEFAULT_CHARSET
    TitleFont.Color = clWindowText
    TitleFont.Height = -12
    TitleFont.Name = 'Segoe UI'
    TitleFont.Style = []
    Columns = <
      item
        Expanded = False
        FieldName = 'CODIGO'
        Width = 65
        Visible = True
      end
      item
        Expanded = False
        FieldName = 'URL'
        Width = 511
        Visible = True
      end
      item
        Expanded = False
        FieldName = 'DATAINICIO'
        Title.Caption = 'Data Incial'
        Width = 104
        Visible = True
      end
      item
        Expanded = False
        FieldName = 'DATAFIM'
        Title.Caption = 'Data Final'
        Width = 123
        Visible = True
      end>
  end
end
