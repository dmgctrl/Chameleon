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

#import <UIKit/UITextView.h>
#import <UIKit/UIColor.h>
#import <UIKit/UIFont.h>
#import <UIKit/UIPasteboard.h>
#import <UIKit/UITapGestureRecognizer.h>
#import <UIKit/UITouch.h>
#import <UIKit/NSTextStorage.h>
#import <UIKit/NSTextContainer.h>
#import <UIKit/NSLayoutManager.h>
//
#import "UIColor+AppKit.h"
#import "UIFont+UIPrivate.h"
#import "_UITextStorage.h"
#import "_UITextInteractionAssistant.h"
//
#import <AppKit/NSColor.h>
#import <AppKit/NSCursor.h>
//
#import <QuartzCore/QuartzCore.h>


typedef NS_ENUM(NSUInteger, NSSelectionGranularity) {
    NSSelectByCharacter = 0,
    NSSelectByWord = 1,
    NSSelectByParagraph = 2
};


NSString *const UITextViewTextDidBeginEditingNotification = @"UITextViewTextDidBeginEditingNotification";
NSString *const UITextViewTextDidChangeNotification = @"UITextViewTextDidChangeNotification";
NSString *const UITextViewTextDidEndEditingNotification = @"UITextViewTextDidEndEditingNotification";

static NSString* const kUIEditableKey = @"UIEditable";


@interface _UITextContainerView : UIView
@property (nonatomic) NSTextContainer* textContainer;
@property (nonatomic) NSRange selectedRange;
@property (nonatomic) BOOL shouldShowInsertionPoint;
- (NSRect) _viewRectForCharacterRange:(NSRange)range;
@end


@protocol UITextViewDelegatePlus
- (BOOL) textView:(UITextView*)textView doCommandBySelector:(SEL)selector;
@end


@interface _UITextViewPosition : UITextPosition
+ (instancetype) positionWithOffset:(NSInteger)offset;
- (instancetype) initWithOffset:(NSInteger)offset;
@property (nonatomic, assign) NSInteger offset;
@end


@interface _UITextViewRange : UITextRange
- (instancetype) initWithStart:(_UITextViewPosition*)start end:(_UITextViewPosition*)end;
@property (nonatomic, readonly) _UITextViewPosition* start;
@property (nonatomic, readonly) _UITextViewPosition* end;
@end


@implementation UITextView {
    NSTextStorage* _textStorage;
    NSTextContainer* _textContainer;
    NSLayoutManager* _layoutManager;

    _UITextContainerView* _textContainerView;

    _UITextInteractionAssistant* _interactionAssistant;
    
    struct {
        BOOL shouldBeginEditing : 1;
        BOOL didBeginEditing : 1;
        BOOL shouldEndEditing : 1;
        BOOL didEndEditing : 1;
        BOOL shouldChangeText : 1;
        BOOL didChange : 1;
        BOOL didChangeSelection : 1;
        BOOL doCommandBySelector : 1;
    } _delegateHas;

    struct {
        bool didBeginEditing : 1;
    } _flags;
    
    NSUInteger _selectionOrigin;
    NSSelectionGranularity _selectionGranularity;
}
@dynamic delegate;
@synthesize markedTextStyle = _markedTextStyle;
@synthesize selectionAffinity = _selectionAffinity;
@synthesize inputDelegate;
@synthesize tokenizer;

static void _commonInitForUITextView(UITextView* self)
{
    self.textColor = [UIColor blackColor];
    self.font = [UIFont systemFontOfSize:17];
    self.dataDetectorTypes = UIDataDetectorTypeNone;
    self.editable = YES;
    self.contentMode = UIViewContentModeScaleToFill;
    self.clipsToBounds = YES;

    self->_selectedRange = (NSRange){ NSNotFound, 0 };
    
    self->_textContainerView = [[_UITextContainerView alloc] initWithFrame:CGRectZero];
    [self->_textContainerView setTextContainer:[self textContainer]];
    [self->_textContainerView setBackgroundColor:[self backgroundColor]];
    [self addSubview:self->_textContainerView];
}

- (instancetype) initWithFrame:(CGRect)frame textContainer:(NSTextContainer*)textContainer
{
    if (nil != (self = [super initWithFrame:frame])) {
        _textContainer = textContainer;
        _commonInitForUITextView(self);
    }
    return self;
}

- (instancetype) initWithFrame:(CGRect)frame
{
    return [self initWithFrame:frame textContainer:nil];
}

- (instancetype) initWithCoder:(NSCoder*)coder
{
    if (nil != (self = [super initWithCoder:coder])) {
        _commonInitForUITextView(self);
        if ([coder containsValueForKey:kUIEditableKey]) {
            self.editable = [coder decodeBoolForKey:kUIEditableKey];
        }
    }
    return self;
}


#pragma mark Properties

- (NSAttributedString*) attributedText
{
    NSTextStorage* textStorage = [self textStorage];
    return [textStorage attributedSubstringFromRange:(NSRange){ 0, [textStorage length] }];
}

