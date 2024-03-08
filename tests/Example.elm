module Example exposing (..)

-- import Fuzz exposing (Fuzzer, int, list, string)

import Expect exposing (Expectation)
import Main
import Test exposing (..)


suite : Test
suite =
    describe "Probando la funcion que obtiene el número de mes"
        [ test "Enero" (\_ -> Expect.equal (Main.getMesNum Main.Ene) 1)
        , test "Septiembre" (\_ -> Expect.equal (Main.getMesNum Main.Sep) 9)
        , test "Diciembre" (\_ -> Expect.equal (Main.getMesNum Main.Dic) 12)
        ]
