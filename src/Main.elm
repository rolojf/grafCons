module Main exposing (..)

-- * Imports

import Array exposing (Array)
import Array.Extra as Array
import Chart as C
import Chart.Attributes as CA
import Chart.Item as CI
import Css.Global
import Datos exposing (..)
import Dict exposing (Dict)
import Dict.Any as Any exposing (AnyDict)
import FormatNumber exposing (format)
import FormatNumber.Locales exposing (usLocale)
import Html exposing (Html)
import Html.Attributes as Attr
import Html.Styled as HtmlS exposing (div, span, text)
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
    div
        [ css
            [ Tw.container
            , Tw.mx_auto
            ]
        ]
        [ Css.Global.global Tw.globalStyles
        , div
            [ css
                [ Tw.max_w_screen_sm
                , Tw.mt_2
                , Tw.mx_20
                , Tw.h_full
                , Tw.text_3xl
                , Tw.font_semibold
                , Tw.text_color Theme.gray_500
                ]
            ]
            [ text
                ("Su Consumo vs Generación de Panel "
                    ++ format usLocale (datos.capPanelesWatts * datos.paneles / 1000)
                    ++ " kWp"
                )
            ]
        , div
            [ css
                [ Tw.max_w_screen_sm
                , Tw.mt_1
                , Tw.mx_32
                , Tw.h_full
                , Tw.text_xl
                , Tw.text_color Theme.gray_500
                ]
            ]
            [ text
                (format usLocale (datos.capPanelesWatts * datos.paneles / 1000)
                    ++ " kWp porque son "
                    ++ String.fromFloat datos.paneles
                    ++ " paneles por "
                    ++ String.fromInt datos.capPanelesWatts
                    ++ " watts cada uno / 1,000 "
                )
            ]
        , div
            [ css
                [ Tw.max_w_screen_sm
                , Tw.mt_6
                , Tw.mx_36
                , Tw.h_full
                ]
            ]
            [ grafica |> HtmlS.fromUnstyled ]

        {- , div
           [ css [ Tw.text_2xl, Tw.text_color Theme.lime_800, Tw.m_6 ] ]
           [ text <|
               Debug.toString <|
                   Array.map (format usLocale) adic
           ]
        -}
        , div [ css [ Tw.max_w_screen_sm, Tw.mt_10, Tw.mx_36, Tw.text_xl, Tw.font_semibold, Tw.text_color Theme.gray_500 ] ]
            [ text "En cada bimestre, las dos primeras "
            , span [ css [ Tw.text_color Theme.amber_800 ] ]
                [ text "barras café " ]
            , text " son el consumo en años previos. "
            , if datos.hayAdic then
                text "Y se suma "

              else
                text ""
            , if datos.hayAdic then
                span [ css [ Tw.text_color Theme.sky_500 ] ]
                    [ text "el consumo calculado de climas adicionales. " ]

              else
                text ""
            , span
                [ css [ Tw.text_color Theme.green_600 ] ]
                [ text "Lo generado por el PANEL SOLAR, " ]
            , text "debe alcancanzar para "
            , span [ css [ Tw.text_color Theme.red_600 ] ]
                [ text "el consumo con tarifa excedente (alto costo) " ]
            , text "y a lo mejor para "
            , span [ css [ Tw.text_color Theme.yellow_600 ] ]
                [ text "el consumo con subsidio (bajo costo)" ]
            , text "."
            ]
        ]
        |> HtmlS.toUnstyled



-- * Valores Generales


genera =
    -- generación de 4 paneles de 595w = 2.38kW
    [ 245, 259, 331, 337, 366, 367, 379, 374, 311, 287, 247, 233 ] |> Array.fromList


reparteAdic =
    [ 0.3, 0.3, 0.1, 0.5, 0.8, 1.0, 1.0, 0.9, 0.7, 0.3, 0.2, 0.2 ]


limDAC =
    850


repartoXestacionalidad =
    Any.fromList getMesNum [ ( Ene, 0.22 ), ( Feb, 0.2 ), ( Mar, 0.1 ), ( Abr, 0.25 ), ( May, 0.8 ), ( Jun, 1.0 ), ( Jul, 1.0 ), ( Ago, 0.85 ), ( Sep, 0.7 ), ( Oct, 0.3 ), ( Nov, 0.1 ), ( Dic, 0.2 ) ]



-- * Funciones Habilitadoras


adic : DatosP -> Array Float
adic caso =
    let
        consMax =
            List.map kWhxTonHr caso.climasAdic |> List.sum
    in
    List.map (\cadaMes -> consMax * cadaMes) reparteAdic |> Array.fromList


