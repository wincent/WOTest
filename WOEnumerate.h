//
//  WOEnumerate.h
//  WOTest (imported from WODebug 28/01/06)
//
//  Created by Wincent Colaiuta on 12/10/04.
//
//  Copyright 2004-2006 Wincent Colaiuta.
//  This program is distributed in the hope that it will be useful, but WITHOUT
//  ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
//  FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License
//  in the accompanying file, "LICENSE.txt", for more details.
//

//! \file WOEnumerate.h

// don't attempt to redefine macro (for example, may already be defined by WOCommon)
#ifndef WO_ENUMERATE

/*! WO_ENUMERATE is a convenience macro for expressing the Objective-C enumerator idiom in more compact form. Instead of the standard, longer form:

<pre>NSEnumerator *enumerator = [collection objectEnumerator];
id object = nil;
while ((object = [enumerator nextObject]))
NSLog(@"Object: %@", object);</pre>

The following, shorter form can be used:

<pre>WO_ENUMERATE(collection, object)
NSLog(@"Object: %@", object);</pre>

Or for those that prefer a Perl-like syntax:

<pre>foreach (object, collection)
NSLog(@"Object: %@", object);</pre>

The WO_ENUMERATE macro is also considerably faster than the standard form because is uses a cached IMP (implementation pointer) and selector to speed up repeated invocations of the <tt>nextObject</tt> selector. In informal testing (enumerating over a 10,000,000-item array ten times) the macro performed 49% faster than the standard idiom (averaging 3.6 million objects per second compared with 2.4 million per second).

If passed a nil pointer instead of a valid collection, no iterations are performed. If passed an object which does not respond to the objectEnumerator selector then an exception is raised. Both of these behaviours match the pattern of the standard idiom.

Note that the compiler C dialect must be set to C99 or GNU99 in order to use this macro because of the initialization of variables inside the for expression.

\see  http://mjtsai.com/blog/2003/12/08/cocoa_enumeration and http://rentzsch.com/papers/improvingCocoaObjCEnumeration

*/
#define WO_ENUMERATE(collection, object)                                                                                        \
for (id WOMacroEnumerator_ ## object    = [collection objectEnumerator],                                                        \
     WOMacroSelector_ ## object         = (id)@selector(nextObject),                                                            \
     WOMacroMethod_ ## object           = (id)[WOMacroEnumerator_ ## object methodForSelector:(SEL)WOMacroSelector_ ## object], \
     object                             = WOMacroEnumerator_ ## object ?                                                        \
     ((IMP)WOMacroMethod_ ## object)(WOMacroEnumerator_ ## object, (SEL)WOMacroSelector_ ## object) : nil;                   \
     object != nil;                                                                                                             \
     object = ((IMP)WOMacroMethod_ ## object)(WOMacroEnumerator_ ## object, (SEL)WOMacroSelector_ ## object))

/*! Perl-like syntax for WO_ENUMERATE. */
#define foreach(object, collection) WO_ENUMERATE(collection, object)

#endif /* WO_ENUMERATE */

#ifndef WO_REVERSE_ENUMERATE

#define WO_REVERSE_ENUMERATE(collection, object)                                                                                \
for (id WOMacroEnumerator_ ## object    = [collection reverseObjectEnumerator],                                                 \
     WOMacroSelector_ ## object         = (id)@selector(nextObject),                                                            \
     WOMacroMethod_ ## object           = (id)[WOMacroEnumerator_ ## object methodForSelector:(SEL)WOMacroSelector_ ## object], \
     object = WOMacroEnumerator_ ## object ?                                                                                    \
     ((IMP)WOMacroMethod_ ## object)(WOMacroEnumerator_ ## object,(SEL)WOMacroSelector_ ## object) : nil;                    \
     object != nil;                                                                                                             \
     object = ((IMP)WOMacroMethod_ ## object)(WOMacroEnumerator_ ## object, (SEL)WOMacroSelector_ ## object))

#endif /* WO_REVERSE_ENUMERATE */

#ifndef WO_KEY_ENUMERATE

#define WO_KEY_ENUMERATE(collection, key)                                                                               \
for (id WOMacroEnumerator_ ## key   = [collection keyEnumerator],                                                       \
     WOMacroSelector_ ## key        = (id)@selector(nextObject),                                                        \
     WOMacroMethod_ ## key          = (id)[WOMacroEnumerator_ ## key methodForSelector:(SEL)WOMacroSelector_ ## key],   \
     key = WOMacroEnumerator_ ## key ?                                                                                  \
     ((IMP)WOMacroMethod_ ## key)(WOMacroEnumerator_ ## key, (SEL)WOMacroSelector_ ## key) : nil;                    \
     key != nil;                                                                                                        \
     key = ((IMP)WOMacroMethod_ ## key)(WOMacroEnumerator_ ## key, (SEL)WOMacroSelector_ ## key))

/*! Perl-like syntax for WO_KEY_ENUMERATE. */
#define foreachkey(key, collection) WO_KEY_ENUMERATE(collection, key)

#endif /* WO_KEY_ENUMERATE */
