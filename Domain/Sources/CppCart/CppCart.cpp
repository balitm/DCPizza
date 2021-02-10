//
//  CppCart.cpp
//  Domain
//
//  Created by Balázs Kilvády on 02/09/21.
//

#include <numeric>
#include "CppCart.hpp"
#include "Pizza.hpp"
#include "Drink.hpp"
#include "Ingredient.hpp"

namespace cpplib {
// Initialize static member of class.
int Cart::_additionNumber = 0;

Cart::Cart() {}

Cart::Cart(const vector<Pizza>& pizzas, vector<Drink> drinks, double basePrice)
: _pizzas(pizzas), _drinks(drinks), basePrice(basePrice)
{
    _additionNumber = int(pizzas.size() + drinks.size());
    _ids = vector<int>(_additionNumber);
    std::iota(_ids.begin(), _ids.end(), 0);
}

void Cart::add(const Pizza& pizza)
{
    auto pos = _ids.begin() + _pizzas.size();
    _ids.insert(pos, _additionNumber);
    _pizzas.push_back(pizza);
    _additionNumber++;
}

void Cart::add(const Drink& drink)
{
    _ids.push_back(_additionNumber);
    _drinks.push_back(drink);
    ++_additionNumber;
}

void Cart::remove(int index)
{
    _ids.erase(_ids.begin() + index);
    auto count = _pizzas.size();
    if (index < count) {
        _pizzas.erase(_pizzas.begin() + index);
    } else {
        _drinks.erase(_drinks.begin() + index - count);
    }
}

void Cart::empty()
{
    _drinks.clear();
    _pizzas.clear();
    _ids.clear();
    _additionNumber = 0;
}

bool Cart::is_empty() const
{
    return _pizzas.empty() && _drinks.empty();
}

double Cart::total_price() const
{
    double price(0);
    std::for_each(_pizzas.cbegin(), _pizzas.cend(), [&](const Pizza& pizza) {
        price += _pizza_price(pizza);
    });
    std::for_each(_drinks.cbegin(), _drinks.cend(), [&](const Drink &drink) {
        price += drink.price;
    });
    return price;
}

vector<CartItem> Cart::items() const
{
    auto pizza_count = _pizzas.size();
    auto drink_count = _drinks.size();
    vector<CartItem> items;
    int id = 0;
    assert(_ids.size() == pizza_count + drink_count);
    items.reserve(pizza_count + drink_count);

    std::transform(_pizzas.cbegin(), _pizzas.cend(),
                   items.begin(), [&id, this](const Pizza& pizza) -> CartItem {
        return CartItem(pizza.name,
                        _pizza_price(pizza),
                        _ids[id++]);
    });
    assert(id == pizza_count);
    std::transform(_drinks.cbegin(), _drinks.cend(), std::back_inserter(items),
                   [&id, this](const Drink& drink) -> CartItem {
        return CartItem(drink.name, drink.price, _ids[id++]);
    });
    assert(id == pizza_count + drink_count);

    return items;
}

double Cart::_pizza_price(const Pizza& pizza) const
{
    double price(basePrice);
    auto &ingredients = pizza.ingredients;
    std::for_each(ingredients.cbegin(), ingredients.cend(), [&](const Ingredient& ingredient) {
        price += ingredient.price;
    });
    return price;
}

}
