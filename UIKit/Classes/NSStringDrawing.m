#import "NSStringDrawing.h"
#import <UIKit/UIStringDrawing.h>
#import <UIKit/UIFont.h>
#import <UIKit/NSText.h>
#import <UIKit/UIGraphics.h>
#import <CoreGraphics/CoreGraphics.h>


@interface NSStringDrawingContext ()
@property (nonatomic, readonly) CTFrameRef CTFrame;
@end

@implementation NSStringDrawingContext

- (void) dealloc
{
    self.CTFrame = nil;
}

- (void) setCTFrame:(CTFrameRef)frame
{
    if (frame != _CTFrame) {
        if (_CTFrame) {
            CFRelease(_CTFrame), _CTFrame = nil;
        }
        _CTFrame = frame;
        if (frame) {
            CFRetain(frame);
        }
    }
}

@end


@implementation NSAttributedString (NSStringDrawing)
@end


@implementation NSAttributedString (NSExtendedStringDrawing)

- (void) drawWithRect:(CGRect)rect options:(NSStringDrawingOptions)options context:(NSStringDrawingContext*)context
{
    NSStringDrawingContext* contextToUse = context ?: [[NSStringDrawingContext alloc] init];
    if (![context CTFrame]) {
        [self boundingRectWithSize:rect.size options:options context:contextToUse];
    }
    
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    @try {
        CGContextSaveGState(ctx);
        
        CGContextTranslateCTM(ctx, rect.origin.x, rect.origin.y);
        CGContextScaleCTM(ctx, 1.0f, -1.0f);
        CGContextTranslateCTM(ctx, 0, -rect.size.height);
        
        CTFrameDraw([context CTFrame], UIGraphicsGetCurrentContext());
    } @finally {
        CGContextRestoreGState(ctx);
    }
}

- (CGRect) boundingRectWithSize:(CGSize)constrainedToSize options:(NSStringDrawingOptions)options context:(NSStringDrawingContext*)context
{
    CGSize size = {};
    NSMutableArray* lines = nil;
    
    CTFramesetterRef framesetter = CTFramesetterCreateWithAttributedString((__bridge CFAttributedStringRef)self);
    if (framesetter) {
        CFRange fitRange;
        CGSize suggestedSize = CTFramesetterSuggestFrameSizeWithConstraints(framesetter, (CFRange){}, NULL, constrainedToSize, &fitRange);
        CGSize boundingBox = {
            suggestedSize.width = MIN(ceil(suggestedSize.width), constrainedToSize.width),
            suggestedSize.height = MIN(ceil(suggestedSize.height), constrainedToSize.height)
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
                    
                    [context setCTFrame:frame];
                }
                CFRelease(frame), frame = nil;
            }
            CFRelease(path), path = nil;
        }
        CFRelease(framesetter), framesetter = nil;
    }
    
    return (CGRect){
        .size = size
    };
}

@end
