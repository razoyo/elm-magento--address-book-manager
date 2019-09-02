port module Main exposing (..)

import Browser

-- We're using elm-ui for styling
import Element exposing (..)
import Element.Events exposing (onClick)
import Element.Input as Input

-- Elm core modules needed
import Dict
import Html exposing (Html)
import Html.Attributes
import Json.Decode as Decode exposing (Decoder, field, string, int, map, value)
import Json.Encode exposing (Value)

-- Local app imports
import Stub exposing (Address)

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
    uiStatus : UIStates
    , addresses : Stub.Addresses
  }


type UIStates = View 
  | AddNew 
  | Edit Int


newAddress : Address
newAddress = 
  Address -1 "" "" "" "" "" [] "" "" "" "" "" "" False False

-- 
init : String -> ( Model, Cmd Msg )
init _ =
  ( { uiStatus = View
    , addresses = Stub.addresses
    } 
   , Cmd.none -- this will be the command to return the addresses from Magento in production
   )
  -- return model and inital command

-- UPDATE

type Msg = Changed Value
  | RemoveAddress Int
  | EditAddress Int
  | CreateAddress
  | ViewAddresses

update : Msg -> Model -> ( Model, Cmd msg )
update msg model =
  case msg of
    Changed message ->
      ( model, Cmd.none )
  -- what to do with Update Msgs
    
    EditAddress addressId ->
      ( { model | uiStatus = Edit addressId }, Cmd.none )

    RemoveAddress addressId ->
      ( { model | 
          addresses = Dict.remove addressId model.addresses
        }
      , Cmd.none ) -- add Cmd to remove address from Magento

    CreateAddress ->
      ( { model | uiStatus = AddNew }, Cmd.none )

    ViewAddresses ->
      ( { model | uiStatus = View }, Cmd.none )


-- VIEW

view : Model -> Html Msg
view model =
  layout []
    <|
      case model.uiStatus of
        View ->
          column [ width fill ] [ row [ width fill ] [ el [ alignRight, onClick CreateAddress ] (text "Add New") ] 
            , wrappedRow [ width fill, padding 10 ] ( showAddresses model.addresses ) 
            ]

        AddNew ->
          column [ width fill ] [ row [ width fill ] [ el [ alignRight, onClick ViewAddresses ] (text "X") ] 
            , wrappedRow [] [ el [] (text "Add New Address") ]
            ]

        Edit addressId ->
          column [ width fill ] [ row [ width fill ] [ el [ alignRight, onClick ViewAddresses ] (text "X") ] 
            , wrappedRow [ width fill, padding 10 ] [ showAddress addressId model.addresses ]
          ]


showAddresses : Stub.Addresses -> List ( Element Msg )
showAddresses addresses =
  
  Dict.values addresses
    |> \x -> List.map viewAddress x


showAddress : Int -> Stub.Addresses -> Element Msg -- May not need this function in final version | only reason to show single address is to edit it
showAddress addressId addresses =
  
  Dict.get addressId addresses
    |> \y -> Maybe.withDefault newAddress y
    |> \x -> viewEditAddress x


viewAddress : Address -> Element Msg
viewAddress address =
  column [ width fill, spacing 10, padding 5, alignTop ] [
     text ( composeName address )
     , composeStreetBlock address.street
     , row [] [ el [] (text address.city)
       , el [] (text address.region)
       , el [] (text address.postalCode)
     ]
     , el [] (text address.country)
     , (if address.isDefaultShipping then (el [] (text "Default Shipping"))  else none)
     , (if address.isDefaultBilling then (el [] (text "Default Billing"))  else none)
     , el [ onClick (RemoveAddress address.mageId) ] (text "remove")
     , el [ onClick (EditAddress address.mageId) ] (text "edit")
     ]


viewEditAddress : Address -> Element Msg
viewEditAddress address =
  column [ width fill, spacing 10, padding 5, alignTop ] [
     text ( composeName address )
     , composeStreetBlock address.street
     , row [] [ el [] (text address.city)
       , el [] (text address.region)
       , el [] (text address.postalCode)
     ]
     , el [] (text address.country)
     , el [ onClick (RemoveAddress address.mageId) ] (text "remove")
     , el [ onClick (EditAddress address.mageId) ] (text "edit")
     ]


composeName : Address -> String
composeName address =
  address.prefix
  ++ if address.prefix /= "" then " " else ""
  ++ address.firstName
  ++ " "
  ++ address.middleName
  ++ if address.middleName /= "" then " " else ""
  ++ address.lastName
  ++ if address.suffix /= "" then " " else ""
  ++ address.suffix


composeStreetBlock : List String -> Element msg
composeStreetBlock streetAddresses =
  column [] ( List.map (\x -> el [] (text x) ) streetAddresses )
