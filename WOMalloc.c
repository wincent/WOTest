/*
 *  WOMalloc.c
 *  WODebug
 *
 *  Created by Wincent Colaiuta on 07 February 2006.
 *  Copyright 2006-2007 Wincent Colaiuta.
 *
 */

#include "WOMalloc.h"

#ifndef _STRING_H_
#include <string.h>
#endif

#ifndef _SYS_ERRNO_H_
#include <errno.h>
#endif

#ifndef _STDARG_H
#include <stdarg.h>
#endif

#if !defined(TRUE)
#define TRUE    1
#endif

#if !defined(FALSE)
#define FALSE   0
#endif

_Bool WOMallocShouldFail(void);

_Bool WOMallocShouldFail()
{
    // check "always fail" environment variable
    const char *alwaysFail = (const char *)getenv("WOMallocFailAlways");
    if ((alwaysFail != NULL) && (strcmp(alwaysFail, "1") == 0))
        return TRUE;

    // check "fail randomly" environment variable
    const char *randomly = (const char *)getenv("WOMallocFailRandomly");
    if (randomly != NULL)
    {
        // try to extract double value between 0 and 1 from environment variable
        double probability = strtod(randomly, (char **)NULL); // ignore errors

        // impose range limits
        if (probability <= 0) return FALSE;  // don't force failure
        if (probability >= 1) return TRUE;   // do force failure

        // given probability, decide whether or not to fail
        // get value between 0 and 0xfffffffe (2 to the power of 31, minus 1)
        if (random() < (probability * 0xfffffffe))
            return TRUE;
    }

    return FALSE; // fallback case: don't force failure
}

#pragma mark -
#pragma mark Base wrapper functions

void * WOMalloc(size_t size)
{
    if (WOMallocShouldFail())
    {
        errno = ENOMEM;
        return NULL;
    }

    return malloc(size);
}

void * WOCalloc(size_t count, size_t size)
{
    if (WOMallocShouldFail())
    {
        errno = ENOMEM;
        return NULL;
    }

    return calloc(count, size);
}

void * WOValloc(size_t size)
{
    if (WOMallocShouldFail())
    {
        errno = ENOMEM;
        return NULL;
    }

    return valloc(size);
}

void * WORealloc(void *ptr, size_t size)
{
    if (WOMallocShouldFail())
    {
        errno = ENOMEM;
        return NULL;
    }

    return realloc(ptr, size);
}

void * WOReallocf(void *ptr, size_t size)
{
    if (WOMallocShouldFail())
    {
        errno = ENOMEM;
        return NULL;
    }

    return reallocf(ptr, size);
}

#pragma mark -
#pragma mark Wrapper functions with forced failure control

void * WOMallocFail(size_t size, _Bool fail)
{
    if (fail)
    {
        errno = ENOMEM;
        return NULL;
    }

    return malloc(size);
}

void * WOCallocFail(size_t count, size_t size, _Bool fail)
{
    if (fail)
    {
        errno = ENOMEM;
        return NULL;
    }

    return calloc(count, size);
}

void * WOVallocFail(size_t size, _Bool fail)
{
    if (fail)
    {
        errno = ENOMEM;
        return NULL;
    }

    return valloc(size);
}

void * WOReallocFail(void *ptr, size_t size, _Bool fail)
{
    if (fail)
    {
        errno = ENOMEM;
        return NULL;
    }

    return realloc(ptr, size);
}

void * WOReallocfFail(void *ptr, size_t size, _Bool fail)
{
    if (fail)
    {
        errno = ENOMEM;
        return NULL;
    }

    return reallocf(ptr, size);
}

#pragma mark -
#pragma mark Variadic helper functions

void * WOMallocFailv(size_t size, ...)
{
    va_list args;
    va_start(args, size);
    int   fail            = FALSE;
    void    *returnValue    = NULL;

    // get optional failure flag, if present
    if ((fail = va_arg(args, int)))
        returnValue = WOMallocFail(size, fail); // use forced failure version
    else
        returnValue = WOMalloc(size);           // use standard version

    va_end(args);
    return returnValue;
}

void * WOCallocFailv(size_t count, size_t size, ...)
{
    va_list args;
    va_start(args, size);
    int   fail            = FALSE;
    void    *returnValue    = NULL;

    // get optional failure flag, if present
    if ((fail = va_arg(args, int)))
        returnValue = WOCallocFail(count, size, fail);
    else
        returnValue = WOCalloc(count, size);

    va_end(args);
    return returnValue;
}

void * WOVallocFailv(size_t size, ...)
{
    va_list args;
    va_start(args, size);
    int   fail            = FALSE;
    void    *returnValue    = NULL;

    // get optional failure flag, if present
    if ((fail = va_arg(args, int)))
        returnValue = WOVallocFail(size, fail);
    else
        returnValue = WOValloc(size);

    va_end(args);
    return returnValue;
}

void * WOReallocFailv(void *ptr, size_t size, ...)
{
    va_list args;
    va_start(args, size);
    int   fail            = FALSE;
    void    *returnValue    = NULL;

    // get optional failure flag, if present
    if ((fail = va_arg(args, int)))
        returnValue = WOReallocFail(ptr, size, fail);
    else
        returnValue = WORealloc(ptr, size);

    va_end(args);
    return returnValue;
}

void * WOReallocfFailv(void *ptr, size_t size, ...)
{
    va_list args;
    va_start(args, size);
    int   fail            = FALSE;
    void    *returnValue    = NULL;

    // get optional failure flag, if present
    if ((fail = va_arg(args, int)))
        returnValue = WOReallocfFail(ptr, size, fail);
    else
        returnValue = WOReallocf(ptr, size);

    va_end(args);
    return returnValue;
}
