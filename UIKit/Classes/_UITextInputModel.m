#import "_UITextInputModel.h"
//
#import <UIKit/NSTextStorage.h>
#import <UIKit/NSTextContainer.h>
#import <UIKit/NSLayoutManager.h>


@implementation _UITextInputModel {
    struct {
        bool textInputShouldBeginEditing : 1;
        bool textInputShouldChangeCharactersInRangeReplacementText : 1;
        bool textInputDidChange : 1;
        bool textInputWillChangeSelectionFromCharacterRangeToCharacterRange : 1;
        bool textInputPrepareAttributedTextForInsertion : 1;
    } _delegateHas;
}
@synthesize markedTextStyle;

- (instancetype) initWithLayoutManager:(NSLayoutManager*)layoutManager
{
    if (nil != (self = [super init])) {
        _layoutManager = layoutManager;
    }
    return self;
}

- (void) setDelegate:(id<_UITextInputModelDelegate>)delegate
{
    if (_delegate != delegate) {
        _delegate = delegate;
        _delegateHas.textInputDidChange = [delegate respondsToSelector:@selector(textInputDidChange:)];
        _delegateHas.textInputPrepareAttributedTextForInsertion = [delegate respondsToSelector:@selector(textInput:prepareAttributedTextForInsertion:)];
        _delegateHas.textInputShouldBeginEditing = [delegate respondsToSelector:@selector(textInputShouldBeginEditing:)];
        _delegateHas.textInputShouldChangeCharactersInRangeReplacementText = [delegate respondsToSelector:@selector(textInput:shouldChangeCharactersInRange:replacementText:)];
    }
}

- (NSTextContainer*) _textContainer
{
    return [[[self layoutManager] textContainers] objectAtIndex:0];
}

- (NSTextStorage*) _textStorage
{
    return [[self layoutManager] textStorage];
}


#pragma mark UIKeyInput

- (BOOL) hasText
{
    return [[self _textStorage] length] > 0;
}


#pragma mark UITextInput

- (NSInteger) beginningOfDocument
{
    return 0;
}

- (NSInteger) closestPositionToPoint:(CGPoint)point
{
    return [self _characterIndexAtPoint:point];
}

- (NSInteger) closestPositionToPoint:(CGPoint)point withinRange:(NSRange)range
{
    NSInteger position = [self closestPositionToPoint:point];
    if (position < range.location) {
        return range.location;
    } else if (position > (range.location + range.length)) {
        return range.location + range.length;
    }
    return position;
}

- (NSRange) characterRangeAtPoint:(CGPoint)point
{
    NSTextContainer* textContainer = [self _textContainer];
    NSLayoutManager* layoutManager = [textContainer layoutManager];
    
    NSRange actualGlyphRange;
    NSUInteger glyphIndex = [layoutManager glyphIndexForPoint:point inTextContainer:textContainer];
    return [layoutManager characterRangeForGlyphRange:(NSRange){ glyphIndex, 1 } actualGlyphRange:&actualGlyphRange];
}

- (NSInteger) characterOffsetOfPosition:(NSInteger)position withinRange:(NSRange)range
{
#warning Implement -characterOffsetOfPosition:withinRange:
    [self doesNotRecognizeSelector:_cmd];
    return 0;
}

- (NSInteger) endOfDocument
{
    return [[self _textStorage] length];
}

- (NSRange) markedTextRange
{
#warning Implement -markedTextRange
    return (NSRange){};
}

- (void) setMarkedText:(NSString*)markedText selectedRange:(NSRange)selectedRange
{
#warning Implement -setMarkedText:selectedRange:
    [self doesNotRecognizeSelector:_cmd];
}

- (void) unmarkText
{
#warning Implement -unmarkText
}

- (NSInteger) positionFromPosition:(NSInteger)position offset:(NSInteger)offset
{
    NSInteger newOffset = position + offset;
    if (newOffset < 0) {
        return 0;
    } else if (newOffset > [[self _textStorage] length]) {
        return [[self _textStorage] length];
    }
    return newOffset;
}

- (NSInteger) positionFromPosition:(NSInteger)position inDirection:(UITextLayoutDirection)direction offset:(NSInteger)offset
{
    switch (direction) {
        case UITextLayoutDirectionDown: {
            return [self _indexWhenMovingDownFromIndex:position by:offset];
        }
        case UITextLayoutDirectionUp: {
            return [self _indexWhenMovingUpFromIndex:position by:offset];
        }
        case UITextLayoutDirectionLeft: {
            return [self _indexWhenMovingLeftFromIndex:position by:offset];
        }
        case UITextLayoutDirectionRight: {
            return [self _indexWhenMovingRightFromIndex:position by:offset];
        }
    }
}

