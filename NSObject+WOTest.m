//
//  NSObject+WOTest.m
//  WOTest
//
//  Created by Wincent Colaiuta on 12 June 2005.
//
//  Copyright 2005-2007 Wincent Colaiuta.
//  This program is free software: you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation, either version 3 of the License, or
//  (at your option) any later version.
//
//  This program is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License
//  along with this program.  If not, see <http://www.gnu.org/licenses/>.
//

// category header
#import "NSObject+WOTest.h"

// system headers
#import <objc/objc-runtime.h>
#import <objc/Protocol.h>

// other headers
#import "NSScanner+WOTest.h"
#import "NSValue+WOTest.h"

@implementation NSObject (WOTest)

+ (NSString *)WOTest_descriptionForObject:(id)anObject
{
    if (!anObject) return @"(nil)";
    
    @try
    {
        // special case handling for NSValue objects
        if ([self WOTest_object:anObject isKindOfClass:[NSValue class]])
            return [(NSValue *)anObject WOTest_description];
        
        // fallback case: try "description" selector
        if ([self WOTest_object:anObject respondsToSelector:@selector(description)])
        {
            NSString *returnType = [self WOTest_returnTypeForObject:anObject selector:@selector(description)];
            
            if ([self WOTest_isIdReturnType:returnType])
            {
                NSString *description = [anObject description];
                if ([self WOTest_object:description isKindOfClass:[NSString class]])
                    return description;
            }
            else if ([self WOTest_isCharacterStringReturnType:returnType] || 
                     [self WOTest_isConstantCharacterStringReturnType:returnType])
            {
                const char *charString = (const char *)[anObject description];
                return [NSString stringWithUTF8String:charString];
            }
        }
    }
    @catch (id e) 
    {
        // fall through
    }
    return NSStringFromClass(object_getClass(anObject)); // last resort
}

+ (BOOL)WOTest_isRegisteredClass:(Class)aClass
{
    if (!aClass) return NO;
    
    BOOL    isRegisteredClass   = NO;
    int     numClasses          = 0;
    int     newNumClasses       = objc_getClassList(NULL, 0);
    Class   *classes            = NULL;
    
    // get list of all classes on the system
    while (numClasses < newNumClasses)
    {
        numClasses          = newNumClasses;
        size_t bufferSize   = sizeof(Class) * numClasses;
        classes             = realloc(classes, bufferSize);
        NSAssert1((classes != NULL), @"realloc() failed (size %d)", bufferSize);
        newNumClasses       = objc_getClassList(classes, numClasses);
    }
    
    if (classes)
    {
        for (int i = 0; i < newNumClasses; i++)
        { 
            if (aClass == classes[i])   // found in list!
            {
                isRegisteredClass = YES;
                break;
            }
        }
        free(classes);
    }
    return isRegisteredClass;
}

/*! Returns YES if aClass is the metaclass of a class that is registered with the runtime. */
+ (BOOL)WOTest_isMetaClass:(Class)aClass
{
    if (!aClass) return NO;
    
    BOOL    isMetaClass     = NO;
    int     numClasses      = 0;
    int     newNumClasses   = objc_getClassList(NULL, 0);
    Class   *classes        = NULL;
    
    // get a list of all classes on the system
    // get list of all classes on the system
    while (numClasses < newNumClasses)
    {
        numClasses          = newNumClasses;
        size_t bufferSize   = sizeof(Class) * numClasses;
        classes             = realloc(classes, bufferSize);
        NSAssert1((classes != NULL), @"realloc() failed (size %d)", bufferSize);
        newNumClasses       = objc_getClassList(classes, numClasses);
    }
    
    if (classes)
    {
        for (int i = 0; i < newNumClasses; i++)
        {
            if (class_isMetaClass(classes[i]))  // looking at a meta class
            {
                if (aClass == classes[i])		// found in list!
                {
                    isMetaClass = YES;
                    break;
                }
            }
            else // not looking at a meta class, look up its meta class
            {
                if (aClass == object_getClass(classes[i])) // found it!
                {
                    isMetaClass = YES;
                    break;
                }
            }
        }
        free(classes);
    }
    return isMetaClass;    
}

+ (BOOL)WOTest_object:(id)anObject isKindOfClass:(Class)aClass
{
    if (!aClass)    return NO;
    NSParameterAssert([self WOTest_isRegisteredClass:aClass] || [self WOTest_isMetaClass:aClass]);
    if (!anObject)  return NO;
    Class objectClass = object_getClass(anObject);
    
    if (objectClass == aClass)
        return YES;
    else
    {
		// check superclass
        Class superClass = class_getSuperclass(objectClass);
		if (superClass)
			return [self WOTest_instancesOfClass:superClass areKindOfClass:aClass];                
    }
    
    return NO; // give up
}

