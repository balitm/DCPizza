//
//  CartItem.cpp
//  Domain
//
//  Created by Balázs Kilvády on 02/25/21.
//

#include "CartItem.hpp"

namespace cpplib {

CartItem::CartItem(const string& name, double price, int id)
: name(strdup(name.c_str())), price(price), id(id) {};

CartItem::CartItem(const CartItem& other) {
    ::memcpy(this, &other, sizeof(CartItem));
    assert(id == other.id);
    assert(price == other.price);
    name = strdup(other.name);
    assert(strcmp(name, other.name) == 0);
}

CartItem::CartItem(CartItem&& other)
{
    ::memcpy(this, &other, sizeof(CartItem));
    assert(id == other.id);
    assert(price == other.price);
    assert(strcmp(name, other.name) == 0);
    other.name = nullptr;
}

CartItem::~CartItem()
{
    if (name != nullptr) {
        ::free((void *)name);
    }
}

}
