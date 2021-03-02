//
//  CCart.hpp
//  DCPizza
//
//  Created by Balázs Kilvády on 02/23/21.
//  Copyright © 2021. kil-dev. All rights reserved.
//

#ifndef CCart_hpp
#define CCart_hpp

#include <stdbool.h>
#include <stddef.h>

#ifdef __cplusplus
extern "C"  {
#endif

struct Drink;
typedef struct Drink Drink;

struct Pizza;
typedef struct Pizza Pizza;

struct Cart;
typedef struct Cart Cart;

typedef struct _CartItem CartItem;

Cart *cart_create_empty();
Cart *cart_create(const Pizza *pizzas[], size_t pizza_count,
                  const Drink *drinks[], size_t drink_count,
                  double basePrice);

double cart_base_price(const Cart *);
void cart_set_base_price(Cart *, double);
Drink const **cart_drinks(const Cart *, size_t *);
Pizza const **cart_pizzas(const Cart *, size_t *);

void cart_add_pizza(Cart *cart, const Pizza *pizza);
void cart_add_drink(Cart *cart, const Drink *drink);
void cart_remove(Cart *cart, int index);
void cart_empty(Cart *cart);

bool cart_is_empty(const Cart *cart);
double cart_total_price(const Cart *cart);
CartItem **cart_items(const Cart *cart, size_t *p_size);

#ifdef __cplusplus
}
#endif

#endif /* CCart_hpp */
