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
import Http
import Json.Decode as Decode exposing (Decoder, field, string, int, bool, value, null, oneOf)
import Json.Encode as Encode exposing (Value)
import Json.Decode.Pipeline exposing (required, optional, hardcoded)

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


-- MODEL

type alias Model = {
    uiStatus : UIStates
    , addresses : Addresses
    , editingAddress : Address
    , cookie : { sessionId: String , formKey: String }
  }


type UIStates = View 
  | AddNew 
  | Edit
  
  
newAddress : Address
newAddress = 
  Address "-1" "" "" "" "" "" ["","",""] "" "" "" "" "" "" False False


-- 
init : String -> ( Model, Cmd Msg )
init cookie =
  let
    debug = Debug.log "parsed cookie" ( cookieParse cookie )
  in
  ( { uiStatus = View
    , addresses = Dict.empty 
    , editingAddress = newAddress
    , cookie = cookieParse cookie
    } 
  , Http.get { url = "/razoyo/customer/addresses/"
    , expect =  Http.expectString LoadAddresses
    } )



-- UPDATE

type Msg = Changed Value
  | LoadAddresses (Result Http.Error String)
  | RemoveAddress String
  | EditAddress String
  | CreateAddress
  | ViewAddresses
  | SaveAddressUpdate String
  | UpdateFirstName String 
  | UpdateLastName String 
  | UpdateMiddleName String
  | UpdatePrefix String
  | UpdateSuffix String
  | UpdateStreet Int String
  | UpdateCompany String
  | UpdateTelephone String
  | UpdatePostalCode String
  | UpdateCity String
  | UpdateRegion String
  | UpdateCountry String
  | UpdateIsDefaultShipping Bool 
  | UpdateIsDefaultBilling Bool
  | Posted (Result Http.Error ())


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
  let 
    editAddress = model.editingAddress
  in

  case msg of
    Changed message ->
      ( model, Cmd.none )
  -- what to do with Update Msgs

    LoadAddresses result ->
      ( { model | addresses = getAddresses result }, Cmd.none )

    EditAddress addressId ->
      ( { model | uiStatus = Edit
        , editingAddress = Dict.get addressId model.addresses |> \x -> Maybe.withDefault newAddress x  
        }, Cmd.none )

    RemoveAddress addressId ->
      ( { model | addresses = Dict.remove addressId model.addresses
        }
      , Http.post {
        url = "/customer/address/delete/id/" ++ addressId ++ "/form_key/" ++ model.cookie.formKey
        , body = Http.emptyBody 
        , expect = Http.expectWhatever Posted
        } 
      )

    CreateAddress ->
      ( { model | uiStatus = AddNew
        , editingAddress = newAddress }, Cmd.none )

    ViewAddresses ->
      ( { model | uiStatus = View }, Cmd.none )

    SaveAddressUpdate addressId ->
      let
        checkedAddresses = ensureUniqueDefaults model.editingAddress model.addresses
        updatedAddresses = Dict.insert addressId model.editingAddress checkedAddresses
      in
      ( { model | addresses = updatedAddresses
        , uiStatus = View }
      , Http.post {
        url = "/customer/address/formPost"
        , body = Http.jsonBody ( addressPostEncode model.cookie model.editingAddress ) 
        , expect = Http.expectWhatever Posted
        } 
      )

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

    UpdateStreet index newStreet ->
      let
        streets = List.indexedMap (\x y -> if x == index then newStreet else y) model.editingAddress.street
        updateAddress = model.editingAddress
        resultAddress = { updateAddress | street = streets }
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

    Posted result ->
      let
        debug = 
          case result of 
            Err e ->
              let
                x = Debug.log "Post error" e
              in
                "Error"

            Ok v ->
              let
                x = Debug.log "Post success" v
              in
                "OK"

      in
      ( model, Cmd.none )


ensureUniqueDefaults : Address -> Addresses  -> Addresses
ensureUniqueDefaults editingAddress addresses =
  addresses 
    |> (\a -> if editingAddress.isDefaultBilling then clearBilling a else a)
    |> (\a -> if editingAddress.isDefaultShipping then clearShipping a else a)


clearBilling : Addresses -> Addresses
clearBilling addresses =
  Dict.map (\_ v -> { v | isDefaultBilling = False }) addresses


