//
//  Pizza.h
//  DCPizza
//
//  Created by Balázs Kilvády on 02/10/21.
//  Copyright © 2021. kil-dev. All rights reserved.
//

#ifndef Pizza_h
#define Pizza_h

#include <stddef.h>

#ifdef __cplusplus
extern "C"  {
#endif

struct Ingredient;
typedef struct Ingredient Ingredient;

struct Pizza;
typedef struct Pizza Pizza;

// MARK: - Struct for returning an array

Pizza *pizza_create_empty();
Pizza *pizza_create_copy(const Pizza *other,
                         const Ingredient *ingredients[],
                         size_t ingredient_count);
Pizza *pizza_create(const char *name,
                    const Ingredient *ingredients[],
                    size_t ingredient_count,
                    const char *url_string);
void pizza_destroy(Pizza *pizza);

double pizza_price(const Pizza *pizza, double basePrice);
const char *pizza_ingredient_names(const Pizza *pizza);

// MARK: - Accessors

const char *pizza_name(const Pizza *);
const char *pizza_url_string(const Pizza *);
Ingredient const **pizza_ingredients(const Pizza *pizza, size_t *);

#ifdef __cplusplus
}
#endif

#endif /* Pizza_h */
