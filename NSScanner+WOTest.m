//
//  NSScanner+WOTest.m
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
//  $Id: NSScanner+WOTest.m 208 2007-07-07 19:02:28Z wincent $

#import "NSScanner+WOTest.h"
#import <objc/objc-class.h>
#import "NSString+WOTest.h"
#import "NSValue+WOTest.h"

#define WO_LEGAL_IDENTIFIER_CHARACTERS  @"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789_"

@implementation NSScanner (WOTest)

- (BOOL)WOTest_peekCharacter:(unichar *)value;
{
    NSParameterAssert(value != NULL);
    unsigned scanLocation   = [self scanLocation];
    NSString *string        = [self string];
    if (string && ([string length] > scanLocation))
    {
        *value = [string characterAtIndex:scanLocation];
        return YES;
    }   
    return NO;
}

- (BOOL)WOTest_scanCharacter:(unichar *)value;
{    
    unichar  character;
    if ([self WOTest_peekCharacter:&character])
    {
        if (value)
            *value = character;
        [self setScanLocation:[self scanLocation] + 1];
        return YES;
    }
    return NO;
}

- (BOOL)WOTest_scanCharacterFromSet:(NSCharacterSet *)scanSet intoChar:(unichar *)value;
{
    if (!scanSet) return NO; // nothing to do
    
    unsigned    scanLocation = [self scanLocation];
    unichar     character;
    if ([self WOTest_scanCharacter:&character] && [scanSet characterIsMember:character])
    {
        if (value)
            *value = character;
        return YES;
    }
    
    [self setScanLocation:scanLocation]; // revert
    return NO;
}

- (BOOL)WOTest_scanReturnTypeIntoString:(NSString **)stringValue
{
    if ([self scanLocation] != 0)
        return NO; // the return type must be at the start of the string
    
    // scan a single type (the first one will be the return type)
    return [self WOTest_scanTypeIntoString:stringValue];
}

- (BOOL)WOTest_scanTypeIntoString:(NSString **)stringValue
{
    unsigned    scanLocation        = [self scanLocation];
    NSString    *qualifiers         = nil;
    NSString    *type               = nil;
    
    // scan any qualifers that are present
    if (![self WOTest_scanQualifiersIntoString:&qualifiers]) qualifiers = @"";
    
    // scan type
    if ([self WOTest_scanBitfieldIntoString:&type]          ||
        [self scanPointerIntoString:&type]                  ||
        [self WOTest_scanArrayIntoString:&type]             ||
        [self WOTest_scanStructIntoString:&type]            ||
        [self WOTest_scanUnionIntoString:&type]             ||
        [self WOTest_scanNonCompoundTypeIntoString:&type])
    {
        // success
        if (stringValue)
            *stringValue = 
                [NSString stringWithFormat:@"%@%@", qualifiers, type];
        return YES;        
    }
    
    [self setScanLocation:scanLocation]; // revert
    return NO;
}

- (BOOL)WOTest_scanQualifiersIntoString:(NSString **)stringValue
{    
    NSCharacterSet *qualifiersSet = 
    [NSCharacterSet characterSetWithCharactersInString:
        [NSString stringWithFormat:@"%C%C%C%C%C%C%C",
            WO_ENCODING_QUALIFIER_CONST,    WO_ENCODING_QUALIFIER_IN,
            WO_ENCODING_QUALIFIER_INOUT,    WO_ENCODING_QUALIFIER_OUT,
            WO_ENCODING_QUALIFIER_BYCOPY,   WO_ENCODING_QUALIFIER_BYREF,
            WO_ENCODING_QUALIFIER_ONEWAY]];
    
    return [self scanCharactersFromSet:qualifiersSet
                            intoString:stringValue];
}

- (BOOL)WOTest_scanNonCompoundTypeIntoString:(NSString **)stringValue
{
    NSCharacterSet *nonCompoundSet = 
    [NSCharacterSet characterSetWithCharactersInString:
        [NSString stringWithFormat:@"%C%C%C%C%C%C%C%C%C%C%C%C%C%C%C%C%C%C%C",
            _C_ID,      _C_CLASS,   _C_SEL,     _C_CHR,     _C_UCHR,    
            _C_SHT,     _C_USHT,    _C_INT,     _C_UINT,    _C_LNG,
            _C_ULNG,    _C_LNGLNG,  _C_ULNGLNG, _C_FLT,     _C_DBL,     
            _C_99BOOL,  _C_VOID,    _C_UNDEF,   _C_CHARPTR]];
    
    unichar character;
    if ([self WOTest_scanCharacterFromSet:nonCompoundSet intoChar:&character])
    {
        if (stringValue)
            *stringValue = [NSString WOTest_stringWithCharacter:character]; 
        return YES;
    }
     
    return NO;
}

- (BOOL)WOTest_scanBitfieldIntoString:(NSString **)stringValue
{
    unsigned scanLocation = [self scanLocation];
    
    unichar marker; // look for bitfield marker
    int num;        // scan number of bits
    if ([self WOTest_scanCharacter:&marker] && (marker == _C_BFLD) && [self scanInt:&num])
    {
        if (stringValue)
            *stringValue = [NSString stringWithFormat:@"%C%d", marker, num];
        return YES;
    }
    
    [self setScanLocation:scanLocation]; // revert
    return NO;
}