clearShipping : Addresses -> Addresses
clearShipping addresses =
  Dict.map (\_ v -> { v | isDefaultShipping = False }) addresses  

cookieParse : String -> {sessionId: String, formKey: String}
cookieParse cookie =
  let

    cookieList = String.split "; " cookie
      |> List.map (\x -> String.split "=" x)

    sessId = List.filter (\x -> List.member "PHPSESSID" x) cookieList
      |> List.head
      |> Maybe.withDefault []
      |> List.reverse
      |> List.head
      |> Maybe.withDefault ""

    formKey = List.filter (\x -> List.member "form_key" x) cookieList
      |> List.head
      |> Maybe.withDefault []
      |> List.reverse
      |> List.head
      |> Maybe.withDefault ""

  in
  { sessionId = sessId, formKey = formKey }



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
            , wrappedRow [ width fill, padding 10 ] [ viewEditAddress model.editingAddress ]
            ]

        Edit ->
          column [ width fill ] [ row [ width fill ] [ el [ alignRight, onClick ViewAddresses ] (text "X") ] 
            , wrappedRow [ width fill, padding 10 ] [ viewEditAddress model.editingAddress ]
          ]


showAddresses : Addresses -> List ( Element Msg )
showAddresses addresses =
  
  Dict.values addresses
    |> \x -> List.map viewAddress x


showAddress : String -> Addresses -> Element Msg -- May not need this function in final version | only reason to show single address is to edit it
showAddress addressId addresses =
  
  Dict.get addressId addresses
    |> \y -> Maybe.withDefault newAddress y
    |> \x -> viewEditAddress x


