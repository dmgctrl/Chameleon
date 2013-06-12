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

#import "UIImageRep.h"
#import "UIGraphics.h"

static CGImageSourceRef CreateCGImageSourceWithFile(NSString *imagePath)
{
    NSString *macPath = [[[imagePath stringByDeletingPathExtension] stringByAppendingString:@"~mac"] stringByAppendingPathExtension:[imagePath pathExtension]];
    return CGImageSourceCreateWithURL((CFURLRef)[NSURL fileURLWithPath:macPath], NULL) ?: CGImageSourceCreateWithURL((CFURLRef)[NSURL fileURLWithPath:imagePath], NULL);
}

@implementation UIImageRep
@synthesize scale=_scale;

+ (NSArray*) imageRepsWithContentsOfFile:(NSString*)file
{
    NSAssert(file != nil, @"???");
    NSMutableArray* reps = [NSMutableArray arrayWithCapacity:2];

    CGImageSourceRef source = CreateCGImageSourceWithFile(file);
    if (source) {
        /*  Roll through the various images contained within the source, looking
         *  at the properties of each for the lowest dpi in the X and Y 
         *  directions.  If this information is unavailable, then stop.
         */
        BOOL dpiInfoPresent = NO;
        CGFloat dotsPerInchXAt1x = INFINITY;
        CGFloat dotsPerInchYAt1x = INFINITY;
        for (NSInteger i = 0, iMax = CGImageSourceGetCount(source); i < iMax; i++) {
            NSDictionary* properties = (NSDictionary*)CGImageSourceCopyPropertiesAtIndex(source, i, NULL);
            if (!properties) {
                continue;
            }

            CGFloat dotsPerInchX = [[properties objectForKey:(id)kCGImagePropertyDPIWidth] floatValue];
            CGFloat dotsPerInchY = [[properties objectForKey:(id)kCGImagePropertyDPIHeight] floatValue];
            [properties release];

            if (dotsPerInchX == 0 || dotsPerInchY == 0) {
                continue;
            }
            
            dotsPerInchXAt1x = MIN(dotsPerInchX, dotsPerInchXAt1x);
            dotsPerInchYAt1x = MIN(dotsPerInchY, dotsPerInchYAt1x);
            dpiInfoPresent = YES;
        }
        
        if (dpiInfoPresent) {
            for (NSInteger i = 0, iMax = CGImageSourceGetCount(source); i < iMax; i++) {
                NSDictionary* properties = (NSDictionary*)CGImageSourceCopyPropertiesAtIndex(source, i, NULL);
                if (!properties) {
                    continue;
                }

                CGFloat scaleX = [[properties objectForKey:(id)kCGImagePropertyDPIWidth] floatValue] / dotsPerInchXAt1x;
                CGFloat scaleY = [[properties objectForKey:(id)kCGImagePropertyDPIHeight] floatValue] / dotsPerInchYAt1x;
                [properties release];

                if (fabs(scaleX - scaleY) < 0.01) {
                    UIImageRep* rep = [[UIImageRep alloc] initWithCGImageSource:source imageIndex:i scale:scaleX];
                    if (rep) {
                        [reps addObject:rep];
                        [rep release];
                    }
                }
            }
        } else {
            UIImageRep* rep = [[UIImageRep alloc] initWithCGImageSource:source imageIndex:0 scale:1.0];
            if (rep) {
                [reps addObject:rep];
                [rep release];
            }
        }
        
        CFRelease(source);
    }
    
    return ([reps count] > 0)? reps : nil;
}

+ (NSArray*) imageRepsWithContentsOfFile:(NSString*)file and2xVariant:(NSString*)fileAt2x
{
    NSMutableArray* reps = [NSMutableArray array];
    
    if (file) {
        UIImageRep* repAt1x = [[[self class] alloc] initWithContentsOfFile:file scale:1.0];
        if (repAt1x) {
            [reps addObject:repAt1x];
            [repAt1x release];
        }
    }
    if (fileAt2x) {
        UIImageRep* repAt2x = [[[self class] alloc] initWithContentsOfFile:fileAt2x scale:2.0];
        if (repAt2x) {
            [reps addObject:repAt2x];
            [repAt2x release];
        }
    }

    return ([reps count] > 0)? reps : nil;
}