- (BOOL)WOTest_scanArrayIntoString:(NSString **)stringValue
{
    unsigned scanLocation = [self scanLocation];
    
    unichar startMarker, endMarker; // look for array start marker
    int num;                        // scan number of elements
    NSString *type;                 // scan type of elements
    
    if ([self WOTest_scanCharacter:&startMarker] && (startMarker == _C_ARY_B) &&
        [self scanInt:&num] && [self WOTest_scanTypeIntoString:&type] &&
        [self WOTest_scanCharacter:&endMarker] && (endMarker == _C_ARY_E))
    {
        if (stringValue)
            *stringValue = [NSString stringWithFormat:@"%C%d%@%C", startMarker, num, type, endMarker];
        return YES;
    }
    
    
    [self setScanLocation:scanLocation]; // revert
    return NO;
}

- (BOOL)WOTest_scanIdentifierIntoString:(NSString **)stringValue
{
    unsigned scanLocation = [self scanLocation];
    
    unichar firstChar, equalsChar;
    if ([self WOTest_peekCharacter:&firstChar])
    {
        // identifiers must begin with a letter or underscore (no numbers!)
        if (((firstChar >= 'a') && (firstChar <= 'z')) || 
            ((firstChar >= 'A') && (firstChar <= 'Z')) ||
            (firstChar == '_'))
        {
            NSString *identifier;   // scan identifier
            if ([self scanCharactersFromSet:
                [NSCharacterSet characterSetWithCharactersInString:
                    WO_LEGAL_IDENTIFIER_CHARACTERS]
                                 intoString:&identifier])
            {
                if ([self WOTest_peekCharacter:&equalsChar] && (equalsChar == '='))
                {
                    if (stringValue)
                        *stringValue = identifier;
                    return YES;
                }
            }
        }
        else // special case: check for anonymous/unknown identifiers ('?')
        {
            if ([self WOTest_scanCharacter:&firstChar] && (firstChar == _C_UNDEF) &&
                [self WOTest_peekCharacter:&equalsChar] && (equalsChar == '='))
            {
                if (stringValue)
                    *stringValue = [NSString WOTest_stringWithCharacter:_C_UNDEF];
                return YES;
            }
        }
    }
    
    [self setScanLocation:scanLocation]; // revert
    return NO;
}

- (BOOL)WOTest_scanStructIntoString:(NSString **)stringValue
{
    unsigned scanLocation = [self scanLocation];
    
    unichar startMarker, endMarker;
    NSString *identifier;
    if ([self WOTest_scanCharacter:&startMarker] && (startMarker == _C_STRUCT_B))
    {
        // scan optional identifier
        if ([self WOTest_scanIdentifierIntoString:&identifier])
        {
            [self WOTest_scanCharacter:NULL]; // scan past "="
            
            // prepare identifier for later insertion (append equals sign)
            identifier = [NSString stringWithFormat:@"%@=", identifier];
        }
        else // optional identifier not found
            identifier = @"";
        
        // scan types until you hit end marker
        NSMutableString *types = [NSMutableString string];
        NSString *type;
        while ([self WOTest_scanTypeIntoString:&type])
        {
            [types appendString:type];
            [self scanInt:nil]; // skip over any superfluous numbers in string
        }
        
        // scan end marker
        if ([self WOTest_scanCharacter:&endMarker] && (endMarker == _C_STRUCT_E))
        {
            if (stringValue)
                *stringValue = [NSString stringWithFormat:@"%C%@%@%C", startMarker, identifier, types, endMarker];
            return YES;
        }
    }
    [self setScanLocation:scanLocation]; // revert
    return NO;
}

- (BOOL)WOTest_scanUnionIntoString:(NSString **)stringValue
{
    unsigned scanLocation = [self scanLocation];
    
    unichar startMarker, equalsMarker, endMarker;
    NSString *identifier;
    if ([self WOTest_scanCharacter:&startMarker] && (startMarker == _C_UNION_B))
    {
        // scan optional identifier
        unsigned identifierLocation = [self scanLocation];
        if ([self WOTest_scanIdentifierIntoString:&identifier] &&
            [self WOTest_scanCharacter:&equalsMarker] && (equalsMarker == '='))
            // prepare identifier for later insertion (append equals sign)
            identifier = [NSString stringWithFormat:@"%@=", identifier];
        else // optional identifier not found
        {
            identifier = @"";
            [self setScanLocation:identifierLocation];
        }

        // scan types until you hit end marker
        NSMutableString *types = [NSMutableString string];
        NSString *type;
        while ([self WOTest_scanTypeIntoString:&type])
        {
            [types appendString:type];
            [self scanInt:nil]; // skip over any superfluous numbers in string
        }
        
        // scan end marker
        if ([self WOTest_scanCharacter:&endMarker] && (endMarker == _C_UNION_E))
        {
            if (stringValue)
                *stringValue = [NSString stringWithFormat:@"%C%@%@%C", startMarker, identifier, types, endMarker];
            return YES;
        }
    }
        
    [self setScanLocation:scanLocation]; // revert
    return NO;    
}

- (BOOL)scanPointerIntoString:(NSString **)stringValue
{
    unsigned scanLocation = [self scanLocation];
    
    unichar marker; // look for pointer marker
    NSString *type; // scan type to which pointer points
    if ([self WOTest_scanCharacter:&marker] && (marker == _C_PTR) && [self WOTest_scanTypeIntoString:&type])
    {
        if (stringValue)
            *stringValue = [NSString stringWithFormat:@"%C%@", marker, type];
        return YES;
    }
    
    [self setScanLocation:scanLocation]; // revert
    return NO;
}

@end
