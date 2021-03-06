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

#import "UIColor+UIPrivate.h"
#import "UIColorRep.h"
#import "UIImage+UIPrivate.h"
#import "UIGraphics.h"
#import <AppKit/NSColor.h>
#import <AppKit/NSColorSpace.h>

static UIColor *BlackColor = nil;
static UIColor *DarkGrayColor = nil;
static UIColor *LightGrayColor = nil;
static UIColor *WhiteColor = nil;
static UIColor *GrayColor = nil;
static UIColor *RedColor = nil;
static UIColor *GreenColor = nil;
static UIColor *BlueColor = nil;
static UIColor *CyanColor = nil;
static UIColor *YellowColor = nil;
static UIColor *MagentaColor = nil;
static UIColor *OrangeColor = nil;
static UIColor *PurpleColor = nil;
static UIColor *BrownColor = nil;
static UIColor *ClearColor = nil;

@implementation UIColor {
    id _representations;
}

- (instancetype) initWithNSColor:(NSColor *)aColor
{
    if (!aColor) {
        self = nil;
    } else {
        NSColor *c = [aColor colorUsingColorSpace:[NSColorSpace deviceRGBColorSpace]];
        CGFloat components[[c numberOfComponents]];
        [c getComponents:components];
        CGColorRef color = CGColorCreate([[c colorSpace] CGColorSpace], components);
        self = [self initWithCGColor:color];
        CGColorRelease(color);
    }
    return self;
}

- (instancetype) initWithCoder:(NSCoder*)coder
{
    CGFloat r = [coder decodeFloatForKey:@"UIRed"];
    CGFloat g = [coder decodeFloatForKey:@"UIGreen"];
    CGFloat b = [coder decodeFloatForKey:@"UIBlue"];
    CGFloat a = [coder decodeFloatForKey:@"UIAlpha"];
    if (nil != (self = [self initWithNSColor:[NSColor colorWithCalibratedRed:r green:g blue:b alpha:a]])) {
        //
    }
    return self;
}

- (void) encodeWithCoder:(NSCoder*)coder
{
    [self doesNotRecognizeSelector:_cmd];
}


+ (instancetype) colorWithNSColor:(NSColor *)c
{
    return [[self alloc] initWithNSColor:c];
}

+ (UIColor*) colorWithWhite:(CGFloat)white alpha:(CGFloat)alpha
{
    return [[self alloc] initWithWhite:white alpha:alpha];
}

+ (UIColor*) colorWithHue:(CGFloat)hue saturation:(CGFloat)saturation brightness:(CGFloat)brightness alpha:(CGFloat)alpha
{
    return [[self alloc] initWithHue:hue saturation:saturation brightness:brightness alpha:alpha];
}

+ (UIColor*) colorWithRed:(CGFloat)red green:(CGFloat)green blue:(CGFloat)blue alpha:(CGFloat)alpha
{
    return [[self alloc] initWithRed:red green:green blue:blue alpha:alpha];
}

+ (UIColor*) colorWithCGColor:(CGColorRef)ref
{
    return [[self alloc] initWithCGColor:ref];
}

+ (UIColor*) colorWithPatternImage:(UIImage *)patternImage
{
    return [[self alloc] initWithPatternImage:patternImage];
}

+ (UIColor*) blackColor			{ return BlackColor ?: (BlackColor = [[self alloc] initWithWhite:0.f alpha:1.f]); }
+ (UIColor*) darkGrayColor		{ return DarkGrayColor ?: (DarkGrayColor = [[self alloc] initWithWhite:0.333f alpha:1.f]); }
+ (UIColor*) lightGrayColor		{ return LightGrayColor ?: (LightGrayColor = [[self alloc] initWithWhite:0.667f alpha:1.f]); }
+ (UIColor*) whiteColor			{ return WhiteColor ?: (WhiteColor = [[self alloc] initWithWhite:1.f alpha:1.f]); }
+ (UIColor*) grayColor			{ return GrayColor ?: (GrayColor = [[self alloc] initWithWhite:0.5f alpha:1.f]); }
+ (UIColor*) redColor			{ return RedColor ?: (RedColor = [[self alloc] initWithRed:1.f green:0.f blue:0.f alpha:1.f]); }
+ (UIColor*) greenColor			{ return GreenColor ?: (GreenColor = [[self alloc] initWithRed:0.f green:1.f blue:0.f alpha:1.f]); }
+ (UIColor*) blueColor			{ return BlueColor ?: (BlueColor = [[self alloc] initWithRed:0.f green:0.f blue:1.f alpha:1.f]); }
+ (UIColor*) cyanColor			{ return CyanColor ?: (CyanColor = [[self alloc] initWithRed:0.f green:1.f blue:1.f alpha:1.f]); }
+ (UIColor*) yellowColor		{ return YellowColor ?: (YellowColor = [[self alloc] initWithRed:1.f green:1.f blue:0.f alpha:1.f]); }
+ (UIColor*) magentaColor		{ return MagentaColor ?: (MagentaColor = [[self alloc] initWithRed:1.f green:0.f blue:1.f alpha:1.f]); }
+ (UIColor*) orangeColor		{ return OrangeColor ?: (OrangeColor = [[self alloc] initWithRed:1.f green:0.5f blue:0.f alpha:1.f]); }
+ (UIColor*) purpleColor		{ return PurpleColor ?: (PurpleColor = [[self alloc] initWithRed:0.5f green:0.f blue:0.5f alpha:1.f]); }
+ (UIColor*) brownColor			{ return BrownColor ?: (BrownColor = [[self alloc] initWithRed:0.6f green:0.4f blue:0.2f alpha:1.f]); }
+ (UIColor*) clearColor			{ return ClearColor ?: (ClearColor = [[self alloc] initWithWhite:0.f alpha:0.f]); }

