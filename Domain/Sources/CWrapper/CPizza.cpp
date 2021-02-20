//
//  Pizza.cpp
//  DCPizza
//
//  Created by Balázs Kilvády on 02/10/21.
//  Copyright © 2021. kil-dev. All rights reserved.
//

#include "CPizza.hpp"
#include "Pizza.hpp"
#include "Ingredient.hpp"
#include <string.h>

using std::unique_ptr;

// MARK: - Private helpers

const cpplib::Pizza& convert(const Pizza* pizza) {
    return *reinterpret_cast<const cpplib::Pizza*>(pizza);
}

unique_ptr<vector<const cpplib::Ingredient*>> convert(const Ingredient* ingredients[],
                                                      size_t ingredient_count) {
    auto ingredient_vector = new vector<const cpplib::Ingredient*>;
    std::transform(ingredients, ingredients + ingredient_count, std::back_inserter(*ingredient_vector),
                   [](const Ingredient* ingredient) -> const cpplib::Ingredient* {
        auto ptr = reinterpret_cast<const cpplib::Ingredient*>(ingredient);
        return ptr;
    });
    return unique_ptr<vector<const cpplib::Ingredient*>>(ingredient_vector);
}

#ifdef __cplusplus
extern "C"  {
#endif

// MARK: - exported publics

Pizza *pizza_create_empty()
{
    return reinterpret_cast<Pizza *>(new cpplib::Pizza());
}

Pizza *pizza_create_copy(const Pizza *other,
                         const Ingredient *ingredients[],
                         size_t ingredient_count)
{
    const cpplib::Pizza& other_pizza = convert(other);
    if (ingredient_count > 0) {
        assert(ingredients != nullptr);
        auto unique_ptr = convert(ingredients, ingredient_count);
        return reinterpret_cast<Pizza *>(new cpplib::Pizza(other_pizza, unique_ptr.get()));
    }
    return reinterpret_cast<Pizza *>(new cpplib::Pizza(other_pizza, nullptr));
}

Pizza *pizza_create(const char *name,
                    const Ingredient *ingredients[],
                    size_t ingredient_count,
                    const char *url_string)
{
    auto urlstr = url_string ? url_string : "";
    const auto pizza = new cpplib::Pizza(name,
                                         *convert(ingredients, ingredient_count),
                                         urlstr);
    return reinterpret_cast<Pizza *>(pizza);
}

void pizza_destroy(Pizza *pizza)
{
    delete reinterpret_cast<cpplib::Pizza *>(pizza);
}

double pizza_price(const Pizza *pizza, double basePrice)
{
    return reinterpret_cast<const cpplib::Pizza *>(pizza)->price(basePrice);
}

// Note: Caller must free the memory of the string.
const char *pizza_ingredient_names(const Pizza *pizza)
{
    const string& ingredients = reinterpret_cast<const cpplib::Pizza *>(pizza)->ingredient_names();
    const char *str = strdup(ingredients.c_str());
    return str;
}

const char *pizza_name(const Pizza *pizza)
{
    return reinterpret_cast<const cpplib::Pizza *>(pizza)->name.c_str();
}

const char *pizza_url_string(const Pizza *pizza)
{
    return reinterpret_cast<const cpplib::Pizza *>(pizza)->url_string.c_str();
}

const Ingredient * const *pizza_ingredients(const Pizza *pizza, size_t *p_size)
{
    const auto &ingredients = reinterpret_cast<const cpplib::Pizza *>(pizza)->ingredients;
    *p_size = ingredients.size();
    auto carray = reinterpret_cast<const Ingredient * const *>(ingredients.data());
    return carray;
    // vector<const Ingredient *> result;
    // std::transform(ingredients.cbegin(), ingredients.cend(), result.begin(),
    //                [](const cpplib::Ingredient &ingredient) -> const Ingredient * {
    //     return reinterpret_cast<const Ingredient *>(&ingredient);
    // });
    // return reinterpret_cast<const Ingredient *>(ingredients.data());
}

#ifdef __cplusplus
}
#endif
