//
//  Drink.cpp
//  DCPizza
//
//  Created by Balázs Kilvády on 02/10/21.
//  Copyright © 2021. kil-dev. All rights reserved.
//

#include "CDrink.hpp"
#include "Drink.hpp"

#ifdef __cplusplus
extern "C"  {
#endif

Drink *drink_create(ID id,
                     const char *name,
                     double price)
{
    return reinterpret_cast<Drink *>(new cpplib::Drink(id, name, price));
}

void drink_destroy(Drink *drink)
{
    delete reinterpret_cast<cpplib::Drink *>(drink);
}

ID drink_id(Drink *drink)
{
    return reinterpret_cast<cpplib::Drink *>(drink)->id;
}

void drink_set_id(Drink *drink, ID id)
{
    reinterpret_cast<cpplib::Drink *>(drink)->id = id;
}

const char *drink_name(Drink *drink)
{
    return reinterpret_cast<cpplib::Drink *>(drink)->name.c_str();
}

double drink_price(Drink *drink)
{
    return reinterpret_cast<cpplib::Drink *>(drink)->price;
}

#ifdef __cplusplus
}
#endif
