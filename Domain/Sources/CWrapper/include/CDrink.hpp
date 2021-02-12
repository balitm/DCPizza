//
//  Drink.h
//  DCPizza
//
//  Created by Balázs Kilvády on 02/10/21.
//  Copyright © 2021. kil-dev. All rights reserved.
//

#ifndef Drink_h
#define Drink_h

#include "CID.hpp"

#ifdef __cplusplus
extern "C"  {
#endif

struct Drink;
typedef struct Drink Drink;

Drink *drink_create(ID id,
                    const char *name,
                    double price);
void drink_destroy(Drink *drink);

// MARK: - Accessors

ID drink_id(Drink *);
void drink_set_id(Drink *, ID);
const char *drink_name(Drink *);
double drink_price(Drink *);

#ifdef __cplusplus
}
#endif

#endif /* Drink_h */