viewAddress : Address -> Element Msg
viewAddress address =
  column [ width fill, spacing 10, padding 5, alignTop ] [
     text ( composeName address )
     , column [] (List.map (\x -> el [] (text x)) address.street)
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
    wrappedRow [ width fill, spacing 5 ] [ Input.text [ width (fillPortion 1) ] { label = Input.labelAbove [] (text "Prefix")
      , text = address.prefix
      , placeholder = Just (Input.placeholder []( text address.prefix ))
      , onChange = UpdatePrefix
      } 
      , Input.text [ width (fillPortion 3) ] { label = Input.labelAbove [] (text "First Name")
      , text = address.firstName
      , placeholder = Just (Input.placeholder []( text address.firstName ))
      , onChange = UpdateFirstName
      } 
      , Input.text [ width (fillPortion 3) ] { label = Input.labelAbove [] (text "Middle Name")
      , text = address.middleName
      , placeholder = Just (Input.placeholder []( text address.middleName ))
      , onChange = UpdateMiddleName
      }
      , Input.text [ width (fillPortion 3) ] { label = Input.labelAbove [] (text "Last Name")
      , text = address.lastName
      , placeholder = Just (Input.placeholder []( text address.lastName ))
      , onChange = UpdateLastName
      }
      , Input.text [ width (fillPortion 1) ] { label = Input.labelAbove [] (text "Suffix")
      , text = address.suffix
      , placeholder = Just (Input.placeholder []( text address.suffix ))
      , onChange = UpdateSuffix
      } 
    ]
    , composeStreetInputBlock address.street
    , row [ spacing 5, padding 5 ] [ Input.text [ htmlAttribute (Html.Attributes.id "city") ] { label = Input.labelAbove [] (text "City")
      , text = address.city
      , placeholder = Just (Input.placeholder []( text address.city ))
      , onChange = UpdateCity
      } 
    , Input.text [ htmlAttribute (Html.Attributes.id "region") ] { label = Input.labelAbove [] (text "Region/State")
      , text = address.region
      , placeholder = Just (Input.placeholder []( text address.region ))
      , onChange = UpdateRegion
      } 
    , Input.text [ htmlAttribute (Html.Attributes.id "post_code") ] { label = Input.labelAbove [] (text "PostalCode")
      , text = address.postalCode
      , placeholder = Just (Input.placeholder []( text address.postalCode ))
      , onChange = UpdatePostalCode
      } 
    ]
    , row [width ( fill |> maximum 350 ), spacing 5] [ Input.text [] { label = Input.labelAbove [] (text "Country")
      , text = address.country
      , placeholder = Just (Input.placeholder [ htmlAttribute (Html.Attributes.id "country") ] ( text address.country ))
      , onChange = UpdateCountry
      }
    ]
    , row [ spacing 10 ] [ Input.checkbox [] { label = Input.labelRight [ padding 10 ] (text "Default Shipping")
      , onChange = UpdateIsDefaultShipping
      , icon = Input.defaultCheckbox
      , checked = address.isDefaultShipping
      }
      , Input.checkbox [] { label = Input.labelRight [ padding 10 ] (text "Default Billing")
        , onChange = UpdateIsDefaultBilling
        , icon = Input.defaultCheckbox
        , checked = address.isDefaultBilling
      }
    ]
    , row [ spacing 25, padding 5 ] [ Input.button [] { onPress = Just ( SaveAddressUpdate address.mageId )
      , label = text "Save Changes"
      }
      , el [ onClick (RemoveAddress address.mageId) ] (text "remove")
    ]
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


composeStreetInputBlock : List String -> Element Msg
composeStreetInputBlock streetAddresses =
  column [ width ( fill |> maximum 350 ), spacing 5 ] (
      List.indexedMap (\x y -> ( 
        Input.text [ width fill
          , htmlAttribute (Html.Attributes.id ("street_" ++ ( String.fromInt x )) )
          ] { label = (if x == 0 then Input.labelAbove [] ( text "Street" ) else Input.labelHidden "")
            , text = y
            , placeholder = Just (Input.placeholder []( text y ))
            , onChange = UpdateStreet x
            }
        ) ) streetAddresses 
    )



--- HTTP

getAddresses : (Result Http.Error String) -> Addresses
getAddresses result =
  let 
    emptyDict = Dict.insert "-1" newAddress Dict.empty
  in
    case result of
      Ok jsonAddresses ->
        case Decode.decodeString (Decode.list addressDecoder) jsonAddresses of
          Ok v ->
              List.map ( \x -> ( x.mageId, normalizeStreetBlock x ) ) v |> Dict.fromList
          Err e ->
            let
              _ = Debug.log "not decoded!" e
            in
              emptyDict

      Err _ -> 
        emptyDict


normalizeStreetBlock : Address -> Address
normalizeStreetBlock address =
      { address | street =  (address.street ++ List.repeat (3 - (List.length address.street)) "") }


addressDecoder : Decoder Address
addressDecoder =
  Decode.succeed Address
    |> required "id" string
    |> required "first_name" string 
    |> required "last_name" string 
    |> optional "middle_name" (oneOf [ string, null "" ]) ""
    |> optional "prefix" (oneOf [ string, null "" ]) ""
    |> optional "suffix" (oneOf [ string, null "" ]) ""
    |> required "street" (Decode.list string)
    |> optional "company" (oneOf [ string, null "" ]) ""
    |> optional "telephone" (oneOf [ string, null "" ]) ""
    |> required "postcode" string
    |> required "city" string
    |> required "region" string
    |> required "country_id" string
    |> required "is_default_shipping" (oneOf [ bool, null False ])
    |> required "is_default_billing" (oneOf [ bool, null False ])


addressPostEncode : { sessionId : String, formKey : String } -> Address -> Value
addressPostEncode sessionData address =
  Encode.object [ ( "form_key", Encode.string sessionData.formKey )
    , ( "PHPSESSID", Encode.string sessionData.sessionId )
    , ( "first_name",  Encode.string address.firstName ) 
    , ( "last_name", Encode.string address.lastName ) 
    , ( "middle_name", Encode.string address.middleName )
    , ( "prefix", Encode.string address.prefix )
    , ( "suffix", Encode.string address.suffix )
    , ( "street", Encode.string (Encode.encode 0 (Encode.list Encode.string address.street) ))
    , ( "company", Encode.string address.company)
    , ( "telephone", Encode.string address.telephone )
    , ( "postcode", Encode.string address.postalCode )
    , ( "city", Encode.string address.city )
    , ( "region", Encode.string address.region )
    , ( "country_id", Encode.string address.country )
    , ( "is_default_shipping", Encode.bool address.isDefaultShipping )
    , ( "is_default_billing", Encode.bool address.isDefaultBilling )
  ]
