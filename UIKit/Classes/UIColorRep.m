/*
 * Copyright (c) 2012, The Iconfactory. All rights reserved.
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

#import "UIColorRep.h"
#import "UIImageRep.h"
#import "UIGraphics.h"
#import <AppKit/NSApplication.h>
#import <UIKit/UIGeometry.h>

static void drawPatternImage(void *info, CGContextRef ctx)
{
    UIImageRep *rep = [(__bridge UIColorRep *)info patternImageRep];

    UIGraphicsPushContext(ctx);
    CGContextSaveGState(ctx);
    
    [rep drawInRect:(CGRect){CGPointZero, rep.imageSize} fromRect:CGRectNull];
    
    CGContextRestoreGState(ctx);
    UIGraphicsPopContext();
}

@implementation UIColorRep

- (id)initWithPatternImageRepresentation:(UIImageRep *)patternImageRep
{
    if (!patternImageRep) {
        self = nil;
    } else if ((self=[super init])) {
        _patternImageRep = patternImageRep;
    }
    return self;
}

- (id)initWithCGColor:(CGColorRef)color
{
    if (!color) {
        self = nil;
    } else if ((self=[super init])) {
        _CGColor = CGColorRetain(color);
    }
    return self;
}

- (void)dealloc
{
    CGColorRelease(_CGColor);
}

- (CGColorRef)CGColor
{
    if (!_CGColor && _patternImageRep) {
        const CGSize imageSize = _patternImageRep.imageSize;
        const CGFloat scaler = 1/_patternImageRep.scale;
        const CGAffineTransform t = CGAffineTransformMakeScale(scaler, scaler);
        static const CGPatternCallbacks callbacks = {0, &drawPatternImage, NULL};
        
        CGPatternRef pattern = CGPatternCreate ((__bridge void *)self,
                                                CGRectMake (0, 0, imageSize.width, imageSize.height),
                                                t,
                                                imageSize.width,
                                                imageSize.height,
                                                kCGPatternTilingConstantSpacing,
                                                true,
                                                &callbacks);

        CGColorSpaceRef space = CGColorSpaceCreatePattern(NULL);
        CGFloat components[1] = {1.0};

        _CGColor = CGColorCreateWithPattern(space, pattern, components);

        CGColorSpaceRelease(space);
        CGPatternRelease(pattern);
    }
    
    return _CGColor;
}

- (CGFloat)scale
{
    return _patternImageRep? _patternImageRep.scale : 1;
}

- (BOOL)isOpaque
{
    if (!_patternImageRep && _CGColor) {
        return CGColorGetAlpha(_CGColor) == 1;
    } else {
        return _patternImageRep.opaque;
    }
}

@end