kWhxTonHr : Clima -> Float
kWhxTonHr clima =
    let
        consumoOperacion =
            if clima.tipoClima == Inverter then
                0.5

            else
                0.8

        consumoArranque =
            if clima.tipoClima == Inverter then
                0.9

            else
                1.3
    in
    case clima.frecUso of
        Diario horas ->
            30
                * clima.tons
                * (consumoArranque
                    * clima.horasEnArranque
                    + consumoOperacion
                    * (horas - clima.horasEnArranque)
                  )

        Semanal horas veces ->
            4.33
                * clima.tons
                * (if (horas - clima.horasEnArranque * toFloat veces) < 0 then
                    0

                   else
                    (horas - (toFloat veces * clima.horasEnArranque))
                        * consumoOperacion
                        + (clima.horasEnArranque
                            * toFloat veces
                            * consumoArranque
                          )
                  )

        Mensual horas veces ->
            (if (clima.horasEnArranque * toFloat veces - horas) < 0 then
                0

             else
                (horas - (toFloat veces * clima.horasEnArranque))
                    * clima.tons
                    * consumoOperacion
            )
                + clima.horasEnArranque
                * toFloat veces
                * clima.tons
                * consumoArranque


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


mesesToGraph : List Mes
mesesToGraph =
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


secBimCons : DatosP -> List Int -> Array ( MesAnio, Int )
secBimCons caso cconsumo =
    let
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
                [ MesAnio caso.mesMasAntiguo caso.anioMasAntiguo ]
                (List.repeat caso.bimestresDeHistorial 1)
                |> List.reverse
                |> Array.fromList

        consumoArray =
            Array.fromList cconsumo
    in
    Array.map2
        (\bim cons -> ( bim, cons ))
        secBimestres
        consumoArray



-- * Repartición del Consumo


reparteConsumo :
    DatosP
    ->
        ( AnyDict LlaveComparable MesAnio Int
        , { consumoPaAtras : List Int

          -- : AnyDict LlaveComparable MesAnio Int
          , anyDictBase : AnyDict LlaveComparable MesAnio Int
          }
        )
