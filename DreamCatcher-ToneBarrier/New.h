//
//  New.h
//  DreamCatcher-ToneBarrier
//
//  Created by James Bush on 9/10/20.
//

#ifndef New_h
#define New_h

#include <stdio.h>
#include <stddef.h>

void * new (const void * class, ...);
void delete (void * item);

void * clone (const void * self);
int differ (const void * self, const void * b);

size_t sizeOf (const void * self);

#endif /* New_h */
