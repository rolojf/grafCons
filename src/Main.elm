module Main exposing (main)

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
                , Tw.mx_20
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


consumo =
    [ { bimPago = "Jun"
      , dosAtras = 1250
      , unoAtras = 1500
      , subsidio = 900
      , limDAC = 1700
      , gen = 1000
      }
    , { bimPago = "Ago"
      , dosAtras = 1750
      , unoAtras = 1450
      , subsidio = 900
      , limDAC = 1700
      , gen = 1100
      }
    , { bimPago = "Sep"
      , dosAtras = 1150
      , unoAtras = 1000
      , subsidio = 900
      , limDAC = 1700
      , gen = 925
      }
    , { bimPago = "Nov"
      , dosAtras = 1250
      , unoAtras = 950
      , subsidio = 350
      , limDAC = 1700
      , gen = 950
      }
    , { bimPago = "Feb"
      , dosAtras = 1250
      , unoAtras = 1400
      , subsidio = 350
      , limDAC = 700
      , gen = 860
      }
    , { bimPago = "Abr"
      , dosAtras = 1150
      , unoAtras = 1050
      , subsidio = 350
      , limDAC = 1700
      , gen = 900
      }
    ]


grafica : Html msg
grafica =
    C.chart
        [ CA.width 480
        , CA.height 360

        {- , CA.htmlAttrs
           [ Attr.style "position" "absolute" ]
           , Attr.style "background" "#fcf9e9"
           , Attr.style "height" "50px"
           , Attr.style "width" "50%"
           ]
        -}
        ]
        [ C.yAxis [ CA.width 0.15, CA.noArrow, CA.color CA.darkBlue ]
        , C.xAxis [ CA.width 0.15, CA.noArrow, CA.color CA.darkBlue ]

        --, C.yTicks []
        , C.xLabels
            [ CA.fontSize 12
            , CA.color "cyan"
            ]
        , C.yLabels
            [ CA.withGrid
            , CA.fontSize 12
            , CA.color "red"
            ]

        {- , C.labelAt
           (CA.percent 20)
           CA.middle
           [ CA.moveLeft 5
           , CA.rotate 90
           , CA.fontSize 2
           , CA.color "blue"
           ]
           [ S.text "Energía - kWh" ]
        -}
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
                [ C.bar .subsidio [ CA.color CA.red, CA.opacity 0.9 ]
                , C.bar
                    (\elReg ->
                        max 0 (max elReg.dosAtras elReg.unoAtras - elReg.subsidio)
                    )
                    [ CA.color CA.yellow ]
                ]
            , C.bar .gen [ CA.color CA.green ]
            ]
            consumo
        ]
