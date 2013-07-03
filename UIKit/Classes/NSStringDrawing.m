#import "NSStringDrawing.h"
#import <UIKit/UIStringDrawing.h>
#import <UIKit/UIFont.h>
#import <UIKit/NSText.h>
#import <UIKit/UIGraphics.h>
#import <CoreGraphics/CoreGraphics.h>


@interface NSStringDrawingContext ()
@property (nonatomic, readonly) CTFrameRef CTFrame;
@property (nonatomic, readonly) NSAttributedString* attributedString;
@end

@implementation NSStringDrawingContext

- (void) dealloc
{
    if (_CTFrame) {
        CFRelease(_CTFrame), _CTFrame = nil;
    }
}

- (void) setCTFrame:(CTFrameRef)frame forAttributedString:(NSAttributedString*)attributedString
{
    if (frame != _CTFrame || attributedString != _attributedString) {
        if (_CTFrame) {
            CFRelease(_CTFrame), _CTFrame = nil;
        }
        _attributedString = attributedString;
        _CTFrame = frame;
        if (frame) {
            CFRetain(frame);
        }
    }
}

- (CGSize) renderedSize
{
    if (!_CTFrame) {
        return CGSizeZero;
    }

    NSArray* lines = (__bridge NSArray*)CTFrameGetLines(_CTFrame);
    CFIndex numberOfLines = [lines count];
    if (numberOfLines == 0) {
        return CGSizeZero;
    }
    
    CGFloat maxWidth = 0;
    CGFloat ascender;
    CGFloat leading;
    for (NSUInteger i = 0; i < numberOfLines; i++) {
        CTLineRef line = (__bridge CTLineRef)lines[i];
        CGFloat width = CTLineGetTypographicBounds(line, &ascender, NULL, &leading);
        CGFloat trailingWhitespaceWidth = CTLineGetTrailingWhitespaceWidth(line);
        maxWidth = MAX(maxWidth, width - trailingWhitespaceWidth);
    }
    
    CGPathRef path = CTFrameGetPath(_CTFrame);
    CGRect boundingBox = CGPathGetBoundingBox(path);
    
    CGPoint lastLineOrigin;
    CTFrameGetLineOrigins(_CTFrame, CFRangeMake(numberOfLines - 1, 1), &lastLineOrigin);
    return (CGSize){
        .width = ceilf(maxWidth),
        .height = MAX(ceilf(lastLineOrigin.y + ascender + leading) + 1.0f, boundingBox.size.height),
    };
}

@end


@implementation NSAttributedString (NSStringDrawing)
@end


@implementation NSAttributedString (NSExtendedStringDrawing)

- (void) drawWithRect:(CGRect)rect options:(NSStringDrawingOptions)options context:(NSStringDrawingContext*)context
{
    NSStringDrawingContext* contextToUse = context ?: [[NSStringDrawingContext alloc] init];
    if (self != [context attributedString]) {
        [self boundingRectWithSize:rect.size options:options context:contextToUse];
    }
    
    CGContextRef c = UIGraphicsGetCurrentContext();
    @try {
        CGContextSaveGState(c);
        
        CGContextTranslateCTM(c, rect.origin.x, rect.origin.y);
        CGContextScaleCTM(c, 1.0f, -1.0f);
        CGContextTranslateCTM(c, 0, -rect.size.height);
        
        CTFrameDraw([context CTFrame], c);
    } @finally {
        CGContextRestoreGState(c);
    }
}

- (CGRect) boundingRectWithSize:(CGSize)size options:(NSStringDrawingOptions)options context:(NSStringDrawingContext*)context
{
    NSStringDrawingContext* contextToUse = context ?: [[NSStringDrawingContext alloc] init];

    CTFramesetterRef framesetter = CTFramesetterCreateWithAttributedString((__bridge CFAttributedStringRef)self);
    if (framesetter) {
        CFRange fitRange;
        CGSize suggestedSize = CTFramesetterSuggestFrameSizeWithConstraints(framesetter, (CFRange){}, NULL, size, &fitRange);
        CGSize boundingBox = {
            MIN(ceil(suggestedSize.width), size.width),
            MIN(ceil(suggestedSize.height), size.height)
        };
        CGMutablePathRef path = CGPathCreateMutable();
        if (path) {
            CGPathAddRect(path, NULL, (CGRect){ .size = boundingBox });
            CTFrameRef frame = CTFramesetterCreateFrame(framesetter, (CFRange){}, path, NULL);
            if (frame) {
                [context setCTFrame:frame forAttributedString:self];

                CFRelease(frame), frame = nil;
            }
            CFRelease(path), path = nil;
        }
        CFRelease(framesetter), framesetter = nil;
    }
    
    return (CGRect){
        .size = [contextToUse renderedSize]
    };
}

@end
