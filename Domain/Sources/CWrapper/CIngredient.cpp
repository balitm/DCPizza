//
//  Ingredient.cpp
//  DCPizza
//
//  Created by Balázs Kilvády on 02/10/21.
//  Copyright © 2021. kil-dev. All rights reserved.
//

#include "CIngredient.hpp"
#include "Ingredient.hpp"
#include "Utility.hpp"

#ifdef __cplusplus
extern "C"  {
#endif

// MARK: - Helpers

inline const cpplib::Ingredient *_cpp_pointer(const Ingredient *ingredient)
 {
    return _cpp_cpointer<cpplib::Ingredient>(ingredient);
 }

inline const cpplib::Ingredient &_cpp_reference(const Ingredient *ingredient)
 {
    return _cpp_creference<cpplib::Ingredient>(ingredient);
 }

inline Ingredient *_create_obj(cpplib::Ingredient *ptr)
 {
    return _create_obj<cpplib::Ingredient, Ingredient>(ptr);
 }

// MARK: - Implementations

Ingredient *ingredient_create(ID id,
                              const char *name,
                              double price)
{
    return _create_obj(new cpplib::Ingredient(id, name, price));
}

Ingredient *ingredient_create_copy(const Ingredient *other)
{
    auto src = _cpp_pointer(other);
    return _create_obj(new cpplib::Ingredient(*src));
}

void ingredient_destroy(Ingredient *ingredient)
{
    delete _cpp_pointer(ingredient);
}

ID ingredient_id(Ingredient *ingredient)
{
    return _cpp_pointer(ingredient)->id;
}

const char *ingredient_name(Ingredient *ingredient)
{
    return _cpp_pointer(ingredient)->name.c_str();
}

double ingredient_price(Ingredient *ingredient)
{
    return _cpp_pointer(ingredient)->price;
}

#ifdef __cplusplus
}
#endif
