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
        , HtmlS.div
            [ css [ Tw.text_2xl, Tw.text_color Theme.lime_800, Tw.mb_4 ] ]
            [ HtmlS.text <| Debug.toString <| reparteConsumo
            , HtmlS.br [] []
            , HtmlS.br [] []
            , HtmlS.text <| Debug.toString <| obtnPrimerBim May
            , HtmlS.br [] []
            , HtmlS.br [] []
            , HtmlS.text <| Debug.toString <| obtnSegundoBim May
            , HtmlS.br [] []
            ]
        ]
        |> HtmlS.toUnstyled



-- * Valores Generales
-- generación de 4 paneles de 595w = 2.38kW


genera =
    [ 245, 259, 331, 337, 366, 367, 379, 374, 311, 287, 247, 233 ] |> Array.fromList



-- ** Nueva Versión VG


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
    Array.fromList listaMesesTx


mesesTy : Array Mes
mesesTy =
    Array.fromList
        [ Ene, Feb, Mar, Abr, May, Jun, Jul, Ago, Sep, Oct, Nov, Dic ]


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


listadoDeMeses : List String
listadoDeMeses =
    List.repeat 3 listaMesesTx
        |> List.concat


type alias MesAnio =
    { mes : Mes
    , anio : Int
    }



-- ** Nueva Anterior VG


type Bimestre
    = ParNon
    | NonPar



-- * Valores Particulares


bimestresDeHistorial : Int
bimestresDeHistorial =
    12


paneles : Float
paneles =
    8


limDAC =
    850


capPanelesWatts =
    545


consumoPaAtras : List Int
consumoPaAtras =
    [ 2121, 958, 590, 793, 701, 1271, 1596, 1283, 532, 582, 576, 1127 ]
        |> List.reverse



-- ** Nueva versión
-- día de corte del primer mes del bimestre


parcial : Float
parcial =
    18 / 31


mesMasAntiguo : Mes
mesMasAntiguo =
    Ago


anioMasAntiguo : Int
anioMasAntiguo =
    2022



-- ** Versión anterior


saltaUnMes : Bool
saltaUnMes =
    True



-- bimestre más antiguo que aparece en el historial de consumo


bimestreUltimo : Int
bimestreUltimo =
    12



-- del bimestre último capturado


esteCaso : Bimestre
esteCaso =
    NonPar



-- * Construcción de listados
-- ** Version Nueva CL


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


mesAnt : Mes -> Mes
mesAnt anterior =
    if anterior == Ene then
        Dic

    else
        Array.get (getMesNum anterior - 1) mesesTy |> Maybe.withDefault Nov


listaMesesTx : List String
listaMesesTx =
    [ "Ene", "Feb", "Mar", "Abr", "May", "Jun", "Jul", "Ago", "Sep", "Oct", "Nov", "Dic" ]


type alias LlaveComparable =
    ( String, Int )


convierteLlave : MesAnio -> LlaveComparable
convierteLlave monthYear =
    ( getMesTxt monthYear.mes
    , monthYear.anio
    )


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



-- ** Version Anterior CL


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



-- * Repartición del Consumo
-- ** Versioń Nueva RC


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


unoDict =
    anyDictBase
        |> reparteAMeses
            2000
            (MesAnio Dic 2023)


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


subMes : Int -> Int
subMes mes =
    if mes < 4 || mes > 9 then
        175

    else
        450


subRepartido : MesAnio -> Int
subRepartido mesInicDelBim =
    let
        uno =
            (mesInicDelBim.mes |> getMesNum |> subMes |> toFloat) * (1 - parcial) |> round

        dos =
            mesInicDelBim |> mesAnioSig |> .mes |> getMesNum |> subMes

        tres =
            (mesInicDelBim |> mesAnioSig |> mesAnioSig |> .mes |> getMesNum |> subMes |> toFloat) * parcial |> round
    in
    uno + dos + tres


mesBimPrevio : Mes -> Mes
mesBimPrevio =
    if parcial <= 0.5 then
        mesAnt >> mesAnt

    else
        mesAnt >> mesAnt >> mesAnt


