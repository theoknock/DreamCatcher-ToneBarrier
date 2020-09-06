#ifndef SET_H
#define SET_H

extern const void * Set;

/*  Taks an element, adds it to a set */
void * add (void * set, const void * element);

/*  Looks for an element in a set and returns whatever is present in the set or a null pointer. */
void * find (const void * set, const void * element);

/*  Locates an element, removes it from a set, and returns whatever was removed. */
void * drop (void * set, const void * element);

/*  Converts the result of $find into a truth value.*/
int contains (const void * set, const void * element);

#endif