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

#import "UILabel.h"
#import "UIColor.h"
#import "UIFont.h"
#import "UIGraphics.h"
#import "UIColor+AppKit.h"
#import "NSStringDrawing.h"
#import <AppKit/NSApplication.h>
#import <AppKit/NSParagraphStyle.h>
#import <AppKit/NSShadow.h>

static NSString* const kUIFontKey = @"UIFont";
static NSString* const kUIHighlightedColorKey = @"UIHighlightedColor";
static NSString* const kUIShadowColorKey = @"UIShadowColor";
static NSString* const kUIShadowOffsetKey = @"UIShadowOffset";
static NSString* const kUITextColorKey = @"UITextColor";
static NSString* const kUITextKey = @"UIText";
static NSString* const kUITextAlignmentKey = @"UITextAlignment";
static NSString* const kUIBaselineAdjustmentKey = @"UIBaselineAdjustment";
static NSString* const kUIAdjustsFontSizeToFitKey = @"UIAdjustsFontSizeToFit";

typedef void DrawTextInRectMethod(id, SEL, CGRect);

@implementation UILabel {
    enum {
        kRenderModeNone = 0,
        kRenderModePlainText,
        kRenderModeAttributedText
    } _renderMode;
    struct {
        BOOL overridesDrawTextInRect : 1;
    } _flags;
    
    NSStringDrawingContext* _stringDrawingContext;
    NSAttributedString* _attributedTextForDrawing;
}

static SEL kDrawTextInRectSelector;
static DrawTextInRectMethod* kDefaultImplementationOfDrawTextInRect;

+ (void) initialize
{
    if (self == [UILabel class]) {
        kDrawTextInRectSelector = @selector(drawTextInRect:);
        kDefaultImplementationOfDrawTextInRect = (DrawTextInRectMethod*)[UILabel instanceMethodForSelector:kDrawTextInRectSelector];
    }
}

- (void) _commonInitForUILabel
{
    _flags.overridesDrawTextInRect = (kDefaultImplementationOfDrawTextInRect != (DrawTextInRectMethod*)[[self class] instanceMethodForSelector:kDrawTextInRectSelector]);

    self.userInteractionEnabled = NO;
    self.textAlignment = UITextAlignmentLeft;
    self.lineBreakMode = UILineBreakModeTailTruncation;
    self.textColor = [UIColor blackColor];
    self.backgroundColor = [UIColor whiteColor];
    self.enabled = YES;
    self.font = [UIFont systemFontOfSize:17];
    self.numberOfLines = 1;
    self.contentMode = UIViewContentModeLeft;
    self.clipsToBounds = YES;
    self.shadowOffset = CGSizeMake(0,-1);
    self.baselineAdjustment = UIBaselineAdjustmentAlignBaselines;
}

- (id) initWithFrame:(CGRect)frame
{
    if (nil != (self = [super initWithFrame:frame])) {
        [self _commonInitForUILabel];
    }
    return self;
}

- (id) initWithCoder:(NSCoder*)coder
{
    if (nil != (self = [super initWithCoder:coder])) {
        [self _commonInitForUILabel];
        if ([coder containsValueForKey:kUIFontKey]) {
            self.font = [coder decodeObjectForKey:kUIFontKey];
        }
        if ([coder containsValueForKey:kUIHighlightedColorKey]) {
            self.highlightedTextColor = [coder decodeObjectForKey:kUIHighlightedColorKey];
        }
        if ([coder containsValueForKey:kUIShadowColorKey]) {
            self.shadowColor = [coder decodeObjectForKey:kUIShadowColorKey];
        }
        if ([coder containsValueForKey:kUIShadowOffsetKey]) {
            self.shadowOffset = [coder decodeCGSizeForKey:kUIShadowOffsetKey];
        }
        if ([coder containsValueForKey:kUITextColorKey]) {
            self.textColor = [coder decodeObjectForKey:kUITextColorKey];
        }
        if ([coder containsValueForKey:kUITextKey]) {
            self.text = [coder decodeObjectForKey:kUITextKey];
        }
        if ([coder containsValueForKey:kUITextAlignmentKey]) {
            self.textAlignment = [coder decodeBoolForKey:kUITextAlignmentKey];
        }
        if ([coder containsValueForKey:kUIBaselineAdjustmentKey]) {
            self.baselineAdjustment = [coder decodeIntegerForKey:kUIBaselineAdjustmentKey];
        }
        if ([coder containsValueForKey:kUIAdjustsFontSizeToFitKey]) {
            self.adjustsFontSizeToFitWidth = [coder decodeBoolForKey:kUIAdjustsFontSizeToFitKey];
        }
    }
    return self;
}