- (void) setAttributedText:(NSAttributedString*)attributedText
{
    NSTextStorage* textStorage = [self textStorage];
    if (attributedText) {
        [textStorage replaceCharactersInRange:(NSRange){ 0, [textStorage length]} withAttributedString:attributedText];
    } else {
        [textStorage deleteCharactersInRange:(NSRange){ 0, [textStorage length]}];
    }
    [self setSelectedRange:(NSRange){ 0, 0 }];
    [self _didChangeText];
}

- (UITextAutocapitalizationType) autocapitalizationType
{
    return UITextAutocapitalizationTypeNone;
}

- (void) setAutocapitalizationType:(UITextAutocapitalizationType)type
{
}

- (UITextAutocorrectionType) autocorrectionType
{
    return UITextAutocorrectionTypeDefault;
}

- (void) setAutocorrectionType:(UITextAutocorrectionType)type
{
}

- (void) setEditable:(BOOL)editable
{
    _editable = editable;
}

- (BOOL) enablesReturnKeyAutomatically
{
    return YES;
}

- (void) setEnablesReturnKeyAutomatically:(BOOL)enabled
{
}

- (void) setFont:(UIFont*)font
{
    NSAssert(nil != font, @"???");
    _font = font;
    NSTextStorage* textStorage = [self textStorage];
    [textStorage addAttribute:(id)kCTFontAttributeName value:font range:(NSRange){ 0, [textStorage length] }];
    [_textContainerView setNeedsDisplay];
}

- (UIKeyboardAppearance) keyboardAppearance
{
    return UIKeyboardAppearanceDefault;
}

- (void) setKeyboardAppearance:(UIKeyboardAppearance)type
{
}

- (UIKeyboardType) keyboardType
{
    return UIKeyboardTypeDefault;
}

- (void) setKeyboardType:(UIKeyboardType)type
{
}

- (NSLayoutManager*) layoutManager
{
    return [[self textContainer] layoutManager];
}

- (UIReturnKeyType) returnKeyType
{
    return UIReturnKeyDefault;
}

- (void) setReturnKeyType:(UIReturnKeyType)type
{
}

- (void) setSelectedRange:(NSRange)range
{
    [self _setSelectedRange:range affinity:_selectionAffinity stillSelecting:NO];
}

- (NSString*) text
{
    return [[self textStorage] string];
}

- (void) setText:(NSString*)text
{
    if (text) {
        [self setAttributedText:[[NSAttributedString alloc] initWithString:text attributes:[self _stringAttributes]]];
    } else {
        [self setAttributedText:nil];
    }
}

- (void) setTextAlignment:(UITextAlignment)textAlignment
{
    _textAlignment = textAlignment;
    [_textContainerView setNeedsDisplay];
}

- (void) setTextColor:(UIColor*)textColor
{
    _textColor = textColor;
    NSTextStorage* textStorage = [self textStorage];
    [textStorage addAttribute:(id)kCTForegroundColorAttributeName value:textColor range:(NSRange){ 0, [textStorage length] }];
    [_textContainerView setNeedsDisplay];
}

- (NSTextContainer*) textContainer
{
    if (!_textContainer) {
        _textContainer = [[NSTextContainer alloc] initWithContainerSize:(CGSize){ [self bounds].size.width, CGFLOAT_MAX }];
        [_textContainer setWidthTracksTextView:YES];
        _textStorage = [[_UITextStorage alloc] init];
        _layoutManager = [[NSLayoutManager alloc] init];
        [_layoutManager addTextContainer:_textContainer];
        [_textStorage addLayoutManager:_layoutManager];
    }
    return _textContainer;
}

- (NSTextStorage*) textStorage
{
    return [[[self textContainer] layoutManager] textStorage];
}


#pragma mark Property Overrides

- (void) setBackgroundColor:(UIColor*)backgroundColor
{
    [super setBackgroundColor:backgroundColor];
    [_textContainerView setBackgroundColor:backgroundColor];
}

- (void) setDelegate:(id<UITextViewDelegate>)delegate
{
    if (delegate != self.delegate) {
        [super setDelegate:delegate];
        _delegateHas.shouldBeginEditing = [delegate respondsToSelector:@selector(textViewShouldBeginEditing:)];
        _delegateHas.didBeginEditing = [delegate respondsToSelector:@selector(textViewDidBeginEditing:)];
        _delegateHas.shouldEndEditing = [delegate respondsToSelector:@selector(textViewShouldEndEditing:)];
        _delegateHas.didEndEditing = [delegate respondsToSelector:@selector(textViewDidEndEditing:)];
        _delegateHas.shouldChangeText = [delegate respondsToSelector:@selector(textView:shouldChangeTextInRange:replacementText:)];
        _delegateHas.didChange = [delegate respondsToSelector:@selector(textViewDidChange:)];
        _delegateHas.didChangeSelection = [delegate respondsToSelector:@selector(textViewDidChangeSelection:)];
        _delegateHas.doCommandBySelector = [delegate respondsToSelector:@selector(textView:doCommandBySelector:)];
    }
}


