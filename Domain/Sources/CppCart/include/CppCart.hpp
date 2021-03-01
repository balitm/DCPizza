#ifndef CppCart_hpp
#define CppCart_hpp

#include <vector>
#include "CartItem.hpp"

using std::vector;

using std::unique_ptr;

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
    double base_price;

    Cart();
    Cart(const vector<Pizza>&, const vector<Drink>&, double base_price);
    Cart(unique_ptr<vector<Pizza>>, unique_ptr<vector<Drink>>, double base_price);

    inline const vector<Drink>* drinks() const { return &_drinks; }
    inline const vector<Pizza>* pizzas() const { return &_pizzas; }

    void add(const Pizza&);
    void add(const Drink&);
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
