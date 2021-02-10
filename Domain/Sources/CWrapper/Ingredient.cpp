//
//  Ingredient.cpp
//  DCPizza
//
//  Created by Balázs Kilvády on 02/10/21.
//  Copyright © 2021. kil-dev. All rights reserved.
//

#include "Ingredient.h"
#include "Ingredient.hpp"

#ifdef __cplusplus
extern "C"  {
#endif

Ingredient *ingredient_create(ID id,
                              const char *name,
                              double price)
{
    return reinterpret_cast<Ingredient *>(new cpplib::Ingredient(id, name, price));
}

void ingredient_destroy(Ingredient *ingredient)
{
    delete reinterpret_cast<cpplib::Ingredient *>(ingredient);
}

#ifdef __cplusplus
}
#endif