#pragma mark Layout

- (void) layoutSubviews
{
    [super layoutSubviews];

    CGRect bounds = [self bounds];
    NSTextContainer* textContainer = [self textContainer];
    NSLayoutManager* layoutManager = [textContainer layoutManager];
    UIEdgeInsets contentInset = [self contentInset];
    CGFloat containerWidth = bounds.size.width - (contentInset.left + contentInset.right);
    [textContainer setContainerSize:(CGSize){
        containerWidth,
        CGFLOAT_MAX
    }];
    [layoutManager ensureLayoutForTextContainer:textContainer];
    CGSize contentSize = {
        containerWidth,
        [layoutManager usedRectForTextContainer:textContainer].size.height
    };
    [self setContentSize:contentSize];
    [_textContainerView setFrame:(CGRect){
        .size = contentSize
    }];
    [_textContainerView setNeedsDisplayInRect:bounds];
}


#pragma mark Scrolling

- (void) scrollRangeToVisible:(NSRange)range
{
    UIEdgeInsets contentInset = [self contentInset];
    CGRect boundingRect = [_textContainerView _viewRectForCharacterRange:range];
    boundingRect.origin.y -= contentInset.top;
    boundingRect.size.height += contentInset.top + contentInset.bottom;
    [super scrollRectToVisible:boundingRect animated:NO];
}

- (void) scrollToBeginningOfDocument:(id)sender
{
    NSRange range = [self selectedRange];
    [self _setAndScrollToRange:(NSRange){
        [self _indexWhenMovingToBeginningOfDocumentFromIndex:[self selectedRange].location],
        0
    }];
    [self setSelectedRange:range];
}

- (void) scrollToEndOfDocument:(id)sender
{
    NSRange range = [self selectedRange];
    [self _setAndScrollToRange:(NSRange){
        [self _indexWhenMovingToEndOfDocumentFromIndex:[self selectedRange].location],
        0
    }];
    [self setSelectedRange:range];
}


#pragma mark UIView

- (void) willMoveToWindow:(UIWindow*)window
{
    [super willMoveToWindow:window];
    if (window) {
        _interactionAssistant = [[_UITextInteractionAssistant alloc] initWithView:self];
        [self addGestureRecognizer:[_interactionAssistant singleTapGesture]];
    } else {
        [self removeGestureRecognizer:[_interactionAssistant singleTapGesture]];
        _interactionAssistant = nil;
    }
}


#pragma mark UIResponder

- (BOOL) acceptsFirstMouse
{
    return [self canBecomeFirstResponder];
}

- (void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch* touch = [[event allTouches] anyObject];
    [self _setAndScrollToRange:(NSRange){
        [self _characterIndexAtPoint:[touch locationInView:_textContainerView]],
        0
    }];
    [super touchesBegan:touches withEvent:event];
}

- (void) touchesMoved:(NSSet*)touches withEvent:(UIEvent *)event
{
    UITouch* touch = [[event allTouches] anyObject];
    NSUInteger index = [self _characterIndexAtPoint:[touch locationInView:_textContainerView]];
    NSRange range;
    if (_selectionOrigin > index) {
        range = (NSRange){ index, _selectionOrigin - index };
        [self scrollRangeToVisible:range];
    } else {
        range = (NSRange){ _selectionOrigin, index - _selectionOrigin };
        [self scrollRangeToVisible:(NSRange){ NSMaxRange(range), 0 }];
    }
    [self _setSelectedRange:range affinity:_selectionAffinity stillSelecting:YES];
    [super touchesMoved:touches withEvent:event];
}

- (BOOL) canBecomeFirstResponder
{
    return (self.window != nil);
}

- (BOOL) becomeFirstResponder
{
    if ([super becomeFirstResponder]) {
        [_textContainerView setShouldShowInsertionPoint:YES];
        _flags.didBeginEditing = NO;
        return YES;
    }
    return NO;
}

- (BOOL) resignFirstResponder
{
    if ([self _endEditingIfNecessary]) {
        if ([super resignFirstResponder]) {
            [_textContainerView setShouldShowInsertionPoint:NO];
            return YES;
        }
    }
    return NO;
}

- (void) doCommandBySelector:(SEL)selector
{
    if (_delegateHas.doCommandBySelector && [(id<UITextViewDelegatePlus>)[self delegate] textView:self doCommandBySelector:selector]) {
        /* Do Nothing */
    } else if ([self respondsToSelector:selector]) {
        void (*command)(id, SEL, id) = (void*)[[self class] instanceMethodForSelector:selector];
        command(self, selector, self);
    }
}

- (void) selectAll:(id)sender
{
    [self setSelectedRange:NSMakeRange(0, [[self textStorage] length])];
}

- (void) deleteBackward:(id)sender
{
    [self deleteBackward];
}

