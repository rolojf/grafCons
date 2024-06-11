module Example exposing (todos)

-- import Fuzz exposing (Fuzzer, int, list, string)

import Chart.Item exposing (Any)
import Datos
import Dict.Any as Any
import Expect exposing (Expectation)
import Main
import Test exposing (..)


todos =
    Test.concat
        [ suite1
        , suite2
        , suite3
        ]


suite1 : Test
suite1 =
    describe "Probando la funcion que obtiene el número de mes"
        [ test "Enero" (\_ -> Expect.equal (Main.getMesNum Datos.Ene) 1)
        , test "Septiembre" (\_ -> Expect.equal (Main.getMesNum Datos.Sep) 9)
        , test "Diciembre" (\_ -> Expect.equal (Main.getMesNum Datos.Dic) 12)
        , test "mesSiguienteDic" (\_ -> Expect.equal (Main.mesSig Datos.Dic) Datos.Ene)
        , test "mesSiguientJule" (\_ -> Expect.equal (Main.mesSig Datos.Jul) Datos.Ago)
        , test "mesSiguienteEne" (\_ -> Expect.equal (Main.mesSig Datos.Ene) Datos.Feb)
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
        [ test "ClimaRecámara" (\_ -> Expect.equal (Main.kWhxTonHr climaRecamara) 159.0)
        , test "ClimaASocial" (\_ -> Expect.within (Expect.Absolute 0.1) (Main.kWhxTonHr climaASocial) 49.362)
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
        [ test "MesAnio Marzo" (\_ -> Expect.equal (Main.mesAnioSig marzo) abril)
        , test "MesAnio Diciembre" (\_ -> Expect.equal (Main.mesAnioSig diciembre) enero)
        , test "Conviete a comparable" (\_ -> Expect.equal (Main.convierteLlave abril) ( "Abr", 2022 ))
        , test "Suma de watts anuales"
            (\_ ->
                Expect.lessThan 1
                    ((Datos.datosParaTest1 |> Main.reparteConsumo |> Tuple.second |> .consumoPaAtras |> List.sum)
                        - (Datos.datosParaTest1 |> Main.reparteConsumo |> Tuple.first |> Any.values |> List.sum)
                    )
            )

        --, test "reparticion normal" (\_ -> Expect.equal (Main.convierteLlave abril) ( "Abr", 2022 ))
        ]