obtnPrimerBim : Mes -> Int
obtnPrimerBim mes =
    case
        Any.get
            (MesAnio (mesBimPrevio mes) anioMasAntiguo)
            reparteConsumo
    of
        Just consumoEse ->
            consumoEse

        Nothing ->
            case
                Any.get
                    (MesAnio (mesBimPrevio mes) (anioMasAntiguo + 1))
                    reparteConsumo
            of
                Just consumoAhoraEste ->
                    consumoAhoraEste

                Nothing ->
                    999999


obtnSegundoBim : Mes -> Int
obtnSegundoBim mes =
    case
        Any.get
            (MesAnio (mesBimPrevio mes) (anioMasAntiguo + 2))
            reparteConsumo
    of
        Just consumoEse ->
            consumoEse

        Nothing ->
            case
                Any.get
                    (MesAnio (mesBimPrevio mes) (anioMasAntiguo + 1))
                    reparteConsumo
            of
                Just consumoAhoraEste ->
                    consumoAhoraEste

                Nothing ->
                    999999


consumo =
    let
        obtenSubsidio : Int -> Int -> Float
        obtenSubsidio mes1 mes2 =
            subMes mes1 + subMes mes2 |> toFloat

        obtenGenera : Int -> Int -> Float
        obtenGenera m1 m2 =
            (paneles * capPanelesWatts / (4 * 595))
                * ((Array.get (m1 - 1) genera |> Maybe.withDefault 0)
                    + (Array.get (m2 - 1) genera |> Maybe.withDefault 0)
                  )
    in
    [ { dosAtras = (obtnPrimerBim Ene + obtnPrimerBim Feb) |> toFloat
      , unoAtras = (obtnSegundoBim Ene + obtnSegundoBim Feb) |> toFloat
      , subsidio =
            case esteCaso of
                ParNon ->
                    obtenSubsidio 1 2

                NonPar ->
                    obtenSubsidio 2 3
      , gen = obtenGenera 1 2
      }
    , { dosAtras = (obtnPrimerBim Mar + obtnPrimerBim Abr) |> toFloat
      , unoAtras = (obtnSegundoBim Mar + obtnSegundoBim Abr) |> toFloat
      , subsidio =
            case esteCaso of
                ParNon ->
                    obtenSubsidio 3 4

                NonPar ->
                    obtenSubsidio 4 5
      , gen = obtenGenera 3 4
      }
    , { dosAtras = (obtnPrimerBim May + obtnPrimerBim Jun) |> toFloat
      , unoAtras = (obtnSegundoBim May + obtnSegundoBim Jun) |> toFloat
      , subsidio =
            case esteCaso of
                ParNon ->
                    obtenSubsidio 5 6

                NonPar ->
                    obtenSubsidio 6 7
      , gen = obtenGenera 5 6
      }
    , { dosAtras = (obtnPrimerBim Jul + obtnPrimerBim Ago) |> toFloat
      , unoAtras = (obtnSegundoBim Jul + obtnSegundoBim Ago) |> toFloat
      , subsidio =
            case esteCaso of
                ParNon ->
                    obtenSubsidio 7 8

                NonPar ->
                    obtenSubsidio 8 9
      , gen = obtenGenera 7 8
      }
    , { dosAtras = (obtnPrimerBim Sep + obtnPrimerBim Oct) |> toFloat
      , unoAtras = (obtnSegundoBim Sep + obtnSegundoBim Oct) |> toFloat
      , subsidio =
            case esteCaso of
                ParNon ->
                    obtenSubsidio 9 10

                NonPar ->
                    obtenSubsidio 10 11
      , gen = obtenGenera 9 10
      }
    , { dosAtras = (obtnPrimerBim Nov + obtnPrimerBim Dic) |> toFloat
      , unoAtras = (obtnSegundoBim Nov + obtnSegundoBim Dic) |> toFloat
      , subsidio =
            case esteCaso of
                ParNon ->
                    obtenSubsidio 11 12

                NonPar ->
                    obtenSubsidio 12 1
      , gen = obtenGenera 11 12
      }
    ]



-- ** Versión Anterior RC


consumoEnOrden : List ( Int, Int )
consumoEnOrden =
    List.map2 (\bim cons -> ( bim, cons )) seQuedanBimestres consumoPaAtras


consumoPenultimoA : Dict Int Int
consumoPenultimoA =
    List.take 6 consumoEnOrden |> Dict.fromList


consumoUltimoA : Dict Int Int
consumoUltimoA =
    List.drop 6 consumoEnOrden |> Dict.fromList


consumoOld =
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