- (void) deleteForward:(id)sender
{
    NSRange range = [self selectedRange];
    if (range.length > 0) {
        if (![self _canChangeTextInRange:range replacementText:@""]) {
            return;
        }
        [self _replaceCharactersInRange:range withString:@""];
        [self _didChangeText];
    } else if (range.location < [[self textStorage] length]) {
        if (![self _canChangeTextInRange:(NSRange){ range.location, 1 } replacementText:@""]) {
            return;
        }
        [self _replaceCharactersInRange:(NSRange){ range.location, 1 } withString:@""];
        [self _didChangeText];
    }
}

- (void) deleteWordBackward:(id)sender
{
    if ([self selectedRange].length == 0) {
        [self moveWordLeftAndModifySelection:self];
    }
    [self deleteBackward:self];
}

- (void) moveLeft:(id)sender
{
    [self _setAndScrollToRange:(NSRange){
        [self _indexWhenMovingLeftFromIndex:[self selectedRange].location],
        0
    }];
}

- (void) moveLeftAndModifySelection:(id)sender
{
    [self _modifySelectionWith:^NSInteger(NSInteger index) {
        return [self _indexWhenMovingLeftFromIndex:index];
    }];
}

- (void) moveWordLeft:(id)sender
{
    [self _setAndScrollToRange:(NSRange){
        [self _indexWhenMovingWordLeftFromIndex:[self selectedRange].location],
        0
    }];
}

- (void) moveWordLeftAndModifySelection:(id)sender
{
    [self _modifySelectionWith:^NSInteger(NSInteger index) {
        return [self _indexWhenMovingWordLeftFromIndex:index];
    }];
}

- (void) moveRight:(id)sender
{
    [self _setAndScrollToRange:(NSRange){
        [self _indexWhenMovingRightFromIndex:NSMaxRange([self selectedRange])],
        0
    }];
}

- (void) moveRightAndModifySelection:(id)sender
{
    [self _modifySelectionWith:^NSInteger(NSInteger index) {
        return [self _indexWhenMovingRightFromIndex:index];
    }];
}

- (void) moveWordRight:(id)sender
{
    [self _setAndScrollToRange:(NSRange){
        [self _indexWhenMovingWordRightFromIndex:[self selectedRange].location],
        0
    }];
}

- (void) moveWordRightAndModifySelection:(id)sender
{
    [self _modifySelectionWith:^NSInteger(NSInteger index) {
        return [self _indexWhenMovingWordRightFromIndex:index];
    }];
}

- (void) moveUp:(id)sender
{
    [self _setAndScrollToRange:(NSRange){
        [self _indexWhenMovingUpFromIndex:[self selectedRange].location by:1],
        0
    }];
}

- (void) moveUpAndModifySelection:(id)sender
{
    [self _modifySelectionWith:^NSInteger(NSInteger index) {
        return [self _indexWhenMovingUpFromIndex:index by:1];
    }];
}

- (void) moveDown:(id)sender
{
    [self _setAndScrollToRange:(NSRange){
        [self _indexWhenMovingDownFromIndex:NSMaxRange([self selectedRange]) by:1],
        0
    }];
}

- (void) moveDownAndModifySelection:(id)sender
{
    [self _modifySelectionWith:^NSInteger(NSInteger index) {
        return [self _indexWhenMovingDownFromIndex:index by:index];
    }];
}

- (void) moveToBeginningOfLine:(id)sender
{
    [self _setAndScrollToRange:(NSRange){
        [self _indexWhenMovingToBeginningOfLineFromIndex:[self selectedRange].location],
        0
    }];
}

- (void) moveToBeginningOfLineAndModifySelection:(id)sender
{
    [self _modifySelectionWith:^NSInteger(NSInteger index) {
        return [self _indexWhenMovingToBeginningOfLineFromIndex:index];
    }];
}

- (void) moveToEndOfLine:(id)sender
{
    [self _setAndScrollToRange:(NSRange){
        [self _indexWhenMovingToEndOfLineFromIndex:NSMaxRange([self selectedRange])],
        0
    }];
}

- (void) moveToEndOfLineAndModifySelection:(id)sender
{
    [self _modifySelectionWith:^NSInteger(NSInteger index) {
        return [self _indexWhenMovingToEndOfLineFromIndex:index];
    }];    
}

- (void) moveToBeginningOfParagraph:(id)sender
{
    [self _setAndScrollToRange:(NSRange){
        [self _indexWhenMovingToBeginningOfParagraphFromIndex:[self selectedRange].location],
        0
    }];
}

- (void) moveParagraphBackwardAndModifySelection:(id)sender
{
    [self _modifySelectionWith:^NSInteger(NSInteger index) {
        return [self _indexWhenMovingToBeginningOfParagraphFromIndex:index];
    }];
}

