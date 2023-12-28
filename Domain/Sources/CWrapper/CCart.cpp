//
//  CCart.cpp
//  DCPizza
//
//  Created by Balázs Kilvády on 02/23/21.
//  Copyright © 2021. kil-dev. All rights reserved.
//

#include "CCart.hpp"
#include "CppCart.hpp"
#include "Drink.hpp"
#include "Pizza.hpp"
#include "Utility.hpp"
#include "CCartItem.hpp"

using std::unique_ptr;

template <class CPPT, typename CT>
unique_ptr<vector<CPPT>> convert(const CT* input[],
                                 size_t input_count) {
    auto out_vector = new vector<CPPT>;
    std::for_each(input, input + input_count,
                   [&out_vector](const CT* in) {
        auto cpp_obj = _cpp_cpointer<CPPT>(in);
        out_vector->emplace_back(*cpp_obj);
    });
    return unique_ptr<vector<CPPT>>(out_vector);
}

// Note: Caller must free the memory of the string.
template<class CPPT, typename CT>
CT const **array_getter(const vector<CPPT> &vector, size_t *p_size)
{
    *p_size = vector.size();
    CT const **buffer = (CT const **)malloc(vector.size() * sizeof(CT *));
    std::transform(vector.cbegin(), vector.cend(), buffer,
                   [](const CPPT &item) -> CT * {
        return reinterpret_cast<CT *>(new CPPT(item));
    });
    return buffer;
}

#ifdef __cplusplus
extern "C"  {
#endif

// MARK: - Helpers

inline const cpplib::Cart *_cpp_cpointer(const Cart *cart)
{
    return _cpp_cpointer<cpplib::Cart>(cart);
}

inline cpplib::Cart *_cpp_pointer(Cart *cart)
{
    return _cpp_pointer<cpplib::Cart>(cart);
}

inline const cpplib::Cart &_cpp_creference(const Cart *cart)
{
    return _cpp_creference<cpplib::Cart>(cart);
}

inline cpplib::Cart &_cpp_reference(Cart *cart)
{
    return _cpp_reference<cpplib::Cart>(cart);
}

inline Cart *_create_obj(cpplib::Cart *ptr)
{
    return _create_obj<cpplib::Cart, Cart>(ptr);
}

// MARK: - exported publics

Cart *cart_create_empty()
{
    return _create_obj(new cpplib::Cart());
}

Cart *cart_create(const Pizza *pizzas[], size_t pizza_count,
                  const Drink *drinks[], size_t drink_count,
                  double basePrice)
{
    auto pizza_vector = convert<cpplib::Pizza>(pizzas, pizza_count);
    auto drink_vector = convert<cpplib::Drink>(drinks, drink_count);
    return _create_obj(new cpplib::Cart(std::move(pizza_vector), std::move(drink_vector), basePrice));
}

void cart_add_pizza(Cart *cart, const Pizza *pizza)
{
    _cpp_pointer(cart)->add(_cpp_creference<cpplib::Pizza>(pizza));
}

void cart_add_drink(Cart *cart, const Drink *drink)
{
    _cpp_pointer(cart)->add(_cpp_creference<cpplib::Drink>(drink));
}

void cart_remove(Cart *cart, int index)
{
    _cpp_pointer(cart)->remove(index);
}

void cart_empty(Cart *cart)
{
    _cpp_pointer(cart)->empty();
}

bool cart_is_empty(const Cart *cart)
{
    return _cpp_cpointer(cart)->is_empty();
}

double cart_total_price(const Cart *cart)
{
    return _cpp_cpointer(cart)->total_price();
}

CartItem **cart_items(const Cart *cart, size_t *p_size)
{
    const auto &items(_cpp_cpointer(cart)->items());
    *p_size = items.size();
    CartItem **buffer = (CartItem **)malloc(items.size() * sizeof(CartItem *));
    std::transform(items.cbegin(), items.cend(), buffer,
                   [](const cpplib::CartItem &item) -> CartItem * {
        return _create_obj<cpplib::CartItem, CartItem>(new cpplib::CartItem(item));
    });
    return buffer;
}

// MARK: - Accessors

double cart_base_price(const Cart *cart)
{
    return _cpp_cpointer(cart)->base_price;
}

void cart_set_base_price(Cart *cart, double price)
{
    _cpp_pointer(cart)->base_price = price;
}

Drink const **cart_drinks(const Cart *cart, size_t *p_size)
{
    const auto &drinks(*_cpp_cpointer(cart)->drinks());
    return array_getter<cpplib::Drink, Drink>(drinks, p_size);
}

Pizza const **cart_pizzas(const Cart *cart, size_t *p_size)
{
    const auto &pizzas(*_cpp_cpointer(cart)->pizzas());
    return array_getter<cpplib::Pizza, Pizza>(pizzas, p_size);
}

#ifdef __cplusplus
}
#endif