#pragma mark Properties

- (void) setAttributedText:(NSAttributedString*)attributedText
{
    if (attributedText) {
        _renderMode = kRenderModeAttributedText;
        _attributedText = attributedText;
    } else {
        _renderMode = kRenderModeNone;
        _attributedText = nil;
        _text = nil;
    }
    [self setNeedsDisplay];
}

- (void) setEnabled:(BOOL)newEnabled
{
    if (newEnabled != _enabled) {
        _enabled = newEnabled;
        [self setNeedsDisplay];
    }
}

- (void) setFrame:(CGRect)frame
{
    const BOOL redisplay = !CGSizeEqualToSize(frame.size, [self frame].size);
    [super setFrame:frame];
    if (redisplay) {
        [self setNeedsDisplay];
    }
}

- (void) setFont:(UIFont*)font
{
    if (font == nil) {
        [NSException raise:NSInvalidArgumentException format:@"font must not be nil."];
    }
    if (font != _font) {
        _font = font;
        [self setNeedsDisplay];
    }
}

- (void) setHighlighted:(BOOL)highlighted
{
    if (highlighted != _highlighted) {
        _highlighted = highlighted;
        [self setNeedsDisplay];
    }
}

- (void) setLineBreakMode:(UILineBreakMode)mode
{
    if (mode != _lineBreakMode) {
        _lineBreakMode = mode;
        [self setNeedsDisplay];
    }
}

- (void) setNumberOfLines:(NSInteger)lines
{
    if (lines != _numberOfLines) {
        _numberOfLines = lines;
        [self setNeedsDisplay];
    }
}

- (void) setShadowColor:(UIColor*)color
{
    if (color != _shadowColor) {
        _shadowColor = color;
        [self setNeedsDisplay];
    }
}

- (void) setShadowOffset:(CGSize)offset
{
    if (!CGSizeEqualToSize(offset,_shadowOffset)) {
        _shadowOffset = offset;
        [self setNeedsDisplay];
    }
}

- (void) setText:(NSString*)text
{
    if (text) {
        _renderMode = kRenderModePlainText;
        _text = [text copy];
    } else {
        _renderMode = kRenderModeNone;
        _attributedText = nil;
        _text = nil;
    }
    [self setNeedsDisplay];
}

- (void) setTextAlignment:(UITextAlignment)alignment
{
    if (alignment != _textAlignment) {
        _textAlignment = alignment;
        [self setNeedsDisplay];
    }
}

- (void) setTextColor:(UIColor*)color
{
    if (color == nil) {
        [NSException raise:NSInvalidArgumentException format:@"color must not be nil."];
    }
    if (color != _textColor) {
        _textColor = color;
        [self setNeedsDisplay];
    }
}


#pragma mark Geometry

- (CGSize) sizeThatFits:(CGSize)size
{
    CGSize constrainedToSize = {
        .width = (_numberOfLines > 0)? CGFLOAT_MAX : size.width,
        .height = (_numberOfLines <= 0)? CGFLOAT_MAX : (_font.lineHeight * _numberOfLines)
    };
    return [_text sizeWithFont:_font constrainedToSize:constrainedToSize lineBreakMode:_lineBreakMode];
}


#pragma mark Drawing

