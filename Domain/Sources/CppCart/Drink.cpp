//
//  Drink.cpp
//  DCPizza
//
//  Created by Balázs Kilvády on 02/09/21.
//  Copyright © 2021. kil-dev. All rights reserved.
//

#include "Drink.hpp"

namespace cpplib {

Drink::Drink(ID id,
             const string& name,
             double price)
: id(id), name(name.c_str()), price(price)
{}

}
