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
type alias Model = {
    firstName :  String
    , lastName : String
    , street1 : String
    , street2 : String
    , street3 : String
    , city : String
    , state : String
    , postalCode : String
    , country : String
  }

-- 
init : String -> ( Model, Cmd Msg )
init _ =
  ( { firstName = ""
    , lastName = ""
    , street1 = ""
    , street2 = ""
    , street3 = ""
    , city = ""
    , state = ""
    , postalCode = ""
    , country = ""
    }, Cmd.none )
  -- return model and inital command

-- UPDATE

type Msg = Changed Value
  | UpdateFirstName String
  | UpdateLastName String
  | UpdateStreet1 String
  | UpdateStreet2 String
  | UpdateStreet3 String
  | UpdateCity String
  | UpdateState String
  | UpdatePostalcode String
  | UpdateCountry String

update : Msg -> Model -> ( Model, Cmd msg )
update msg model =
  case msg of
    Changed message ->
      ( model, Cmd.none )
  -- what to do with Update Msgs
    
    UpdateFirstName name ->
      ( { model | firstName = name }
      , Cmd.none 
      )

    UpdateLastName name ->
      ( { model | lastName = name }
      , Cmd.none 
      )

    UpdateStreet1 street ->
      ( { model | street1 = street }
      , Cmd.none 
      )

    UpdateStreet2 street ->
      ( { model | street2 = street }
      , Cmd.none 
      )

    UpdateStreet3 street ->
      ( { model | street3 = street }
      , Cmd.none 
      )

    UpdateCity city ->
      ( { model | city = city }
      , Cmd.none 
      )

    UpdateState state ->
      ( { model | state = state }
      , Cmd.none 
      )

    UpdatePostalcode code ->
      ( { model | postalCode = code }
      , Cmd.none 
      )

    UpdateCountry country ->
      ( { model | country = country }
      , Cmd.none 
      )


-- VIEW

view : Model -> Html Msg
view model =
  layout []
    <|
      column [ width fill ] [
        wrappedRow [ padding 5, spacing 10] [
          Input.text [ alignTop, width ( fillPortion 2 ) ] 
            { onChange = UpdateFirstName
            , text = model.firstName
            , placeholder = Nothing
            , label = Input.labelLeft [ centerY ] ( text "First Name" )
            }
          , Input.text [ alignTop, width ( fillPortion 2 )  ] 
            { onChange = UpdateLastName
            , text = model.lastName
            , placeholder = Nothing
            , label = Input.labelLeft [ centerY ] ( text "Last Name" )
            }
          , column [ alignTop, width ( fillPortion 3 |> minimum 300 )  ] [
            Input.text [ alignRight ] 
              { onChange = UpdateStreet1
              , text = model.street1
              , placeholder = Nothing
              , label = Input.labelLeft [ centerY ] ( text "Address" )
              }
            , Input.text [alignRight] 
              { onChange = UpdateStreet2
              , text = model.street2
              , placeholder = Nothing
              , label = Input.labelHidden "Address line 2"
              }
            , Input.text [alignRight] 
              { onChange = UpdateStreet3
              , text = model.street3
              , placeholder = Nothing
              , label = Input.labelHidden "Address line 3"
              }
          ]
          , Input.text [ alignTop, width ( fillPortion 2 )  ]
            { onChange = UpdateCity
            , text = model.city
            , placeholder = Nothing
            , label = Input.labelLeft [ centerY ] ( text "City" )
            }
          , Input.text [ alignTop, width ( fillPortion 1 )  ]
            { onChange = UpdateState
            , text = model.state
            , placeholder = Nothing
            , label = Input.labelLeft [ centerY ] ( text "State" )
            }
          , Input.text [ alignTop, width ( fillPortion 2 )  ]
            { onChange = UpdatePostalcode
            , text = model.postalCode
            , placeholder = Nothing
            , label = Input.labelLeft [ centerY ] ( text "ZipCode" )
            }
          , Input.text [ alignTop, width ( fillPortion 2 )  ]
            { onChange = UpdateCountry
            , text = model.country
            , placeholder = Nothing
            , label = Input.labelLeft [ centerY ] ( text "Country" )
            }
        ]  
      ]
