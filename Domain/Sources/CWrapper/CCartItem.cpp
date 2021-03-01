//
//  CCartItem.cpp
//  DCPizza
//
//  Created by Balázs Kilvády on 02/26/21.
//  Copyright © 2021. kil-dev. All rights reserved.
//

#include "CCartItem.hpp"
#include "CartItem.hpp"
#include "Utility.hpp"

CartItem *cart_item_create(const char* name,
                           double price,
                           int id)
{
    return _create_obj<cpplib::CartItem, CartItem>(new cpplib::CartItem(name, price, id));
}