- (NSInteger) positionWithinRange:(NSRange)range farthestInDirection:(UITextLayoutDirection)direction
{
#warning Implement -positionWithinRange:farthestInDirection:
    [self doesNotRecognizeSelector:_cmd];
    return 0;
}

- (NSInteger) positionWithinRange:(NSRange)range atCharacterOffset:(NSInteger)offset
{
#warning Implement -positionWithinRange:farthestInDirection:
    [self doesNotRecognizeSelector:_cmd];
    return 0;
}

- (UITextWritingDirection) baseWritingDirectionForPosition:(NSInteger)position inDirection:(UITextStorageDirection)direction
{
#warning Implement -baseWritingDirectionForPosition:inDirection:
    [self doesNotRecognizeSelector:_cmd];
    return UITextWritingDirectionNatural;
}

- (void) setBaseWritingDirection:(UITextWritingDirection)writingDirection forRange:(NSRange)range
{
#warning Implement -setBaseWritingDirection:forRange:
    [self doesNotRecognizeSelector:_cmd];
}

- (CGRect) firstRectForRange:(NSRange)range
{
#warning Implement -firstRectForRange:
    return CGRectZero;
}

- (CGRect) caretRectForPosition:(NSInteger)position
{
#warning Implement -caretRectForPosition:
    return CGRectZero;
}

- (NSArray*) selectionRectsForRange:(NSRange)range
{
#warning Implement -selectionRectsForRange:
    return nil;
}

- (void) replaceRange:(NSRange)range withText:(NSString*)text
{
    [self _replaceCharactersInRange:range withString:text];
}

- (BOOL) shouldChangeTextInRange:(NSRange)range replacementText:(NSString*)text
{
    NSInteger start = range.location;
    NSInteger end = range.location + range.length;
    if (start < 0 || end < start || end > [[self _textStorage] length]) {
        return NO;
    }
    return [self _canChangeTextInRange:(NSRange){ start, end - start } replacementText:text];
}

- (NSDictionary*) textStylingAtPosition:(NSInteger)position inDirection:(UITextStorageDirection)direction
{
    return [[self _textStorage] attributesAtIndex:position effectiveRange:NULL];
}

- (NSString*) textInRange:(NSRange)range
{
    return [[[self _textStorage] string] substringWithRange:range];
}

- (NSRange) textRangeFromPosition:(NSInteger)fromPosition toPosition:(NSInteger)toPosition
{
    return (NSRange){ fromPosition, toPosition - fromPosition };
}


#pragma mark _UITextInputPlus

- (NSRange) textRangeOfWordContainingPosition:(NSInteger)index
{
    NSString* text = [[self _textStorage] string];
    __block NSUInteger start = 0;
    [text enumerateSubstringsInRange:NSMakeRange(0, index) options:(NSStringEnumerationByWords | NSStringEnumerationReverse) usingBlock:^(NSString *substring, NSRange substringRange, NSRange enclosingRange, BOOL *stop){
        if (enclosingRange.length > substringRange.length) {
            start = enclosingRange.location + substringRange.length;
        } else {
            start = substringRange.location;
        }
        *stop = YES;
    }];
    __block NSUInteger end = 0;
    [text enumerateSubstringsInRange:NSMakeRange(index, [text length] - index) options:(NSStringEnumerationByWords) usingBlock:^(NSString *substring, NSRange substringRange, NSRange enclosingRange, BOOL *stop){
        if (enclosingRange.location < substringRange.location) {
            end = substringRange.location;
        } else {
            end = substringRange.location + substringRange.length;
        }
        *stop = YES;
    }];
    return (NSRange){ start, end - start };
}


#pragma mark Private Methods

- (BOOL) _canChangeTextInRange:(NSRange)range replacementText:(NSString*)string
{
    if (_delegateHas.textInputShouldChangeCharactersInRangeReplacementText) {
        return [[self delegate] textInput:self shouldChangeCharactersInRange:range replacementText:string];
    } else {
        return YES;
    }
}

- (void) _replaceCharactersInRange:(NSRange)range withString:(NSString*)string
{
    NSTextStorage* textStorage = [self _textStorage];
    if (_delegateHas.textInputPrepareAttributedTextForInsertion) {
        NSMutableAttributedString* text = [[NSMutableAttributedString alloc] initWithString:string];
        [[self delegate] textInput:self prepareAttributedTextForInsertion:text];
        [textStorage replaceCharactersInRange:range withAttributedString:text];
    } else {
        [textStorage replaceCharactersInRange:range withString:string];
    }
    if (_delegateHas.textInputDidChange) {
        [[self delegate] textInputDidChange:self];
    }
}

