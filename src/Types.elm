module Types exposing (..)

type FrontendModel =
    Nada

type BackendModel =
    NadaAtras

type FrontendMsg
    = FNoop

type ToBackend
    = NoOpToBackend

type BackendMsg
    = NoOpBackendMsg

type ToFrontend
    = NoOpToFrontend
