//
//  Set.h
//  DreamCatcher-ToneBarrier
//
//  Created by James Bush on 9/10/20.
//

#ifndef Set_h
#define Set_h

#include <stdio.h>

extern const void * Set;

void * add (void * set, const void * element);
void * find (const void * set, const void * element);
void * drop (void * set, const void * element);
int contains (const void * set, const void * element);
unsigned count (const void * set);

#endif /* Set_h */
