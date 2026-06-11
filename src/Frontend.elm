module Frontend exposing (..)

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
import Lamdera exposing (sendToBackend)
import List.Extra as List
import Svg as S
import Svg.Attributes as SA
import Svg.Events as SE
import Tailwind.Breakpoints as TwBp
import Tailwind.Theme as Theme
import Tailwind.Utilities as Tw
import Types exposing (..)



-- * Main que en este caso es solo el view


app =
    Lamdera.frontend
        { init = \_ _ -> ( Nada, Cmd.none )
        , onUrlRequest = \_ -> FNoop
        , onUrlChange = \_ -> FNoop
        , update = update
        , updateFromBackend = updateFromBackend
        , subscriptions = \_ -> Sub.none
        , view =
            \model ->
                { title = "Lamdera"
                , body = viewBody model
                }
        }


update : FrontendMsg -> FrontendModel -> ( FrontendModel, Cmd FrontendMsg )
update msg model =
    ( Nada, Cmd.none )


updateFromBackend : ToFrontend -> FrontendModel -> ( FrontendModel, Cmd FrontendMsg )
updateFromBackend msg model =
    ( Nada, Cmd.none )


viewBody _ =
    [ div
        [ css
            [ Tw.container
            , Tw.mx_auto
            ]
        ]
        [ Css.Global.global Tw.globalStyles
        , div
            [ css
                [ Tw.max_w_screen_sm
                , Tw.mt_8
                , Tw.mx_24
                , Tw.h_full
                , Tw.text_3xl
                , Tw.font_semibold
                , Tw.text_color Theme.gray_500
                ]
            ]
            [ text
                ("Consumo vs Generación. Panel "
                    ++ format usLocale (toFloat (datos.capPanelesWatts * datos.paneles) / 1000)
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
                (format usLocale (toFloat (datos.capPanelesWatts * datos.paneles) / 1000)
                    ++ " kWp porque son "
                    ++ String.fromInt datos.paneles
                    ++ " paneles por "
                    ++ String.fromInt datos.capPanelesWatts
                    ++ " watts cada uno / 1,000 "
                )
            ]
        , case huecos datos.historial of
            [] ->
                text ""

            avisos ->
                div
                    [ css
                        [ Tw.max_w_screen_sm
                        , Tw.mt_4
                        , Tw.mx_36
                        , Tw.text_lg
                        , Tw.font_semibold
                        , Tw.text_color Theme.red_600
                        ]
                    ]
                    [ text ("Revisar captura del historial: " ++ String.join "; " avisos) ]
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
                   secBimCons datos
           ]
        -}
        , div [ css [ Tw.max_w_screen_sm, Tw.mt_10, Tw.mx_36, Tw.text_xl, Tw.font_semibold, Tw.text_color Theme.gray_500 ] ]
            ([ text "En cada bimestre, las dos primeras "
             , span [ css [ Tw.text_color Theme.amber_800 ] ]
                [ text "barras café " ]
             , text " son el consumo en años previos. "
             , if datos.hayAdic then
                text "Y se suma "

               else
                text ""
             , if datos.hayAdic then
                span [ css [ Tw.text_color Theme.sky_500 ] ]
                    [ text
                        (case datos.climasAdic of
                            ListaDeClimas _ ->
                                "el consumo calculado de climas adicionales. "

                            Porcentaje pct ->
                                "el consumo calculado con el " ++ String.fromFloat (pct * 100) ++ "% adicional. "
                        )
                    ]

               else
                text ""
             , span
                [ css [ Tw.text_color Theme.green_600 ] ]
                [ text "Lo generado por el PANEL SOLAR" ]
             ]
                ++ (if datos.sinGraficarSubsidio then
                        List.singleton (text " debe cubrir el consumo.")

                    else
                        [ text " debe alcancanzar para "
                        , span [ css [ Tw.text_color Theme.red_600 ] ]
                            [ text "el consumo con tarifa excedente (alto costo) " ]
                        , text "y a lo mejor para "
                        , span [ css [ Tw.text_color Theme.yellow_600 ] ]
                            [ text "el consumo con subsidio (bajo costo)" ]
                        , text "."
                        ]
                   )
            )
        ]
        |> HtmlS.toUnstyled
    ]



-- * Valores Generales


genera =
    -- generación de 4 paneles de 595w = 2.38kW
    [ 245, 259, 331, 337, 366, 367, 379, 374, 311, 287, 247, 233 ]
        |> List.map (\cons1 -> cons1 * 0.95)
        |> Array.fromList


