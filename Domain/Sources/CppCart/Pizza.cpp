//
//  Pizza.cpp
//  DCPizza
//
//  Created by Balázs Kilvády on 02/09/21.
//  Copyright © 2021. kil-dev. All rights reserved.
//

#include <numeric>
#include "Pizza.hpp"

namespace cpplib {

Pizza::Pizza(const Pizza& other, const vector<Ingredient> * ingredients)
: name(other.name), url_string(other.url_string)
{
    this->ingredients = ingredients ? *ingredients : other.ingredients;
}

Pizza::Pizza()
: name("Custom"), ingredients(), url_string()
{}

Pizza::Pizza(const string& name,
             const vector<Ingredient>& ingredients,
             const string * url_string)
: name(name), ingredients(ingredients), url_string(url_string)
{}

double Pizza::price(double basePrice) const {
    double price = 0;
    for (auto &i : ingredients) {
        price += i.price;
    }
    return price;
}

string Pizza::ingredient_names() const {
    auto it = ingredients.cbegin();

    if (it == ingredients.cend()) {
        return string();
    }
    string i_names(it->name);
    ++it;
    for (; it != ingredients.cend(); ++it) {
        i_names += ", " + it->name;
    }
    i_names += ".";

    return i_names;
}

}
