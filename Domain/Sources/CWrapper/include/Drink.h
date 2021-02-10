//
//  Drink.h
//  DCPizza
//
//  Created by Balázs Kilvády on 02/10/21.
//  Copyright © 2021. kil-dev. All rights reserved.
//

#ifndef Drink_h
#define Drink_h

#include "ID.h"

#ifdef __cplusplus
extern "C"  {
#endif

struct Drink;
typedef struct Drink Drink;

Drink *drink_create(ID id,
                    const char *name,
                    double price);
void drink_destroy(Drink *drink);

#ifdef __cplusplus
}
#endif

#endif /* Drink_h */