- (CGRect) textRectForBounds:(CGRect)bounds limitedToNumberOfLines:(NSInteger)numberOfLines
{
    if ([_text length] > 0) {
        CGSize maxSize = bounds.size;
        if (numberOfLines > 0) {
            maxSize.height = _font.lineHeight * numberOfLines;
        }
        CGSize size = [_text sizeWithFont: _font constrainedToSize: maxSize lineBreakMode: _lineBreakMode];
        return (CGRect){bounds.origin, size};
    }
    return (CGRect){bounds.origin, {0, 0}};
}

- (void) drawTextInRect:(CGRect)rect
{
//    NSDictionary* attributes = [self _synthesizeTextAttributes];
//    NSAttributedString* attributedString = [[NSAttributedString alloc] initWithString:_text attributes:attributes];
    
    CGRect drawRect = CGRectZero;
    CGSize maxSize = rect.size;
    if (_numberOfLines > 0) {
        maxSize.height = _font.lineHeight * (_numberOfLines + 0.5);
    }
    drawRect.size = [_text sizeWithFont:_font constrainedToSize:maxSize lineBreakMode:_lineBreakMode];
    drawRect = CGRectOffset(drawRect, 0, roundf((rect.size.height - drawRect.size.height) / 2.f));
    
    [_text drawInRect:drawRect withFont:_font lineBreakMode:_lineBreakMode alignment:_textAlignment];

    [[UIColor blueColor] set];
    UIRectFrame(drawRect);
    [[UIColor redColor] set];
    UIRectFrame(rect);
}

- (void) drawRect:(CGRect)rect
{
    if (_renderMode != kRenderModeNone) {
        if (_flags.overridesDrawTextInRect) {
            CGContextRef c = UIGraphicsGetCurrentContext();
            @try {
                CGContextSaveGState(c);
                CGContextSetShadowWithColor(UIGraphicsGetCurrentContext(), _shadowOffset, 0, _shadowColor.CGColor);
                UIColor* drawColor = (_highlighted && _highlightedTextColor)? _highlightedTextColor : _textColor;
                [drawColor setFill];

                [self drawTextInRect:[self textRectForBounds:[self bounds] limitedToNumberOfLines:[self numberOfLines]]];
            } @finally {
                CGContextRestoreGState(c);
            }
        } else {
            [self drawTextInRect:[self textRectForBounds:[self bounds] limitedToNumberOfLines:[self numberOfLines]]];
        }
    }
}

- (NSString*) _preprocessText:(NSString*)text
{
    return text;
}

- (NSAttributedString*) _preprocessAttributedText:(NSAttributedString*)text
{
    return text;
}

- (NSAttributedString*) _attributedTextForDrawing
{
    if (!_attributedTextForDrawing) {
        if (_renderMode == kRenderModePlainText) {
            UIColor* textColor = (_highlighted && _highlightedTextColor)? _highlightedTextColor : _textColor;
            NSMutableParagraphStyle* paragraphStyle = [[NSMutableParagraphStyle alloc] init];
            [paragraphStyle setTighteningFactorForTruncation:0.0f];
            [paragraphStyle setLineBreakMode:(CTLineBreakMode)_lineBreakMode];
            [paragraphStyle setAlignment:(NSTextAlignment)_textAlignment];
            NSShadow* shadow = [[NSShadow alloc] init];
            [shadow setShadowColor:[[self shadowColor] NSColor]];
            [shadow setShadowOffset:[self shadowOffset]];
            
            _attributedTextForDrawing = [[NSAttributedString alloc] initWithString:[self _preprocessText:_text] attributes:@{
                NSFontAttributeName: _font,
                NSKernAttributeName: @(0.0f),
                NSLigatureAttributeName: @(0.0f),
                NSParagraphStyleAttributeName: paragraphStyle,
                NSShadowAttributeName: shadow,
                (textColor? NSForegroundColorAttributeName : (id)kCTForegroundColorFromContextAttributeName): (textColor? (id)[_textColor CGColor] : @(YES)),
            }];
        } else if (_renderMode == kRenderModeAttributedText) {
            _attributedTextForDrawing = [self _preprocessAttributedText:_attributedText];
        }
        _stringDrawingContext = [[NSStringDrawingContext alloc] init];
    }
    return _attributedTextForDrawing;
}

@end
