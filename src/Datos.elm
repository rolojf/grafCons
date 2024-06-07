module Datos exposing (..)


type Mes
    = Ene
    | Feb
    | Mar
    | Abr
    | May
    | Jun
    | Jul
    | Ago
    | Sep
    | Oct
    | Nov
    | Dic


type Frecuente
    = Diario Float
    | Semanal Float Int
    | Mensual Float Int


type TipoClima
    = Normal
    | Inverter


type alias Clima =
    { tons : Float
    , horasEnArranque : Float
    , tipoClima : TipoClima
    , area : String
    , frecUso : Frecuente
    }


type alias DatosP =
    { paneles : Float
    , capPanelesWatts : Int
    , consumoTodos : List Int
    , bimestresDeHistorial : Int
    , hayAdic : Bool
    , climasAdic : List Clima
    , mesMasAntiguo : Mes
    , anioMasAntiguo : Int
    , nombre : String
    , parcial : Float
    }


datos =
    { paneles = 7
    , capPanelesWatts = 550
    , consumoTodos = [ 1632, 757, 1075, 1017, 2020, 1883, 703, 456, 790, 634, 1715, 1149 ]
    , bimestresDeHistorial = 12
    , hayAdic = False
    , climasAdic = []
    , mesMasAntiguo = May
    , anioMasAntiguo = 2022
    , nombre = "Gilberto Ref. Doc. Romero"
    , parcial = 24 / 30
    }



{- datosPapaYuri =
       { paneles = 7
       , capPanelesWatts = 550
       , consumoTodos = [ 2121, 958, 590, 793, 701, 1271, 1596, 1283, 532, 582, 576, 1127 ]
       , bimestresDeHistorial = 12
       , hayAdic = False
       , climasAdic = []
       , mesMasAntiguo = Ago
       , anioMasAntiguo = 2021
       , nombre = "Mamá de Yuri"
       , parcial = 13 / 30
       }



   otrosConsumos =
          Dict.fromList
              [ ( "Eduardo Zanella R.", [ 127 + 326, 373, 877, 1007, 912, 682, 395, 370, 621, 1136, 1082, 635 ] )
              , ( "Rosalinda Garza", [ 319, 239, 1013, 1835, 1634, 747, 329, 249, 512, 1604, 1650, 917 ] )
              , ( "Jess", [ 809, 465, 1573, 1648, 882, 515, 648, 548, 1019, 1570, 1248, 422 ] )
              , ( "Faby", [ 1206, 991, 954, 1444, 1580, 1517, 842, 809, 952, 701, 1536, 1519 ] )
              ]

      climasAdic : Dict String (List Clima)
      climasAdic =
          [ ( "Anterior"
            , [ { tons = 1.5, horasEnArranque = 2, tipoClima = Normal, area = "Área Social", frecUso = Semanal 7.0 2 }
              , { tons = 1.0, horasEnArranque = 2, tipoClima = Inverter, area = "Recamara de los niños", frecUso = Diario 9.0 }
              ]
            )
          , ( "Jess"
            , [ { tons = 1, horasEnArranque = 1, tipoClima = Inverter, area = "Cosina", frecUso = Diario 6.0 } ]
            )
          ]
              |> Dict.fromList



      parcial : Dict String Float
      parcial =
          [ ( "Jess", 9 / 30.42 )
          , ( "Faby", 8 / 30.0 )
          ]
              |> Dict.fromList

      mesMasAntiguo : Dict String Mes
      mesMasAntiguo =
          [ ( "Jess", Feb )
          , ( "Faby", May )
          ]
              |> Dict.fromList

-}
