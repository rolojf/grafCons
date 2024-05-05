module Example exposing (todos)

-- import Fuzz exposing (Fuzzer, int, list, string)

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
        [ test "Enero" (\_ -> Expect.equal (Main.getMesNum Main.Ene) 1)
        , test "Septiembre" (\_ -> Expect.equal (Main.getMesNum Main.Sep) 9)
        , test "Diciembre" (\_ -> Expect.equal (Main.getMesNum Main.Dic) 12)
        , test "mesSiguienteDic" (\_ -> Expect.equal (Main.mesSig Main.Dic) Main.Ene)
        , test "mesSiguientJule" (\_ -> Expect.equal (Main.mesSig Main.Jul) Main.Ago)
        , test "mesSiguienteEne" (\_ -> Expect.equal (Main.mesSig Main.Ene) Main.Feb)
        ]


suite3 : Test
suite3 =
    let
        climaRecamara =
            { tons = 1.0, horasEnArranque = 2, tipoClima = Main.Inverter, area = "Recamara de los niños", frecUso = Main.Diario 9.0 }

        climaASocial =
            { tons = 1.5, horasEnArranque = 2, tipoClima = Main.Normal, area = "Área Social", frecUso = Main.Semanal 7.0 2 }
    in
    describe "Validando el consumo de climas"
        [ test "ClimaRecámara" (\_ -> Expect.equal (Main.kWhxTonHr climaRecamara) 159.0)
        , test "ClimaASocial" (\_ -> Expect.within (Expect.Absolute 0.1) (Main.kWhxTonHr climaASocial) 49.362)
        ]


suite2 : Test
suite2 =
    let
        marzo =
            { mes = Main.Mar, anio = 2022 }

        abril =
            { mes = Main.Abr, anio = 2022 }

        diciembre =
            { mes = Main.Dic, anio = 2023 }

        enero =
            { mes = Main.Ene, anio = 2024 }
    in
    describe "Probando la funcion que regresa el siguiente mes"
        [ test "MesAnio Marzo" (\_ -> Expect.equal (Main.mesAnioSig marzo) abril)
        , test "MesAnio Diciembre" (\_ -> Expect.equal (Main.mesAnioSig diciembre) enero)
        , test "Conviete a comparable" (\_ -> Expect.equal (Main.convierteLlave abril) ( "Abr", 2022 ))
        , test "Suma de watts anuales"
            (\_ ->
                Expect.lessThan 2
                    (List.sum Main.consumoPaAtras
                        - (Any.values Main.reparteConsumo |> List.sum)
                    )
            )

        --, test "reparticion normal" (\_ -> Expect.equal (Main.convierteLlave abril) ( "Abr", 2022 ))
        ]
