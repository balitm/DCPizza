//
//  CartItem.hpp
//  Domain
//
//  Created by Balázs Kilvády on 02/09/21.
//

#ifndef CartItem_hpp
#define CartItem_hpp

#include <string>
using std::string;

namespace cpplib {

struct CartItem {
    string name;
    double price;
    int id;

    CartItem(const string& name, double price, int id)
    : name(name), price(price), id(id) {};
};

}

#endif /* CartItem_hpp */
