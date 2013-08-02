#import "_UITextInputModelAdapter.h"
#import "_UITextInputModel.h"


@implementation _UITextInputModelAdapter {
    _UITextInputModel* _inputModel;
}

- (instancetype) initWithInputModel:(_UITextInputModel*)inputModel
{
    NSAssert(nil != inputModel, @"???");
    if (nil != (self = [super init])) {
        _inputModel = inputModel;
    }
    return self;
}

- (NSString*) textInRange:(UITextRange*)range
{
    return [_inputModel textInRange:range];
}

- (void) replaceRange:(UITextRange*)range withText:(NSString*)text
{
    [_inputModel replaceRange:range withText:text];
}

- (BOOL) shouldChangeTextInRange:(UITextRange*)range replacementText:(NSString*)text
{
    return [_inputModel shouldChangeTextInRange:range replacementText:text];
}

- (UITextRange*) selectedTextRange
{
    return [_inputModel selectedTextRange];
}

- (void) setSelectedTextRange:(UITextRange*)selectedTextRange
{
    [_inputModel setSelectedTextRange:selectedTextRange];
}

- (UITextRange*) markedTextRange
{
    return [_inputModel markedTextRange];
}

- (void) setMarkedText:(NSString*)markedText selectedRange:(NSRange)selectedRange
{
    [_inputModel setMarkedText:markedText selectedRange:selectedRange];
}

- (void) unmarkText
{
    [_inputModel unmarkText];
}

- (UITextRange*) textRangeFromPosition:(UITextPosition*)fromPosition toPosition:(UITextPosition*)toPosition
{
    return [_inputModel textRangeFromPosition:fromPosition toPosition:toPosition];
}

- (UITextPosition*) positionFromPosition:(UITextPosition*)position offset:(NSInteger)offset
{
    return [_inputModel positionFromPosition:position offset:offset];
}

- (UITextPosition*) positionFromPosition:(UITextPosition*)position inDirection:(UITextLayoutDirection)direction offset:(NSInteger)offset
{
    return [_inputModel positionFromPosition:position inDirection:direction offset:offset];
}

- (UITextPosition*) beginningOfDocument
{
    return [_inputModel beginningOfDocument];
}

- (UITextPosition*) endOfDocument
{
    return [_inputModel endOfDocument];
}

- (NSComparisonResult) comparePosition:(UITextPosition*)position toPosition:(UITextPosition*)other
{
    return [_inputModel comparePosition:position toPosition:other];
}

- (NSInteger) offsetFromPosition:(UITextPosition*)fromPosition toPosition:(UITextPosition*)toPosition
{
    return [_inputModel offsetFromPosition:fromPosition toPosition:toPosition];
}

- (UITextPosition*) positionWithinRange:(UITextRange*)range farthestInDirection:(UITextLayoutDirection)direction
{
    return [_inputModel positionWithinRange:range farthestInDirection:direction];
}

- (UITextRange*) characterRangeByExtendingPosition:(UITextPosition*)position inDirection:(UITextLayoutDirection)direction
{
    return [_inputModel characterRangeByExtendingPosition:position inDirection:direction];
}

- (UITextWritingDirection) baseWritingDirectionForPosition:(UITextPosition*)position inDirection:(UITextStorageDirection)direction
{
    return [_inputModel baseWritingDirectionForPosition:position inDirection:direction];
}

- (void) setBaseWritingDirection:(UITextWritingDirection)writingDirection forRange:(UITextRange*)range
{
    [_inputModel setBaseWritingDirection:writingDirection forRange:range];
}

- (CGRect) firstRectForRange:(UITextRange*)range
{
    return [_inputModel firstRectForRange:range];
}

- (CGRect) caretRectForPosition:(UITextPosition*)position
{
    return [_inputModel caretRectForPosition:position];
}

- (NSArray*) selectionRectsForRange:(UITextRange*)range
{
    return [_inputModel selectionRectsForRange:range];
}

- (UITextPosition*) closestPositionToPoint:(CGPoint)point
{
    return [_inputModel closestPositionToPoint:point];
}

- (UITextPosition*) closestPositionToPoint:(CGPoint)point withinRange:(UITextRange*)range
{
    return [_inputModel closestPositionToPoint:point withinRange:range];
}

- (UITextRange*) characterRangeAtPoint:(CGPoint)point
{
    return [_inputModel characterRangeAtPoint:point];
}

@end
