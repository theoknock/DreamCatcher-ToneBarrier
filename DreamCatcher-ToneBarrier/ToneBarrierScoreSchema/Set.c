#include "Set.h"
#include "Object.h"
#include "new.h"

#include <stddef.h>
#include <assert.h>

struct Set
{
    unsigned count;
};


static const size_t _Set = sizeof(struct Set);
const void * Set = & _Set;

struct Object
{
    unsigned count;
    struct Set * in;
};

static const size_t _Object = sizeof(struct Object);
const void * Object = & _Object;



/*  Taks an element, adds it to a set */
void * add (void * _set, const void * _element)
{
    /*  cast arguments  */
    struct Set * set = _set;
    struct Object * element = (void*)_element;

    /*  assert arguments are not null   */
    assert(set);
    assert(element);

    /*  determine if element is in set  */
    if (! element -> in)
        element -> in = set;                /*  register the element with this set  */
    else
        assert(element -> in == set);       /*  assert this element is already in this set  */
    ++ element -> count, ++ set -> count;   /*    increment the element and set reference counts    */

    return element;
}



/*  Looks for an element in a set and returns whatever is present in the set or a null pointer. */
void * find (const void * _set, const void * _element)
{
    const struct Object * element = _element;

    assert(_set);
    assert(element);

    return element -> in == _set ? (void *) element : 0;
}



/*  Locates an element, removes it from a set, and returns whatever was removed. */
void * drop (void * _set, const void * _element)
{
    /*  cast objects    */
    struct Set * set = _set;
    struct Object * element = find(set, _element);


    if (element)
    {
        if (-- element -> count == 0)
            element -> in = 0;
        -- set -> count;
    }
    return element;
}



unsigned count (const void * _set)
{   
    /*  cast to set */
    const struct Set * set = _set;

    assert(set);

    /*  return the set's references */
    return set -> count;
}



/*  Converts the result of $find into a truth value.*/
int contains (const void * _set, const void * _element)
{
    /*  return the truth of finding the element */
    return find(_set, _element) != 0;
}
