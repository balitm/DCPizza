//
//  Ingredient.h
//  DCPizza
//
//  Created by Balázs Kilvády on 02/10/21.
//  Copyright © 2021. kil-dev. All rights reserved.
//

#ifndef Ingredient_h
#define Ingredient_h

#include "CID.hpp"

#ifdef __cplusplus
extern "C"  {
#endif

struct Ingredient;
typedef struct Ingredient Ingredient;

Ingredient *ingredient_create(ID id,
                              const char *name,
                              double price);
void ingredient_destroy(Ingredient *ingredient);

#ifdef __cplusplus
}
#endif

#endif /* Ingredient_h */