- (NSUInteger) _characterIndexAtPoint:(CGPoint)point
{
    NSTextContainer* textContainer = [self _textContainer];
    NSLayoutManager* layoutManager = [textContainer layoutManager];
    NSTextStorage* textStorage = [layoutManager textStorage];
    NSUInteger length = [textStorage length];
    
    CGFloat fraction = 0;
    NSUInteger index = [layoutManager characterIndexForPoint:point inTextContainer:textContainer fractionOfDistanceBetweenInsertionPoints:&fraction];
    if (index >= length) {
        return length;
    } else if ([[NSCharacterSet newlineCharacterSet] characterIsMember:[[textStorage string] characterAtIndex:index]]) {
        return index;
    } else {
        return index + (fraction > 0.75);
    }
}

- (NSInteger) _indexWhenMovingRightFromIndex:(NSInteger)index
{
    return [self _indexWhenMovingRightFromIndex:index by:1];
}

- (NSInteger) _indexWhenMovingRightFromIndex:(NSInteger)index by:(NSInteger)byNumberOfGlyphs
{
    NSLayoutManager* layoutManager = [self layoutManager];
    NSInteger numberOfGlyphs = [layoutManager numberOfGlyphs];
    NSInteger newIndex = index + byNumberOfGlyphs;
    if (newIndex < 0) {
        return 0;
    } else if (newIndex >= numberOfGlyphs) {
        return numberOfGlyphs;
    } else {
        return newIndex;
    }
}

- (NSInteger) _indexWhenMovingLeftFromIndex:(NSInteger)index
{
    return [self _indexWhenMovingLeftFromIndex:index by:1];
}

- (NSInteger) _indexWhenMovingLeftFromIndex:(NSInteger)index by:(NSInteger)byNumberOfGlyphs
{
    NSLayoutManager* layoutManager = [self layoutManager];
    NSInteger numberOfGlyphs = [layoutManager numberOfGlyphs];
    NSInteger newIndex = index - byNumberOfGlyphs;
    if (newIndex < 0) {
        return 0;
    } else if (newIndex >= numberOfGlyphs) {
        return numberOfGlyphs;
    } else {
        return newIndex;
    }
}

- (NSInteger) _indexWhenMovingWordLeftFromIndex:(NSInteger)index
{
    NSString* text = [[self _textStorage] string];
    NSRange range = NSMakeRange(0, index);
    NSInteger __block newIndex;
    NSInteger __block counter = 0;
    [text enumerateSubstringsInRange:range options:(NSStringEnumerationByWords | NSStringEnumerationReverse) usingBlock:^(NSString *substring, NSRange substringRange, NSRange enclosingRange, BOOL *stop){
        newIndex = substringRange.location;
        counter++;
        *stop = YES;
    }];
    return newIndex < 0 ? 0 : newIndex;
}

- (NSInteger) _indexWhenMovingWordRightFromIndex:(NSInteger)index
{
    NSString* text = [[self _textStorage] string];
    NSInteger maxIndex = [text length];
    NSRange range = NSMakeRange(index, maxIndex - index);
    NSInteger __block newIndex;
    [text enumerateSubstringsInRange:range options:NSStringEnumerationByWords usingBlock:^(NSString *substring, NSRange substringRange, NSRange enclosingRange, BOOL *stop){
        newIndex = substringRange.location + substring.length;
        *stop = YES;
    }];
    return MIN(newIndex, maxIndex);
}

- (NSInteger) _indexWhenMovingUpFromIndex:(NSInteger)index by:(NSInteger)numberOfLines
{
    if (numberOfLines <= 0) {
        return index;
    }
    
    NSTextContainer* textContainer = [self _textContainer];
    NSLayoutManager* layoutManager = [textContainer layoutManager];
    NSInteger numberOfGlyphs = [layoutManager numberOfGlyphs];
    
    if (index <= 0) {
        return 0;
    }
    
    NSInteger newIndex = MIN(index, numberOfGlyphs - 1);
    NSInteger lineNumber = 0;
    NSRect fragmentRect = {};
    CGFloat x = floor([layoutManager locationForGlyphAtIndex:newIndex].x);
    do {
        NSRange range;
        fragmentRect = [layoutManager lineFragmentRectForGlyphAtIndex:newIndex effectiveRange:&range];
        if (lineNumber >= numberOfLines) {
            break;
        }
        lineNumber++;
        newIndex = range.location - 1;
    } while (newIndex > 0);
    
    if (newIndex <= 0) {
        return 0;
    }
    
    CGFloat fraction = 0;
    NSInteger glyphIndex = [layoutManager glyphIndexForPoint:(CGPoint){ x, CGRectGetMinY(fragmentRect) } inTextContainer:textContainer fractionOfDistanceThroughGlyph:&fraction];
    if (![layoutManager notShownAttributeForGlyphAtIndex:glyphIndex]) {
        glyphIndex += (fraction > 0.75);
    }
    return glyphIndex;
}

