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

#import "UIStringDrawing.h"
#import "UIFont.h"
#import "UIFont+UIPrivate.h"
#import "UIColor.h"
#import <AppKit/AppKit.h>
#import "UIGraphics.h"


@interface NSAttributedString (UIStringDrawing)
+ (NSAttributedString*) attributedStringWithString:(NSString*)string font:(UIFont*)font color:(UIColor*)color lineBreakMode:(UILineBreakMode)lineBreakMode textAlignment:(UITextAlignment)textAlignment shadow:(NSShadow*)shadow;
@end


NSString *const UITextAttributeFont = @"UITextAttributeFont";
NSString *const UITextAttributeTextColor = @"UITextAttributeTextColor";
NSString *const UITextAttributeTextShadowColor = @"UITextAttributeTextShadowColor";
NSString *const UITextAttributeTextShadowOffset = @"UITextAttributeTextShadowOffset";

static CTLineTruncationType CTLineTruncationTypeFromUILineBreakMode(UILineBreakMode lineBreakMode)
{
    switch (lineBreakMode) {
        case UILineBreakModeHeadTruncation:   return kCTLineTruncationStart;
        case UILineBreakModeTailTruncation:   return kCTLineTruncationEnd;
        case UILineBreakModeMiddleTruncation: return kCTLineTruncationMiddle;
        default: @throw [NSException exceptionWithName:NSInvalidArgumentException reason:@"TODO" userInfo:nil];
    }
}

static CTLineBreakMode CTLineBreakModeFromUILineBreakMode(UILineBreakMode lineBreakMode)
{
    switch (lineBreakMode) {
        case UILineBreakModeWordWrap:         return kCTLineBreakByWordWrapping;
        case UILineBreakModeCharacterWrap:    return kCTLineBreakByCharWrapping;
        case UILineBreakModeClip:             return kCTLineBreakByClipping;
        case UILineBreakModeHeadTruncation:   return kCTLineBreakByTruncatingHead;
        case UILineBreakModeTailTruncation:   return kCTLineBreakByTruncatingTail;
        case UILineBreakModeMiddleTruncation: return kCTLineBreakByTruncatingMiddle;
    }
}

static NSTextAlignment NSTextAlignmentFromUITextAlignment(UITextAlignment textAlignment)
{
    switch (textAlignment) {
        case UITextAlignmentLeft:   return NSLeftTextAlignment;
        case UITextAlignmentCenter: return NSCenterTextAlignment;
        case UITextAlignmentRight:  return NSRightTextAlignment;
    }
}

