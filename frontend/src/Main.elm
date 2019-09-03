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
import Stub exposing (..)

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
    , editingAddress : Address
  }


type UIStates = View 
  | AddNew 
  | Edit Int


type AddressField = MageId Int
  | FirstName String 
  | LastName  String
  | MiddleName  String
  | Prefix String
  | Suffix String
  | Street ( List String )
  | Company String
  | Telephone String
  | PostalCode String 
  | City String
  | Region String
  | Country String
  | IsDefaultShipping Bool 
  | IsDefaultBilling Bool
  
  
newAddress : Address
newAddress = 
  Address -1 "" "" "" "" "" [] "" "" "" "" "" "" False False

-- 
init : String -> ( Model, Cmd Msg )
init _ =
  ( { uiStatus = View
    , addresses = addresses
    , editingAddress = newAddress
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
  | SetEditingAddressValue Address AddressField

update : Msg -> Model -> ( Model, Cmd msg )
update msg model =
  case msg of
    Changed message ->
      ( model, Cmd.none )
  -- what to do with Update Msgs
    
    EditAddress addressId ->
      ( { model | uiStatus = Edit addressId
        , editingAddress = Dict.get addressId model.addresses |> \x -> Maybe.withDefault newAddress x  
        }, Cmd.none )

    RemoveAddress addressId ->
      ( { model | 
          addresses = Dict.remove addressId model.addresses
        }
      , Cmd.none ) -- add Cmd to remove address from Magento

    CreateAddress ->
      ( { model | uiStatus = AddNew }, Cmd.none )

    ViewAddresses ->
      ( { model | uiStatus = View }, Cmd.none )

    SetEditingAddressValue address field ->
       case field of 
         MageId _ ->
           ( model, Cmd.none )

         FirstName value ->
           let
             editAddress = { address | firstName = value }
             updateAddresses = Dict.insert address.mageId editAddress model.addresses
           in
             ( { model | addresses = updateAddresses }, Cmd.none )

         LastName value ->
           let
             editAddress = { address | lastName = value }
             updateAddresses = Dict.insert address.mageId editAddress model.addresses
           in
             ( { model | addresses = updateAddresses }, Cmd.none )

         MiddleName value ->
           let
             editAddress = { address | middleName = value }
             updateAddresses = Dict.insert address.mageId editAddress model.addresses
           in
             ( { model | addresses = updateAddresses }, Cmd.none )

         Prefix value ->
           let
             editAddress = { address | prefix = value }
             updateAddresses = Dict.insert address.mageId editAddress model.addresses
           in
             ( { model | addresses = updateAddresses }, Cmd.none )

         Suffix value ->
           let
             editAddress = { address | suffix = value }
             updateAddresses = Dict.insert address.mageId editAddress model.addresses
           in
             ( { model | addresses = updateAddresses }, Cmd.none )

         Street value ->
           let
             editAddress = { address | street = value }
             updateAddresses = Dict.insert address.mageId editAddress model.addresses
           in
             ( { model | addresses = updateAddresses }, Cmd.none )

         Company value ->
           let
             editAddress = { address | company = value }
             updateAddresses = Dict.insert address.mageId editAddress model.addresses
           in
             ( { model | addresses = updateAddresses }, Cmd.none )

         Telephone value ->
           let
             editAddress = { address | telephone = value }
             updateAddresses = Dict.insert address.mageId editAddress model.addresses
           in
             ( { model | addresses = updateAddresses }, Cmd.none )

         PostalCode value ->
           let
             editAddress = { address | postalCode = value }
             updateAddresses = Dict.insert address.mageId editAddress model.addresses
           in
             ( { model | addresses = updateAddresses }, Cmd.none )

         City value ->
           let
             editAddress = { address | city = value }
             updateAddresses = Dict.insert address.mageId editAddress model.addresses
           in
             ( { model | addresses = updateAddresses }, Cmd.none )

         Region value ->
           let
             editAddress = { address | region = value }
             updateAddresses = Dict.insert address.mageId editAddress model.addresses
           in
             ( { model | addresses = updateAddresses }, Cmd.none )

         Country value ->
           let
             editAddress = { address | country = value }
             updateAddresses = Dict.insert address.mageId editAddress model.addresses
           in
             ( { model | addresses = updateAddresses }, Cmd.none )

         IsDefaultShipping value ->
           let
             editAddress = { address | isDefaultShipping = value }
             updateAddresses = Dict.insert address.mageId editAddress model.addresses
           in
             ( { model | addresses = updateAddresses }, Cmd.none )

         IsDefaultBilling value ->
           let
             editAddress = { address | isDefaultBilling = value }
             updateAddresses = Dict.insert address.mageId editAddress model.addresses
           in
             ( { model | addresses = updateAddresses }, Cmd.none )



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


showAddresses : Addresses -> List ( Element Msg )
showAddresses addresses =
  
  Dict.values addresses
    |> \x -> List.map viewAddress x


showAddress : Int -> Addresses -> Element Msg -- May not need this function in final version | only reason to show single address is to edit it
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
    row [] [ Input.text [] { label = Input.labelLeft [] (text "Prefix")
      , text = address.prefix
      , placeholder = Just (Input.placeholder []( text address.prefix ))
      , onChange = SetEditingAddressValue address Prefix
      } 
    ]
    , row [] [ Input.text [] { label = Input.labelLeft [] (text "First Name")
      , text = address.firstName
      , placeholder = Just (Input.placeholder []( text address.firstName ))
      , onChange = ( SetEditingAddressValue FirstName )
      } 
    ]
    , text ( composeName address )
    , composeStreetBlock address.street
    , row [] [ el [] (text address.city)
      , el [] (text address.region)
      , el [] (text address.postalCode)
    ]
    , el [] (text address.country)
    , el [ onClick (RemoveAddress address.mageId) ] (text "remove")
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
