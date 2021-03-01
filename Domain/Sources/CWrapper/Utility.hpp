//
//  Utility.hpp
//  DCPizza
//
//  Created by Balázs Kilvády on 02/23/21.
//  Copyright © 2021. kil-dev. All rights reserved.
//

#ifndef Utility_hpp
#define Utility_hpp

#include <vector>
using std::vector;

template<class CPPT, typename CT>
inline CT *_create_obj(CPPT *ptr)
{
    return reinterpret_cast<CT *>(ptr);
}

template<class CPPT, typename CT>
inline const CPPT *_cpp_cpointer(const CT *c_obj)
{
    return reinterpret_cast<const CPPT *>(c_obj);
}

template<class CPPT, typename CT>
inline const CPPT &_cpp_creference(const CT *c_obj)
{
    return *(reinterpret_cast<const CPPT *>(c_obj));
}

template<class CPPT, typename CT>
inline CPPT *_cpp_pointer(CT *c_obj)
{
    return reinterpret_cast<CPPT *>(c_obj);
}

template<class CPPT, typename CT>
inline CPPT &_cpp_reference(CT *c_obj)
{
    return *(reinterpret_cast<CPPT *>(c_obj));
}

#endif /* Utility_hpp */
