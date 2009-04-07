/*
 * WOMalloc.h
 * WODebug
 *
 * Copyright 2006-2009 Wincent Colaiuta.
 *
 */

#ifndef _STDLIB_H_
#include <stdlib.h>
#endif

/*! Wrappers for memory allocation functions which can be used to simulate out-of-memory conditions for testing purposes. There are two ways of simulating failures:

1. set an environment variable to provoke failures (other vars can be used to control when: always, randomly etc)
2. use macros to pass an extra "forced failure" parameter

Environment variables:

WOMallocFailAlways set to 1 to always fail, 0 to not force failure

WOMallocFailRandomly (set to value between 0 and 1 indicating desired frequency of failures; 0 is equivalent to no forced failures, 1 is equivalent to "fail always")

If set WOMallocFailAlways overrides WOMallocFailRandomly

*/

#pragma mark -
#pragma mark Variadic macros

/*!
\name Variadic macros

 These variadic macros wrap the wrapper functions in such a way that the caller can optionally specify an extra "true" or "false" parameter to force an allocation to fail for testing purposes. One way to do this would be to code in C++ or Objective-C++ and overload the functions so as to provide alternative versions with and without the forced failure flags. An alternative approach has been taken here and that is to use variadic macros and some helper functions which do not require function overloading and can therefore be used in normal C code.

\startgroup
*/

#define WO_MALLOC(size, ...)            WOMallocFailv(size, ## __VAR_ARGS__)

#define WO_CALLOC(count, size, ...)     WOCallocFailv\
                                        (count, size, ## __VAR_ARGS__)

#define WO_VALLOC(size, ...)            WOVallocFailv(size, ## __VAR_ARGS__)

#define WO_REALLOC(ptr, size, ...)      WOReallocFailv\
                                        (ptr, size, ## __VAR_ARGS__)

#define WO_REALLOCF(ptr, size, ...)     WOReallocfFailv\
                                        (ptr, size, ## __VAR_ARGS__)

/*! \endgroup */

#pragma mark -
#pragma mark Base wrapper functions

void * WOMalloc(size_t size);

void * WOCalloc(size_t count, size_t size);

void * WOValloc(size_t size);

void * WORealloc(void *ptr, size_t size);

void * WOReallocf(void *ptr, size_t size);

#pragma mark -
#pragma mark Wrapper functions with forced failure control

void * WOMallocFail(size_t size, _Bool fail);

void * WOCallocFail(size_t count, size_t size, _Bool fail);

void * WOVallocFail(size_t size, _Bool fail);

void * WOReallocFail(void *ptr, size_t size, _Bool fail);

void * WOReallocfFail(void *ptr, size_t size, _Bool fail);

#pragma mark -
#pragma mark Variadic helper function prototypes

void * WOMallocFailv(size_t size, ...);

void * WOCallocFailv(size_t count, size_t size, ...);

void * WOVallocFailv(size_t size, ...);

void * WOReallocFailv(void *ptr, size_t size, ...);

void * WOReallocfFailv(void *ptr, size_t size, ...);