reparteAdic =
    [ 0.3, 0.3, 0.1, 0.5, 0.8, 1.0, 1.0, 0.9, 0.7, 0.3, 0.2, 0.2 ]


limDAC =
    850


verSubsidio : Bool
verSubsidio =
    False


repartoXestacionalidad =
    Any.fromList getMesNum [ ( Ene, 0.22 ), ( Feb, 0.2 ), ( Mar, 0.1 ), ( Abr, 0.25 ), ( May, 0.8 ), ( Jun, 1.0 ), ( Jul, 1.0 ), ( Ago, 0.85 ), ( Sep, 0.7 ), ( Oct, 0.3 ), ( Nov, 0.1 ), ( Dic, 0.2 ) ]



-- * Funciones Habilitadoras


adicFromLista : List Clima -> Array Float
adicFromLista climas =
    let
        consMax =
            List.map kWhxTonHr climas |> List.sum
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



-- * Repartición del Consumo


esBisiesto : Int -> Bool
esBisiesto anio =
    (modBy 4 anio == 0 && modBy 100 anio /= 0) || modBy 400 anio == 0


diasEnMes : Mes -> Int -> Int
diasEnMes mes anio =
    if mes == Feb then
        if esBisiesto anio then
            29

        else
            28

    else if List.member mes [ Abr, Jun, Sep, Nov ] then
        30

    else
        31


{-| Días que cubre el periodo en cada mes calendario, en orden cronológico.
Convención de lecturas del medidor: el día `del` es exclusivo y el día `al`
es inclusivo, así la suma de días empata con la duración del periodo.
-}
diasPorMes : Periodo -> List ( MesAnio, Int )
diasPorMes periodo =
    let
        avanza : Int -> MesAnio -> List ( MesAnio, Int ) -> List ( MesAnio, Int )
        avanza tope actual acc =
            if tope <= 0 then
                acc

            else if actual.mes == periodo.al.mes && actual.anio == periodo.al.anio then
                ( actual, periodo.al.dia ) :: acc

            else
                avanza (tope - 1) (mesAnioSig actual) (( actual, diasEnMes actual.mes actual.anio ) :: acc)
    in
    (if periodo.del.mes == periodo.al.mes && periodo.del.anio == periodo.al.anio then
        [ ( MesAnio periodo.del.mes periodo.del.anio, periodo.al.dia - periodo.del.dia ) ]

     else
        avanza 12
            (mesAnioSig (MesAnio periodo.del.mes periodo.del.anio))
            [ ( MesAnio periodo.del.mes periodo.del.anio
              , diasEnMes periodo.del.mes periodo.del.anio - periodo.del.dia
              )
            ]
    )
        |> List.reverse
        |> List.filter (\( _, dias ) -> dias > 0)


{-| Reparte los kWh de cada periodo entre los meses calendario que toca,
proporcional a los días cubiertos en cada mes. `dias` acumula la cobertura
para saber si un mes quedó completo.
-}
reparteConsumo : DatosP -> AnyDict LlaveComparable MesAnio { kwh : Float, dias : Int }
reparteConsumo cas0 =
    let
        agrega : Periodo -> AnyDict LlaveComparable MesAnio { kwh : Float, dias : Int } -> AnyDict LlaveComparable MesAnio { kwh : Float, dias : Int }
        agrega periodo dict =
            let
                reparto =
                    diasPorMes periodo

                totalDias =
                    List.sum (List.map Tuple.second reparto)
            in
            List.foldl
                (\( mesAnio, dias ) d ->
                    Any.update mesAnio
                        (\previo ->
                            let
                                p =
                                    Maybe.withDefault { kwh = 0, dias = 0 } previo
                            in
                            Just
                                { kwh = p.kwh + toFloat periodo.kWh * toFloat dias / toFloat totalDias
                                , dias = p.dias + dias
                                }
                        )
                        d
                )
                dict
                reparto
    in
    List.foldl agrega (Any.empty convierteLlave) cas0.historial


