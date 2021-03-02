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
#include "Utility.hpp"
#include <string.h>

using std::unique_ptr;

// MARK: - Private helpers

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

inline const cpplib::Pizza *_cpp_pointer(const Pizza *pizza)
{
    return _cpp_cpointer<cpplib::Pizza>(pizza);
}

inline const cpplib::Pizza &_cpp_reference(const Pizza *pizza)
{
    return _cpp_creference<cpplib::Pizza>(pizza);
}

inline Pizza *_create_obj(cpplib::Pizza *ptr)
{
    return _create_obj<cpplib::Pizza, Pizza>(ptr);
}

#ifdef __cplusplus
extern "C"  {
#endif

// MARK: - exported publics

Pizza *pizza_create_empty()
{
    return _create_obj(new cpplib::Pizza());
}

Pizza *pizza_create_copy(const Pizza *other,
                         const Ingredient *ingredients[],
                         size_t ingredient_count)
{
    const cpplib::Pizza& other_pizza = _cpp_reference(other);
    if (ingredient_count > 0) {
        assert(ingredients != nullptr);
        auto unique_ptr = convert(ingredients, ingredient_count);
        return reinterpret_cast<Pizza *>(new cpplib::Pizza(other_pizza, unique_ptr.get()));
    }
    return _create_obj(new cpplib::Pizza(other_pizza, nullptr));
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
    return _create_obj(pizza);
}

void pizza_destroy(Pizza *pizza)
{
    delete reinterpret_cast<cpplib::Pizza *>(pizza);
}

double pizza_price(const Pizza *pizza, double basePrice)
{
    return _cpp_pointer(pizza)->price(basePrice);
}

// Note: Caller must free the memory of the string.
const char *pizza_ingredient_names(const Pizza *pizza)
{
    const string& ingredients = _cpp_pointer(pizza)->ingredient_names();
    const char *str = strdup(ingredients.c_str());
    return str;
}

const char *pizza_name(const Pizza *pizza)
{
    return _cpp_pointer(pizza)->name.c_str();
}

const char *pizza_url_string(const Pizza *pizza)
{
    return _cpp_pointer(pizza)->url_string.c_str();
}

// Note: Caller must free the memory of the string.
Ingredient const **pizza_ingredients(const Pizza *pizza, size_t *p_size)
{
    const auto &ingredients = _cpp_pointer(pizza)->ingredients;
    *p_size = ingredients.size();
    Ingredient const **buffer = (Ingredient const **)malloc(ingredients.size() * sizeof(Ingredient *));
    std::transform(ingredients.cbegin(), ingredients.cend(), buffer,
                   [](const cpplib::Ingredient *ptr) -> Ingredient * {
        return reinterpret_cast<Ingredient *>(new cpplib::Ingredient(*ptr));
    });
    return buffer;
}

#ifdef __cplusplus
}
#endif
