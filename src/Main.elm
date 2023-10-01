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
    HtmlS.div [ css [ Tw.container, Tw.mx_auto ] ]
        [ Css.Global.global Tw.globalStyles
        , HtmlS.div
            [ css
                [ Tw.m_3
                , Tw.border_2
                , Tw.border_r_2
                , Tw.border_color Theme.red_600
                , Tw.p_1
                ]
            ]
            [ HtmlS.text "This page is just static HTML, rendered by Elm." ]
        , HtmlS.div
            [ css [ Tw.max_w_screen_sm ] ]
            [ grafica |> HtmlS.fromUnstyled ]
        ]
        |> HtmlS.toUnstyled


grafica : Html msg
grafica =
    C.chart
        [ CA.width 30
        , CA.height 40
        ]
        [ C.bars []
            [ C.bar .income []
            , C.bar .spending []
            ]
            [ { income = 10, spending = 2 }
            , { income = 12, spending = 6 }
            , { income = 18, spending = 16 }
            ]
        ]
