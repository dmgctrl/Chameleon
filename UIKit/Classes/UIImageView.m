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

#import "UIImageView+UIPrivate.h"
#import "UIImage.h"
#import "UIGraphics.h"
#import "UIColor.h"
#import "UIImage+AppKit.h"
#import "UIWindow.h"
#import "UIImage+UIPrivate.h"
#import "UIScreen.h"
#import "UIImageRep.h"
//
#import <QuartzCore/QuartzCore.h>

static NSString* const kUIImageKey = @"UIImage";

static NSArray* CGImagesWithUIImages(NSArray* images)
{
    NSMutableArray* CGImages = [NSMutableArray arrayWithCapacity:[images count]];
    for (UIImage* image in images) {
        [CGImages addObject:(__bridge id)[image CGImage]];
    }
    return CGImages;
}

@implementation UIImageView {
    NSInteger _drawMode;
}

static void commonInit(UIImageView* self)
{
    self.userInteractionEnabled = NO;
    self.opaque = NO;
}

- (instancetype) initWithFrame:(CGRect)frame
{
    if (nil != (self = [super initWithFrame:frame])) {
        commonInit(self);
    }
    return self;
}

- (instancetype) initWithCoder:(NSCoder*)coder
{
    if (nil != (self = [super initWithCoder:coder])) {
        commonInit(self);
        if ([coder containsValueForKey:kUIImageKey]) {
            self.image = [coder decodeObjectForKey:kUIImageKey];
        }
    }
    return self;
}

- (instancetype) initWithImage:(UIImage*)image highlightedImage:(UIImage*)highlightedImage;
{
    if (nil != (self = [super initWithFrame:(CGRect){ .size = [image size] }])) {
        commonInit(self);
        _image = image;
        _highlightedImage = highlightedImage;
    }
    return self;
}

- (instancetype) initWithImage:(UIImage*)image
{
    return [self initWithImage:image highlightedImage:nil];
}


#pragma mark Properties

- (void) setBounds:(CGRect)bounds
{
    [self _displayIfNeededChangingFromOldSize:self.bounds.size toNewSize:bounds.size];
    [super setBounds:bounds];
}

- (void) setFrame:(CGRect)frame
{
    [self _displayIfNeededChangingFromOldSize:self.frame.size toNewSize:frame.size];
    [super setFrame:frame];
}

- (void) setHighlighted:(BOOL)highlighted
{
    if (highlighted != _highlighted) {
        _highlighted = highlighted;
        [self setNeedsDisplay];

        if ([self isAnimating]) {
            [self startAnimating];
        }
    }
}

- (void) setHighlightedImage:(UIImage*)highlightedImage
{
    if (_highlightedImage != highlightedImage) {
        _highlightedImage = highlightedImage;
        if (_highlighted) {
            [self setNeedsDisplay];
        }
    }
}

- (void) setImage:(UIImage*)image
{
    if (_image != image) {
        _image = image;
        if (!_highlighted || !_highlightedImage) {
            [self setNeedsDisplay];
        }
    }
}


#pragma mark UIView

- (CGSize) sizeThatFits:(CGSize)size
{
    return _image? _image.size : CGSizeZero;
}


#pragma mark NSCoding

- (void) encodeWithCoder:(NSCoder*)coder
{
    [self doesNotRecognizeSelector:_cmd];
}


#pragma mark Public Methods

- (void) startAnimating
{
    NSArray* images = _highlighted? _highlightedAnimationImages : _animationImages;
    
    CAKeyframeAnimation* animation = [CAKeyframeAnimation animationWithKeyPath:@"contents"];
    animation.calculationMode = kCAAnimationDiscrete;
    animation.duration = self.animationDuration ?: ([images count] * (1/30.0));
    animation.repeatCount = self.animationRepeatCount ?: HUGE_VALF;
    animation.values = CGImagesWithUIImages(images);
    animation.removedOnCompletion = NO;
    animation.fillMode = kCAFillModeBoth;
    
    [self.layer addAnimation:animation forKey:@"contents"];
}

- (void) stopAnimating
{
    [self.layer removeAnimationForKey:@"contents"];
}

- (BOOL) isAnimating
{
    return ([self.layer animationForKey:@"contents"] != nil);
}


#pragma mark Private Methods

- (void) _setDrawMode:(NSInteger)drawMode
{
    _drawMode = drawMode;
    [self setNeedsDisplay];
}


- (BOOL) _hasResizableImage
{
    return (_image.topCapHeight > 0 || _image.leftCapWidth > 0);
}

