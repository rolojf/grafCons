module Main exposing (main)

import Array exposing (Array)
import Chart as C
import Chart.Attributes as CA
import Chart.Events as CE
import Chart.Item as CI
import Css.Global
import Dict exposing (Dict)
import Html exposing (Html)
import Html.Attributes as Attr
import Html.Styled as HtmlS
import Html.Styled.Attributes exposing (css)
import Svg as S
import Svg.Attributes as SA
import Svg.Events as SE
import Tailwind.Breakpoints as TwBp
import Tailwind.Theme as Theme
import Tailwind.Utilities as Tw


main : Html msg
main =
    HtmlS.div
        [ css
            [ Tw.container
            , Tw.mx_auto
            ]
        ]
        [ Css.Global.global Tw.globalStyles
        , HtmlS.div
            [ css
                [ Tw.mt_3
                , Tw.border_2
                , Tw.border_r_2
                , Tw.border_color Theme.red_600
                , Tw.p_2
                ]
            ]
            [ HtmlS.text "This page is just static HTML, rendered by Elm." ]
        , HtmlS.div
            [ css
                [ Tw.max_w_screen_sm
                , Tw.my_12
                , Tw.mx_36
                , Tw.h_full
                ]
            ]
            [ grafica |> HtmlS.fromUnstyled ]
        , HtmlS.div
            [ css
                [ Tw.bg_color Theme.blue_600
                , Tw.w_96
                , Tw.h_6
                ]
            ]
            []
        , HtmlS.div
            [ css [ Tw.text_3xl, Tw.text_color Theme.lime_800 ] ]
            [ HtmlS.text (Debug.toString consumoUltimoA) ]
        ]
        |> HtmlS.toUnstyled


meses : Array String
meses =
    Array.fromList
        [ "Ene", "Feb", "Mar", "Abr", "May", "Jun", "Jul", "Ago", "Sep", "Oct", "Nov", "Dic" ]


saltaUnMes =
    True


limDAC =
    850


paneles =
    8


consumo1 =
    [ { dosAtras = 0
      , unoAtras = 251
      , subsidio = 175
      , gen = 508
      }
    , { dosAtras = 0
      , unoAtras = 257
      , subsidio = 175
      , gen = 558
      }
    , { dosAtras = 0
      , unoAtras = 428
      , subsidio = 175
      , gen = 712
      }
    , { dosAtras = 0
      , unoAtras = 468
      , subsidio = 450
      , gen = 794
      }

    -- Mayo
    , { dosAtras = 0
      , unoAtras = 962
      , subsidio = 450
      , gen = 838
      }
    , { dosAtras = 0
      , unoAtras = 911
      , subsidio = 450
      , gen = 827
      }
    , { dosAtras = 0
      , unoAtras = 1002
      , subsidio = 450
      , gen = 884
      }

    -- Ago
    , { dosAtras = 0
      , unoAtras = 889
      , subsidio = 450
      , gen = 838
      }
    , { dosAtras = 980
      , unoAtras = 1350
      , subsidio = 450
      , gen = 699
      }
    , { dosAtras = 0
      , unoAtras = 511
      , subsidio = 175
      , gen = 692
      }
    , { dosAtras = 0
      , unoAtras = 413
      , subsidio = 175
      , gen = 584
      }
    , { dosAtras = 0
      , unoAtras = 338
      , subsidio = 175
      , gen = 493
      }
    ]


generacion : Array Int
generacion =
    [ 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12 ] |> Array.fromList


type Bimestre
    = ParNon
    | NonPar


consumoPaAtras : List Int
consumoPaAtras =
    [ 1688, 1731, 1386, 984, 917, 1037, 1390, 1342, 1564, 995, 1107, 1193 ] |> List.reverse


bimestreUltimo : Int
bimestreUltimo =
    89


esteCaso : Bimestre
esteCaso =
    ParNon


bimestresParNon : List Int
bimestresParNon =
    [ 23, 45, 67, 89, 1011, 1201 ]


bimestresNonPar : List Int
bimestresNonPar =
    [ 12, 34, 56, 78, 910, 1112 ]


listadoDeBimestres : List Int
listadoDeBimestres =
    case esteCaso of
        ParNon ->
            List.repeat 3 bimestresParNon |> List.concat

        NonPar ->
            List.repeat 3 bimestresNonPar |> List.concat


seQuedanBimestres : List Int
seQuedanBimestres =
    let
        checaSi : Int -> List Int -> List Int
        checaSi valor listaAcum =
            if List.length listaAcum == 0 then
                if valor <= bimestreUltimo then
                    []

                else
                    [ valor ]

            else
                valor :: listaAcum
    in
    List.foldl checaSi [] listadoDeBimestres |> List.reverse


