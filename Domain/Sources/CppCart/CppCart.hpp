#ifndef CppCart_hpp
#define CppCart_hpp

#include <vector>
#include "CartItem.hpp"

using std::vector;

namespace cpplib {

struct Pizza;
struct Drink;

class Cart {
private:
    static int _additionNumber;

    vector<Pizza> _pizzas;
    vector<Drink> _drinks;
    vector<int> _ids;

public:
    double basePrice;

    Cart();
    Cart(const vector<Pizza>& pizzas, vector<Drink> drinks, double basePrice);

    void add(const Pizza& pizza);
    void add(const Drink& drink);
    void remove(int index);
    void empty();
    bool is_empty() const;
    double total_price() const;
    vector<CartItem> items() const;

private:
    double _pizza_price(const Pizza& pizza) const;
};
}

#endif /* CppCart_hpp */
