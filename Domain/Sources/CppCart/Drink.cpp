//
//  Drink.cpp
//  DCPizza
//
//  Created by Balázs Kilvády on 02/09/21.
//  Copyright © 2021. kil-dev. All rights reserved.
//

#include "Drink.hpp"
#include <iostream>

namespace cpplib {

Drink::Drink(ID id,
             const string& name,
             double price)
: id(id), name(name), price(price)
{
    std::cout << "Drink created with: ("
    << id << ", "
    << name << ", "
    << price << ")\n";
}

Drink::~Drink()
{
    std::cout << "Drink destroyed with: ("
    << id << ", "
    << name << ", "
    << price << ")\n";
}

}
