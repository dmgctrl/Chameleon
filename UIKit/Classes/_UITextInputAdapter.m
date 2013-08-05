#import "_UITextInputAdapter.h"
/**/
#import "_UITextInputModel.h"
#import "_UITextInteractionController.h"
#import "_UITextViewPosition.h"
#import "_UITextViewRange.h"


@implementation _UITextInputAdapter {
    _UITextInputModel* _inputModel;
    _UITextInteractionController* _interactionController;
}
@synthesize markedTextRange;
@synthesize markedTextStyle;
@synthesize inputDelegate;
@synthesize tokenizer;


- (instancetype) initWithInputModel:(_UITextInputModel*)inputModel interactionController:(_UITextInteractionController*)interactionController
{
    NSAssert(nil != inputModel, @"???");
    NSAssert(nil != interactionController, @"???");
    if (nil != (self = [super init])) {
        _inputModel = inputModel;
        _interactionController = interactionController;
    }
    return self;
}


#pragma mark UIKeyInput

- (BOOL) hasText
{
    return [_inputModel hasText];
}

- (void) insertText:(NSString*)text
{
    [_interactionController insertText:text];
}

- (void) deleteBackward
{
    [_interactionController deleteBackward];
}


#pragma mark UITextInput

- (NSString*) textInRange:(_UITextViewRange*)range
{
    NSAssert(!range || [range isKindOfClass:[_UITextViewRange class]], @"???");
    return [_inputModel textInRange:[range NSRange]];
}

- (void) replaceRange:(_UITextViewRange*)range withText:(NSString*)text
{
    NSAssert(!range || [range isKindOfClass:[_UITextViewRange class]], @"???");
    [_inputModel replaceRange:[range NSRange] withText:text];
}

- (BOOL) shouldChangeTextInRange:(_UITextViewRange*)range replacementText:(NSString*)text
{
    NSAssert(!range || [range isKindOfClass:[_UITextViewRange class]], @"???");
    return [_inputModel shouldChangeTextInRange:[range NSRange] replacementText:text];
}

- (UITextRange*) selectedTextRange
{
    NSRange range = [_inputModel selectedRange];
    if (range.location == NSNotFound && range.length == 0) {
        return nil;
    } else {
        return [_UITextViewRange rangeWithNSRange:range];
    }
}

- (void) setSelectedTextRange:(_UITextViewRange*)selectedTextRange
{
    NSAssert(!selectedTextRange || [selectedTextRange isKindOfClass:[_UITextViewRange class]], @"???");
    if (!selectedTextRange) {
        [_inputModel setSelectedRange:(NSRange){ NSNotFound, 0 }];
    } else {
        [_inputModel setSelectedRange:[selectedTextRange NSRange]];
    }
}

- (UITextRange*) markedTextRange
{
    return [_UITextViewRange rangeWithNSRange:[_inputModel markedTextRange]];
}

- (void) setMarkedText:(NSString*)markedText selectedRange:(NSRange)selectedRange
{
    [_inputModel setMarkedText:markedText selectedRange:selectedRange];
}

- (void) unmarkText
{
    [_inputModel unmarkText];
}

- (UITextRange*) textRangeFromPosition:(_UITextViewPosition*)fromPosition toPosition:(_UITextViewPosition*)toPosition
{
    NSAssert([fromPosition isKindOfClass:[_UITextViewPosition class]], @"???");
    NSAssert([toPosition isKindOfClass:[_UITextViewPosition class]], @"???");
    return [[_UITextViewRange alloc] initWithStart:fromPosition end:toPosition];
}

- (UITextRange*) textRangeOfWordContainingPosition:(_UITextViewPosition*)position
{
    NSAssert(!position || [position isKindOfClass:[_UITextViewPosition class]], @"???");
    if (!position) {
        return nil;
    }
    return [_UITextViewRange rangeWithNSRange:[_inputModel textRangeOfWordContainingPosition:[position offset]]];
}

- (UITextPosition*) positionFromPosition:(_UITextViewPosition*)position offset:(NSInteger)offset
{
    NSAssert(!position || [position isKindOfClass:[_UITextViewPosition class]], @"???");
    if (!position) {
        return nil;
    }
    return [_UITextViewPosition positionWithOffset:[_inputModel positionFromPosition:[position offset] offset:offset]];
}

- (UITextPosition*) positionFromPosition:(_UITextViewPosition*)position inDirection:(UITextLayoutDirection)direction offset:(NSInteger)offset
{
    NSAssert(!position || [position isKindOfClass:[_UITextViewPosition class]], @"???");
    if (!position) {
        return nil;
    }
    return [_UITextViewPosition positionWithOffset:[_inputModel positionFromPosition:[position offset] inDirection:direction offset:offset]];
}

- (UITextPosition*) beginningOfDocument
{
    return [_UITextViewPosition positionWithOffset:[_inputModel beginningOfDocument]];
}

- (UITextPosition*) endOfDocument
{
    return [_UITextViewPosition positionWithOffset:[_inputModel endOfDocument]];
}