- (void) moveToBeginningOfParagraphOrMoveUp:(id)sender
{
    if ([self _isLocationAtBeginningOfParagraph]) {
        [self moveUp:self];
    } else {
        [self moveToBeginningOfParagraph:self];
    }
}

- (void) moveParagraphBackwardOrMoveUpAndModifySelection:(id)sender
{
    if ([self _isLocationAtBeginningOfParagraph]) {
        [self moveUpAndModifySelection:self];
    } else {
        [self moveParagraphBackwardAndModifySelection:self];
    }
}

- (void) moveToEndOfParagraph:(id)sender
{
    [self _setAndScrollToRange:(NSRange){
        [self _indexWhenMovingToEndOfParagraphFromIndex:[self selectedRange].location],
        0
    }];
}

- (void) moveToEndOfParagraphOrMoveDown:(id)sender
{
    if ([self _isLocationAtEndOfParagraph]) {
        [self moveDown:self];
    } else {
        [self moveToEndOfParagraph:self];
    }
}

- (void) moveParagraphForwardAndModifySelection:(id)sender
{
    [self _modifySelectionWith:^NSInteger(NSInteger index) {
        return [self _indexWhenMovingToEndOfParagraphFromIndex:index];
    }];
}

- (void) moveParagraphForwardOrMoveDownAndModifySelection:(id)sender
{
    if ([self _isLocationAtEndOfParagraph]) {
        [self moveDownAndModifySelection:self];
    } else {
        [self moveParagraphForwardAndModifySelection:self];
    }
}

- (void) moveToBeginningOfDocument:(id)sender
{
    [self _setAndScrollToRange:(NSRange){
        [self _indexWhenMovingToBeginningOfDocumentFromIndex:[self selectedRange].location],
        0
    }];
}

- (void) moveToBeginningOfDocumentAndModifySelection:(id)sender
{
    [self _modifySelectionWith:^NSInteger(NSInteger index) {
        return [self _indexWhenMovingToBeginningOfDocumentFromIndex:index];
    }];
}

- (void) moveToEndOfDocument:(id)sender
{
    [self _setAndScrollToRange:(NSRange){
        [self _indexWhenMovingToEndOfDocumentFromIndex:[self selectedRange].location],
        0
    }];
}

- (void) moveToEndOfDocumentAndModifySelection:(id)sender
{
    [self _modifySelectionWith:^NSInteger(NSInteger index) {
        return [self _indexWhenMovingToEndOfDocumentFromIndex:index];
    }];
}

- (void) cut:(id)sender
{
    NSRange range = [self selectedRange];
    if (range.length > 0) {
        [[UIPasteboard generalPasteboard] setString:[[self text] substringWithRange:range]];
        [self _replaceCharactersInRange:range withString:@""];
        [self _didChangeText];
    }
}

- (void) copy:(id)sender
{
    NSRange range = [self selectedRange];
    if (range.length > 0) {
        [[UIPasteboard generalPasteboard] setString:[[self text] substringWithRange:range]];
    }
}

- (void) paste:(id)sender
{
    NSRange range = [self selectedRange];
    [self _replaceCharactersInRange:range withString:[[UIPasteboard generalPasteboard] string]];
    [self _didChangeText];
}

- (void) insertNewline:(id)sender
{
    [self insertText:@"\n"];
}


#pragma mark UIKeyInput

- (BOOL) hasText
{
    return [[self textStorage] length] > 0;
}

- (void) insertText:(NSString*)text
{
    if (![self _beginEditingIfNecessary]) {
        return;
    }
    NSRange range = [self selectedRange];
    if (![self _canChangeTextInRange:range replacementText:text]) {
        return;
    }
    [self _replaceCharactersInRange:range withString:text];
    [self _didChangeText];
    [self scrollRangeToVisible:[self selectedRange]];
}

- (void) deleteBackward
{
    NSRange range = [self selectedRange];
    if (range.length > 0) {
        if (![self _canChangeTextInRange:range replacementText:@""]) {
            return;
        }
        [self _replaceCharactersInRange:range withString:@""];
        [self _didChangeText];
    } else if (range.location > 0) {
        range.location--;
        if (![self _canChangeTextInRange:(NSRange){ range.location, 1 } replacementText:@""]) {
            return;
        }
        [self _replaceCharactersInRange:(NSRange){ range.location, 1 } withString:@""];
        [self _didChangeText];
    }
}


#pragma mark UITextInput

- (NSString*) textInRange:(_UITextViewRange*)range
{
    NSAssert(!range || [range isKindOfClass:[_UITextViewRange class]], @"???");
    if (!range) {
        return nil;
    }
    NSInteger start = [[range start] offset];
    NSInteger end = [[range end] offset];
    NSTextStorage* textStorage = [self textStorage];
    if (start < 0 || end < start || end > [textStorage length]) {
        return nil;
    }
    return [[textStorage string] substringWithRange:(NSRange){ start, end - start }];
}

