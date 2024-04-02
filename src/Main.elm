module Main exposing (..)

-- * Imports

import Array exposing (Array)
import Chart as C
import Chart.Attributes as CA
import Chart.Events as CE
import Chart.Item as CI
import Css.Global
import Dict exposing (Dict)
import FormatNumber exposing (format)
import FormatNumber.Locales exposing (usLocale)
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



-- * Main que en este caso es solo el view
-- Este es el gráfico para el consumo del cliente de David de Yessica 24-ene-2024


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
                [ Tw.max_w_screen_sm
                , Tw.my_12
                , Tw.mx_36
                , Tw.h_full
                ]
            ]
            [ grafica |> HtmlS.fromUnstyled ]
        , HtmlS.div
            [ css [ Tw.text_3xl, Tw.text_color Theme.lime_800, Tw.mb_4 ] ]
            [ HtmlS.text (Debug.toString (getMesNum Ene))
            , HtmlS.br [] []
            ]
        ]
        |> HtmlS.toUnstyled



-- * Valores Generales


type Mes
    = Ene
    | Feb
    | Mar
    | Abr
    | May
    | Jun
    | Jul
    | Ago
    | Sep
    | Oct
    | Nov
    | Dic


mesesTx : Array String
mesesTx =
    Array.fromList
        [ "Ene", "Feb", "Mar", "Abr", "May", "Jun", "Jul", "Ago", "Sep", "Oct", "Nov", "Dic" ]


mesesTy : Array Mes
mesesTy =
    Array.fromList
        [ Ene, Feb, Mar, Abr, May, Jun, Jul, Ago, Sep, Oct, Nov, Dic ]


parcial : Float
parcial =
    18 / 31


getMesNum : Mes -> Int
getMesNum cualMes =
    Array.indexedMap
        (\indice mes ->
            if mes == cualMes then
                indice + 1

            else
                0
        )
        mesesTy
        |> Array.toList
        |> List.sum


bimestresDeHistorial : Int
bimestresDeHistorial =
    12


mesMasAntiguo : Mes
mesMasAntiguo =
    Ago


limDAC =
    850


type Bimestre
    = ParNon
    | NonPar



-- generación de 4 paneles de 595w = 2.38kW


genera =
    [ 245, 259, 331, 337, 366, 367, 379, 374, 311, 287, 247, 233 ] |> Array.fromList



-- * Valores Particulares


saltaUnMes : Bool
saltaUnMes =
    True


paneles : Float
paneles =
    8


capPanelesWatts =
    545


consumoPaAtras : List Int
consumoPaAtras =
    [ 2121, 958, 590, 793, 701, 1271, 1596, 1283, 532, 582, 576, 1127 ]
        --    [ 456, 1138, 2067, 1559, 897, 598, 452, 1097, 1874, 1960, 1332, 471 ]
        |> List.reverse



-- bimestre más antiguo que aparece en el historial de consumo


bimestreUltimo : Int
bimestreUltimo =
    12



-- del bimestre último capturado


esteCaso : Bimestre
esteCaso =
    NonPar



-- * Nueva construcción de listados
-- * Construcción de listados de bimestres


bimestresParNon : List Int
bimestresParNon =
    [ 23, 45, 67, 89, 1011, 1201 ]


bimestresNonPar : List Int
bimestresNonPar =
    [ 12, 34, 56, 78, 910, 1112 ]


listadoqueAplica : Array Int
listadoqueAplica =
    (case esteCaso of
        ParNon ->
            bimestresParNon

        NonPar ->
            bimestresNonPar
    )
        |> Array.fromList



-- construyo un listado largo (3x) de bimestres solo para ver que meses voy a sacar para cada bimestre


listadoLargoDeBimestres : List Int
listadoLargoDeBimestres =
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
                if valor == bimestreUltimo then
                    [ valor ]

                else
                    []

            else
                valor :: listaAcum
    in
    List.foldl checaSi [] listadoLargoDeBimestres
        |> List.reverse



-- * Repartición del consumo


consumoEnOrden : List ( Int, Int )
consumoEnOrden =
    List.map2 (\bim cons -> ( bim, cons )) seQuedanBimestres consumoPaAtras


consumoPenultimoA : Dict Int Int
consumoPenultimoA =
    List.take 6 consumoEnOrden |> Dict.fromList


