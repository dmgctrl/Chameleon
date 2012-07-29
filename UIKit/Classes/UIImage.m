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

#import "UIImage+UIPrivate.h"
#import "UIThreePartImage.h"
#import "UINinePartImage.h"
#import "UIGraphics.h"
#import "UIPhotosAlbum.h"
#import "UIImageRep.h"

@implementation UIImage

+ (id) imageNamed:(NSString*)name
{
    if (!name) {
        return nil;
    }
    
    UIImage* image = [self _cachedImageForName:name];
    if (!image) {
        NSBundle* bundle = [NSBundle mainBundle];
        NSString* type = [name pathExtension];
        NSString* resource = [type length]? [name stringByDeletingPathExtension] : name;
        NSString* resourceForMac = [resource stringByAppendingString:@"~mac"];
        
        NSString* pathToFileWithMultipleResolutions = nil;
        if (![type length]) {
            pathToFileWithMultipleResolutions = [bundle pathForResource:resourceForMac ofType:@"tiff"];
            if (!pathToFileWithMultipleResolutions) {
                pathToFileWithMultipleResolutions = [bundle pathForResource:resource ofType:@"tiff"];
                if (!pathToFileWithMultipleResolutions) {
                    type = @"png";
                }
            }
        }
        if (pathToFileWithMultipleResolutions) {
            image = [[self alloc] _initWithRepresentations:[UIImageRep imageRepsWithContentsOfFile:pathToFileWithMultipleResolutions]];
        } else {
            NSString* resourceForMacAt2x = [resource stringByAppendingString:@"@2x~mac"];
            NSString* pathToFileAt2x = [bundle pathForResource:resourceForMacAt2x ofType:type];
            NSString* pathToFileAt1x = [bundle pathForResource:resourceForMac ofType:type];
            if (!pathToFileAt2x && !pathToFileAt1x) {
                NSString* resourceAt2x = [resource stringByAppendingString:@"@2x"];
                pathToFileAt2x = [bundle pathForResource:resourceAt2x ofType:type];
                pathToFileAt1x = [bundle pathForResource:resource ofType:type];
            }
            if (pathToFileAt2x) {
                image = [[self alloc] _initWithRepresentations:[UIImageRep imageRepsWithContentsOfFile:pathToFileAt1x and2xVariant:pathToFileAt2x]];
            } else if (pathToFileAt1x) {
                image = [[self alloc] _initWithRepresentations:[UIImageRep imageRepsWithContentsOfFile:pathToFileAt1x]];
            }
        }

        if (image) {
            [self _cacheImage:image forName:name];
            [image autorelease];
        }
    }

    return image;
}

- (id)initWithContentsOfFile:(NSString *)imagePath
{
    return imagePath? [self _initWithRepresentations:[UIImageRep imageRepsWithContentsOfFile:imagePath]] : nil;
}

- (id)initWithData:(NSData *)data
{
    return [self _initWithRepresentations:[NSArray arrayWithObjects:[[[UIImageRep alloc] initWithData:data] autorelease], nil]];
}

- (id)initWithCGImage:(CGImageRef)imageRef
{
    return [self initWithCGImage:imageRef scale:1 orientation:UIImageOrientationUp];
}

- (id)initWithCGImage:(CGImageRef)imageRef scale:(CGFloat)scale orientation:(UIImageOrientation)orientation
{
    return [self _initWithRepresentations:[NSArray arrayWithObjects:[[[UIImageRep alloc] initWithCGImage:imageRef scale:scale] autorelease], nil]];
}

- (void)dealloc
{
    [_representations release];
    [super dealloc];
}

+ (UIImage *)imageWithData:(NSData *)data
{
    return data? [[[self alloc] initWithData:data] autorelease] : nil;
}

+ (UIImage *)imageWithContentsOfFile:(NSString *)path
{
    return path? [[[self alloc] initWithContentsOfFile:path] autorelease] : nil;
}

+ (UIImage *)imageWithCGImage:(CGImageRef)imageRef
{
    return [[[self alloc] initWithCGImage:imageRef] autorelease];
}

+ (UIImage *)imageWithCGImage:(CGImageRef)imageRef scale:(CGFloat)scale orientation:(UIImageOrientation)orientation
{
    return [[[self alloc] initWithCGImage:imageRef scale:scale orientation:orientation] autorelease];
}

