module Pruebas exposing (todos)

import Datos exposing (Mes(..), fecha)
import Dict.Any as Any
import Expect exposing (Expectation)
import Frontend exposing (MesAnio)
import Test exposing (..)


todos =
    Test.concat
        [ suite1
        , suite2
        , suite3
        , suite4
        , suite5
        , suite6
        ]


suite1 : Test
suite1 =
    describe "Probando la funcion que obtiene el número de mes"
        [ test "Enero" (\_ -> Expect.equal (Frontend.getMesNum Datos.Ene) 1)
        , test "Septiembre" (\_ -> Expect.equal (Frontend.getMesNum Datos.Sep) 9)
        , test "Diciembre" (\_ -> Expect.equal (Frontend.getMesNum Datos.Dic) 12)
        , test "mesSiguienteDic" (\_ -> Expect.equal (Frontend.mesSig Datos.Dic) Datos.Ene)
        , test "mesSiguientJule" (\_ -> Expect.equal (Frontend.mesSig Datos.Jul) Datos.Ago)
        , test "mesSiguienteEne" (\_ -> Expect.equal (Frontend.mesSig Datos.Ene) Datos.Feb)
        ]


suite2 : Test
suite2 =
    let
        marzo =
            { mes = Datos.Mar, anio = 2022 }

        abril =
            { mes = Datos.Abr, anio = 2022 }

        diciembre =
            { mes = Datos.Dic, anio = 2023 }

        enero =
            { mes = Datos.Ene, anio = 2024 }
    in
    describe "Probando la funcion que regresa el siguiente mes"
        [ test "MesAnio Marzo" (\_ -> Expect.equal (Frontend.mesAnioSig marzo) abril)
        , test "MesAnio Diciembre" (\_ -> Expect.equal (Frontend.mesAnioSig diciembre) enero)
        , test "Conviete a comparable" (\_ -> Expect.equal (Frontend.convierteLlave abril) ( "Abr", 2022 ))
        ]


suite3 : Test
suite3 =
    let
        climaRecamara =
            { tons = 1.0, horasEnArranque = 2, tipoClima = Datos.Inverter, area = "Recamara de los niños", frecUso = Datos.Diario 9.0 }

        climaASocial =
            { tons = 1.5, horasEnArranque = 2, tipoClima = Datos.Normal, area = "Área Social", frecUso = Datos.Semanal 7.0 2 }
    in
    describe "Validando el consumo de climas"
        [ test "ClimaRecámara" (\_ -> Expect.equal (Frontend.kWhxTonHr climaRecamara) 159.0)
        , test "ClimaASocial" (\_ -> Expect.within (Expect.Absolute 0.1) (Frontend.kWhxTonHr climaASocial) 49.362)
        ]


suite4 : Test
suite4 =
    describe "Días por mes calendario y bisiestos"
        [ test "Feb bisiesto" (\_ -> Expect.equal (Frontend.diasEnMes Feb 2024) 29)
        , test "Feb no bisiesto" (\_ -> Expect.equal (Frontend.diasEnMes Feb 2025) 28)
        , test "Feb fin de siglo no bisiesto" (\_ -> Expect.equal (Frontend.diasEnMes Feb 2100) 28)
        , test "Feb 2000 bisiesto" (\_ -> Expect.equal (Frontend.diasEnMes Feb 2000) 29)
        , test "Abril 30 días" (\_ -> Expect.equal (Frontend.diasEnMes Abr 2025) 30)
        , test "Diciembre 31 días" (\_ -> Expect.equal (Frontend.diasEnMes Dic 2025) 31)
        , test "Reparto de días del 6 Feb 25 al 8 Abr 25, como en el recibo"
            (\_ ->
                Expect.equal
                    (Frontend.diasPorMes { del = fecha 6 Feb 25, al = fecha 8 Abr 25, kWh = 464 })
                    [ ( MesAnio Feb 2025, 22 )
                    , ( MesAnio Mar 2025, 31 )
                    , ( MesAnio Abr 2025, 8 )
                    ]
            )
        , test "Periodo dentro de un solo mes"
            (\_ ->
                Expect.equal
                    (Frontend.diasPorMes { del = fecha 5 Jul 25, al = fecha 20 Jul 25, kWh = 100 })
                    [ ( MesAnio Jul 2025, 15 ) ]
            )
        ]


