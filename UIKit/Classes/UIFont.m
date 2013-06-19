/*
 * Copyright (c) 2011, The Iconfactory. All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are met:
 *
 * 1. Redistributions of source code must retain the above copyright
 *    notice, this list of conditions and the following disclaimer.
 *
 * 2. Redistributions in binary form must reproduce the above copyright notice,
 *    this list of conditions and the following disclaimer in the documentation
 *    and/or other materials provided with the distribution.
 *
 * 3. Neither the name of The Iconfactory nor the names of its contributors may
 *    be used to endorse or promote products derived from this software without
 *    specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
 * ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
 * WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
 * DISCLAIMED. IN NO EVENT SHALL THE ICONFACTORY BE LIABLE FOR ANY DIRECT,
 * INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING,
 * BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
 * DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
 * LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE
 * OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF
 * ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

#import "UIFont.h"
#import <Cocoa/Cocoa.h>

static NSString *UIFontSystemFontName = nil;
static NSString *UIFontBoldSystemFontName = nil;
static NSString *UIFontItalicSystemFontName = nil;

static NSString* const kUIFontNameKey = @"UIFontName";
static NSString* const kUIFontPointSizeKey = @"UIFontPointSize";
static NSString* const kUIFontTraitsKey = @"UIFontTraits";
static NSString* const kUISystemFontKey = @"UISystemFont";


@implementation UIFont {
    CTFontRef _font;
}

+ (void) setSystemFontName:(NSString*)name
{
    UIFontSystemFontName = [name copy];
}

+ (void) setBoldSystemFontName:(NSString*)name
{
    UIFontBoldSystemFontName = [name copy];
}

+ (void) setItalicSystemFontName:(NSString*)name
{
    UIFontItalicSystemFontName = [name copy];
}

+ (UIFont*) fontWithName:(NSString*)fontName size:(CGFloat)fontSize
{
    return [self fontWithNSFont:[NSFont fontWithName:fontName size:fontSize]];
}

+ (UIFont*) fontWithNSFont:(NSFont*)nsfont
{
    static NSCache* cache;
    UIFont* font = [cache objectForKey:nsfont];
    if (!font) {
        if (!cache) {
            cache = [[NSCache alloc] init];
        }
        font = [[UIFont alloc] initWithCTFont:(__bridge CTFontRef)nsfont];
        [cache setObject:font forKey:nsfont];
    }
    return font;
}

- (void) dealloc
{
    if (_font) {
        CFRelease(_font), _font = nil;
    }
}

- (instancetype) initWithCoder:(NSCoder*)coder
{
    if (nil != (self = [super init])) {
        NSString* fontName = [coder decodeObjectForKey:kUIFontNameKey];
        CGFloat fontPointSize = [coder decodeFloatForKey:kUIFontPointSizeKey];
        _font = CTFontCreateWithName((__bridge CFStringRef)fontName, fontPointSize, NULL);
        if (!_font) {
            return nil;
        }
    }
    return self;
}

- (instancetype) initWithCTFont:(CTFontRef)font
{
    NSAssert(nil != font, @"???");
    if (nil != (self = [super init])) {
        _font = CFRetain(font);
    }
    return self;
}

- (void) encodeWithCoder:(NSCoder*)coder
{
    [self doesNotRecognizeSelector:_cmd];
}

static NSArray* _getFontCollectionNames(CTFontCollectionRef collection, CFStringRef nameAttr)
{
    NSMutableSet *names = [NSMutableSet set];
    if (collection) {
        CFArrayRef descriptors = CTFontCollectionCreateMatchingFontDescriptors(collection);
        if (descriptors) {
            NSInteger count = CFArrayGetCount(descriptors);
            for (NSInteger i = 0; i < count; i++) {
                CTFontDescriptorRef descriptor = (CTFontDescriptorRef) CFArrayGetValueAtIndex(descriptors, i);
                CFTypeRef name = CTFontDescriptorCopyAttribute(descriptor, nameAttr);
                if(name) {
                    if (CFGetTypeID(name) == CFStringGetTypeID()) {
                        [names addObject:(__bridge NSString*)name];
                    }
                    CFRelease(name);
                }
            }
            CFRelease(descriptors);
        }
    }
    return [names allObjects];
}

+ (NSArray*) familyNames
{
    CTFontCollectionRef collection = CTFontCollectionCreateFromAvailableFonts(NULL);
    NSArray* names = _getFontCollectionNames(collection, kCTFontFamilyNameAttribute);
    if (collection) {
        CFRelease(collection);
    }
    return names;
}

+ (NSArray*) fontNamesForFamilyName:(NSString*)familyName
{
    NSArray* names = nil;
    CTFontDescriptorRef descriptor = CTFontDescriptorCreateWithAttributes((__bridge CFDictionaryRef)@{
        (NSString*)kCTFontFamilyNameAttribute: familyName,
    });
    if (descriptor) {
        CFArrayRef descriptors = CFArrayCreate(NULL, (CFTypeRef*) &descriptor, 1, &kCFTypeArrayCallBacks);
        if (descriptors) {
            CTFontCollectionRef collection = CTFontCollectionCreateWithFontDescriptors(descriptors, NULL);
            names = _getFontCollectionNames(collection, kCTFontNameAttribute);
            if (collection) {
                CFRelease(collection);
            }
            CFRelease(descriptors);
        }
        CFRelease(descriptor);
    }
    return names;
}

+ (UIFont*) systemFontOfSize:(CGFloat)fontSize
{
    NSFont* systemFont = UIFontSystemFontName? [NSFont fontWithName:UIFontSystemFontName size:fontSize] : [NSFont systemFontOfSize:fontSize];
    return [self fontWithNSFont:systemFont];
}

+ (UIFont*) boldSystemFontOfSize:(CGFloat)fontSize
{
    NSFont* systemFont = UIFontBoldSystemFontName? [NSFont fontWithName:UIFontBoldSystemFontName size:fontSize] : [NSFont boldSystemFontOfSize:fontSize];
    return [self fontWithNSFont:systemFont];
}

+ (UIFont*) italicSystemFontOfSize:(CGFloat)fontSize {
    NSFont* systemFont = UIFontItalicSystemFontName? [NSFont fontWithName:UIFontItalicSystemFontName size:fontSize] : [NSFont systemFontOfSize:fontSize];
    return [self fontWithNSFont:systemFont];
}

- (NSString*) fontName
{
    return (__bridge_transfer NSString*)CTFontCopyFullName(_font);
}

- (CGFloat) ascender
{
    return CTFontGetAscent(_font);
}

- (CGFloat) descender
{
    return -CTFontGetDescent(_font);
}

- (CGFloat) pointSize
{
    return CTFontGetSize(_font);
}

- (CGFloat) xHeight
{
    return CTFontGetXHeight(_font);
}

- (CGFloat) capHeight
{
    return CTFontGetCapHeight(_font);
}

- (CGFloat) lineHeight
{
    // this seems to compute heights that are very close to what I'm seeing on iOS for fonts at
    // the same point sizes. however there's still subtle differences between fonts on the two
    // platforms (iOS and Mac) and I don't know if it's ever going to be possible to make things
    // return exactly the same values in all cases.
    return ceilf(self.ascender) - floorf(self.descender) + ceilf(CTFontGetLeading(_font));
}

- (NSString*) familyName
{
    return (__bridge_transfer NSString*)CTFontCopyFamilyName(_font);
}

- (UIFont*) fontWithSize:(CGFloat)fontSize
{
    UIFont* font = nil;
    CTFontRef newFont = CTFontCreateCopyWithAttributes(_font, fontSize, NULL, NULL);
    if (newFont) {
        font = [[UIFont alloc] initWithCTFont:newFont];
        CFRelease(newFont);
        return nil;
    }
    return font;
}

- (NSFont*) NSFont
{
    return (__bridge NSFont*)_font;
}

- (CTFontRef) CTFont
{
    return _font;
}

@end
