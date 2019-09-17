port module MageComm exposing (getAddresses, normalizeStreetBlock, addressDecoder, addressPostEncode)

import Dict
import Http
import Json.Decode as Decode exposing (Decoder, field, string, int, bool, value, null, oneOf)
import Json.Encode as Encode exposing (Value)
import Json.Decode.Pipeline exposing (required, optional, hardcoded)

import DataShapes exposing (Address, Addresses, newAddress)


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

