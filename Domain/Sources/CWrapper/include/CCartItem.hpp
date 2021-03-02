//
//  CCartItem.hpp
//  DCPizza
//
//  Created by Balázs Kilvády on 02/25/21.
//  Copyright © 2021. kil-dev. All rights reserved.
//

#ifndef CCartItem_hpp
#define CCartItem_hpp

#ifdef __cplusplus
extern "C"  {
#endif

typedef struct _CartItem {
    const char* name;
    double price;
    int id;
} CartItem;

CartItem *cart_item_create(const char* name,
                           double price,
                           int id);

#ifdef __cplusplus
}
#endif

#endif /* CCartItem_hpp */
