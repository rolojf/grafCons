module Main exposing (main)

import Array exposing (Array)
import Chart as C
import Chart.Attributes as CA
import Chart.Events as CE
import Chart.Item as CI
import Css.Global
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


consumo =
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
                        Maybe.withDefault "NoMes"
                            (Array.get
                                (valor - 1)
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
            [ {- C.bar .dosAtras
                     [ CA.color CA.brown
                     , CA.opacity 0.4
                     ]
                 , C.bar .unoAtras
                     [ CA.color CA.brown
                     , CA.opacity 0.4
                     ]
                 ,
              -}
              C.stacked
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
            , C.bar (\reg -> reg.gen * paneles / 10) [ CA.color CA.green ]
            ]
            consumo
        ]
