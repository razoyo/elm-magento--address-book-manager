port module DataShapes exposing (Address, Addresses, newAddress)

import Dict

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