static NSArray* CTLinesForString(NSString* string, CGSize constrainedToSize, UIFont*font, UILineBreakMode lineBreakMode, CGSize* renderSize, void(^block)(CTFrameRef, CGSize))
{ 
    if (!font || constrainedToSize.height == 0 || constrainedToSize.width == 0) {
        if (renderSize) {
            *renderSize = CGSizeZero;
        }
        return nil;
    }

    CGSize size = {};
    NSMutableArray* lines = nil;
    
    NSAttributedString* attributedString = [NSAttributedString attributedStringWithString:string font:font color:nil lineBreakMode:lineBreakMode textAlignment:UITextAlignmentLeft shadow:nil];
    CTFramesetterRef framesetter = CTFramesetterCreateWithAttributedString((__bridge CFAttributedStringRef)attributedString);
    if (framesetter) {
        CFRange fitRange;
        CGSize suggestedSize = CTFramesetterSuggestFrameSizeWithConstraints(framesetter, (CFRange){}, NULL, constrainedToSize, &fitRange);
        CGSize boundingBox = {
            .width = MIN(ceil(suggestedSize.width), constrainedToSize.width),
            .height = MIN(ceil(suggestedSize.height), constrainedToSize.height)
        };
        CGMutablePathRef path = CGPathCreateMutable();
        if (path) {
            CGPathAddRect(path, NULL, (CGRect){ .size = boundingBox });
            CTFrameRef frame = CTFramesetterCreateFrame(framesetter, (CFRange){}, path, NULL);
            if (frame) {
                lines = (__bridge NSMutableArray*)CTFrameGetLines(frame);
                CFIndex numberOfLines = [lines count];
                if (numberOfLines > 0) {
                    BOOL calculateMaxWidth = YES;

                    if (lineBreakMode == UILineBreakModeClip) {
                        CTLineRef line = (__bridge CTLineRef)lines[numberOfLines - 1];
                        CFRange range = CTLineGetStringRange(line);
                        CTTypesetterRef typesetter = CTFramesetterGetTypesetter(framesetter);
                        lines[numberOfLines - 1] = (__bridge_transfer id)CTTypesetterCreateLine(
                            typesetter,
                            (CFRange){
                                range.location,
                                CTTypesetterSuggestClusterBreak(typesetter, range.location, constrainedToSize.width)
                            }
                        );
                    } else if (lineBreakMode != UILineBreakModeCharacterWrap) {
                        /*  The CoreText machinery will attempt to fill the allotted space with
                         *  single characters (even if word wrapping is specified.)  Apple's sizing
                         *  functions return a string width of zero.
                         */
                        CFStringTokenizerRef tokenizer = CFStringTokenizerCreate(NULL, (__bridge CFStringRef)string, (CFRange){.length = [string length]}, kCFStringTokenizerUnitWord, NULL);
                        if (tokenizer) {
                            CFStringTokenizerAdvanceToNextToken(tokenizer);
                            CFRange range = CFStringTokenizerGetCurrentTokenRange(tokenizer);
                            if (range.location == kCFNotFound) {
                                calculateMaxWidth = NO;
                            } else {
                                CTTypesetterRef typesetter = CTFramesetterGetTypesetter(framesetter);
                                CFIndex breakIndex = CTTypesetterSuggestClusterBreak(typesetter, 0, constrainedToSize.width);
                                if (breakIndex < (range.location + range.length)) {
                                    calculateMaxWidth = NO;
                                }
                            }
                            CFRelease(tokenizer), tokenizer = nil;
                        }
                    }
                    
                    CGFloat maxWidth = 0;
                    CGFloat ascender;
                    CGFloat leading;
                    for (NSUInteger i = 0; i < numberOfLines; i++) {
                        CTLineRef line = (__bridge CTLineRef)lines[i];
                        CGFloat width = CTLineGetTypographicBounds(line, &ascender, NULL, &leading);
                        CGFloat trailingWhitespaceWidth = CTLineGetTrailingWhitespaceWidth(line);
                        if (calculateMaxWidth) {
                            maxWidth = MAX(maxWidth, width - trailingWhitespaceWidth);
                        }
                    }
                    
                    CGPoint lastLineOrigin;
                    CTFrameGetLineOrigins(frame, CFRangeMake(numberOfLines - 1, 1), &lastLineOrigin);
                    size = (CGSize){
                        .width = ceilf(maxWidth),
                        .height = MAX(ceilf(lastLineOrigin.y + ascender + leading) + 1.0f, boundingBox.height),
                    };
                    
                    if (block) {
                        block(frame, size);
                    }
                }
                CFRelease(frame), frame = nil;
            }
            CFRelease(path), path = nil;
        }
        CFRelease(framesetter), framesetter = nil;
    }
    
    if (renderSize) {
        *renderSize = size;
    }
    return lines;
}


@implementation NSAttributedString (UIStringDrawing)

+ (NSAttributedString*) attributedStringWithString:(NSString*)string font:(UIFont*)font color:(UIColor*)color lineBreakMode:(UILineBreakMode)lineBreakMode textAlignment:(UITextAlignment)textAlignment shadow:(NSShadow*)shadow
{
    NSMutableParagraphStyle* paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    [paragraphStyle setTighteningFactorForTruncation:0.0f];
    [paragraphStyle setLineBreakMode:CTLineBreakModeFromUILineBreakMode(lineBreakMode)];
    [paragraphStyle setAlignment:NSTextAlignmentFromUITextAlignment(textAlignment)];
    return [[NSAttributedString alloc] initWithString:string attributes:@{
        NSFontAttributeName: (id)[font ctFontRef],
        NSKernAttributeName: @(0.0f),
        NSLigatureAttributeName: @(0.0f),
        NSParagraphStyleAttributeName: paragraphStyle,
        NSShadowAttributeName: shadow? shadow : [[NSShadow alloc] init],
        (color? NSForegroundColorAttributeName : (id)kCTForegroundColorFromContextAttributeName): (color? (id)[color CGColor] : @(YES)),
    }];
}

@end


@implementation NSString (UIStringDrawing)

