//
//  Pizza.hpp
//  DCPizza
//
//  Created by Balázs Kilvády on 02/09/21.
//  Copyright © 2021. kil-dev. All rights reserved.
//

#ifndef Pizza_hpp
#define Pizza_hpp

#include <string>
#include <vector>
#include "Ingredient.hpp"

using std::vector;
using std::string;

namespace cpplib {

struct Pizza {
public:
    string name;
    vector<Ingredient> ingredients;
    const string* url_string;

    Pizza(const Pizza& other, const vector<Ingredient> * ingredients = nullptr);

    Pizza();
    
    Pizza(
        const string& name,
        const vector<Ingredient>& ingredients,
        const string * url_string
          );

    double price(double basePrice) const;

    string ingredient_names() const;
};

}

#endif /* Pizza_hpp */
