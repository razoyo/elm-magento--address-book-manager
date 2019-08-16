port module Main exposing (..)

import Browser

-- We're using elm-ui for styling
import Element exposing (..)
import Element.Events exposing (onClick)
import Element.Input as Input

import Html exposing (Html)

import Json.Decode as Decode exposing (Decoder, field, string, int, map, value)
import Json.Encode exposing (Value)

main =
  Browser.element
    { init = init
    , update = update
    , subscriptions = subscriptions
    , view = view
    }

-- SUBSCRIPTIONS

subscriptions : Model -> Sub Msg
subscriptions model =
  -- fromJs Changed
  Sub.none
-- this gets us communication from the ports where we'll have to receive some of the key information like user/session, etc.


-- MODEL
type alias Model = {}

-- 
init : String -> ( Model, Cmd Msg )
init _ =
  ( {}, Cmd.none )
  -- return model and inital command

-- UPDATE

type Msg = Changed Value
  -- add other messages here

update : Msg -> Model -> ( Model, Cmd msg )
update msg model =
  case msg of
    Changed message ->
      ( model, Cmd.none )
  -- what to do with Update Msgs

-- VIEW

view : Model -> Html Msg
view model =
  layout []
    <|
      column [] [
        row [] [
          el [] (text "Hello World")
        ]  
      ]
