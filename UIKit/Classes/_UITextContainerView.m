#import "_UITextContainerView.h"
//
#import <QuartzCore/QuartzCore.h>
//
#import <UIKit/UIColor.h>
#import <UIKit/NSTextStorage.h>
#import <UIKit/NSTextContainer.h>
#import <UIKit/NSLayoutManager.h>


@implementation _UITextContainerView {
    CALayer* _insertionPoint;
}

- (instancetype) initWithFrame:(CGRect)frame
{
    if (nil != (self = [super initWithFrame:frame])) {
        _insertionPoint = [CALayer layer];
        _insertionPoint.backgroundColor = [[UIColor blackColor] CGColor];
        _insertionPoint.actions = @{
            @"onOrderIn": [NSNull null],
            @"onOrderOut": [NSNull null],
            @"sublayers": [NSNull null],
            @"contents": [NSNull null],
            @"bounds": [NSNull null],
            @"position": [NSNull null],
            @"hidden": [NSNull null],
        };
        
        CAKeyframeAnimation* animation = [CAKeyframeAnimation animationWithKeyPath:@"opacity"];
        [animation setKeyTimes:@[ @0.0f, @0.45, @0.5f ]];
        [animation setValues:@[ @0.0f, @0.0, @1.0f ]];
        [animation setDuration:0.5f];
        [animation setAutoreverses:YES];
        [animation setRepeatCount:CGFLOAT_MAX];
        [_insertionPoint addAnimation:animation forKey:@"opacity"];
        
        [self.layer addSublayer:_insertionPoint];
    }
    return self;
}

- (void) drawRect:(CGRect)rect
{
    NSTextContainer* textContainer = [self textContainer];
    NSLayoutManager* layoutManager = [textContainer layoutManager];
    NSRange glyphRange = [layoutManager glyphRangeForBoundingRect:rect inTextContainer:textContainer];
    if (glyphRange.length) {
        [layoutManager drawBackgroundForGlyphRange:glyphRange atPoint:CGPointZero];
        [layoutManager drawGlyphsForGlyphRange:glyphRange atPoint:CGPointZero];
    }
}

- (void) setSelectedRange:(NSRange)selectedRange
{
    if (_selectedRange.length != selectedRange.length) {
        [self setNeedsDisplay];
    }
    _selectedRange = selectedRange;
    [self setShouldShowInsertionPoint:selectedRange.length == 0];
}

- (void) setShouldShowInsertionPoint:(BOOL)shouldShowInsertionPoint
{
    if (_shouldShowInsertionPoint != shouldShowInsertionPoint) {
        _shouldShowInsertionPoint = shouldShowInsertionPoint;
        _insertionPoint.hidden = !shouldShowInsertionPoint;
    }
}

- (void) setCaretPosition:(NSInteger)caretPosition
{
    CGRect rect = [self _viewRectForCharacterRange:(NSRange){ caretPosition, 0}];
    rect.origin.x = floor(rect.origin.x);
    _insertionPoint.frame = rect;
    _insertionPoint.hidden = !_shouldShowInsertionPoint || (_selectedRange.length > 0);
}

- (NSRect) _viewRectForCharacterRange:(NSRange)range
{
    NSTextContainer* textContainer = [self textContainer];
    NSLayoutManager* layoutManager = [textContainer layoutManager];
    NSTextStorage* textStorage = [layoutManager textStorage];
    
    NSRect result = {};
    if (range.length == 0){
        if (range.location > [textStorage length]) {
            result = [layoutManager extraLineFragmentRect];
        } else {
            NSUInteger rectCount = 0;
            NSRect* rectArray = [layoutManager rectArrayForCharacterRange:(NSRange){ range.location, 1 } withinSelectedCharacterRange:(NSRange){ NSNotFound, 0 } inTextContainer:textContainer rectCount:&rectCount];
            if (rectCount) {
                result = rectArray[0];
            } else {
                rectArray = [layoutManager rectArrayForCharacterRange:(NSRange){ range.location, 0 } withinSelectedCharacterRange:(NSRange){ NSNotFound, 0 } inTextContainer:textContainer rectCount:&rectCount];
                if (rectCount) {
                    result = rectArray[0];
                }
            }
        }
        result.size.width = 1;
    } else {
        if (range.location >= [textStorage length]) {
            result = [layoutManager extraLineFragmentRect];
        } else {
            NSRange glyphRange = [layoutManager glyphRangeForCharacterRange:range actualCharacterRange:NULL];
            result = [layoutManager boundingRectForGlyphRange:glyphRange inTextContainer:textContainer];
        }
    }
    return result;
}

@end