+ (BOOL)WOTest_instancesOfClass:(Class)aClass areKindOfClass:(Class)otherClass
{
    if (!aClass)        return NO;
    NSParameterAssert([self WOTest_isRegisteredClass:aClass] || [self WOTest_isMetaClass:aClass]);
    if (!otherClass)    return NO;
    NSParameterAssert([self WOTest_isRegisteredClass:otherClass] || [self WOTest_isMetaClass:otherClass]);
    
    if (aClass == otherClass)
        return YES;
	
	Class superClass = class_getSuperclass(aClass);
    if (superClass)
        return [self WOTest_instancesOfClass:superClass areKindOfClass:otherClass];
    
    return NO; // give up
}

+ (BOOL)WOTest_class:(Class)aClass respondsToSelector:(SEL)aSelector
{
    if (!aClass) return NO;
    NSParameterAssert([self WOTest_isRegisteredClass:aClass] || [self WOTest_isMetaClass:aClass]);
    if (!aSelector) return NO;
    return (class_getClassMethod(aClass, aSelector) ? YES : NO);
}

+ (BOOL)WOTest_object:(id)anObject respondsToSelector:(SEL)aSelector
{
    if (!anObject)  return NO;
    if (!aSelector) return NO;
    Class theClass = object_getClass(anObject);
    if (class_isMetaClass(theClass))
        return (class_getClassMethod(theClass, aSelector) ? YES : NO);
    else
        return (class_getInstanceMethod(theClass, aSelector) ? YES : NO);
}

+ (BOOL)WOTest_instancesOfClass:(Class)aClass respondToSelector:(SEL)aSelector
{
    if (!aClass) return NO;
    NSParameterAssert([self WOTest_isRegisteredClass:aClass] || [self WOTest_isMetaClass:aClass]);
    if (!aSelector) return NO;
    return (class_getInstanceMethod(aClass, aSelector) ? YES : NO);
}

+ (BOOL)WOTest_instancesOfClass:(Class)aClass conformToProtocol:(Protocol *)aProtocol
{
    if (!aClass)    return NO;
    NSParameterAssert([self WOTest_isRegisteredClass:aClass] || [self WOTest_isMetaClass:aClass]);
    if (!aProtocol) return NO;
	if (class_conformsToProtocol(aClass, aProtocol))
		return YES;
	Class superClass = class_getSuperclass(aClass);
	if (superClass)
        return [self WOTest_instancesOfClass:superClass conformToProtocol:aProtocol];
    
    return NO;  // give up
}

+ (NSString *)WOTest_returnTypeForClass:(Class)aClass selector:(SEL)aSelector
{
    NSParameterAssert(aClass != NULL);
    NSParameterAssert([self WOTest_isRegisteredClass:aClass] || [self WOTest_isMetaClass:aClass]);
    NSParameterAssert(aSelector != NULL);
    Method theMethod = class_getClassMethod(aClass, aSelector);
    
    if (theMethod == NULL) // class does not respond to this selector
        return nil;

    // get return type and list of arguments
	char *returnType = method_copyReturnType(theMethod);
	if (returnType)
	{
		NSString *returnString = [[NSString alloc] initWithUTF8String:returnType];
		free(returnType);
		return returnString;
	}
	return nil;
}

+ (NSString *)WOTest_returnTypeForObject:(id)anObject selector:(SEL)aSelector
{
    NSParameterAssert(anObject != nil);
    NSParameterAssert(aSelector != NULL);
    Method theMethod = class_getInstanceMethod(object_getClass(anObject), aSelector);
		
	if (theMethod == NULL) // object does not respond to this selector
        return nil;
	
    // get return type and list of arguments
	char *returnType = method_copyReturnType(theMethod);
	if (returnType)
	{
		NSString *typeString = [NSString stringWithUTF8String:returnType];
		free(returnType);
		return typeString;
	}
	return nil;    
}

+ (BOOL)WOTest_isIdReturnType:(NSString *)returnType
{
    return [NSValue WOTest_typeIsObject:returnType];
}

+ (BOOL)WOTest_isCharacterStringReturnType:(NSString *)returnType
{
    return [NSValue WOTest_typeIsCharacterString:returnType];
}

+ (BOOL)WOTest_isConstantCharacterStringReturnType:(NSString *)returnType
{
    return [NSValue WOTest_typeIsConstantCharacterString:returnType];
}

+ (BOOL)WOTest_objectReturnsId:(id)anObject forSelector:(SEL)aSelector
{
    NSParameterAssert(anObject != nil);
    NSParameterAssert(aSelector != NULL);
    return [self WOTest_isIdReturnType:[self WOTest_returnTypeForObject:anObject selector:aSelector]];
}

+ (BOOL)WOTest_objectReturnsCharacterString:(id)anObject forSelector:(SEL)aSelector
{
    NSParameterAssert(anObject != nil);
    NSParameterAssert(aSelector != NULL);
    return [self WOTest_isCharacterStringReturnType:[self WOTest_returnTypeForObject:anObject selector:aSelector]];
}

+ (BOOL)WOTest_objectReturnsConstantCharacterString:(id)anObject forSelector:(SEL)aSelector
{
    NSParameterAssert(anObject != nil);
    NSParameterAssert(aSelector != NULL);
    return [self WOTest_isConstantCharacterStringReturnType:[self WOTest_returnTypeForObject:anObject selector:aSelector]];    
}

@end
