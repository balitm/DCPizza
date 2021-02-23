//
//  Utility.hpp
//  DCPizza
//
//  Created by Balázs Kilvády on 02/23/21.
//  Copyright © 2021. kil-dev. All rights reserved.
//

#ifndef Utility_hpp
#define Utility_hpp

template<class CPPT, typename CT>
inline CT *_create_obj(CPPT *ptr)
{
    return reinterpret_cast<CT *>(ptr);
}

template<class CPPT, typename CT>
inline const CPPT *_cpp_pointer(const CT *c_obj)
{
    return reinterpret_cast<const CPPT *>(c_obj);
}

template<class CPPT, typename CT>
inline const CPPT &_cpp_reference(const CT *c_obj)
{
    return *(reinterpret_cast<const CPPT *>(c_obj));
}

#endif /* Utility_hpp */