- (CGRect) _rectForContentWithSize:(CGSize)size withContentMode:(UIViewContentMode)contentMode withinRect:(CGRect)rect
{
    switch (contentMode) {
        case UIViewContentModeScaleAspectFill: {
            if (size.width > size.height) {
                return (CGRect) {
                    .origin = rect.origin,
                    .size = {
                        .width = rect.size.width,
                        .height = rect.size.height * (rect.size.width / size.width),
                    }
                };
            } else {
                return (CGRect) {
                    .origin = rect.origin,
                    .size = {
                        .width = rect.size.width * (rect.size.height / size.height),
                        .height = rect.size.height,
                    }
                };
            }
            break;
        }
        case UIViewContentModeScaleAspectFit: {
            CGFloat scale = 1.0f;
            if (rect.size.width > rect.size.height) {
                scale = rect.size.width / size.width;
            } else {
                scale = rect.size.height / size.height;
            }
            CGFloat width = size.width * scale;
            CGFloat height = size.height * scale;
            return (CGRect){
                .origin = {
                    .x = rect.origin.x + (rect.size.width - width) / 2.0,
                    .y = rect.origin.y + (rect.size.height - height) / 2.0,
                },
                .size = {
                    .width = width,
                    .height = height
                }
            };
        }
        case UIViewContentModeCenter: {
            return (CGRect){
                .origin = {
                    .x = rect.origin.x + (rect.size.width - size.width) / 2.0,
                    .y = rect.origin.y + (rect.size.height - size.height) / 2.0,
                },
                .size = size
            };
        }
        case UIViewContentModeTop: {
            return (CGRect){
                .origin = {
                    .x = rect.origin.x + (rect.size.width - size.width) / 2.0,
                    .y = rect.origin.y,
                },
                .size = size
            };
        }
        case UIViewContentModeBottom: {
            return (CGRect){
                .origin = {
                    .x = rect.origin.x + (rect.size.width - size.width) / 2.0,
                    .y = rect.origin.y + (rect.size.height - size.height),
                },
                .size = size
            };
        }
        case UIViewContentModeLeft: {
            return (CGRect){
                .origin = {
                    .x = rect.origin.x,
                    .y = rect.origin.y + (rect.size.height - size.height) / 2.0,
                },
                .size = size
            };
        }
        case UIViewContentModeRight: {
            return (CGRect){
                .origin = {
                    .x = rect.origin.x + (rect.size.width - size.width),
                    .y = rect.origin.y + (rect.size.height - size.height) / 2.0,
                },
                .size = size
            };
        }
        case UIViewContentModeTopLeft: {
            return (CGRect){
                .origin = {},
                .size = size
            };
        }
        case UIViewContentModeTopRight: {
            return (CGRect){
                .origin = {
                    .x = rect.origin.x + (rect.size.width - size.width),
                },
                .size = size
            };
        }
        case UIViewContentModeBottomLeft: {
            return (CGRect){
                .origin = {
                    .x = rect.origin.x + (rect.size.width - size.width),
                    .y = rect.origin.y + (rect.size.height - size.height),
                },
                .size = size
            };
        }
        case UIViewContentModeBottomRight: {
            return (CGRect){
                .origin = {
                    .x = rect.origin.x,
                    .y = rect.origin.y + (rect.size.height - size.height),
                },
                .size = size
            };
        }

        case UIViewContentModeScaleToFill:
        case UIViewContentModeRedraw:
        default: {
            return rect;
        }
    }
}

- (void) drawRect:(CGRect)rect
{
    UIImage* displayImage = (_highlighted && _highlightedImage)? _highlightedImage : _image;
    
    CGBlendMode blendMode = kCGBlendModeNormal;
    CGFloat alpha = 1.0f;
    if (_drawMode != _UIImageViewDrawModeNormal) {
        if (_drawMode == _UIImageViewDrawModeDisabled) {
            alpha = 0.5f;
        } else if (_drawMode == _UIImageViewDrawModeHighlighted) {
            blendMode = kCGBlendModeDestinationAtop;
        }
    }

    CGRect bounds = [self bounds];
    
    if (blendMode == kCGBlendModeDestinationAtop) {
        [[[UIColor blackColor] colorWithAlphaComponent:0.4] setFill];
        UIRectFill(bounds);
    }

    if (![self _hasResizableImage]) {
        bounds = [self _rectForContentWithSize:[displayImage size] withContentMode:[self contentMode] withinRect:bounds];
    }

    [displayImage drawInRect:bounds blendMode:blendMode alpha:alpha];
}

- (void) _displayIfNeededChangingFromOldSize:(CGSize)oldSize toNewSize:(CGSize)newSize
{
    if (!CGSizeEqualToSize(newSize, oldSize) && [self _hasResizableImage]) {
        [self setNeedsDisplay];
    }
}

@end