consumoUltimoA : Dict Int Int
consumoUltimoA =
    List.drop 6 consumoEnOrden |> Dict.fromList


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

        -- TODO Actualmente en obtenGenera capturo uso meses manualmente
        obtenGenera : Int -> Int -> Float
        obtenGenera m1 m2 =
            (paneles * capPanelesWatts / (4 * 595))
                * ((Array.get (m1 - 1) genera |> Maybe.withDefault 0)
                    + (Array.get (m2 - 1) genera |> Maybe.withDefault 0)
                  )

        subsidioMes : Int -> Int
        subsidioMes mes =
            if mes < 4 || mes > 9 then
                175

            else
                450

        obtenSubsidio : Int -> Int -> Float
        obtenSubsidio mes1 mes2 =
            subsidioMes mes1 + subsidioMes mes2 |> toFloat
    in
    [ { dosAtras = obtenConsumo 0 consumoPenultimoA
      , unoAtras = obtenConsumo 0 consumoUltimoA
      , subsidio =
            case esteCaso of
                ParNon ->
                    obtenSubsidio 1 2

                NonPar ->
                    obtenSubsidio 2 3
      , gen = obtenGenera 1 2
      }
    , { dosAtras = obtenConsumo 1 consumoPenultimoA
      , unoAtras = obtenConsumo 1 consumoUltimoA
      , subsidio =
            case esteCaso of
                ParNon ->
                    obtenSubsidio 3 4

                NonPar ->
                    obtenSubsidio 4 5
      , gen = obtenGenera 3 4
      }
    , { dosAtras = obtenConsumo 2 consumoPenultimoA
      , unoAtras = obtenConsumo 2 consumoUltimoA
      , subsidio =
            case esteCaso of
                ParNon ->
                    obtenSubsidio 5 6

                NonPar ->
                    obtenSubsidio 6 7
      , gen = obtenGenera 5 6
      }
    , { dosAtras = obtenConsumo 3 consumoPenultimoA
      , unoAtras = obtenConsumo 3 consumoUltimoA
      , subsidio =
            case esteCaso of
                ParNon ->
                    obtenSubsidio 7 8

                NonPar ->
                    obtenSubsidio 8 9
      , gen = obtenGenera 7 8
      }
    , { dosAtras = obtenConsumo 4 consumoPenultimoA
      , unoAtras = obtenConsumo 4 consumoUltimoA
      , subsidio =
            case esteCaso of
                ParNon ->
                    obtenSubsidio 9 10

                NonPar ->
                    obtenSubsidio 10 11
      , gen = obtenGenera 9 10
      }
    , { dosAtras = obtenConsumo 5 consumoPenultimoA
      , unoAtras = obtenConsumo 5 consumoUltimoA
      , subsidio =
            case esteCaso of
                ParNon ->
                    obtenSubsidio 11 12

                NonPar ->
                    obtenSubsidio 12 1
      , gen = obtenGenera 11 12
      }
    ]



-- * Armado de la Gráfica


grafica : Html msg
grafica =
    C.chart
        [ CA.width 480
        , CA.height 360
        ]
        [ C.yAxis [ CA.width 0.15, CA.noArrow, CA.color CA.darkBlue ]
        , C.xAxis [ CA.width 0.15, CA.noArrow, CA.color CA.darkBlue ]
        , -- para generar los meses que salen abajo en eje x
          C.generate 12 C.ints .x [] <|
            \plane valor ->
                [ C.xLabel
                    [ CA.x (toFloat valor), CA.fontSize 12, CA.color "blue" ]
                    [ S.text <|
                        Maybe.withDefault "Ene"
                            (Array.get
                                (valor * 2 - 2)
                                mesesTx
                            )
                    ]
                ]
        , C.yLabels
            -- medidas del eje y
            [ CA.withGrid
            , CA.fontSize 12
            , CA.color "blue"
            ]
        , C.labelAt
            -- Leyenda a la izquierda del eje y
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
                |> C.named "Consida dos años atrás"
            , C.bar .unoAtras
                [ CA.color CA.brown
                , CA.opacity 0.4
                ]
                |> C.named "Consumida año pasado"
            , C.stacked
                [ C.bar .subsidio [ CA.color CA.yellow, CA.opacity 0.9 ] |> C.named "Subsidiada- Barata"
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
                    |> C.named "Excedente - Cara"
                ]
            , C.bar (\reg -> reg.gen) [ CA.color CA.green ]
                |> C.named
                    ("Generada x Panel "
                        ++ format usLocale (capPanelesWatts * paneles / 1000)
                        ++ " kWp"
                    )
            ]
            consumo
        , C.legendsAt .max
            .max
            [ CA.column
            , CA.moveLeft 15
            , CA.alignRight
            , CA.spacing 5
            ]
            []
        ]