consumoEnOrden : List ( Int, Int )
consumoEnOrden =
    List.map2 (\bim cons -> ( bim, cons )) seQuedanBimestres consumoPaAtras


consumoPenultimoA : Dict Int Int
consumoPenultimoA =
    List.take 6 consumoEnOrden |> Dict.fromList


consumoUltimoA : Dict Int Int
consumoUltimoA =
    List.drop 6 consumoEnOrden |> Dict.fromList


listadoqueAplica : Array Int
listadoqueAplica =
    (case esteCaso of
        ParNon ->
            bimestresParNon

        NonPar ->
            bimestresNonPar
    )
        |> Array.fromList


genera =
    [ 233, 246, 314, 320, 347, 348, 360, 355, 296, 273, 234, 221 ] |> Array.fromList


consumo =
    let
        obtenBimestre : Int -> Int
        obtenBimestre talBim =
            Array.get talBim listadoqueAplica
                |> Maybe.withDefault 12

        obtenConsumo : Int -> Dict Int Int -> Float
        obtenConsumo delBim cualDict =
            Dict.get (obtenBimestre delBim) cualDict
                |> Maybe.withDefault 0
                |> toFloat

        obtenGenera : Int -> Int -> Float
        obtenGenera m1 m2 =
            1.5
                * ((Array.get (m1 - 1) genera |> Maybe.withDefault 0)
                    + (Array.get (m2 - 1) genera |> Maybe.withDefault 0)
                  )
    in
    [ { dosAtras = obtenConsumo 0 consumoPenultimoA
      , unoAtras = obtenConsumo 0 consumoUltimoA
      , subsidio = 350
      , gen = obtenGenera 2 3
      }
    , { dosAtras = obtenConsumo 1 consumoPenultimoA
      , unoAtras = obtenConsumo 1 consumoUltimoA
      , subsidio = 900
      , gen = obtenGenera 4 5
      }
    , { dosAtras = obtenConsumo 2 consumoPenultimoA
      , unoAtras = obtenConsumo 2 consumoUltimoA
      , subsidio = 900
      , gen = obtenGenera 6 7
      }
    , { dosAtras = obtenConsumo 3 consumoPenultimoA
      , unoAtras = obtenConsumo 3 consumoUltimoA
      , subsidio = 900
      , gen = obtenGenera 8 9
      }

    -- Ago
    , { dosAtras = obtenConsumo 4 consumoPenultimoA
      , unoAtras = obtenConsumo 4 consumoUltimoA
      , subsidio = 350
      , gen = obtenGenera 10 11
      }
    , { dosAtras = obtenConsumo 5 consumoPenultimoA
      , unoAtras = obtenConsumo 5 consumoUltimoA
      , subsidio = 350
      , gen = obtenGenera 12 1
      }
    ]


grafica : Html msg
grafica =
    C.chart
        [ CA.width 480
        , CA.height 360
        ]
        [ C.yAxis [ CA.width 0.15, CA.noArrow, CA.color CA.darkBlue ]
        , C.xAxis [ CA.width 0.15, CA.noArrow, CA.color CA.darkBlue ]
        , C.generate 12 C.ints .x [] <|
            \plane valor ->
                [ C.xLabel
                    [ CA.x (toFloat valor), CA.fontSize 12, CA.color "blue" ]
                    [ S.text <|
                        Maybe.withDefault "Feb"
                            (Array.get
                                (valor * 2 + 1)
                                meses
                            )
                    ]
                ]
        , C.yLabels
            [ CA.withGrid
            , CA.fontSize 12
            , CA.color "blue"
            ]
        , C.labelAt
            (CA.percent -9)
            CA.middle
            [ CA.moveLeft 5
            , CA.rotate 90
            , CA.fontSize 18
            , CA.color "blue"
            ]
            [ S.text "Energía - kWh" ]
        , C.bars [ CA.margin 0.13 ]
            [ C.bar .dosAtras
                [ CA.color CA.brown
                , CA.opacity 0.4
                ]
            , C.bar .unoAtras
                [ CA.color CA.brown
                , CA.opacity 0.4
                ]
            , C.stacked
                [ C.bar .subsidio [ CA.color CA.yellow, CA.opacity 0.9 ]
                , C.bar
                    (\elReg ->
                        let
                            elMax =
                                max 0 (max elReg.dosAtras elReg.unoAtras)
                        in
                        if elMax == 0 then
                            0

                        else
                            elMax - elReg.subsidio
                    )
                    [ CA.color CA.red ]
                ]
            , C.bar (\reg -> reg.gen) [ CA.color CA.green ]
            ]
            consumo
        ]