- (instancetype) initWithWhite:(CGFloat)white alpha:(CGFloat)alpha
{
    CGColorRef color = CGColorCreateGenericGray(white, alpha);
    if (nil == color) {
        return nil;
    }
    self = [self initWithCGColor:color];
    CGColorRelease(color);
    return self;
}

- (instancetype) initWithHue:(CGFloat)hue saturation:(CGFloat)saturation brightness:(CGFloat)brightness alpha:(CGFloat)alpha
{
    return [self initWithNSColor:[NSColor colorWithDeviceHue:hue saturation:saturation brightness:brightness alpha:alpha]];
}

- (instancetype) initWithRed:(CGFloat)red green:(CGFloat)green blue:(CGFloat)blue alpha:(CGFloat)alpha
{
    CGColorRef color = CGColorCreateGenericRGB(red, green, blue, alpha);
    if (nil == color) {
        return nil;
    }
    self = [self initWithCGColor:color];
    CGColorRelease(color);
    return self;
}

- (instancetype) _initWithRepresentations:(NSArray *)reps
{
    if ([reps count] == 0) {
        self = nil;
    } else if ((self=[super init])) {
        _representations = [reps copy];
    }
    return self;
}

- (instancetype) initWithCGColor:(CGColorRef)ref
{
    return [self _initWithRepresentations:@[[[UIColorRep alloc] initWithCGColor:ref]]];
}

- (instancetype) initWithPatternImage:(UIImage *)patternImage
{
    NSArray *imageReps = [patternImage _representations];
    NSMutableArray *colorReps = [NSMutableArray arrayWithCapacity:[imageReps count]];

    for (UIImageRep *imageRep in imageReps) {
        [colorReps addObject:[[UIColorRep alloc] initWithPatternImageRepresentation:imageRep]];
    }
    
    return [self _initWithRepresentations:colorReps];
}

- (UIColorRep*) _bestRepresentationForProposedScale:(CGFloat)scale
{
    UIColorRep *bestRep = nil;
    
    for (UIColorRep *rep in _representations) {
        if (rep.scale > scale) {
            break;
        } else {
            bestRep = rep;
        }
    }
    
    return bestRep ?: [_representations lastObject];
}

- (BOOL)_isOpaque
{
    for (UIColorRep *rep in _representations) {
        if (!rep.opaque) {
            return NO;
        }
    }

    return YES;
}

- (void)set
{
    [self setFill];
    [self setStroke];
}

- (void)setFill
{
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(ctx, [self _bestRepresentationForProposedScale:_UIGraphicsGetContextScaleFactor(ctx)].CGColor);
}

- (void)setStroke
{
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGContextSetStrokeColorWithColor(ctx, [self _bestRepresentationForProposedScale:_UIGraphicsGetContextScaleFactor(ctx)].CGColor);
}

- (CGColorRef)CGColor
{
    return [self _bestRepresentationForProposedScale:1].CGColor;
}

- (UIColor *)colorWithAlphaComponent:(CGFloat)alpha
{
    CGColorRef newColor = CGColorCreateCopyWithAlpha(self.CGColor, alpha);
    UIColor *resultingUIColor = [UIColor colorWithCGColor:newColor];
    CGColorRelease(newColor);
    return resultingUIColor;
}

- (NSColor *)NSColor
{
    CGColorRef color = self.CGColor;
    NSColorSpace *colorSpace = [[NSColorSpace alloc] initWithCGColorSpace:CGColorGetColorSpace(color)];
    const NSInteger numberOfComponents = CGColorGetNumberOfComponents(color);
    const CGFloat *components = CGColorGetComponents(color);
    NSColor *theColor = [NSColor colorWithColorSpace:colorSpace components:components count:numberOfComponents];
    return theColor;
}

- (NSString *)description
{
    // The color space string this gets isn't exactly the same as Apple's implementation.
    // For instance, Apple's implementation returns UIDeviceRGBColorSpace for [UIColor redColor]
    // This implementation returns kCGColorSpaceDeviceRGB instead.
    // Apple doesn't actually define UIDeviceRGBColorSpace or any of the other responses anywhere public,
    // so there isn't any easy way to emulate it.
    CGColorSpaceRef colorSpaceRef = CGColorGetColorSpace(self.CGColor);
	CFStringRef colorSpaceName = CGColorSpaceCopyName(colorSpaceRef);
    NSString *colorSpace = [NSString stringWithFormat:@"%@", (__bridge NSString*) colorSpaceName];
	CFRelease(colorSpaceName);

    const size_t numberOfComponents = CGColorGetNumberOfComponents(self.CGColor);
    const CGFloat *components = CGColorGetComponents(self.CGColor);
    NSMutableString *componentsString = [NSMutableString stringWithString:@"{"];
    
    for (NSInteger index = 0; index < numberOfComponents; index++) {
        if (index) [componentsString appendString:@", "];
        [componentsString appendFormat:@"%g", components[index]];
    }
    [componentsString appendString:@"}"];

    return [NSString stringWithFormat:@"<%@: %p; colorSpace = %@; components = %@>", [self className], self, colorSpace, componentsString];
}

- (NSString*) colorSpaceName
{
    return (__bridge_transfer NSString*)CGColorSpaceCopyName(CGColorGetColorSpace([self CGColor]));
}

- (BOOL) isEqual:(id)object {
    if (![object isKindOfClass:[self class]]) {
        return NO;
    }
    UIColor* color = (UIColor*) object;    
    return CGColorEqualToColor(self.CGColor, color.CGColor);
}

@end