- (void) replaceRange:(_UITextViewRange*)range withText:(NSString*)text
{
    NSAssert(!range || [range isKindOfClass:[_UITextViewRange class]], @"???");
    NSInteger start = [[range start] offset];
    NSInteger end = [[range end] offset];
    if (start < 0 || end < start || end > [[self textStorage] length]) {
        return /* Question: Exception? */;
    }
    [self _replaceCharactersInRange:(NSRange){ start, end - start } withString:text];
}

- (BOOL) shouldChangeTextInRange:(_UITextViewRange*)range replacementText:(NSString*)text
{
    NSInteger start = [[range start] offset];
    NSInteger end = [[range end] offset];
    if (start < 0 || end < start || end > [[self textStorage] length]) {
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

- (UITextRange*) markedTextRange
{
#warning Implement -markedTextRange
    UIKIT_STUB_W_RETURN(@"-markedTextRange");
}

- (void) setMarkedText:(NSString*)markedText selectedRange:(NSRange)selectedRange
{
#warning Implement -setMarkedText:selectedRange:
    UIKIT_STUB(@"-setMarkedText:selectedRange:");
}

- (void) unmarkText
{
#warning Implement -unmarkText
    UIKIT_STUB(@"-unmarkText");
}

- (UITextRange*) textRangeFromPosition:(_UITextViewPosition*)fromPosition toPosition:(_UITextViewPosition*)toPosition
{
    NSAssert([fromPosition isKindOfClass:[_UITextViewPosition class]], @"???");
    NSAssert([toPosition isKindOfClass:[_UITextViewPosition class]], @"???");
    return [[_UITextViewRange alloc] initWithStart:fromPosition end:toPosition];
}

- (UITextPosition*) positionFromPosition:(_UITextViewPosition*)position offset:(NSInteger)offset
{
    NSAssert(!position || [position isKindOfClass:[_UITextViewPosition class]], @"???");
    if (!position) {
        return nil;
    }
    NSInteger newOffset = [position offset] + offset;
    if (newOffset < 0 || newOffset > [[self textStorage] length]) {
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

- (UITextPosition*) beginningOfDocument
{
    return [_UITextViewPosition positionWithOffset:0];
}

- (UITextPosition*) endOfDocument
{
    return [_UITextViewPosition positionWithOffset:[[self textStorage] length]];
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
#warning Implement -positionWithinRange:farthestInDirection:
    UIKIT_STUB_W_RETURN(@"-positionWithinRange:farthestInDirection:");
}

- (UITextRange*) characterRangeByExtendingPosition:(_UITextViewPosition*)position inDirection:(UITextLayoutDirection)direction
{
    NSAssert(!position || [position isKindOfClass:[_UITextViewPosition class]], @"???");
#warning Implement -characterRangeByExtendingPosition:inDirection:
    UIKIT_STUB_W_RETURN(@"-characterRangeByExtendingPosition:inDirection:");
}

- (UITextWritingDirection) baseWritingDirectionForPosition:(_UITextViewPosition*)position inDirection:(UITextStorageDirection)direction
{
    NSAssert(!position || [position isKindOfClass:[_UITextViewPosition class]], @"???");
#warning Implement -baseWritingDirectionForPosition:inDirection:
    UIKIT_STUB(@"-baseWritingDirectionForPosition:inDirection:");
    return UITextWritingDirectionNatural;
}

- (void) setBaseWritingDirection:(UITextWritingDirection)writingDirection forRange:(UITextRange*)range
{
    NSAssert(!range || [range isKindOfClass:[_UITextViewRange class]], @"???");
#warning Implement -setBaseWritingDirection:forRange:
    UIKIT_STUB(@"-setBaseWritingDirection:forRange:");
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
    NSAssert(!range || [range isKindOfClass:[_UITextViewRange class]], @"???");
#warning Implement -selectionRectsForRange:
    UIKIT_STUB_W_RETURN(@"-selectionRectsForRange:");
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
    NSTextContainer* textContainer = [self textContainer];
    NSLayoutManager* layoutManager = [textContainer layoutManager];
    
    NSRange actualGlyphRange;
    NSUInteger glyphIndex = [layoutManager glyphIndexForPoint:point inTextContainer:textContainer];
    NSRange range = [layoutManager characterRangeForGlyphRange:(NSRange){ glyphIndex, 1 } actualGlyphRange:&actualGlyphRange];
    if (!range.length) {
        return nil;
    }

    return [self textRangeFromPosition:[_UITextViewPosition positionWithOffset:range.location] toPosition:[_UITextViewPosition positionWithOffset:range.location + range.length]];
}


#pragma mark Private Methods

- (NSUInteger) _characterIndexAtPoint:(CGPoint)point
{
    NSTextContainer* textContainer = [self textContainer];
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

- (BOOL) _beginEditingIfNecessary
{
    if (![self isEditable]) {
        return NO;
    }
    if (!_flags.didBeginEditing) {
        if (_delegateHas.shouldBeginEditing && ![[self delegate] textViewShouldBeginEditing:self]) {
            return NO;
        }
        if (_delegateHas.didBeginEditing) {
            [[self delegate] textViewDidBeginEditing:self];
        }
        _flags.didBeginEditing = YES;
        [[NSNotificationCenter defaultCenter] postNotificationName:UITextViewTextDidBeginEditingNotification object:self];
    }
    return YES;
}

- (BOOL) _endEditingIfNecessary
{
    if (_flags.didBeginEditing) {
        if (_delegateHas.shouldEndEditing && ![[self delegate] textViewShouldEndEditing:self]) {
            return NO;
        }
        if (_delegateHas.didEndEditing) {
            [[self delegate] textViewDidEndEditing:self];
        }
        _flags.didBeginEditing = NO;
        [[NSNotificationCenter defaultCenter] postNotificationName:UITextViewTextDidEndEditingNotification object:self];
    }
    return YES;
}

- (BOOL) _canChangeTextInRange:(NSRange)range replacementText:(NSString*)string
{
    if (_delegateHas.shouldChangeText) {
        return [[self delegate] textView:self shouldChangeTextInRange:range replacementText:string];
    } else {
        return YES;
    }
}

- (void) _didChangeText
{
    [self setNeedsLayout];
    if (_delegateHas.didChange) {
        [[self delegate] textViewDidChange:self];
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:UITextViewTextDidChangeNotification object:self];
}

- (void) _replaceCharactersInRange:(NSRange)range withString:(NSString*)string
{
    NSTextStorage* textStorage = [self textStorage];
    [textStorage replaceCharactersInRange:range withString:string];
    [textStorage setAttributes:[self _stringAttributes] range:(NSRange){ range.location, [string length] }];
    [self setSelectedRange:(NSRange){ range.location + [string length], 0 }];
    [_textContainerView setNeedsDisplay];
}

- (void) _setAndScrollToRange:(NSRange)range upstream:(BOOL)upstream
{
    [self setSelectedRange:range];
    
    if (upstream) {
        [self scrollRangeToVisible:(NSRange){ range.location, 0 }];
    } else {
        [self scrollRangeToVisible:(NSRange){ NSMaxRange(range), 0 }];
    }
}

- (void) _setAndScrollToRange:(NSRange)range
{
    [self _setAndScrollToRange:range upstream:YES];
}

- (void) _setSelectedRange:(NSRange)selectedRange affinity:(UITextStorageDirection)affinity stillSelecting:(BOOL)stillSelecting
{
    if (_selectedRange.location == selectedRange.location && _selectedRange.length == selectedRange.length) {
        return;
    }
    if (!stillSelecting && !selectedRange.length) {
        _selectionOrigin = selectedRange.location;
    }

    NSLayoutManager* layoutManager = [self layoutManager];
    if (_selectedRange.length) {
        [layoutManager removeTemporaryAttribute:NSBackgroundColorAttributeName forCharacterRange:_selectedRange];
    }
    if (selectedRange.length) {
        [layoutManager addTemporaryAttribute:NSBackgroundColorAttributeName value:[NSColor selectedTextBackgroundColor] forCharacterRange:selectedRange];
    }
    _selectedRange = selectedRange;
    _selectionAffinity = affinity;
    _selectionGranularity = NSSelectByCharacter;

    _textContainerView.selectedRange = selectedRange;
    
    if (_delegateHas.didChangeSelection) {
        [self.delegate textViewDidChangeSelection:self];
    }
}

- (NSDictionary*) _stringAttributes
{
    NSAssert(nil != _font, @"???");
    NSMutableParagraphStyle* paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    [paragraphStyle setTighteningFactorForTruncation:0.0f];
    [paragraphStyle setAlignment:(NSTextAlignment)_textAlignment];
    
    return @{
        UITextAttributeFont: _font,
        UITextAttributeTextColor: _textColor,
        NSKernAttributeName: @(0.0f),
        NSLigatureAttributeName: @(0.0f),
        NSParagraphStyleAttributeName: paragraphStyle,
    };
}

- (NSString*) description
{
    NSString *textAlignment = @"";
    switch (self.textAlignment) {
        case UITextAlignmentLeft:
            textAlignment = @"Left";
            break;
        case UITextAlignmentCenter:
            textAlignment = @"Center";
            break;
        case UITextAlignmentRight:
            textAlignment = @"Right";
            break;
    }
    return [NSString stringWithFormat:@"<%@: %p; textAlignment = %@; selectedRange = %@; editable = %@; textColor = %@; font = %@; delegate = %@>", [self className], self, textAlignment, NSStringFromRange(self.selectedRange), (self.editable ? @"YES" : @"NO"), self.textColor, self.font, self.delegate];
}

- (id) mouseCursorForEvent:(UIEvent*)event
{
    return self.editable? [NSCursor IBeamCursor] : nil;
}


#pragma mark Cursor Calculations

- (void) _modifySelectionWith:(NSInteger(^)(NSInteger))calculation
{
    NSRange range = [self selectedRange];
    NSInteger start = range.location;
    NSInteger end = NSMaxRange(range);
    BOOL upstream = (end <= _selectionOrigin);
    NSInteger index = calculation(upstream ? start : end);
    if (index > _selectionOrigin) {
        range.location = _selectionOrigin;
        range.length = index - _selectionOrigin;
    } else {
        range.location = index;
        range.length = _selectionOrigin - index;
    }
    [self _setAndScrollToRange:range upstream:upstream];
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
    NSString* text = [self text];
    NSRange range = NSMakeRange(0, index);
    NSInteger __block newIndex;
    NSInteger __block counter = 0;
    [text enumerateSubstringsInRange:range options:(NSStringEnumerationByWords | NSStringEnumerationReverse) usingBlock:^(
        NSString *substring,
        NSRange substringRange,
        NSRange enclosingRange,
        BOOL *stop){
        newIndex = substringRange.location;
            counter++;
            *stop = YES;
        }
    ];
    return newIndex < 0 ? 0 : newIndex;
}

- (NSInteger) _indexWhenMovingWordRightFromIndex:(NSInteger)index
{
    NSString* text = [self text];
    NSInteger maxIndex = [text length];
    NSRange range = NSMakeRange(index, maxIndex - index);
    NSInteger __block newIndex;
    [text enumerateSubstringsInRange:range options:NSStringEnumerationByWords usingBlock:^(
        NSString *substring,
        NSRange substringRange,
        NSRange enclosingRange,
        BOOL *stop){
            newIndex = substringRange.location + substring.length;
            *stop = YES;
        }
    ];
    return MIN(newIndex, maxIndex);
}

- (NSInteger) _indexWhenMovingUpFromIndex:(NSInteger)index by:(NSInteger)numberOfLines
{
    if (numberOfLines <= 0) {
        return index;
    }
    
    NSTextContainer* textContainer = [self textContainer];
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

    NSTextContainer* textContainer = [self textContainer];
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
    NSInteger textLength = [[self textStorage] length];
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
    NSInteger textLength = [[self textStorage] length];
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


- (BOOL) _isLocationAtBeginningOfParagraph
{ // needs to know what to do if downstream.
    NSRange range = [self selectedRange];
    NSInteger start = range.location;
    NSInteger end = NSMaxRange(range);
    BOOL upstream = (end <= _selectionOrigin);
    NSInteger index = upstream ? start : end;
    NSString* string = [self text];
    return [string lineRangeForRange:(NSRange){ index, 0 }].location == index;
}

- (BOOL) _isLocationAtEndOfParagraph
{ //Needs upstream distinction
    NSString* string = [self text];
    NSUInteger index = NSMaxRange([self selectedRange]);
    return NSMaxRange([string paragraphRangeForRange:(NSRange){ index, 0 }]) == index + 1;
}

- (NSInteger) _indexWhenMovingToBeginningOfParagraphFromIndex:(NSInteger)index
{
    NSString* string = [self text];
    return [string paragraphRangeForRange:(NSRange){ index, 0 }].location;
}

- (NSInteger) _indexWhenMovingToEndOfParagraphFromIndex:(NSInteger)index
{
    NSString* string = [self text];
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
    return [[self textStorage] length];
}

@end


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
    _selectedRange = selectedRange;
    [self _updateInsertionPointPosition];
    [self setNeedsDisplay];
}

- (void) setShouldShowInsertionPoint:(BOOL)shouldShowInsertionPoint
{
    if (_shouldShowInsertionPoint != shouldShowInsertionPoint) {
        _shouldShowInsertionPoint = shouldShowInsertionPoint;
        [self _updateInsertionPointPosition];
    }
}

- (void) _updateInsertionPointPosition
{
    CGRect rect = [self _viewRectForCharacterRange:[self selectedRange]];
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


@implementation _UITextViewPosition

static NSUInteger hashForTextPosition;

+ (void) initialize
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        hashForTextPosition = [[_UITextViewPosition class] hash];
    });
}

+ (instancetype) positionWithOffset:(NSInteger)offset
{
    return [[_UITextViewPosition alloc] initWithOffset:offset];
}

- (instancetype) initWithOffset:(NSInteger)offset
{
    if (nil != (self = [super init])) {
        _offset = offset;
    }
    return self;
}

- (BOOL) isEqual:(id)object
{
    return self == object || ([object isKindOfClass:[_UITextViewPosition class]] && [((_UITextViewPosition*)object) offset] == [self offset]);
}

- (NSUInteger) hash
{
    return (37 * _offset) ^ hashForTextPosition;
}

@end


@implementation _UITextViewRange 
@synthesize start = _start;
@synthesize end = _end;

- (instancetype) initWithStart:(_UITextViewPosition*)start end:(_UITextViewPosition*)end
{
    if (nil != (self = [super init])) {
        _start = start;
        _end = end;
    }
    return self;
}

- (BOOL) isEmpty
{
    return _start == _end;
}

@end

