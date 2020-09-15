//
//  Object.h
//  DreamCatcher-ToneBarrier
//
//  Created by James Bush on 9/10/20.
//

#ifndef Object_h
#define Object_h

#include <stdio.h>

extern const void * Object;        /* new(Object); */

int differ (const void * a, const void * b);

size_t sizeOf (const void * a);

#endif /* Object_h */
