#include <string.h>
#include <stdlib.h>
#include <assert.h>
#include "String.h"
#include "new.h"



/**
 *  @brief String class descriptor.
 */
struct String
{
    const void * class;
    char * text;
};



/**
 *  @brief String contructor: construct from char[].
 *  @param[in] ctor_args A provided list of argments passed.
 *  @returns This string initialized.
 */
static void *
String_ctor (void * _self, va_list * ctor_args)
{
    /* Reinterpret self as a string. */
    struct String * self = _self;
    /* Get provided argument as text. */
    const char* text = va_arg(*ctor_args, const char*);
    /* Allocate memory for character array. */
    self->text = malloc(strlen(text)+1);
    /* Ensure allocation. */
    assert(self->text);
    /* Copy string (null-terminated). */
    strcpy(self->text, text);

    return self;
}



/**
 *  @brief String destructor.
 *  @param[in] _self The string to destruct.
 *  @returns This string uninitialized.
 */
static void *
String_dtor(void * _self)
{
    struct String * self = _self;
    free (self->text), self->text = 0;
    return self;
}



/**
 *  @brief String copy method.
 *  @param[in] _self The string to copy.
 *  @returns This string (the clone).
 */
static void *
String_clone(const void * _self)
{
    const struct String * self = _self;
    return new (String, self->text);
}



/**
 *  @brief String compare method.
 *  @param[in] _self This string instance (caller).
 *  @param[in] _b The other string instance to compare with.
 *  @returns The result of comparing the strings.
 */
static int
String_differ(const void * _self, const void * _b)
{
    const struct String * self = _self;
    const struct String * b = _b;
    /* If a string is being compared with itself, this
     *  method is trivial, and we can just return true. */
    if (self == b)
    {
        return 0;
    }
    
    /* Check if b is not null and is an instance
     *  of String. */
    if (!b || b->class != String)
    {
        return 1;
    }
    /* Compare the text of both String objects. */
    return strcmp(self->text, b->text);
}



/**
 *  @brief Link string methods to class descriptor.
 */
static const struct Class _String = {
    sizeof(struct String),
    String_ctor,
    String_dtor,
    String_clone,
    String_differ
};

/* Point external String type reference to linked descriptor. */
const void * String = &_String;