suite5 : Test
suite5 =
    let
        repartido =
            Frontend.reparteConsumo Datos.datosParaTest1

        kwhDe mes anio =
            Any.get (MesAnio mes anio) repartido
                |> Maybe.map .kwh
                |> Maybe.withDefault -1
    in
    describe "Repartición del consumo por días exactos (datosParaTest1)"
        [ test "Mar 2022: 31 de los 61 días del periodo de 150 kWh"
            (\_ -> Expect.within (Expect.Absolute 0.0001) (kwhDe Mar 2022) (150 * 31 / 61))
        , test "Abr 2022: 30 de los 61 días del periodo de 150 kWh"
            (\_ -> Expect.within (Expect.Absolute 0.0001) (kwhDe Abr 2022) (150 * 30 / 61))
        , test "Ene 2024: 31 de los 60 días del periodo de 1800 kWh (Feb 24 bisiesto)"
            (\_ -> Expect.within (Expect.Absolute 0.0001) (kwhDe Ene 2024) (1800 * 31 / 60))
        , test "Conservación: la suma mensual es la suma del historial"
            (\_ ->
                Expect.within (Expect.Absolute 0.001)
                    (Any.values repartido |> List.map .kwh |> List.sum)
                    (Datos.datosParaTest1.historial |> List.map .kWh |> List.sum |> toFloat)
            )
        ]


suite6 : Test
suite6 =
    let
        regError =
            { dosAtras = -1.0
            , unoAtras = -1.0
            , subsidio = -1.0
            , gen = -1.0
            , adicional = -1.0
            }

        barra cuantas caso =
            Frontend.consumo caso
                |> List.drop cuantas
                |> List.head
                |> Maybe.withDefault regError

        encadenado =
            [ { del = fecha 6 Feb 25, al = fecha 8 Abr 25, kWh = 464 }
            , { del = fecha 5 Dic 24, al = fecha 6 Feb 25, kWh = 778 }
            ]

        conHueco =
            [ { del = fecha 7 Feb 25, al = fecha 8 Abr 25, kWh = 464 }
            , { del = fecha 5 Dic 24, al = fecha 6 Feb 25, kWh = 778 }
            ]
    in
    describe "Barras bimestrales y validación del historial"
        [ test "Barra Ene+Feb dosAtras = bimestre Dic22-Feb23 completo"
            (\_ -> Expect.within (Expect.Absolute 0.0001) (barra 0 Datos.datosParaTest1).dosAtras 900)
        , test "Barra Ene+Feb unoAtras = bimestre Dic23-Feb24 completo"
            (\_ -> Expect.within (Expect.Absolute 0.0001) (barra 0 Datos.datosParaTest1).unoAtras 1800)
        , test "Barra Mar+Abr dosAtras (datosParaTest1)"
            (\_ -> Expect.within (Expect.Absolute 0.0001) (barra 1 Datos.datosParaTest1).dosAtras 150)
        , test "Barra Mar+Abr unoAtras (datosParaTest1)"
            (\_ -> Expect.within (Expect.Absolute 0.0001) (barra 1 Datos.datosParaTest1).unoAtras 1050)
        , test "Barra Mar+Abr dosAtras (datosParaTest2)"
            (\_ -> Expect.within (Expect.Absolute 0.0001) (barra 1 Datos.datosParaTest2).dosAtras 540)
        , test "Barra Mar+Abr unoAtras (datosParaTest2)"
            (\_ -> Expect.within (Expect.Absolute 0.0001) (barra 1 Datos.datosParaTest2).unoAtras 1620)
        , test "Historial encadenado no marca huecos"
            (\_ -> Expect.equal (Frontend.huecos encadenado) [])
        , test "Historial con hueco marca un aviso"
            (\_ -> Expect.equal (List.length (Frontend.huecos conHueco)) 1)
        , test "El historial real capturado no tiene huecos"
            (\_ -> Expect.equal (Frontend.huecos Datos.datos.historial) [])
        ]
