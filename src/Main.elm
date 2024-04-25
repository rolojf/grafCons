module Main exposing (..)

-- * Imports

import Array exposing (Array)
import Array.Extra as Array
import Chart as C
import Chart.Attributes as CA
import Chart.Events as CE
import Chart.Item as CI
import Css.Global
import Dict exposing (Dict)
import Dict.Any as Any exposing (AnyDict)
import FormatNumber exposing (format)
import FormatNumber.Locales exposing (usLocale)
import Html exposing (Html)
import Html.Attributes as Attr
import Html.Styled as HtmlS
import Html.Styled.Attributes exposing (css)
import List.Extra as List
import Svg as S
import Svg.Attributes as SA
import Svg.Events as SE
import Tailwind.Breakpoints as TwBp
import Tailwind.Theme as Theme
import Tailwind.Utilities as Tw



-- * Main que en este caso es solo el view


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

        {- , HtmlS.div
           [ css [ Tw.text_2xl, Tw.text_color Theme.lime_800, Tw.mb_4 ] ]
           [ HtmlS.text <| Debug.toString <| obtenSubsidio 0 6
           , HtmlS.br [] []
           , HtmlS.br [] []
           ]
        -}
        ]
        |> HtmlS.toUnstyled



-- * Valores Generales


genera =
    -- generación de 4 paneles de 595w = 2.38kW
    [ 245, 259, 331, 337, 366, 367, 379, 374, 311, 287, 247, 233 ] |> Array.fromList


limDAC =
    850


repartoXestacionalidad =
    Any.fromList getMesNum [ ( Ene, 0.22 ), ( Feb, 0.2 ), ( Mar, 0.1 ), ( Abr, 0.25 ), ( May, 0.8 ), ( Jun, 1.0 ), ( Jul, 1.0 ), ( Ago, 0.85 ), ( Sep, 0.7 ), ( Oct, 0.3 ), ( Nov, 0.1 ), ( Dic, 0.2 ) ]



-- * Valores Particulares


bimestresDeHistorial : Int
bimestresDeHistorial =
    12


paneles : Float
paneles =
    7


capPanelesWatts =
    595


consumoPaAtras : List Int
consumoPaAtras =
    [ 2121, 958, 590, 793, 701, 1271, 1596, 1283, 532, 582, 576, 1127 ]
        |> List.reverse


parcial : Float
parcial =
    18 / 31


mesMasAntiguo : Mes
mesMasAntiguo =
    Ago


anioMasAntiguo : Int
anioMasAntiguo =
    2022



-- * Funciones Habilitadoras


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


type alias LlaveComparable =
    ( String, Int )


mesesTx : Array String
mesesTx =
    Array.fromList listaMesesTx


mesesTy : Array Mes
mesesTy =
    Array.fromList
        [ Ene, Feb, Mar, Abr, May, Jun, Jul, Ago, Sep, Oct, Nov, Dic ]


listaMesesTx : List String
listaMesesTx =
    [ "Ene", "Feb", "Mar", "Abr", "May", "Jun", "Jul", "Ago", "Sep", "Oct", "Nov", "Dic" ]


mesesToGraph : Array Mes
mesesToGraph =
    Array.fromList
        [ Ene, Mar, May, Jul, Sep, Nov ]


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


getMesTxt : Mes -> String
getMesTxt cualMes =
    cualMes
        |> getMesNum
        |> (\x -> x - 1)
        |> (\x -> Array.get x mesesTx)
        |> Maybe.withDefault "Error"


type alias MesAnio =
    { mes : Mes
    , anio : Int
    }


mesAnioSig : MesAnio -> MesAnio
mesAnioSig anterior =
    { mes =
        if anterior.mes == Dic then
            Ene

        else
            Array.get (getMesNum anterior.mes) mesesTy |> Maybe.withDefault Nov
    , anio =
        if anterior.mes == Dic then
            anterior.anio + 1

        else
            anterior.anio
    }


mesSig : Mes -> Mes
mesSig month =
    Array.get (getMesNum month) mesesTy |> Maybe.withDefault Ene


mesAnt : Mes -> Mes
mesAnt anterior =
    if anterior == Ene then
        Dic

    else
        Array.get (getMesNum anterior - 1) mesesTy |> Maybe.withDefault Nov


convierteLlave : MesAnio -> LlaveComparable
convierteLlave monthYear =
    ( getMesTxt monthYear.mes
    , monthYear.anio
    )



-- * Construcción de listados


listadoDeMeses : List String
listadoDeMeses =
    List.repeat 3 listaMesesTx
        |> List.concat


