//
//  NSException+WOTest.m
//  WOTest
//
//  Created by Wincent Colaiuta on 19 October 2004.
//
//  Copyright 2004-2007 Wincent Colaiuta.
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

#import "NSException+WOTest.h"
#import "NSObject+WOTest.h"

@implementation NSException (WOTest)

+ (NSString *)WOTest_descriptionForException:(id)exception
{
    @try
    {
        if ([NSObject WOTest_object:exception isKindOfClass:[NSException class]])
            return [NSString stringWithFormat:@"%@: %@", [exception name], [exception reason]];
        else if ([NSObject WOTest_object:exception respondsToSelector:@selector(name)])
        {
            NSString *name = nil; // attempt to get name

            if ([NSObject WOTest_objectReturnsId:exception forSelector:@selector(name)])
            {
                name = [exception name];
                if (![NSObject WOTest_object:name isKindOfClass:[NSString class]])
                    @throw self; // the returned id is not an NSString; bail
            }
            else if ([NSObject WOTest_objectReturnsCharacterString:exception forSelector:@selector(name)] ||
                     [NSObject WOTest_objectReturnsConstantCharacterString:exception forSelector:@selector(name)])
            {
                const char *charString = (const char *)[exception name];
                name = [NSString stringWithUTF8String:charString];
            }

            NSString *reason = nil; // attempt to get reason
            if ([NSObject WOTest_object:exception respondsToSelector:@selector(reason)])
            {
                if ([NSObject WOTest_objectReturnsId:exception forSelector:@selector(reason)])
                {
                    reason = [exception reason];
                    if (![NSObject WOTest_object:reason isKindOfClass:[NSString class]])
                        @throw self; // the returned id is not an NSString; bail
                }
                else if ([NSObject WOTest_objectReturnsCharacterString:exception forSelector:@selector(reason)] ||
                         [NSObject WOTest_objectReturnsConstantCharacterString:exception forSelector:@selector(reason)])
                {
                    const char *charString = (const char *)[exception reason];
                    reason = [NSString stringWithUTF8String:charString];
                }
            }

            if (name && reason)
                return [NSString stringWithFormat:@"%@: %@", name, reason];
            else if (name)
                return [NSString stringWithFormat:@"%@ (%x)", name, exception];
            else if (reason)
                return [NSString stringWithFormat:@"%@ (%x)", reason, exception];
        }
        else
        {
            return [NSObject WOTest_descriptionForObject:exception];
        }
    }
    @catch (id e)
    {
        // fall through
    }

    // last resort
    return [NSString stringWithFormat:@"unknown exception (%x)", exception];
}

+ (NSString *)WOTest_nameForException:(id)exception
{
    NSString *returnString = nil;
    @try
    {
        if (!exception)
            returnString = @"no exception";
        else if ([NSObject WOTest_object:exception isKindOfClass:[NSException class]])
            returnString = [exception name];
        else if ([NSObject WOTest_object:exception respondsToSelector:@selector(name)])
        {
            if ([NSObject WOTest_objectReturnsId:exception forSelector:@selector(name)])
            {
                returnString = [exception name];
                if (![NSObject WOTest_object:returnString isKindOfClass:[NSString class]])
                    @throw self; // the returned id is not an NSString; bail
            }
            else if ([NSObject WOTest_objectReturnsCharacterString:exception forSelector:@selector(name)] ||
                     [NSObject WOTest_objectReturnsConstantCharacterString:exception forSelector:@selector(name)])
            {
                const char *charString = (const char *)[exception name];
                returnString = [NSString stringWithUTF8String:charString];
            }
        }
        else
            returnString = [NSObject WOTest_descriptionForObject:exception];
    }
    @catch (id e)
    {
        returnString = @"(exception caught trying to determine exception name)";
    }
    return returnString;
}

// TODO: replace with var_args versions
+ (NSException *)WOTest_exceptionWithName:(NSString *)aName reason:(NSString *)aReason inFile:(char *)path atLine:(int)line
{
    NSDictionary *theUserInfo = [NSDictionary dictionaryWithObjectsAndKeys:
        [NSString stringWithUTF8String:path],   WO_TEST_USERINFO_PATH,
        [NSNumber numberWithInt:line],          WO_TEST_USERINFO_LINE, nil];
    return [self exceptionWithName:aName reason:aReason userInfo:theUserInfo];
}

+ (void)WOTest_raise:(NSString *)aName reason:(NSString *)aReason inFile:(char *)path atLine:(int)line
{
    [[self WOTest_exceptionWithName:aName reason:aReason inFile:path atLine:line] raise];
}

@end
