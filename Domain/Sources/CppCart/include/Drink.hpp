//
//  Drink.hpp
//  DCPizza
//
//  Created by Balázs Kilvády on 02/09/21.
//  Copyright © 2021. kil-dev. All rights reserved.
//

#ifndef Drink_hpp
#define Drink_hpp

#include <string>
#include "ID.h"
using std::string;

namespace cpplib {

struct Drink {
    ID id;
    const char* name;
    double price;

    Drink(ID id,
          const string& name,
          double price);
};

}

#endif /* Drink_hpp */
