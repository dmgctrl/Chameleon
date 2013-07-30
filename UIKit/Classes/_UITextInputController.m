#import "_UITextInputController.h"
//
#import <UIKit/NSTextStorage.h>
#import <UIKit/NSTextContainer.h>
#import <UIKit/NSLayoutManager.h>
//
#import "_UITextViewPosition.h"
#import "_UITextViewRange.h"


@implementation _UITextInputController {
    struct {
        bool textInputShouldBeginEditing : 1;
        bool textInputShouldChangeCharactersInRangeReplacementText : 1;
        bool textInputDidChange : 1;
        bool textInputDidChangeSelection : 1;
        bool textInputWillChangeSelectionFromCharacterRangeToCharacterRange : 1;
        bool textInputEditorDidChangeSelection : 1;
        bool textInputPrepareAttributedTextForInsertion : 1;
    } _delegateHas;
}
@synthesize markedTextStyle;
@synthesize tokenizer;
@synthesize inputDelegate;

- (instancetype) initWithLayoutManager:(NSLayoutManager*)layoutManager
{
    if (nil != (self = [super init])) {
        _layoutManager = layoutManager;
        _selectedRange = (NSRange){ NSNotFound, 0 };
    }
    return self;
}

- (void) setDelegate:(id<_UITextInputControllerDelegate>)delegate
{
    if (_delegate != delegate) {
        _delegate = delegate;
        _delegateHas.textInputDidChange = [delegate respondsToSelector:@selector(textInputDidChange:)];
        _delegateHas.textInputDidChangeSelection = [delegate respondsToSelector:@selector(textInputDidChangeSelection:)];
        _delegateHas.textInputEditorDidChangeSelection = [delegate respondsToSelector:@selector(textInputEditorDidChangeSelection:)];
        _delegateHas.textInputPrepareAttributedTextForInsertion = [delegate respondsToSelector:@selector(textInput:prepareAttributedTextForInsertion:)];
        _delegateHas.textInputShouldBeginEditing = [delegate respondsToSelector:@selector(textInputShouldBeginEditing:)];
        _delegateHas.textInputShouldChangeCharactersInRangeReplacementText = [delegate respondsToSelector:@selector(textInput:shouldChangeCharactersInRange:replacementText:)];
        _delegateHas.textInputWillChangeSelectionFromCharacterRangeToCharacterRange = [delegate respondsToSelector:@selector(textInput:willChangeSelectionFromCharacterRange:toCharacterRange:)];
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


#pragma mark Public Methods

- (void) setSelectedRange:(NSRange)selectedRange
{
    if ((_selectedRange.location != selectedRange.location) || (_selectedRange.length != selectedRange.length)) {
        if (_delegateHas.textInputWillChangeSelectionFromCharacterRangeToCharacterRange) {
            selectedRange = [[self delegate] textInput:self willChangeSelectionFromCharacterRange:_selectedRange toCharacterRange:selectedRange];
        }
        _selectedRange = selectedRange;
        if (_delegateHas.textInputDidChangeSelection) {
            [[self delegate] textInputDidChangeSelection:self];
        }
    }
}


#pragma mark UIKeyInput

- (BOOL) hasText
{
    return [[self _textStorage] length] > 0;
}

- (void) insertText:(NSString*)text
{
    [self _replaceCharactersInRange:[self selectedRange] withString:text];
}

- (void) deleteBackward
{
    UITextRange* range = [self selectedTextRange];
    if ([range isEmpty]) {
        UITextPosition* toPosition = [range start];
        UITextPosition* fromPosition = [self positionFromPosition:[range start] offset:-1];
        if (!fromPosition) {
            return;
        }
        range = [self textRangeFromPosition:fromPosition toPosition:toPosition];
    }
    if (![self shouldChangeTextInRange:range replacementText:@""]) {
        return;
    }
    [self replaceRange:range withText:@""];
}


#pragma mark UITextInput

- (UITextPosition*) beginningOfDocument
{
    return [_UITextViewPosition positionWithOffset:0];
}

- (UITextPosition*) closestPositionToPoint:(CGPoint)point
{
    NSInteger offset = [self _characterIndexAtPoint:point];
    return [_UITextViewPosition positionWithOffset:offset];
}

- (UITextPosition*) closestPositionToPoint:(CGPoint)point withinRange:(_UITextViewRange*)range
{
    UITextPosition* position = [self closestPositionToPoint:point];
    if (NSOrderedDescending == [self comparePosition:[range start] toPosition:position]) {
        return [range start];
    }
    if (NSOrderedAscending == [self comparePosition:[range end] toPosition:position]) {
        return [range end];
    }
    return position;
}

- (UITextRange*) characterRangeAtPoint:(CGPoint)point
{
    NSTextContainer* textContainer = [self _textContainer];
    NSLayoutManager* layoutManager = [textContainer layoutManager];
    
    NSRange actualGlyphRange;
    NSUInteger glyphIndex = [layoutManager glyphIndexForPoint:point inTextContainer:textContainer];
    NSRange range = [layoutManager characterRangeForGlyphRange:(NSRange){ glyphIndex, 1 } actualGlyphRange:&actualGlyphRange];
    if (!range.length) {
        return nil;
    }
    
    return [self textRangeFromPosition:[_UITextViewPosition positionWithOffset:range.location] toPosition:[_UITextViewPosition positionWithOffset:range.location + range.length]];
}

- (UITextRange*) characterRangeByExtendingPosition:(_UITextViewPosition*)position inDirection:(UITextLayoutDirection)direction
{
    NSAssert(!position || [position isKindOfClass:[_UITextViewPosition class]], @"???");
#warning Implement -characterRangeByExtendingPosition:inDirection:
    [self doesNotRecognizeSelector:_cmd];
    return nil;
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

- (UITextPosition*) endOfDocument
{
    return [_UITextViewPosition positionWithOffset:[[self _textStorage] length]];
}

- (UITextRange*) markedTextRange
{
#warning Implement -markedTextRange
    return nil;
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

- (NSInteger) offsetFromPosition:(_UITextViewPosition*)fromPosition toPosition:(_UITextViewPosition*)toPosition
{
    NSAssert(!fromPosition || [fromPosition isKindOfClass:[_UITextViewPosition class]], @"???");
    NSAssert(!toPosition || [toPosition isKindOfClass:[_UITextViewPosition class]], @"???");
    if (!fromPosition || !toPosition) {
        return 0;
    }
    return [toPosition offset] - [fromPosition offset];
}

- (UITextPosition*) positionFromPosition:(_UITextViewPosition*)position offset:(NSInteger)offset
{
    NSAssert(!position || [position isKindOfClass:[_UITextViewPosition class]], @"???");
    if (!position) {
        return nil;
    }
    NSInteger newOffset = [position offset] + offset;
    if (newOffset < 0 || newOffset > [[self _textStorage] length]) {
        return nil;
    }
    return [_UITextViewPosition positionWithOffset:newOffset];
}

- (UITextPosition*) positionFromPosition:(_UITextViewPosition*)position inDirection:(UITextLayoutDirection)direction offset:(NSInteger)offset
{
    NSAssert(!position || [position isKindOfClass:[_UITextViewPosition class]], @"???");
    if (!position) {
        return nil;
    }
    NSInteger index = [position offset];
    switch (direction) {
        case UITextLayoutDirectionDown: {
            return [_UITextViewPosition positionWithOffset:[self _indexWhenMovingDownFromIndex:index by:offset]];
        }
        case UITextLayoutDirectionUp: {
            return [_UITextViewPosition positionWithOffset:[self _indexWhenMovingUpFromIndex:index by:offset]];
        }
        case UITextLayoutDirectionLeft: {
            return [_UITextViewPosition positionWithOffset:[self _indexWhenMovingLeftFromIndex:index by:offset]];
        }
        case UITextLayoutDirectionRight: {
            return [_UITextViewPosition positionWithOffset:[self _indexWhenMovingRightFromIndex:index by:offset]];
        }
    }
}

- (UITextPosition*) positionWithinRange:(_UITextViewRange*)range farthestInDirection:(UITextLayoutDirection)direction
{
    NSAssert(!range || [range isKindOfClass:[_UITextViewRange class]], @"???");
#warning Implement -positionWithinRange:farthestInDirection:
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

- (UITextWritingDirection) baseWritingDirectionForPosition:(_UITextViewPosition*)position inDirection:(UITextStorageDirection)direction
{
    NSAssert(!position || [position isKindOfClass:[_UITextViewPosition class]], @"???");
#warning Implement -baseWritingDirectionForPosition:inDirection:
    [self doesNotRecognizeSelector:_cmd];
    return UITextWritingDirectionNatural;
}

- (void) setBaseWritingDirection:(UITextWritingDirection)writingDirection forRange:(UITextRange*)range
{
    NSAssert(!range || [range isKindOfClass:[_UITextViewRange class]], @"???");
#warning Implement -setBaseWritingDirection:forRange:
    [self doesNotRecognizeSelector:_cmd];
}

- (CGRect) firstRectForRange:(_UITextViewRange*)range
{
#warning Implement -firstRectForRange:
    NSAssert(!range || [range isKindOfClass:[_UITextViewRange class]], @"???");
    return CGRectZero;
}

- (CGRect) caretRectForPosition:(_UITextViewPosition*)position
{
#warning Implement -caretRectForPosition:
    NSAssert(!position || [position isKindOfClass:[_UITextViewPosition class]], @"???");
    return CGRectZero;
}

- (NSArray*) selectionRectsForRange:(_UITextViewRange*)range
{
#warning Implement -selectionRectsForRange:
    NSAssert(!range || [range isKindOfClass:[_UITextViewRange class]], @"???");
    return nil;
}

- (void) replaceRange:(_UITextViewRange*)range withText:(NSString*)text
{
    NSAssert(!range || [range isKindOfClass:[_UITextViewRange class]], @"???");
    NSInteger start = [[range start] offset];
    NSInteger end = [[range end] offset];
    if (start < 0 || end < start || end > [[self _textStorage] length]) {
        return /* Question: Exception? */;
    }
    [self _replaceCharactersInRange:(NSRange){ start, end - start } withString:text];
}

- (BOOL) shouldChangeTextInRange:(_UITextViewRange*)range replacementText:(NSString*)text
{
    NSInteger start = [[range start] offset];
    NSInteger end = [[range end] offset];
    if (start < 0 || end < start || end > [[self _textStorage] length]) {
        return NO;
    }
    return [self _canChangeTextInRange:(NSRange){ start, end - start } replacementText:text];
}

- (UITextRange*) selectedTextRange
{
    NSRange range = [self selectedRange];
    if (range.location == NSNotFound && range.length == 0) {
        return nil;
    } else {
        return [self textRangeFromPosition:[_UITextViewPosition positionWithOffset:range.location] toPosition:[_UITextViewPosition positionWithOffset:range.location + range.length]];
    }
}

- (void) setSelectedTextRange:(_UITextViewRange*)selectedTextRange
{
    NSAssert(!selectedTextRange || [selectedTextRange isKindOfClass:[_UITextViewRange class]], @"???");
    if (selectedTextRange) {
        NSInteger start = [[selectedTextRange start] offset];
        NSInteger count = [[selectedTextRange end] offset] - start;
        [self setSelectedRange:(NSRange){ start, count }];
    } else {
        [self setSelectedRange:(NSRange){ NSNotFound, 0 }];
    }
}

- (NSString*) textInRange:(_UITextViewRange*)range
{
    NSAssert(!range || [range isKindOfClass:[_UITextViewRange class]], @"???");
    if (!range) {
        return nil;
    }
    NSInteger start = [[range start] offset];
    NSInteger end = [[range end] offset];
    NSTextStorage* textStorage = [self _textStorage];
    if (start < 0 || end < start || end > [textStorage length]) {
        return nil;
    }
    return [[textStorage string] substringWithRange:(NSRange){ start, end - start }];
}

- (UITextRange*) textRangeFromPosition:(_UITextViewPosition*)fromPosition toPosition:(_UITextViewPosition*)toPosition
{
    NSAssert([fromPosition isKindOfClass:[_UITextViewPosition class]], @"???");
    NSAssert([toPosition isKindOfClass:[_UITextViewPosition class]], @"???");
    return [[_UITextViewRange alloc] initWithStart:fromPosition end:toPosition];
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
    
    [self setSelectedRange:(NSRange){ range.location + [string length], 0 }];
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

@end
