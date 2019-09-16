port module Main exposing (..)

import Browser

-- We're using elm-ui for styling
import Element exposing (..)
import Element.Background as Background
import Element.Events exposing (onClick)
import Element.Input as Input
import Element.Font as Font

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
import Validate exposing (stateOptions)

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
    , suggestRegion : String
    , cookie : { sessionId: String , formKey: String }
  }


type UIStates = View 
  | AddNew 
  | Edit
  
type alias Addresses
  = Dict.Dict String Address

type alias Address = { mageId: String
  , firstName: String
  , lastName: String
  , middleName: String
  , prefix: String
  , suffix: String
  , street: List String
  , company: String
  , telephone: String
  , postalCode: String
  , city: String
  , region: String
  , regionId: Int
  , country: String 
  , isDefaultShipping : Bool
  , isDefaultBilling : Bool
  }
              
newAddress : Address
newAddress = 
  Address "new" "" "" "" "" "" ["","",""] "" "" "" "" "" 0 "US" False False


-- 
init : String -> ( Model, Cmd Msg )
init cookie =
  ( { uiStatus = View
    , addresses = Dict.empty 
    , editingAddress = newAddress
    , suggestRegion = ""
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
  | AcceptRegionSuggestion
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
      ( { model | uiStatus = View
        , suggestRegion = "" }, Cmd.none )

    SaveNewAddress ->
      let
        regionId = lookUpRegionId editAddress.region
        editAddressWithRegion = { editAddress | regionId = (String.toInt regionId |> Maybe.withDefault 0) }
        checkedAddresses = ensureUniqueDefaults editAddressWithRegion model.addresses
        updatedAddresses = Dict.insert "new" editAddressWithRegion checkedAddresses
      in
      ( { model | addresses = updatedAddresses
        , uiStatus = View }
      , Http.post {
        url = "/customer/address/formPost"
        , body = addressPostEncode model.cookie editAddressWithRegion
        , expect = Http.expectWhatever Posted
        } 
      )

    SaveEditedAddress id ->
      let
        checkedAddresses = ensureUniqueDefaults editAddress model.addresses
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
        resultAddress = { editAddress | firstName = newFirst }
      in
        ( { model | editingAddress = resultAddress }, Cmd.none )

    UpdateLastName newLast->
      let
        resultAddress = { editAddress | lastName = newLast }
      in
        ( { model | editingAddress = resultAddress }, Cmd.none )

    UpdateMiddleName newMiddle ->
      let
        resultAddress = { editAddress | middleName = newMiddle }
      in
        ( { model | editingAddress = resultAddress }, Cmd.none )

    UpdatePrefix newPrefix ->
      let
        resultAddress = { editAddress | prefix = newPrefix }
      in
        ( { model | editingAddress = resultAddress }, Cmd.none )

    UpdateSuffix newSuffix ->
      let
        resultAddress = { editAddress | suffix = newSuffix }
      in
        ( { model | editingAddress = resultAddress }, Cmd.none )

    UpdateStreet index newStreet ->
      let
        streets = List.indexedMap (\x y -> if x == index then newStreet else y) model.editingAddress.street
        resultAddress = { editAddress | street = streets }
      in
        ( { model | editingAddress = resultAddress }, Cmd.none )

    UpdateCompany newCompany ->
      let
        resultAddress = { editAddress | company = newCompany }
      in
        ( { model | editingAddress = resultAddress }, Cmd.none )

    UpdateTelephone newPhone ->
      let
        resultAddress = { editAddress | telephone = newPhone }
      in
        ( { model | editingAddress = resultAddress }, Cmd.none )

    UpdatePostalCode newPostal ->
      let
        resultAddress = { editAddress | postalCode = newPostal }
      in
        ( { model | editingAddress = resultAddress }, Cmd.none )

    UpdateCity newCity ->
      let
        resultAddress = { editAddress | city = newCity }
      in
        ( { model | editingAddress = resultAddress }, Cmd.none )

    UpdateRegion newRegion ->
      let
        regionOptions = stateOptions -- add option for Canada
        suggestRegion = 
          if ( String.length newRegion ) > 1 then
            List.head ( Dict.toList ( Dict.filter (\x y -> String.contains newRegion y )  regionOptions )) 
              |> Maybe.withDefault ( "","" )
              |> Tuple.second
          else ""
        resultAddress = { editAddress | region = newRegion }
      in
        ( { model | editingAddress = resultAddress
          , suggestRegion = suggestRegion 
          }, Cmd.none 
        )

    AcceptRegionSuggestion ->
      let
        resultAddress = { editAddress | region = model.suggestRegion }
      in
      ( { model | editingAddress = resultAddress }, Cmd.none )

    UpdateCountry newCountry ->
      let
        resultAddress = { editAddress | country = newCountry }
      in
        ( { model | editingAddress = resultAddress }, Cmd.none )

    UpdateIsDefaultShipping newDefaultShipping ->
      let
        resultAddress = { editAddress | isDefaultShipping = newDefaultShipping }
      in

      ( { model | editingAddress = resultAddress }, Cmd.none )

    UpdateIsDefaultBilling newDefaultBilling ->
      let
        resultAddress = { editAddress | isDefaultBilling = newDefaultBilling }
      in
        ( { model | editingAddress = resultAddress }, Cmd.none )

    Posted result ->
      let
        debug = 
          case result of 
            Err e ->
                "Error"

            Ok v ->
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


lookUpRegionId : String -> String
lookUpRegionId region =
  Dict.filter (\x y -> y == region ) stateOptions
    |> Dict.toList
    |> List.head
    |> Maybe.withDefault ("", "")
    |> Tuple.first


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
  layout [ width fill, padding 5 ]
    <|
      case model.uiStatus of
        View ->
          column [ width fill ] [ 
            row [ width fill, spacing 10 ] [ el [ alignRight, onClick CreateAddress ] (text "Add New") ] 
            , wrappedRow [ width fill, spacing 10, padding 10 ] ( showAddresses model.addresses ) 
            ]

        AddNew ->
          column [ width fill ] [ row [ width fill ] [ el [ alignRight, onClick ViewAddresses ] (text "X") ] 
            , wrappedRow [ width fill, spacing 15 ] [ viewEditAddress model model.editingAddress ]
            , wrappedRow [ spacing 25, width fill ] [ renderButton model SaveNew
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
  column [ width ( fill |> minimum 250 )
    , alignTop
    , spacing 15 ] 
    [ wrappedRow [ spacing 20, Font.color blue, width fill ] [
      ( if address.isDefaultShipping then 
          el [] (text "Default Shipping")  
        else none 
        )
      , ( if address.isDefaultBilling then 
          el [] ( text "Default Billing")  
          else none 
      )
    ]
    , text ( composeName address )
    , column [ spacing 10 ] (List.map (\x -> el [] (text x)) address.street)
    , wrappedRow [ spacing 10, width fill ] [ el [] (text ( address.city ++ ",") )
      , el [] (text address.region)
      , el [] (text address.postalCode)
    ]
    , el [] (text address.country)
    , wrappedRow [ Font.color blue, spacing 20, Font.size 14, width fill ] [
      el [ onClick (RemoveAddress address.mageId) ] (text "remove")
      , el [ onClick (EditAddress address.mageId) ] (text "edit")
      ]
  ]


viewEditAddress : Model -> Address -> Element Msg
viewEditAddress model address =
  column [ width fill, alignTop, spacing 5 ] [
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
    , wrappedRow [ spacing 5, width fill ] [ Input.text [ htmlAttribute (Html.Attributes.id "city"), alignTop ] 
      { label = Input.labelAbove [ alignTop ] (text "City")
      , text = address.city
      , placeholder = Just (Input.placeholder []( text address.city ))
      , onChange = UpdateCity
      }
    , column [ width ( fill |> minimum 150 ) ] [ Input.text [ htmlAttribute (Html.Attributes.id "region"), alignTop ] 
        { label = Input.labelAbove [] (text (if address.country == "US" then "State" else "Provence"))
        , text = address.region
        , placeholder = Nothing
        , onChange = UpdateRegion
        } 
      , el [ onClick AcceptRegionSuggestion, padding 12 ] (text model.suggestRegion) 
    ]
    , Input.text [ htmlAttribute (Html.Attributes.id "post_code")
        , alignTop
        , width (fill |> maximum 100 )
        ] 
      { label = Input.labelAbove [ width fill ] (text "Post")
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
  row [ width (fill |> maximum 360) ] [
    column [ width fill, spacing 5 ] (
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
  ]

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
              let
                debug = Debug.log "decoded" v
              in
              List.map ( \x -> ( x.mageId, normalizeStreetBlock x ) ) v |> Dict.fromList
          Err e ->
              let
                debug = Debug.log "decode error" e
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
    |> required "region_id" int
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
      , Http.stringPart "region_id" (String.fromInt address.regionId)
      , Http.stringPart "region" address.region
      , Http.stringPart "postcode" address.postalCode
      , Http.stringPart "country_id" "US"
      , Http.stringPart "default_billing" (if address.isDefaultBilling then "1" else "0")
      , Http.stringPart "default_shipping" (if address.isDefaultShipping then "1" else "0")
      ]


-- Styles

blue = Element.rgb255 100 100 238

gray = Element.rgb255 155 155 155

green = Element.rgb255 100 238 100

countryButton : String -> Model -> List ( Element.Attribute msg )
countryButton country model =
  let
    pad = padding 15
  in
  if model.editingAddress.country == country then
    [ Background.color green, pad ]

  else
    [ Background.color gray, pad ]

