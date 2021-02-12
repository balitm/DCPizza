//
//  Ingredient.hpp
//  DCPizza
//
//  Created by Balázs Kilvády on 02/09/21.
//  Copyright © 2021. kil-dev. All rights reserved.
//

#ifndef Ingredient_hpp
#define Ingredient_hpp

#include <string>
#include "ID.hpp"
using std::string;

namespace cpplib {

struct Ingredient {
public:
    ID id;
    string name;
    double price;

    Ingredient(ID id,
               const string& name,
               double price);
};

}

#endif /* Ingredient_hpp */
