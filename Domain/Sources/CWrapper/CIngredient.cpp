//
//  Ingredient.cpp
//  DCPizza
//
//  Created by Balázs Kilvády on 02/10/21.
//  Copyright © 2021. kil-dev. All rights reserved.
//

#include "CIngredient.hpp"
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

Ingredient *ingredient_create_copy(const Ingredient *other)
{
    auto src = reinterpret_cast<const cpplib::Ingredient*>(other);
    return reinterpret_cast<Ingredient *>(new cpplib::Ingredient(*src));
}

void ingredient_destroy(Ingredient *ingredient)
{
    delete reinterpret_cast<cpplib::Ingredient *>(ingredient);
}

ID ingredient_id(Ingredient *ingredient)
{
    return reinterpret_cast<cpplib::Ingredient *>(ingredient)->id;
}

void ingredient_set_id(Ingredient *ingredient, ID id)
{
    reinterpret_cast<cpplib::Ingredient *>(ingredient)->id = id;
}

const char *ingredient_name(Ingredient *ingredient)
{
    return reinterpret_cast<cpplib::Ingredient *>(ingredient)->name.c_str();
}

double ingredient_price(Ingredient *ingredient)
{
    return reinterpret_cast<cpplib::Ingredient *>(ingredient)->price;
}

#ifdef __cplusplus
}
#endif
