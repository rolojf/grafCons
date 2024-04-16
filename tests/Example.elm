module Example exposing (todos)

-- import Fuzz exposing (Fuzzer, int, list, string)

import Expect exposing (Expectation)
import Main
import Test exposing (..)


todos =
    Test.concat
        [ suite1
        , suite2
        ]


suite1 : Test
suite1 =
    describe "Probando la funcion que obtiene el número de mes"
        [ test "Enero" (\_ -> Expect.equal (Main.getMesNum Main.Ene) 1)
        , test "Septiembre" (\_ -> Expect.equal (Main.getMesNum Main.Sep) 9)
        , test "Diciembre" (\_ -> Expect.equal (Main.getMesNum Main.Dic) 12)
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

        --, test "reparticion normal" (\_ -> Expect.equal (Main.convierteLlave abril) ( "Abr", 2022 ))
        ]
