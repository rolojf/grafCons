module Main exposing (main)

import Css.Global
import Html.Styled as Html exposing (Html, div, text)
import Html.Styled.Attributes as Attr exposing (css)
import Tailwind.Breakpoints as TWBp
import Tailwind.Theme as Theme
import Tailwind.Utilities as Tw exposing (globalStyles)


main =
    div []
        [ Css.Global.global globalStyles
        , div
            [ css
                [ Tw.m_3
                , Tw.border_2
                , Tw.border_r_2
                , Tw.border_color Theme.red_400
                , Tw.p_1
                ]
            ]
            [ text "This page is just static HTML, rendered by Elm." ]
        ]
        |> Html.toUnstyled
