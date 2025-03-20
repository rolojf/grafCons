module Datos exposing (..)


datos : DatosP
datos =
    { paneles = 6
    , capPanelesWatts = 635
    , consumoTodos = [ 1632, 757, 1075, 1017, 2020, 1883, 703, 456, 790, 634, 1715, 1149 ]
    , bimestresDeHistorial = 12
    , hayAdic = False
    , climasAdic = []
    , mesMasAntiguo = May
    , anioMasAntiguo = 2022
    , nombre = "Gilberto Ref. Doc. Romero"
    , refirio = "Doc Romero"
    , contacto = "81 8280 4898"
    , fecha = ( Mar, 2025 )
    , parcial = 24 / 30
    , sinGraficarSubsidio = False
    }



{-
   esteban =
       { paneles = 8
       , capPanelesWatts = 590

       -- capturado así primero dato frontal y de atrás datos de arriba para abajo
       , consumoTodos = List.reverse [ 951, 1839, 2300, 1835, 592, 644, 633, 1365, 1501, 1045, 697, 537 ]
       , bimestresDeHistorial = 12
       , hayAdic = False
       , climasAdic = []
       , mesMasAntiguo = Dic
       , anioMasAntiguo = 2022
       , nombre = "Esteban Maldonado"
       , refirio = "Fer Matsui"
       , contacto = "81 1222 9801"
       , fecha = ( Dic, 2024 )
       , parcial = 10 / 30
       , sinGraficarSubsidio = False
       }
      datosDeGil =
          { paneles = 4
          , capPanelesWatts = 610

          -- capturado así primero dato frontal y de atrás datos de arriba para abajo
          , consumoTodos = List.reverse [ 459, 544, 863, 1282, 414, 705, 529, 821, 1464, 897, 331, 753 ]
          , bimestresDeHistorial = 12
          , hayAdic = True
          , climasAdic =
              [ { tons = 1.5, horasEnArranque = 1.5, tipoClima = Inverter, area = "Oficina Día", frecUso = Diario 10 }
              ]
          , mesMasAntiguo = Dic
          , anioMasAntiguo = 2022
          , nombre = "Gilberto Arellano"
          , refirio = "Las Treviño"
          , contacto = "81 1030 5354"
          , fecha = ( Dic, 2024 )
          , parcial = 20 / 30
          , sinGraficarSubsidio = False
          }

         aleVega =
             { paneles = 8
             , capPanelesWatts = 610

             -- capturado así primero dato frontal y de atrás datos de arriba para abajo
             , consumoTodos = List.reverse [ 871, 1175, 1432, 650, 650, 650, 1879, 1715, 986, 706, 546, 742 ]
             , bimestresDeHistorial = 12
             , hayAdic = False
             , climasAdic = []
             , mesMasAntiguo = Nov
             , anioMasAntiguo = 2022
             , nombre = "Alejandra Vega"
             , refirio = "Mamá de Dani"
             , contacto = "861 109 7272"
             , fecha = ( Sep, 2024 )
             , parcial = 14 / 30
             , sinGraficarSubsidio = False
             }


         belinda =
             { paneles = 12
             , capPanelesWatts = 610

             -- capturado así primero dato frontal y de atrás datos de arriba para abajo
             , consumoTodos = List.reverse [ 1764, 2327, 3118, 2192, 399, 3837, 767, 702, 2349, 4859, 2748, 1108 ]
             , bimestresDeHistorial = 12
             , hayAdic = False
             , climasAdic = []
             , mesMasAntiguo = Nov
             , anioMasAntiguo = 2022
             , nombre = "Belinda González"
             , refirio = "Laura Vecina"
             , contacto = "81 1042 8982"
             , fecha = ( Sep, 2024 )
             , parcial = 14 / 30
             , sinGraficarSubsidio = True
             }

         Blanca =
             { paneles = 10
             , capPanelesWatts = 610

             -- capturado así primero dato frontal y de atrás datos de arriba para abajo
             , consumoTodos = List.reverse [ 2870, 2776, 1861, 990, 919, 1057, 2355, 2113, 682, 970, 903, 880 ]
             , bimestresDeHistorial = 12
             , hayAdic = False
             , climasAdic = []
             , mesMasAntiguo = Sep
             , anioMasAntiguo = 2022
             , nombre = "Blanca y Armando Gómez"
             , refirio = "Wicho"
             , contacto = ""
             , fecha = ( Oct, 2024 )
             , parcial = 20 / 30
             }

         EdPrzRefEdson =
                { paneles = 10
             , capPanelesWatts = 610

             -- capturado así primero dato frontal y de atrás datos de arriba para abajo
             , consumoTodos = List.reverse [ 2275, 793, 1350, 855, 1234, 1658, 527, 740, 897, 827, 2105, 2538 ]
             , bimestresDeHistorial = 12
             , hayAdic = False
             , climasAdic = []
             , mesMasAntiguo = May
             , anioMasAntiguo = 2022
             , nombre = "Eduardo Pérez"
             , refirio = "Edson de León"
             , contacto = ""
             , fecha = ( Oct, 2024 )
             , parcial = 1 / 30
             }


         JosueRdzRefAlf =
                { paneles = 14
                , capPanelesWatts = 610

                -- capturado así primero dato frontal y de atrás datos de arriba para abajo
                , consumoTodos = List.reverse [ 3082, 3177, 955, 833, 1261, 3232, 1324, 2191, 1585, 1006, 1736, 4009 ]
                , bimestresDeHistorial = 12
                , hayAdic = False
                , climasAdic = []
                , mesMasAntiguo = Jul
                , anioMasAntiguo = 2022
                , nombre = "Josué Rodríguez"
                , refirio = "Alfredo Alanís"
                , contacto = ""
                , fecha = ( Ago, 2024 )
                , parcial = 22 / 30
                }

               DeEdson =
                   { paneles = 4
                   , capPanelesWatts = 610

                   -- capturado así primero dato frontal y de atrás datos de arriba para abajo
                   , consumoTodos = List.reverse [ 1714, 1169, 562, 545, 1043, 1898, 1518, 1046, 696, 722, 1056, 1549 ]
                   , bimestresDeHistorial = 12
                   , hayAdic = False
                   , climasAdic =
                       []
                   , mesMasAntiguo = Jul
                   , anioMasAntiguo = 2022
                   , nombre = "Gabriel González"
                   , refirio = "Edson de León"
                   , contacto = ""
                   , fecha = ( Ago, 2024 )
                   , parcial = 17 / 30
                   }

                  normaChapa =
                      { paneles = 8
                      , capPanelesWatts = 580
                      -- capturado así primero dato frontal y de atrás datos de arriba para abajo
                      , consumoTodos = List.reverse [ 1714, 1169, 562, 545, 1043, 1898, 1518, 1046, 696, 722, 1056, 1549 ]
                      , bimestresDeHistorial = 12
                      , hayAdic = False
                      , climasAdic =
                          []
                      , mesMasAntiguo = Jul
                      , anioMasAntiguo = 2022
                      , nombre = "Norma Chapa"
                      , refirio = "Lili y Fer Matsui"
                      , contacto = ""
                      , fecha = ( Jul, 2024 )
                      , parcial = 17 / 30
                      }




                  luisAPerezRefOscar =
                         { paneles = 18
                      , capPanelesWatts = 585

                      -- capturado así primero dato frontal y de atrás datos de arriba para abajo
                      , consumoTodos = List.reverse [ 2675, 971, 1148, 1103, 2461, 2026, 1284, 767, 1093, 889, 1004, 1570 ]
                      , bimestresDeHistorial = 12
                      , hayAdic = True
                      , climasAdic =
                          [ { tons = 1.5, horasEnArranque = 1.5, tipoClima = Inverter, area = "Nuevo", frecUso = Semanal 4.0 2 }
                          , { tons = 6.0, horasEnArranque = 0.5, tipoClima = Normal, area = "Actuales", frecUso = Diario 8.0 }
                          ]
                      , mesMasAntiguo = Jun
                      , anioMasAntiguo = 2022
                      , nombre = "Luis A. Perez L"
                      , refirio = "Oscar Esteban"
                      , contacto = "81 2590 4199"
                      , fecha = ( Jun, 2024 )
                      , parcial = 17 / 30
                      }

                     netoRefElena =
                         { paneles = 12
                         , capPanelesWatts = 585

                         -- capturado así primero dato frontal y de atrás datos de arriba para abajo
                         , consumoTodos = List.reverse [ 2478, 1006, 995, 938, 2562, 3165, 1641, 918, 785, 1045, 1763, 2049 ]
                         , bimestresDeHistorial = 12
                         , hayAdic = False
                         , climasAdic = []
                         , mesMasAntiguo = Jun
                         , anioMasAntiguo = 2022
                         , nombre = "Neto Amigo de Elena su papá y el recibo a nombre de Carlos Velazquez."
                         , refirio = "Elena María"
                         , contacto = "Neto a través de Elena, Valle del Contry"
                         , fecha = ( Jun, 2024 )
                         , parcial = 23 / 30
                         }

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
    , sinGraficarSubsidio : Bool
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
    , sinGraficarSubsidio = False
    }


datosParaTest2 : DatosP
datosParaTest2 =
    { paneles = 16
    , capPanelesWatts = 610
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
    , sinGraficarSubsidio = False
    }
