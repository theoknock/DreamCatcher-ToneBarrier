//
//  new.h
//  DreamCatcher-ToneBarrier
//
//  Created by Xcode Developer on 8/29/20.
//

#ifndef new_h
#define new_h

#include <stdarg.h>
#include <stdio.h>
#include <stddef.h>
#include <stdlib.h>
#include <assert.h>



void *new(const void *class, ...);
void delete(void *item);

void *clone(const void *self);
int differ(const void *self, const void *b);

size_t sizeOf(const void *self);

#endif /* new_h */
