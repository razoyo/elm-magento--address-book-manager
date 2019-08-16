port module Main exposing (..)

import Browser

-- We're using elm-ui for styling
import Element exposing (..)

import Element.Events exposing (onClick)
import Element.Input as Input

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
  fromJs Changed
-- this gets us communication from the ports where we'll have to receive some of the key information like user/session, etc.


-- MODEL
type alias Model = {}

-- 
init : String -> ( Model, Cmd Msg )
init flags =
  -- return model and inital command

-- UPDATE

type Msg = Changed Value
  -- add other messages here

update : Msg -> Model -> ( Model, Cmd msg )
update msg model =
  -- what to do with Update Msgs

-- VIEW

view : Model -> Html Msg
view model =
  layout []
    <|
      column [] [
        row [] []  
      ]