anyDictBase : AnyDict LlaveComparable MesAnio Int
anyDictBase =
    let
        secMesesIdx : List Int
        secMesesIdx =
            List.range
                (getMesNum mesMasAntiguo)
                (bimestresDeHistorial * 2 + 1 + getMesNum mesMasAntiguo)
                |> List.map
                    (\x -> x - (((x - 1) // 12) * 12))

        secMeses2 =
            List.range
                (getMesNum mesMasAntiguo)
                (bimestresDeHistorial * 2 + 1 + getMesNum mesMasAntiguo)
                |> List.map
                    (\x -> (x - 1) // 12)

        zipSec =
            List.zip secMesesIdx secMeses2

        _ =
            Debug.log "zipSec" zipSec
    in
    List.map
        (\( idx, addAnio ) ->
            ( MesAnio
                (Array.get (idx - 1) mesesTy
                    |> Maybe.withDefault Nov
                )
                (anioMasAntiguo + addAnio)
            , 0
            )
        )
        zipSec
        |> Any.fromList
            convierteLlave


secBimestres : Array MesAnio
secBimestres =
    List.foldl
        (\_ acVeces ->
            case List.head acVeces of
                Nothing ->
                    MesAnio Nov 9999 :: acVeces

                Just ma ->
                    (mesAnioSig ma |> mesAnioSig) :: acVeces
        )
        [ MesAnio mesMasAntiguo anioMasAntiguo ]
        (List.repeat bimestresDeHistorial 1)
        |> List.reverse
        |> Array.fromList


secBimCons : Array ( MesAnio, Int )
secBimCons =
    let
        consumoArray =
            Array.fromList consumoPaAtras
    in
    Array.map2
        (\bim cons -> ( bim, cons ))
        secBimestres
        consumoArray



-- * Repartición del Consumo


reparteAMeses : Int -> MesAnio -> AnyDict LlaveComparable MesAnio Int -> AnyDict LlaveComparable MesAnio Int
reparteAMeses consumoDelBim mesInicDelBim elDict =
    let
        uno =
            round <| (1 - parcial) * 30.0 * toFloat consumoDelBim / 61

        dos =
            round <| 31.0 * toFloat consumoDelBim / 61

        tres =
            consumoDelBim - uno - dos
    in
    elDict
        |> Any.update
            mesInicDelBim
            (Maybe.map ((+) uno))
        |> Any.update
            (mesAnioSig mesInicDelBim)
            (Maybe.map ((+) dos))
        |> Any.update
            (mesAnioSig (mesAnioSig mesInicDelBim))
            (Maybe.map ((+) tres))


reparteConsumo : AnyDict LlaveComparable MesAnio Int
reparteConsumo =
    Array.foldl
        (\cadaElem elDic ->
            elDic
                |> reparteAMeses
                    (Tuple.second cadaElem)
                    (Tuple.first cadaElem)
        )
        anyDictBase
        secBimCons


subMes : Maybe Mes -> Int
subMes mmes =
    case mmes of
        Just month ->
            if List.member month [ Ene, Feb, Mar, Oct, Nov, Dic ] then
                175

            else
                450

        Nothing ->
            99999


obtnSubsidio : Int -> Int -> Float
obtnSubsidio mes1 mes2 =
    subMes (Array.get (mes1 - 1) mesesTy)
        + subMes (Array.get (mes2 - 1) mesesTy)
        |> toFloat


obtnConsumoDelMesPenultimoAnio : Mes -> Int
obtnConsumoDelMesPenultimoAnio mes =
    case
        Any.get
            (MesAnio mes anioMasAntiguo)
            reparteConsumo
    of
        Just consumoEse ->
            consumoEse

        Nothing ->
            case
                Any.get
                    (MesAnio mes (anioMasAntiguo + 1))
                    reparteConsumo
            of
                Just consumoAhoraEste ->
                    consumoAhoraEste

                Nothing ->
                    999999


obtnConsumoDelMesUltimoAnio : Mes -> Int
obtnConsumoDelMesUltimoAnio mes =
    case
        Any.get
            (MesAnio mes (anioMasAntiguo + 2))
            reparteConsumo
    of
        Just consumoEse ->
            consumoEse

        Nothing ->
            case
                Any.get
                    (MesAnio mes (anioMasAntiguo + 1))
                    reparteConsumo
            of
                Just consumoAhoraEste ->
                    consumoAhoraEste

                Nothing ->
                    999999


obtenGenera : Int -> Int -> Float
obtenGenera m1 m2 =
    (paneles * capPanelesWatts / (4 * 595))
        * ((Array.get (m1 - 1) genera |> Maybe.withDefault 0)
            + (Array.get (m2 - 1) genera |> Maybe.withDefault 0)
          )


consumo =
    Array.map
        (\month ->
            { dosAtras =
                obtnConsumoDelMesPenultimoAnio month
                    + obtnConsumoDelMesPenultimoAnio (mesSig month)
                    |> toFloat
            , unoAtras =
                obtnConsumoDelMesUltimoAnio month
                    + obtnConsumoDelMesUltimoAnio (mesSig month)
                    |> toFloat
            , subsidio =
                obtnSubsidio
                    (getMesNum month)
                    (1 + getMesNum month)
            , gen =
                obtenGenera
                    (getMesNum month)
                    (1 + getMesNum month)
            }
        )
        mesesToGraph
        |> Array.toList



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
                |> C.named "Consumida dos años atrás"
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