- (CGSize) sizeWithFont:(UIFont*)font
{
    return [self sizeWithFont:font forWidth:CGFLOAT_MAX lineBreakMode:UILineBreakModeWordWrap];
}

- (CGSize) sizeWithFont:(UIFont*)font forWidth:(CGFloat)width lineBreakMode:(UILineBreakMode)lineBreakMode
{
    return [self sizeWithFont:font constrainedToSize:CGSizeMake(width, [font lineHeight] * 1.5f) lineBreakMode:lineBreakMode];
}

- (CGSize) sizeWithFont:(UIFont*)font constrainedToSize:(CGSize)size
{
    return [self sizeWithFont:font constrainedToSize:size lineBreakMode:UILineBreakModeWordWrap];
}

- (CGSize) sizeWithFont:(UIFont*)font constrainedToSize:(CGSize)size lineBreakMode:(UILineBreakMode)lineBreakMode
{
    CGSize resultingSize = CGSizeZero;
    CTLinesForString(self, size, font, lineBreakMode, &resultingSize, nil);
    return resultingSize;
}

- (CGSize) sizeWithFont:(UIFont*)font minFontSize:(CGFloat)minFontSize actualFontSize:(CGFloat *)actualFontSize forWidth:(CGFloat)width lineBreakMode:(UILineBreakMode)lineBreakMode
{
    return CGSizeZero;
}

- (CGSize) drawAtPoint:(CGPoint)point withFont:(UIFont*)font
{
    return [self drawAtPoint:point forWidth:CGFLOAT_MAX withFont:font lineBreakMode:UILineBreakModeWordWrap];
}

- (CGSize) drawAtPoint:(CGPoint)point forWidth:(CGFloat)width withFont:(UIFont*)font minFontSize:(CGFloat)minFontSize actualFontSize:(CGFloat*)actualFontSize lineBreakMode:(UILineBreakMode)lineBreakMode baselineAdjustment:(UIBaselineAdjustment)baselineAdjustment
{
    return CGSizeZero;
}

- (CGSize) drawAtPoint:(CGPoint)point forWidth:(CGFloat)width withFont:(UIFont*)font fontSize:(CGFloat)fontSize lineBreakMode:(UILineBreakMode)lineBreakMode baselineAdjustment:(UIBaselineAdjustment)baselineAdjustment
{
    UIFont* adjustedFont = ([font pointSize] != fontSize)? [font fontWithSize:fontSize] : font;
    return [self drawInRect:CGRectMake(point.x,point.y,width,adjustedFont.lineHeight) withFont:adjustedFont lineBreakMode:lineBreakMode];
}

- (CGSize) drawAtPoint:(CGPoint)point forWidth:(CGFloat)width withFont:(UIFont*)font lineBreakMode:(UILineBreakMode)lineBreakMode
{
    return [self drawAtPoint:point forWidth:width withFont:font fontSize:[font pointSize] lineBreakMode:lineBreakMode baselineAdjustment:UIBaselineAdjustmentNone];
}
 
- (CGSize) drawInRect:(CGRect)rect withFont:(UIFont*)font lineBreakMode:(UILineBreakMode)lineBreakMode alignment:(UITextAlignment)alignment
{
    CGSize actualSize;
    CTLinesForString(self, rect.size, font, lineBreakMode, &actualSize, ^(CTFrameRef frame, CGSize actualSize) {
        CGContextRef ctx = UIGraphicsGetCurrentContext();
        @try {
            CGContextSaveGState(ctx);
            
            CGContextTranslateCTM(ctx, rect.origin.x, rect.origin.y);
            CGContextScaleCTM(ctx, 1.0f, -1.0f);
            CGContextTranslateCTM(ctx, 0, -rect.size.height);
            
            CTFrameDraw(frame, ctx);
        } @finally {
            CGContextRestoreGState(ctx);
        }
    });
    return actualSize;
}

- (CGSize) drawInRect:(CGRect)rect withFont:(UIFont*)font
{
    return [self drawInRect:rect withFont:font lineBreakMode:UILineBreakModeWordWrap alignment:UITextAlignmentLeft];
}

- (CGSize) drawInRect:(CGRect)rect withFont:(UIFont*)font lineBreakMode:(UILineBreakMode)lineBreakMode
{
    return [self drawInRect:rect withFont:font lineBreakMode:lineBreakMode alignment:UITextAlignmentLeft];
}

@end
