module Stub exposing (Addresses, Address, addresses, httpResult)

import Dict
import Json.Encode as Encode

type alias Addresses
  = Dict.Dict Int Address

type alias Address = { mageId: Int
  , first_name: String
  , last_name: String
  , middle_name: String
  , prefix: String
  , suffix: String
  , street: ( String, String, String )
  , company: String
  , telephone: String
  , postal_code: String
  , city: String
  , region: String
  , country: String 
  , isDefaultShipping : Bool
  , isDefaultBilling : Bool
  }
  
  
addresses : Addresses
addresses =
  Dict.fromList
    [ ( 12, Address 12 "Paul" "Byrne" "William" "" "" ("123 Elm", "", "") "Razoyo" "123-555-1212" "75056" "The Colony" "Texas" "United States of America" True False)
    , ( 13, Address 13 "Giancarlo" "Byrne" "" "" "" ("234 Elm", "Suite 205", "") "Google" "123-555-1213" "75056" "Frisco" "Texas" "United States of America" False True)
    , ( 14, Address 14 "Lucia" "Byrne" "" "" "" ("% Topo Gigio", "234 Main", "Suite 100") "RAI" "123-555-1213" "75056" "Lewisville" "Texas" "United States of America" False False )
    ]    

httpResult =
   Encode.string """[{"id":"1","customer_id":"1","first_name":"Veronica","middle_name":null,"last_name":"Costello","prefix":null,"suffix":null,"company":null,"street":["6146 Honey Bluff Parkway"],"city":"Calder","region":"Michigan","region_code":"MI","region_id":33,"postcode":"49628-7978","country_id":"US","telephone":"(555) 229-3326","vat_id":null,"is_default_billing":true,"is_default_shipping":null},{"id":"3","customer_id":"1","first_name":"Veronica","middle_name":null,"last_name":"Costello","prefix":null,"suffix":null,"company":null,"street":["123 Elm"],"city":"The Colony","region":"Texas","region_code":"TX","region_id":57,"postcode":"75056","country_id":"US","telephone":"990-555-1212","vat_id":null,"is_default_billing":null,"is_default_shipping":true}]"""