- (UIImage *)stretchableImageWithLeftCapWidth:(NSInteger)leftCapWidth topCapHeight:(NSInteger)topCapHeight
{
    const CGSize size = self.size;

    if ((leftCapWidth == 0 && topCapHeight == 0) || (leftCapWidth >= size.width && topCapHeight >= size.height)) {
        return self;
    } else if (leftCapWidth <= 0 || leftCapWidth >= size.width) {
        return [[[UIThreePartImage alloc] initWithRepresentations:[self _representations] capSize:MIN(topCapHeight,size.height) vertical:YES] autorelease];
    } else if (topCapHeight <= 0 || topCapHeight >= size.height) {
        return [[[UIThreePartImage alloc] initWithRepresentations:[self _representations] capSize:MIN(leftCapWidth,size.width) vertical:NO] autorelease];
    } else {
        return [[[UINinePartImage alloc] initWithRepresentations:[self _representations] leftCapWidth:leftCapWidth topCapHeight:topCapHeight] autorelease];
    }
}

- (CGSize)size
{
    CGSize size = CGSizeZero;
    UIImageRep *rep = [_representations lastObject];
    const CGSize repSize = rep.imageSize;
    const CGFloat scale = rep.scale;
    size.width = repSize.width / scale;
    size.height = repSize.height / scale;
    return size;
}

- (NSInteger)leftCapWidth
{
    return 0;
}

- (NSInteger)topCapHeight
{
    return 0;
}

- (CGImageRef)CGImage
{
    return [self _bestRepresentationForProposedScale:2].CGImage;
}

- (UIImageOrientation)imageOrientation
{
    return UIImageOrientationUp;
}

- (CGFloat)scale
{
    return [self _bestRepresentationForProposedScale:2].scale;
}

- (void)drawAtPoint:(CGPoint)point blendMode:(CGBlendMode)blendMode alpha:(CGFloat)alpha
{
    [self drawInRect:(CGRect){point, self.size} blendMode:blendMode alpha:alpha];
}

- (void)drawInRect:(CGRect)rect blendMode:(CGBlendMode)blendMode alpha:(CGFloat)alpha
{
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGContextSaveGState(ctx);
    CGContextSetBlendMode(ctx, blendMode);
    CGContextSetAlpha(ctx, alpha);

    [self drawInRect:rect];
    
    CGContextRestoreGState(ctx);
}

- (void)drawAtPoint:(CGPoint)point
{
    [self drawInRect:(CGRect){point, self.size}];
}

- (void)drawInRect:(CGRect)rect
{
    if (rect.size.height > 0 && rect.size.width > 0) {
        [self _drawRepresentation:[self _bestRepresentationForProposedScale:_UIGraphicsGetContextScaleFactor(UIGraphicsGetCurrentContext())] inRect:rect];
    }
}

@end

void UIImageWriteToSavedPhotosAlbum(UIImage *image, id completionTarget, SEL completionSelector, void *contextInfo)
{
    [[UIPhotosAlbum sharedPhotosAlbum] writeImage:image completionTarget:completionTarget action:completionSelector context:contextInfo];
}

void UISaveVideoAtPathToSavedPhotosAlbum(NSString *videoPath, id completionTarget, SEL completionSelector, void *contextInfo)
{
}

BOOL UIVideoAtPathIsCompatibleWithSavedPhotosAlbum(NSString *videoPath)
{
    return NO;
}

NSData *UIImageJPEGRepresentation(UIImage *image, CGFloat compressionQuality)
{
    CFMutableDataRef data = CFDataCreateMutable(NULL, 0);
    CGImageDestinationRef dest = CGImageDestinationCreateWithData(data, kUTTypeJPEG, 1, NULL);
    CFNumberRef quality = CFNumberCreate(NULL, kCFNumberCGFloatType, &compressionQuality);
    CFStringRef keys[] = { kCGImageDestinationLossyCompressionQuality };
    CFTypeRef values[] = { quality };
    CFDictionaryRef properties = CFDictionaryCreate(NULL, (const void **)&keys, (const void **)&values, 1, NULL, NULL);
    CGImageDestinationAddImage(dest, image.CGImage, properties);
    CGImageDestinationFinalize(dest);
    CFRelease(properties);
    CFRelease(quality);
    CFRelease(dest);
    return [(__bridge NSData *)data autorelease];
}

NSData *UIImagePNGRepresentation(UIImage *image)
{
    CFMutableDataRef data = CFDataCreateMutable(NULL, 0);
    CGImageDestinationRef dest = CGImageDestinationCreateWithData(data, kUTTypePNG, 1, NULL);
    CGImageDestinationAddImage(dest, image.CGImage, NULL);
    CGImageDestinationFinalize(dest);
    CFRelease(dest);
    return [(__bridge NSData *)data autorelease];
}