- (id) initWithContentsOfFile:(NSString*)file scale:(CGFloat)scale
{
    NSAssert(file != nil, @"???");
    NSAssert(scale > 0, @"???");
    CGImageSourceRef source = CreateCGImageSourceWithFile(file);
    if (!source) {
        return nil;
    }
    self = [self initWithCGImageSource:source imageIndex:0 scale:scale];
    CFRelease(source);
    return self;
}

- (id)initWithCGImageSource:(CGImageSourceRef)source imageIndex:(NSUInteger)index scale:(CGFloat)scale
{
    if (!source || CGImageSourceGetCount(source) <= index) {
        [self release];
        self = nil;
    } else if ((self=[super init])) {
        CFRetain(source);
        _imageSource = source;
        _imageSourceIndex = index;
        _scale = scale;
    }
    return self;
}

- (id)initWithCGImage:(CGImageRef)image scale:(CGFloat)scale
{
    if (!image) {
        [self release];
        self = nil;
    } else if ((self=[super init])) {
        _scale = scale;
        _image = CGImageRetain(image);
    }
    return self;
}

- (id)initWithData:(NSData *)data
{
    CGImageSourceRef src = data? CGImageSourceCreateWithData((CFDataRef)data, NULL) : NULL;
    if (src) {
        self = [self initWithCGImageSource:src imageIndex:0 scale:1];
        CFRelease(src);
    } else {
        [self release];
        self = nil;
    }
    
    return self;
}

- (void)dealloc
{
    if (_image) CGImageRelease(_image);
    if (_imageSource) CFRelease(_imageSource);
    [super dealloc];
}

- (BOOL)isLoaded
{
    return (_image != NULL);
}

- (BOOL)isOpaque
{
    BOOL opaque = NO;
    
    if (_image) {
        CGImageAlphaInfo info = CGImageGetAlphaInfo(_image);
        opaque = (info == kCGImageAlphaNone) || (info == kCGImageAlphaNoneSkipLast) || (info == kCGImageAlphaNoneSkipFirst);
    } else if (_imageSource) {
        CFDictionaryRef info = CGImageSourceCopyPropertiesAtIndex(_imageSource, _imageSourceIndex, NULL);
        opaque = CFDictionaryGetValue(info, kCGImagePropertyHasAlpha) != kCFBooleanTrue;
        CFRelease(info);
    }
    
    return opaque;
}

- (CGSize)imageSize
{
    CGSize size = CGSizeZero;
    
    if (_image) {
        size.width = CGImageGetWidth(_image);
        size.height = CGImageGetHeight(_image);
    } else if (_imageSource) {
        CFDictionaryRef info = CGImageSourceCopyPropertiesAtIndex(_imageSource, _imageSourceIndex, NULL);
        CFNumberRef width = CFDictionaryGetValue(info, kCGImagePropertyPixelWidth);
        CFNumberRef height = CFDictionaryGetValue(info, kCGImagePropertyPixelHeight);
        if (width && height) {
            CFNumberGetValue(width, kCFNumberCGFloatType, &size.width);
            CFNumberGetValue(height, kCFNumberCGFloatType, &size.height);
        }
        CFRelease(info);
    }

    return size;
}

- (CGImageRef)CGImage
{
    // lazy load if we only have an image source
    if (!_image && _imageSource) {
        _image = CGImageSourceCreateImageAtIndex(_imageSource, _imageSourceIndex, NULL);
        CFRelease(_imageSource);
        _imageSource = NULL;
    }
    
    return _image;
}

- (void)drawInRect:(CGRect)rect fromRect:(CGRect)fromRect
{
    CGImageRef image = CGImageRetain(self.CGImage);
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGContextSaveGState(ctx);
    CGContextTranslateCTM(ctx, rect.origin.x, rect.origin.y+rect.size.height);
    CGContextScaleCTM(ctx, 1, -1);
    rect.origin = CGPointZero;
    
    if (CGRectIsNull(fromRect)) {
        CGContextDrawImage(ctx, rect, image);
    } else {
        fromRect.origin.x *= _scale;
        fromRect.origin.y *= _scale;
        fromRect.size.width *= _scale;
        fromRect.size.height *= _scale;

        CGImageRef tempImage = CGImageCreateWithImageInRect(image, fromRect);
        CGContextDrawImage(ctx, rect, tempImage);
        CGImageRelease(tempImage);
    }
    
    CGContextRestoreGState(ctx);
    CGImageRelease(image);
}

@end
