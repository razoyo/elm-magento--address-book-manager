module Stub exposing (Addresses, Address, addresses)

import Dict

type alias Addresses
  = Dict.Dict Int Address

type alias Address = { mageId: Int
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
  , country: String 
  , isDefaultShipping : Bool
  , isDefaultBilling : Bool
  }
  
  
addresses : Addresses
addresses =
  Dict.fromList
    [ ( 12, Address 12 "Paul" "Byrne" "William" "" "" ["123 Elm"] "Razoyo" "123-555-1212" "75056" "The Colony" "Texas" "United States of America" True False)
    , ( 13, Address 13 "Giancarlo" "Byrne" "" "" "" ["234 Elm", "Suite 205"] "Google" "123-555-1213" "75056" "Frisco" "Texas" "United States of America" False True)
    , ( 14, Address 14 "Lucia" "Byrne" "" "" "" ["% Topo Gigio", "234 Main", "Suite 100"] "RAI" "123-555-1213" "75056" "Lewisville" "Texas" "United States of America" False False )
    ]    


