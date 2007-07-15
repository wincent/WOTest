//
//  NSString+WOTest.m
//  WOTest
//
//  Created by Wincent Colaiuta on 07 June 2005.
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

#import "NSString+WOTest.h"

void _WOLog(NSString *format, ...)
{
    if (!format) return; // bail
    va_list args;
    va_start(args, format);
    NSString *string = [[NSString alloc] initWithFormat:format arguments:args];
    if (string)
    {
        fprintf(stdout, "%s\n", [string UTF8String]);
        fflush(NULL); // flush all open streams (not just stdout)
        [string release];
    }
    va_end(args);
}

void _WOLogv(NSString *format, va_list args)
{
    if (!format) return; // bail
    NSString *string = [[NSString alloc] initWithFormat:format arguments:args];
    if (string)
    {
        fprintf(stdout, "%s\n", [string UTF8String]);
        fflush(NULL); // flush all open streams (not just stdout)
        [string release]; 
    }
}

@implementation NSString (WOTest)

+ (NSString *)WOTest_stringWithFormat:(NSString *)format arguments:(va_list)argList
{
    return [[[NSString alloc] initWithFormat:format 
                                   arguments:argList] autorelease];
}

+ (NSString *)WOTest_stringWithCharacter:(unichar)character
{
    return [NSString stringWithFormat:@"%C", character];
}

- (NSString *)WOTest_stringByConvertingToAbsolutePath
{
    if ([self isAbsolutePath])
        return self;
    NSString *path = [[NSFileManager defaultManager] currentDirectoryPath];
 
    // TODO: strictly speaking, should write a method stringByAppendPathComponents (see draft above)
    return [path stringByAppendingPathComponent:self];
}

- (NSString *)WOTest_stringByCollapsingWhitespace
{
    NSCharacterSet *whitespace = [NSCharacterSet whitespaceAndNewlineCharacterSet];
    NSMutableString *temp = [NSMutableString stringWithString:self];
    unsigned int length = [temp length];
    for (unsigned int i = 0; i < length; i++)
    {
        if ([whitespace characterIsMember:[temp characterAtIndex:i]])
        {
            // convert newslines, tabs etc to spaces
            [temp replaceCharactersInRange:NSMakeRange(i, 1) withString:@" "];
            
            // was the last character also a space?
            if ((i > 0) && ([temp characterAtIndex:i - 1] == ' '))
            {
                // two consecutive whitespace characters, delete the second
                [temp deleteCharactersInRange:NSMakeRange(i - 1, 1)];
                i--;
                length--;
            }
        }
    }
    return [NSString stringWithString:temp]; // return immutable, autoreleased
}

- (NSString *)WOTest_stringByAppendingCharacter:(unichar)character
{
    return [self stringByAppendingFormat:@"%C", character];
}

@end