- (NSInteger) _indexWhenMovingDownFromIndex:(NSInteger)index by:(NSInteger)numberOfLines
{
    if (numberOfLines <= 0) {
        return index;
    }
    
    NSTextContainer* textContainer = [self _textContainer];
    NSLayoutManager* layoutManager = [textContainer layoutManager];
    NSInteger numberOfGlyphs = [layoutManager numberOfGlyphs];
    
    if (index >= numberOfGlyphs) {
        return numberOfGlyphs;
    }
    
    NSInteger newIndex = MAX(index, 0);
    NSInteger lineNumber = 0;
    NSRect fragmentRect = {};
    CGFloat x = floor([layoutManager locationForGlyphAtIndex:newIndex].x);
    do {
        NSRange range;
        fragmentRect = [layoutManager lineFragmentRectForGlyphAtIndex:newIndex effectiveRange:&range];
        if (lineNumber >= numberOfLines) {
            break;
        }
        lineNumber++;
        newIndex = NSMaxRange(range);
    } while (newIndex < numberOfGlyphs);
    
    if (newIndex >= numberOfGlyphs) {
        return numberOfGlyphs;
    }
    
    CGFloat fraction = 0;
    NSInteger glyphIndex = [layoutManager glyphIndexForPoint:(CGPoint){ x, CGRectGetMinY(fragmentRect) } inTextContainer:textContainer fractionOfDistanceThroughGlyph:&fraction];
    if (![layoutManager notShownAttributeForGlyphAtIndex:glyphIndex]) {
        glyphIndex += (fraction > 0.75);
    }
    return glyphIndex;
}

- (NSInteger) _indexWhenMovingToBeginningOfLineFromIndex:(NSInteger)index
{
    NSInteger textLength = [[self _textStorage] length];
    NSRange lineFragmentRange;
    [[self layoutManager] lineFragmentRectForGlyphAtIndex:(index >= textLength ? textLength - 1 : index) effectiveRange:&lineFragmentRange withoutAdditionalLayout:YES];
    NSInteger newIndex = lineFragmentRange.location;
    if (newIndex >= textLength) {
        return [self _indexWhenMovingToBeginningOfParagraphFromIndex:index];
    }
    return MAX(newIndex, [self _indexWhenMovingToBeginningOfParagraphFromIndex:index]);
}

- (NSInteger) _indexWhenMovingToEndOfLineFromIndex:(NSInteger)index
{
    NSInteger textLength = [[self _textStorage] length];
    if (index >= textLength) {
        return textLength;
    }
    NSRange lineFragmentRange;
    [[self layoutManager] lineFragmentRectForGlyphAtIndex:index effectiveRange:&lineFragmentRange withoutAdditionalLayout:YES];
    NSInteger newIndex = NSMaxRange(lineFragmentRange);
    if (newIndex == textLength) {
        return newIndex;
    }
    return MIN(newIndex - 1, [self _indexWhenMovingToEndOfParagraphFromIndex:index]);
}

- (NSInteger) _indexWhenMovingToBeginningOfParagraphFromIndex:(NSInteger)index
{
    NSString* string = [[self _textStorage] string];
    return [string paragraphRangeForRange:(NSRange){ index, 0 }].location;
}

- (NSInteger) _indexWhenMovingToEndOfParagraphFromIndex:(NSInteger)index
{
    NSString* string = [[self _textStorage] string];
    NSInteger newIndex = NSMaxRange([string lineRangeForRange:(NSRange){ index, 0 }]);
    if (newIndex > 0 && [[NSCharacterSet newlineCharacterSet] characterIsMember:[string characterAtIndex:newIndex - 1]]) {
        newIndex--;
    }
    return newIndex;
}

- (NSInteger) _indexWhenMovingToBeginningOfDocumentFromIndex:(NSInteger)index
{
    return 0;
}

- (NSInteger) _indexWhenMovingToEndOfDocumentFromIndex:(NSInteger)index
{
    return [[self _textStorage] length];
}

- (NSInteger) _endOfDocument
{
    return [[self _textStorage] length];
}

@end
