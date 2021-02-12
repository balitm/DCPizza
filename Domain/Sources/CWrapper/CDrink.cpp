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

#ifdef __cplusplus
}
#endif
