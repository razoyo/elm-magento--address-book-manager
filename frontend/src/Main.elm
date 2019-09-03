port module Main exposing (..)

import Browser

-- We're using elm-ui for styling
import Element exposing (..)
import Element.Events exposing (onClick)
import Element.Input as Input

-- Elm core modules needed
import Array
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
  
  
newAddress : Address
newAddress = 
  Address -1 "" "" "" "" "" ("","","") "" "" "" "" "" "" False False

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
  | UpdateFirstName String 
  | UpdateLastName String 
  | UpdateMiddleName String
  | UpdatePrefix String
  | UpdateSuffix String
  | UpdateFirstStreet String
  | UpdateSecondStreet String
  | UpdateThirdStreet String
  | UpdateCompany String
  | UpdateTelephone String
  | UpdatePostalCode String
  | UpdateCity String
  | UpdateRegion String
  | UpdateCountry String
  | UpdateIsDefaultShipping Bool 
  | UpdateIsDefaultBilling Bool

update : Msg -> Model -> ( Model, Cmd msg )
update msg model =
  let 
    editAddress = model.editingAddress
  in

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

    UpdateFirstName newFirst ->
      let
        updateAddress = model.editingAddress 
        resultAddress = { updateAddress | firstName = newFirst }
      in
        ( { model | editingAddress = resultAddress }, Cmd.none )

    UpdateLastName newLast->
      let
        updateAddress = model.editingAddress 
        resultAddress = { updateAddress | lastName = newLast }
      in
        ( { model | editingAddress = resultAddress }, Cmd.none )

    UpdateMiddleName newMiddle ->
      let
        updateAddress = model.editingAddress 
        resultAddress = { updateAddress | middleName = newMiddle }
      in
        ( { model | editingAddress = resultAddress }, Cmd.none )

    UpdatePrefix newPrefix ->
      let
        updateAddress = model.editingAddress 
        resultAddress = { updateAddress | prefix = newPrefix }
      in
        ( { model | editingAddress = resultAddress }, Cmd.none )

    UpdateSuffix newSuffix ->
      let
        updateAddress = model.editingAddress 
        resultAddress = { updateAddress | suffix = newSuffix }
      in
        ( { model | editingAddress = resultAddress }, Cmd.none )

    UpdateFirstStreet newStreet ->
      let
        updateAddress = model.editingAddress
        ( a, b, c ) = updateAddress.street
        resultAddress = { updateAddress | street = ( newStreet, b, c ) }
      in
        ( { model | editingAddress = resultAddress }, Cmd.none )

    UpdateSecondStreet newStreet ->
      let
        updateAddress = model.editingAddress
        ( a, b, c ) = updateAddress.street
        resultAddress = { updateAddress | street = ( a, newStreet, c ) }
      in
        ( { model | editingAddress = resultAddress }, Cmd.none )

    UpdateThirdStreet newStreet ->
      let
        updateAddress = model.editingAddress
        ( a, b, c ) = updateAddress.street
        resultAddress = { updateAddress | street = ( a, b, newStreet ) }
      in
        ( { model | editingAddress = resultAddress }, Cmd.none )

    UpdateCompany newCompany ->
      let
        updateAddress = model.editingAddress 
        resultAddress = { updateAddress | company = newCompany }
      in
        ( { model | editingAddress = resultAddress }, Cmd.none )

    UpdateTelephone newPhone ->
      let
        updateAddress = model.editingAddress 
        resultAddress = { updateAddress | telephone = newPhone }
      in
        ( { model | editingAddress = resultAddress }, Cmd.none )

    UpdatePostalCode newPostal ->
      let
        updateAddress = model.editingAddress 
        resultAddress = { updateAddress | postalCode = newPostal }
      in
        ( { model | editingAddress = resultAddress }, Cmd.none )

    UpdateCity newCity ->
      let
        updateAddress = model.editingAddress 
        resultAddress = { updateAddress | city = newCity }
      in
        ( { model | editingAddress = resultAddress }, Cmd.none )

    UpdateRegion newRegion ->
      let
        updateAddress = model.editingAddress 
        resultAddress = { updateAddress | region = newRegion }
      in
        ( { model | editingAddress = resultAddress }, Cmd.none )

    UpdateCountry newCountry ->
      let
        updateAddress = model.editingAddress 
        resultAddress = { updateAddress | country = newCountry }
      in
        ( { model | editingAddress = resultAddress }, Cmd.none )

    UpdateIsDefaultShipping newDefaultShipping ->
      let
        updateAddress = model.editingAddress 
        resultAddress = { updateAddress | isDefaultShipping = newDefaultShipping }
      in
        ( { model | editingAddress = resultAddress }, Cmd.none )

    UpdateIsDefaultBilling newDefaultBilling ->
      let
        updateAddress = model.editingAddress 
        resultAddress = { updateAddress | isDefaultBilling = newDefaultBilling }
      in
        ( { model | editingAddress = resultAddress }, Cmd.none )



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
            , wrappedRow [ width fill, padding 10 ] [ viewEditAddress model.editingAddress ]
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
    wrappedRow [] [ Input.text [] { label = Input.labelLeft [] (text "Prefix")
      , text = address.prefix
      , placeholder = Just (Input.placeholder []( text address.prefix ))
      , onChange = UpdatePrefix
      } 
      , Input.text [] { label = Input.labelLeft [] (text "First Name")
      , text = address.firstName
      , placeholder = Just (Input.placeholder []( text address.firstName ))
      , onChange = UpdateFirstName
      } 
      , Input.text [] { label = Input.labelLeft [] (text "Middle Name")
      , text = address.middleName
      , placeholder = Just (Input.placeholder []( text address.middleName ))
      , onChange = UpdateMiddleName
      }
      , Input.text [] { label = Input.labelLeft [] (text "Last Name")
      , text = address.lastName
      , placeholder = Just (Input.placeholder []( text address.lastName ))
      , onChange = UpdateLastName
      }
      , Input.text [] { label = Input.labelLeft [] (text "Suffix")
      , text = address.suffix
      , placeholder = Just (Input.placeholder []( text address.suffix ))
      , onChange = UpdateSuffix
      } 
    ]
    , composeStreetInputBlock address.street
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


composeStreetBlock : ( String, String, String ) -> Element msg
composeStreetBlock streetAddresses =
  let
     ( a, b, c ) = streetAddresses
  in

  column [] [ el [] (text a) 
    ,  el [] (text b)
    ,  el [] (text c)
    ]


composeStreetInputBlock : ( String, String, String ) -> Element Msg
composeStreetInputBlock streetAddresses =
  let
     ( a, b, c ) = streetAddresses
  in
  column [] [
      Input.text [] { label = Input.labelHidden ""
        , text = a
        , placeholder = Just (Input.placeholder []( text a ))
        , onChange = UpdateFirstStreet
        } 
      , Input.text [] { label = Input.labelHidden ""
        , text = b
        , placeholder = Just (Input.placeholder []( text b ))
        , onChange = UpdateSecondStreet 
        } 
      , Input.text [] { label = Input.labelHidden ""
        , text = c
        , placeholder = Just (Input.placeholder []( text c ))
        , onChange = UpdateThirdStreet 
        } 
    ]
