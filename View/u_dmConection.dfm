object dmConection: TdmConection
  Height = 480
  Width = 640
  object Connection: TFDConnection
    Params.Strings = (
      
        'Database=C:\Users\joabk\Desktop\Prova Teste\Fontes\Dados\DB_Donw' +
        'load.db'
      'OpenMode=ReadWrite'
      'DriverID=SQLite')
    Connected = True
    LoginPrompt = False
    Left = 24
    Top = 24
  end
  object Qry_Downloads: TFDQuery
    Connection = Connection
    SQL.Strings = (
      'select * from LOGDOWNLOAD')
    Left = 48
    Top = 88
  end
  object ds_Downloads: TDataSource
    DataSet = Qry_Downloads
    Left = 136
    Top = 88
  end
end
