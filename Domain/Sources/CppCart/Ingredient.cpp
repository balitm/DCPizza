//
//  Ingredient.cpp
//  DCPizza
//
//  Created by Balázs Kilvády on 02/09/21.
//  Copyright © 2021. kil-dev. All rights reserved.
//

#include "Ingredient.hpp"

namespace cpplib {

Ingredient::Ingredient(ID id,
                       const string& name,
                       double price)
: id(id), name(name), price(price) {}

}