reparteConsumo cas0 =
    let
        consumoPaAtras : List Int
        consumoPaAtras =
            List.reverse cas0.consumoTodos

        reparteAMeses : Int -> MesAnio -> AnyDict LlaveComparable MesAnio Int -> AnyDict LlaveComparable MesAnio Int
        reparteAMeses consumoDelBim mesInicDelBim elDict =
            let
                uno =
                    round <| (1 - cas0.parcial) * 30.0 * toFloat consumoDelBim / 61

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

        anyDictBase : AnyDict LlaveComparable MesAnio Int
        anyDictBase =
            let
                secMesesIdx : List Int
                secMesesIdx =
                    List.range
                        (getMesNum cas0.mesMasAntiguo)
                        (cas0.bimestresDeHistorial * 2 + 1 + getMesNum cas0.mesMasAntiguo)
                        |> List.map
                            (\x -> x - (((x - 1) // 12) * 12))

                secMeses2 =
                    List.range
                        (getMesNum cas0.mesMasAntiguo)
                        (cas0.bimestresDeHistorial * 2 + 1 + getMesNum cas0.mesMasAntiguo)
                        |> List.map
                            (\x -> (x - 1) // 12)

                zipSec =
                    List.zip secMesesIdx secMeses2
            in
            List.map
                (\( idx, addAnio ) ->
                    ( MesAnio
                        (Array.get (idx - 1) mesesTy
                            |> Maybe.withDefault Nov
                        )
                        (cas0.anioMasAntiguo + addAnio)
                    , 0
                    )
                )
                zipSec
                |> Any.fromList
                    convierteLlave
    in
    ( Array.foldl
        (\cadaElem elDic ->
            elDic
                |> reparteAMeses
                    (Tuple.second cadaElem)
                    (Tuple.first cadaElem)
        )
        anyDictBase
        (secBimCons cas0 consumoPaAtras)
    , { consumoPaAtras = consumoPaAtras

      {- , reparteAMeses =
         reparteAMeses
             cas0
             (Tuple.first cadaElem)
             (Tuple.second cadaElem)
      -}
      , anyDictBase = anyDictBase
      }
    )


obtnSub : Mes -> Float
obtnSub mmes =
    if List.member mmes [ Ene, Feb, Mar, Oct, Nov, Dic ] then
        175.0

    else
        450.0


obtenGenera : DatosP -> Int -> Int -> Float
obtenGenera caso m1 m2 =
    (caso.paneles * toFloat caso.capPanelesWatts / (4 * 595))
        * ((Array.get (m1 - 1) genera |> Maybe.withDefault 0)
            + (Array.get (m2 - 1) genera |> Maybe.withDefault 0)
          )


consumo : DatosP -> List { dosAtras : Float, unoAtras : Float, subsidio : Float, gen : Float, adicional : Float }
consumo cas0 =
    let
        obtnConsumoDelMesPenultimoAnio : AnyDict LlaveComparable MesAnio Int -> Mes -> Int
        obtnConsumoDelMesPenultimoAnio consRepartido mes =
            case
                Any.get
                    (MesAnio mes cas0.anioMasAntiguo)
                    consRepartido
            of
                Just consumoEse ->
                    consumoEse

                Nothing ->
                    case
                        Any.get
                            (MesAnio mes (cas0.anioMasAntiguo + 1))
                            consRepartido
                    of
                        Just consumoAhoraEste ->
                            consumoAhoraEste

                        Nothing ->
                            999999

        obtnConsumoDelMesUltimoAnio : AnyDict LlaveComparable MesAnio Int -> Mes -> Int
        obtnConsumoDelMesUltimoAnio consRepartido mes =
            case
                Any.get
                    (MesAnio mes (cas0.anioMasAntiguo + 2))
                    consRepartido
            of
                Just consumoEse ->
                    consumoEse

                Nothing ->
                    case
                        Any.get
                            (MesAnio mes (cas0.anioMasAntiguo + 1))
                            consRepartido
                    of
                        Just consumoAhoraEste ->
                            consumoAhoraEste

                        Nothing ->
                            999999
    in
    List.map
        (\month ->
            { dosAtras =
                obtnConsumoDelMesPenultimoAnio (Tuple.first (reparteConsumo cas0)) month
                    + obtnConsumoDelMesPenultimoAnio (Tuple.first (reparteConsumo cas0)) (mesSig month)
                    |> toFloat
            , unoAtras =
                obtnConsumoDelMesUltimoAnio (Tuple.first (reparteConsumo cas0)) month
                    + obtnConsumoDelMesUltimoAnio (Tuple.first (reparteConsumo cas0)) (mesSig month)
                    |> toFloat
            , subsidio =
                obtnSub month + obtnSub (mesSig month)
            , gen =
                obtenGenera
                    cas0
                    (getMesNum month)
                    (1 + getMesNum month)
            , adicional =
                if cas0.hayAdic then
                    case Maybe.map2 (+) (Array.get (getMesNum month) (adic cas0)) (Array.get (getMesNum month - 1) (adic cas0)) of
                        Just laSuma ->
                            laSuma

                        Nothing ->
                            100000.0

                else
                    0
            }
        )
        mesesToGraph



-- * Armado de la Gráfica


grafica : Html msg
grafica =
    C.chart
        [ CA.width 700
        , CA.height 420
        ]
        [ C.yAxis [ CA.width 1.0, CA.noArrow, CA.color CA.darkBlue ]
        , C.xAxis [ CA.width 2.0, CA.noArrow, CA.color CA.purple ]
        , C.generate 12 C.ints .x [] <|
            \plane valor ->
                [ C.xLabel
                    [ CA.x (toFloat valor), CA.fontSize 16, CA.color "blue" ]
                    [ S.text <|
                        Maybe.withDefault "Ene"
                            (Array.get
                                (valor * 2 - 2)
                                mesesTx
                            )
                    ]
                ]
        , C.yLabels
            [ CA.withGrid
            , CA.fontSize 16
            , CA.color "blue"
            ]
        , C.labelAt
            -- Leyenda a la izquierda del eje y
            (CA.percent -9)
            CA.middle
            [ CA.moveLeft 5
            , CA.rotate 90
            , CA.fontSize 20
            , CA.color "blue"
            ]
            [ S.text "Energía - kWh" ]
        , C.bars [ CA.margin 0.13 ]
            [ C.stacked
                [ C.bar .adicional
                    [ CA.color CA.blue
                    , CA.opacity 0.7
                    ]
                    |> C.named "Consumo adicional"
                , C.bar .dosAtras
                    [ CA.color CA.brown
                    , CA.opacity 0.7
                    ]
                    |> C.named "Consumo año antepasado"
                ]
            , C.stacked
                [ C.bar .adicional
                    [ CA.color CA.blue
                    , CA.opacity 0.7
                    ]
                    |> C.named "Consumo adicional"
                , C.bar .unoAtras
                    [ CA.color CA.brown
                    , CA.opacity 0.7
                    ]
                    |> C.named "Consumo año pasado"
                ]
            , C.stacked
                [ C.bar .subsidio [ CA.color CA.yellow, CA.opacity 0.9 ] |> C.named "Subsidiada Barata"
                , C.bar
                    (\elReg ->
                        let
                            elMax =
                                max 0 (max elReg.dosAtras elReg.unoAtras + elReg.adicional)
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
                        ++ format usLocale (datos.capPanelesWatts * datos.paneles / 1000)
                        ++ " kWp"
                    )
            ]
            (consumo datos)
        ]
