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
    { paneles : Int
    , capPanelesWatts : Int
    , consumoTodos : List Int
    , bimestresDeHistorial : Int
    , hayAdic : Bool
    , climasAdic : List Clima
    , mesMasAntiguo : Mes
    , anioMasAntiguo : Int
    , nombre : String
    , refirio : String
    , contacto : String
    , fecha : ( Mes, Int )
    , parcial : Float
    }


datosParaTest1 : DatosP
datosParaTest1 =
    { paneles = 8
    , capPanelesWatts = 550
    , consumoTodos = List.range 1 12 |> List.map (\hm -> hm * 150)
    , bimestresDeHistorial = 12
    , hayAdic = False
    , climasAdic = []
    , mesMasAntiguo = Feb
    , anioMasAntiguo = 2022
    , nombre = "Test 1"
    , refirio = "yo mesmo"
    , contacto = "123-345-6789"
    , fecha = ( May, 2024 )
    , parcial = 10 / 30
    }


datosParaTest2 : DatosP
datosParaTest2 =
    { paneles = 12
    , capPanelesWatts = 550
    , consumoTodos = List.range 1 12 |> List.map (\hm -> hm * 180)
    , bimestresDeHistorial = 12
    , hayAdic = True
    , climasAdic =
        [ { tons = 1.5, horasEnArranque = 2, tipoClima = Normal, area = "Área Social", frecUso = Semanal 7.0 2 }
        , { tons = 1.0, horasEnArranque = 2, tipoClima = Inverter, area = "Recamara de los niños", frecUso = Diario 9.0 }
        ]
    , mesMasAntiguo = Oct
    , anioMasAntiguo = 2021
    , nombre = "Test 2"
    , refirio = "yo mesmo"
    , contacto = "123-345-6789"
    , fecha = ( May, 2024 )
    , parcial = 20 / 30
    }


datos : DatosP
datos =
    { paneles = 12
    , capPanelesWatts = 585

    -- capturado así primero dato frontal y de atrás datos de arriba para abajo
    , consumoTodos = List.reverse [ 2478, 1006, 995, 938, 2562, 3165, 1641, 918, 785, 1045, 1763, 2049 ]
    , bimestresDeHistorial = 12
    , hayAdic = False
    , climasAdic = []
    , mesMasAntiguo = Jun
    , anioMasAntiguo = 2022
    , nombre = "Amigo de Elena su papá y el recibo a nombre de Carlos Velazquez."
    , refirio = "Elena María"
    , contacto = "Valle del Contry, a través de Elena"
    , fecha = ( Jun, 2024 )
    , parcial = 23 / 30
    }



{-
   gabrielGarcíaMtz =
          { paneles = 4
          , capPanelesWatts = 550

          -- capturado así primero dato frontal y de atrás datos de arriba para abajo
          , consumoTodos = List.reverse [ 493, 249, 201, 576, 1388, 278, 206, 212, 218, 257, 1242, 1045 ]
          , bimestresDeHistorial = 12
          , hayAdic = False
          , climasAdic = []
          , mesMasAntiguo = May
          , anioMasAntiguo = 2022
          , nombre = "Gabriel García Mtz."
          , refirio = "yo mesmo"
          , contacto = "123-345-6789"
          , fecha = ( May, 2024 )
          , parcial = 18 / 30
          }

   refAlfredoJun2024 = { paneles = 6
             , capPanelesWatts = 550

             -- capturado así primero dato frontal y de atrás datos de arriba para abajo
             , consumoTodos = List.reverse [ 1060, 2166, 1626, 664, 571, 677, 541, 900, 1054, 659, 579, 450 ]
             , bimestresDeHistorial = 12
             , hayAdic = False
             , climasAdic = []
             , mesMasAntiguo = Nov
             , anioMasAntiguo = 2021
             , nombre = "Gabriel García Mtz."
             , parcial = 10 / 30
             }
      violeta  =
             { paneles = 4
             , capPanelesWatts = 425

             -- capturado así primero dato frontal y de atrás datos de arriba para abajo
             , consumoTodos = List.reverse [ 672, 415, 451, 613, 1141, 983, 343, 421, 797, 420, 680, 791 ]
             , bimestresDeHistorial = 12
             , hayAdic = False
             , climasAdic = []
             , mesMasAntiguo = May
             , anioMasAntiguo = 2022
             , nombre = "Violeta Parra Ref. Doc. Romero"
             , parcial = 13 / 30
             }
            datosPapaYuri =
            { paneles = 6
                , capPanelesWatts = 550

                -- capturado así primero dato frontal y de atrás datos de arriba para abajo
                , consumoTodos = List.reverse [ 2121, 958, 590, 793, 701, 1271, 1596, 1283, 532, 582, 576, 1127 ]
                , bimestresDeHistorial = 12
                , hayAdic = False
                , climasAdic = []
                , mesMasAntiguo = Ago
                , anioMasAntiguo = 2021
                , nombre = "Mamá de Yuri"
                , parcial = 13 / 30
                }
            datosGilDocRomero =
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
