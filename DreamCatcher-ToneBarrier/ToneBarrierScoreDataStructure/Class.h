//
//  Class.h
//  DreamCatcher-ToneBarrier
//
//  Created by Xcode Developer on 8/29/20.
//

#ifndef Class_h
#define Class_h

struct Class {
    size_t size;
    void * (*ctor) (void *self, va_list *app);
    void * (*dtor) (void *self);
    void * (*clone) (const void *self);
    int (*differ) (const void *self, const void *b);
};

#endif /* Class_h */