- (NSComparisonResult) comparePosition:(_UITextViewPosition*)position toPosition:(_UITextViewPosition*)other
{
    NSAssert(!position || [position isKindOfClass:[_UITextViewPosition class]], @"???");
    NSAssert(!other || [other isKindOfClass:[_UITextViewPosition class]], @"???");
    if (!position || !other) {
        return NSOrderedSame;
    }
    NSInteger delta = [position offset] - [other offset];
    if (delta > 0) {
        return NSOrderedDescending;
    } else if (delta < 0) {
        return NSOrderedAscending;
    } else {
        return NSOrderedSame;
    }
}

- (NSInteger) offsetFromPosition:(_UITextViewPosition*)fromPosition toPosition:(_UITextViewPosition*)toPosition
{
    NSAssert(!fromPosition || [fromPosition isKindOfClass:[_UITextViewPosition class]], @"???");
    NSAssert(!toPosition || [toPosition isKindOfClass:[_UITextViewPosition class]], @"???");
    if (!fromPosition || !toPosition) {
        return 0;
    }
    return [toPosition offset] - [fromPosition offset];
}

- (UITextPosition*) positionWithinRange:(_UITextViewRange*)range farthestInDirection:(UITextLayoutDirection)direction
{
    NSAssert(!range || [range isKindOfClass:[_UITextViewRange class]], @"???");
    return [_UITextViewPosition positionWithOffset:[_inputModel positionWithinRange:[range NSRange] farthestInDirection:direction]];
}

- (UITextPosition*) positionWithinRange:(_UITextViewRange*)range atCharacterOffset:(NSInteger)offset
{
    NSAssert(!range || [range isKindOfClass:[_UITextViewRange class]], @"???");
    return [_UITextViewPosition positionWithOffset:[_inputModel positionWithinRange:[range NSRange] atCharacterOffset:offset]];
}

- (UITextRange*) characterRangeByExtendingPosition:(UITextPosition*)position inDirection:(UITextLayoutDirection)direction
{
    NSAssert(!position || [position isKindOfClass:[_UITextViewPosition class]], @"???");
    if (!position) {
        return nil;
    }
    UITextPosition* targetPosition = [self positionFromPosition:position inDirection:direction offset:1];
    if (NSOrderedSame <= [self comparePosition:position toPosition:targetPosition]) {
        return [self textRangeFromPosition:position toPosition:targetPosition];
    } else {
        return [self textRangeFromPosition:targetPosition toPosition:position];
    }
}

- (NSInteger) characterOffsetOfPosition:(_UITextViewPosition*)position withinRange:(_UITextViewRange*)range
{
    NSAssert(!position || [position isKindOfClass:[_UITextViewPosition class]], @"???");
    NSAssert(!range || [range isKindOfClass:[_UITextViewRange class]], @"???");
    return [_inputModel characterOffsetOfPosition:[position offset] withinRange:[range NSRange]];
}

- (UITextWritingDirection) baseWritingDirectionForPosition:(_UITextViewPosition*)position inDirection:(UITextStorageDirection)direction
{
    NSAssert(!position || [position isKindOfClass:[_UITextViewPosition class]], @"???");
    return [_inputModel baseWritingDirectionForPosition:[position offset] inDirection:direction];
}

- (void) setBaseWritingDirection:(UITextWritingDirection)writingDirection forRange:(_UITextViewRange*)range
{
    NSAssert(!range || [range isKindOfClass:[_UITextViewRange class]], @"???");
    [_inputModel setBaseWritingDirection:writingDirection forRange:[range NSRange]];
}

- (CGRect) firstRectForRange:(_UITextViewRange*)range
{
    NSAssert(!range || [range isKindOfClass:[_UITextViewRange class]], @"???");
    return [_inputModel firstRectForRange:[range NSRange]];
}

- (CGRect) caretRectForPosition:(_UITextViewPosition*)position
{
    NSAssert(!position || [position isKindOfClass:[_UITextViewPosition class]], @"???");
    return [_inputModel caretRectForPosition:[position offset]];
}

- (NSArray*) selectionRectsForRange:(_UITextViewRange*)range
{
    NSAssert(!range || [range isKindOfClass:[_UITextViewRange class]], @"???");
    return [_inputModel selectionRectsForRange:[range NSRange]];
}

- (UITextPosition*) closestPositionToPoint:(CGPoint)point
{
    return [_UITextViewPosition positionWithOffset:[_inputModel closestPositionToPoint:point]];
}

- (UITextPosition*) closestPositionToPoint:(CGPoint)point withinRange:(_UITextViewRange*)range
{
    NSAssert(!range || [range isKindOfClass:[_UITextViewRange class]], @"???");
    return [_UITextViewPosition positionWithOffset:[_inputModel closestPositionToPoint:point withinRange:[range NSRange]]];
}

- (UITextRange*) characterRangeAtPoint:(CGPoint)point
{
    return [_UITextViewRange rangeWithNSRange:[_inputModel characterRangeAtPoint:point]];
}

@end