{-| Filas del historial que no encadenan: el `al` de un periodo debe ser
el `del` del siguiente. Si hay huecos probablemente hubo error de captura.
-}
huecos : List Periodo -> List String
huecos historial =
    let
        ordenados =
            List.sortBy (\p -> ( p.del.anio, getMesNum p.del.mes, p.del.dia )) historial

        fechaTx f =
            String.fromInt f.dia ++ " " ++ getMesTxt f.mes ++ " " ++ String.fromInt f.anio
    in
    List.map2
        (\anterior siguiente ->
            if anterior.al == siguiente.del then
                Nothing

            else
                Just
                    ("el periodo que inicia el "
                        ++ fechaTx siguiente.del
                        ++ " no empata con el fin del anterior ("
                        ++ fechaTx anterior.al
                        ++ ")"
                    )
        )
        ordenados
        (List.drop 1 ordenados)
        |> List.filterMap identity


obtnSub : Mes -> Float
obtnSub mmes =
    if List.member mmes [ Ene, Feb, Mar, Oct, Nov, Dic ] then
        175.0

    else
        450.0


obtenGenera : DatosP -> Int -> Int -> Float
obtenGenera caso m1 m2 =
    (toFloat caso.paneles * toFloat caso.capPanelesWatts / (4 * 595))
        * ((Array.get (m1 - 1) genera |> Maybe.withDefault 0)
            + (Array.get (m2 - 1) genera |> Maybe.withDefault 0)
          )


consumo : DatosP -> List { dosAtras : Float, unoAtras : Float, subsidio : Float, gen : Float, adicional : Float }
consumo cas0 =
    let
        repartido =
            reparteConsumo cas0

        -- ( consumo del año más antiguo con el mes completo, ídem del más reciente )
        consMes : Mes -> ( Float, Float )
        consMes mes =
            let
                todas =
                    Any.toList repartido
                        |> List.filter (\( ma, _ ) -> ma.mes == mes)
                        |> List.sortBy (\( ma, _ ) -> ma.anio)

                completas =
                    todas
                        |> List.filter (\( ma, reg ) -> reg.dias >= diasEnMes ma.mes ma.anio)
                        |> List.map (\( _, reg ) -> reg.kwh)
            in
            case completas of
                primero :: resto ->
                    ( primero, List.last resto |> Maybe.withDefault primero )

                [] ->
                    -- sin mes completo: escala la mayor cobertura parcial al mes entero
                    case List.maximumBy (\( _, reg ) -> reg.dias) todas of
                        Just ( ma, reg ) ->
                            let
                                escalado =
                                    reg.kwh * toFloat (diasEnMes ma.mes ma.anio) / toFloat reg.dias
                            in
                            ( escalado, escalado )

                        Nothing ->
                            ( 0, 0 )
    in
    List.map
        (\month ->
            let
                ( mesViejo1, mesNuevo1 ) =
                    consMes month

                ( mesViejo2, mesNuevo2 ) =
                    consMes (mesSig month)

                dosAtras =
                    mesViejo1 + mesViejo2

                unoAtras =
                    mesNuevo1 + mesNuevo2
            in
            { dosAtras = dosAtras
            , unoAtras = unoAtras
            , subsidio =
                obtnSub month + obtnSub (mesSig month)
            , gen =
                obtenGenera
                    cas0
                    (getMesNum month)
                    (1 + getMesNum month)
            , adicional =
                if cas0.hayAdic then
                    case cas0.climasAdic of
                        ListaDeClimas climas ->
                            case Maybe.map2 (+) (Array.get (getMesNum month) (adicFromLista climas)) (Array.get (getMesNum month - 1) (adicFromLista climas)) of
                                Just laSuma ->
                                    laSuma

                                Nothing ->
                                    100000.0

                        Porcentaje pct ->
                            pct * max dosAtras unoAtras

                else
                    0
            }
        )
        [ Ene, Mar, May, Jul, Sep, Nov ]



-- * Armado de la Gráfica


grafica : Html msg
grafica =
    let
        barrasHist =
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
            ]

        barrasGen =
            C.bar (\reg -> reg.gen) [ CA.color CA.green ]
                |> C.named
                    ("Generada x Panel "
                        ++ format usLocale (toFloat (datos.capPanelesWatts * datos.paneles) / 1000)
                        ++ " kWp"
                    )
                |> List.singleton

        barraSub =
            [ C.stacked
                [ C.bar
                    .subsidio
                    [ CA.color CA.yellow, CA.opacity 0.9 ]
                    |> C.named "Subsidiada Barata"
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
            ]

        barrasGraf =
            barrasHist
                ++ (if datos.sinGraficarSubsidio then
                        barrasGen

                    else
                        barraSub ++ barrasGen
                   )
    in
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
            barrasGraf
            (consumo datos)
        ]
