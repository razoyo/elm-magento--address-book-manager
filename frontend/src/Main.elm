port module Main exposing (..)

import Browser

-- We're using elm-ui for styling
import Element exposing (..)
import Element.Background as Background
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
  Address "new" "" "" "" "" "" ["","",""] "" "" "" "" "" "" False False


-- 
init : String -> ( Model, Cmd Msg )
init cookie =
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
  | SaveNewAddress
  | SaveEditedAddress String
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
      let
        debug = Debug.log "getting the Dict" model.addresses
      in
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

    SaveNewAddress ->
      let
        checkedAddresses = ensureUniqueDefaults model.editingAddress model.addresses
        updatedAddresses = Dict.insert "new" model.editingAddress checkedAddresses
      in
      ( { model | addresses = updatedAddresses
        , uiStatus = View }
      , Http.post {
        url = "/customer/address/formPost"
        , body = addressPostEncode model.cookie model.editingAddress
        , expect = Http.expectWhatever Posted
        } 
      )

    SaveEditedAddress id ->
      let
        checkedAddresses = ensureUniqueDefaults model.editingAddress model.addresses
        updatedAddresses = Dict.insert id model.editingAddress checkedAddresses
      in
      ( { model | addresses = updatedAddresses
        , uiStatus = View }
      , Http.request {
        method = "POST"
        , url = "/customer/address/formPost/id/" ++ id ++ "/"
        , body = addressPostEncode model.cookie model.editingAddress
        , headers = 
          [ Http.header "Accept" "text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3"
          , Http.header "Accept-Language" "en-US,en;q=0.9,it;q=0.8,fr;q=0.7"
          , Http.header "Cache-Control" "max-age=0"
          , Http.header "Upgrade-Insecure-Requests" "1"
          ]
        , expect = Http.expectWhatever Posted
        , timeout = Nothing
        , tracker = Nothing
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

type ButtonAction = Update
  | SaveNew

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
            , wrappedRow [ width fill, padding 15 ] [ viewEditAddress model model.editingAddress ]
            , wrappedRow [ spacing 25, padding 15 ] [ renderButton model SaveNew
            , el [ onClick ViewAddresses ] (text "cancel")
            ]
          ]

        Edit ->
          column [ width fill ] [ row [ width fill ] [ el [ alignRight, onClick ViewAddresses ] (text "X") ] 
            , wrappedRow [ width fill, padding 10 ] [ viewEditAddress model model.editingAddress ]
            , wrappedRow [ spacing 25, padding 15 ] [ renderButton model Update
            , el [ onClick (RemoveAddress model.editingAddress.mageId) ] (text "remove")
            , el [ onClick ViewAddresses ] (text "cancel")
            ]
          ]


showAddresses : Addresses -> List ( Element Msg )
showAddresses addresses =
  if Dict.size addresses == 0 then
    [
      column [ width fill, height (px 300) ] [
        el [ centerX, centerY ] ( text "You have no addresses" )
      ]
    ]
  else
     
  Dict.values addresses
    |> \x -> List.map viewAddress x


viewAddress : Address -> Element Msg
viewAddress address =
  let
    debug = Debug.log "view address ID" address.mageId
  in
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


viewEditAddress : Model -> Address -> Element Msg
viewEditAddress model address =
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
    , row [width ( fill |> maximum 350 ), spacing 5] [ 
      Input.button ( countryButton "US" model )
        { onPress = Just ( UpdateCountry "US" )
        , label = ( text "United States" )
        }
      , Input.button ( countryButton "CA" model )
        { onPress = Just ( UpdateCountry "CA" )
        , label = ( text "Canada" )
        }
    ]
    , row [width ( fill |> maximum 350 ), spacing 5] [ Input.text [] { label = Input.labelAbove [] (text "Telephone")
      , text = address.telephone
      , placeholder = Just (Input.placeholder [ htmlAttribute (Html.Attributes.id "telehpone") ] ( text address.telephone ))
      , onChange = UpdateTelephone
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


renderButton : Model -> ButtonAction -> Element Msg
renderButton  model action =
  let
    address = model.editingAddress

    buttonStatus =
      String.length address.firstName > 0
      && String.length address.lastName > 0
      && String.length ( List.head address.street |> Maybe.withDefault "" ) > 0
      && String.length address.city > 0
      && String.length address.region > 1
      && String.length address.postalCode > 4
      && String.length address.country > 1
      && String.length address.telephone > 1

    ( buttonAction, buttonMessage ) =
      case action of
        Update ->
          ( Just ( SaveEditedAddress address.mageId ), "Save Edits" )

        SaveNew -> 
          ( Just ( SaveNewAddress ), "Create Address" )
  in
    case buttonStatus of
      True ->
         Input.button [ padding 15
          , Background.color blue ] 
          { onPress = buttonAction
          , label = text buttonMessage
          }

      False ->
        Input.button [ padding 15
          , Background.color gray ] 
          { onPress = Nothing
          , label = text buttonMessage
          }


--- HTTP

getAddresses : (Result Http.Error String) -> Addresses
getAddresses result =
  let 
    emptyDict = Dict.empty --Dict.insert "-1" newAddress Dict.empty
  in
    case result of
      Ok jsonAddresses ->
        case Decode.decodeString (Decode.list addressDecoder) jsonAddresses of
          Ok v ->
              List.map ( \x -> ( x.mageId, normalizeStreetBlock x ) ) v |> Dict.fromList
          Err e ->
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


addressPostEncode : { sessionId : String, formKey : String } -> Address -> Http.Body
addressPostEncode sessionData address =
  let
    (street1, street2, street3) =
      case address.street of
        [s1, s2, s3] -> (s1, s2, s3)
        _ -> ("", "", "")
  in
    Http.multipartBody 
      [ Http.stringPart "form_key" sessionData.formKey
      , Http.stringPart "firstname" address.firstName
      , Http.stringPart "lastname" address.lastName
      , Http.stringPart "company" address.company
      , Http.stringPart "telephone" address.telephone
      , Http.stringPart "street[]" street1
      , Http.stringPart "street[]" street2
      , Http.stringPart "street[]" street3
      , Http.stringPart "vat_id" ""
      , Http.stringPart "city" address.city
      , Http.stringPart "region_id" "57"
      , Http.stringPart "region" "TX"
      , Http.stringPart "postcode" address.postalCode
      , Http.stringPart "country_id" "US"
      , Http.stringPart "default_billing" (if address.isDefaultBilling then "1" else "0")
      , Http.stringPart "default_shipping" (if address.isDefaultShipping then "1" else "0")
      ]


-- Styles

blue = Element.rgb255 155 155 238

gray = Element.rgb255 155 155 155

green = Element.rgb255 155 238 155

countryButton : String -> Model -> List ( Element.Attribute msg )
countryButton country model =
  let
    pad = padding 15
  in
  if model.editingAddress.country == country then
    [ Background.color green, pad ]

  else
    [ Background.color gray, pad ]

