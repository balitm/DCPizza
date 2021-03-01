//
//  CartItem.hpp
//  Domain
//
//  Created by Balázs Kilvády on 02/09/21.
//

#ifndef CartItem_hpp
#define CartItem_hpp

#include <string.h>
#include <string>
using std::string;

namespace cpplib {

struct CartItem {
    const char* name;
    double price;
    int id;

    CartItem(const string& name, double price, int id);
    CartItem(const CartItem& other);
    CartItem(CartItem&& other);
    ~CartItem();
};

}

#endif /* CartItem_hpp */
