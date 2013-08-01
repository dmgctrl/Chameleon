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
#import "UIResponder+AppKit.h"
#import "_UITextStorage.h"
#import "_UITextInputController.h"
#import "_UITextInputPlus.h"
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


@interface UITextView () <_UITextInputControllerDelegate, _UITextInputPlus>
@end


@implementation UITextView {
    NSTextStorage* _textStorage;
    NSTextContainer* _textContainer;
    NSLayoutManager* _layoutManager;

    _UITextContainerView* _textContainerView;

    _UITextInteractionAssistant* _interactionAssistant;
    _UITextInputController* _inputController;
    
    struct {
        bool shouldBeginEditing : 1;
        bool didBeginEditing : 1;
        bool shouldEndEditing : 1;
        bool didEndEditing : 1;
        bool shouldChangeText : 1;
        bool didChange : 1;
        bool didChangeSelection : 1;
        bool doCommandBySelector : 1;
    } _delegateHas;
    
    struct {
        bool selectionWillChange : 1;
        bool selectionDidChange : 1;
        bool textWillChange : 1;
        bool textDidChange : 1;
    } _inputDelegateHas;

    struct {
        bool editing : 1;
        bool scrollToSelectionAfterLayout : 1;
    } _flags;
    
    BOOL _stillSelecting;
    NSUInteger _selectionOrigin;
    NSSelectionGranularity _selectionGranularity;
    
    id _ob1;
    id _ob2;
}
@dynamic delegate;
@synthesize markedTextStyle = _markedTextStyle;
@synthesize selectionAffinity = _selectionAffinity;
@synthesize inputDelegate = _inputDelegate;
@synthesize tokenizer;

static void _commonInitForUITextView(UITextView* self, NSTextContainer* textContainer)
{
    self.textColor = [UIColor blackColor];
    self.font = [UIFont systemFontOfSize:17];
    self.dataDetectorTypes = UIDataDetectorTypeNone;
    self.editable = YES;
    self.contentMode = UIViewContentModeScaleToFill;
    self.clipsToBounds = YES;

    self->_textContainer = textContainer ?: [[NSTextContainer alloc] initWithContainerSize:(CGSize){ [self bounds].size.width, CGFLOAT_MAX }];
    [self->_textContainer setWidthTracksTextView:YES];
    self->_textStorage = [[_UITextStorage alloc] init];
    self->_layoutManager = [[NSLayoutManager alloc] init];
    [self->_layoutManager addTextContainer:self->_textContainer];
    [self->_textStorage addLayoutManager:self->_layoutManager];
    
    self->_inputController = [[_UITextInputController alloc] initWithLayoutManager:self->_layoutManager];
    [self->_inputController setDelegate:self];
    
    self->_textContainerView = [[_UITextContainerView alloc] initWithFrame:CGRectZero];
    [self->_textContainerView setTextContainer:[self textContainer]];
    [self->_textContainerView setBackgroundColor:[self backgroundColor]];
    [self addSubview:self->_textContainerView];
}

- (instancetype) initWithFrame:(CGRect)frame textContainer:(NSTextContainer*)textContainer
{
    if (nil != (self = [super initWithFrame:frame])) {
        _commonInitForUITextView(self, textContainer);
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
        _commonInitForUITextView(self, nil);
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

- (void) setInputDelegate:(id<UITextInputDelegate>)inputDelegate
{
    if (!inputDelegate || ([self isFirstResponder] && (_inputDelegate != inputDelegate))) {
        _inputDelegate = inputDelegate;
        _inputDelegateHas.selectionDidChange = [inputDelegate respondsToSelector:@selector(selectionDidChange:)];
        _inputDelegateHas.selectionWillChange = [inputDelegate respondsToSelector:@selector(selectionWillChange:)];
        _inputDelegateHas.textDidChange = [inputDelegate respondsToSelector:@selector(textDidChange:)];
        _inputDelegateHas.textWillChange = [inputDelegate respondsToSelector:@selector(textWillChange:)];
    }
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

- (NSRange) selectedRange
{
    return [_inputController selectedRange];
}

- (void) setSelectedRange:(NSRange)range
{
    [_inputController setSelectedRange:range];
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

- (NSTextStorage*) textStorage
{
    return [[[self textContainer] layoutManager] textStorage];
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
    
    if (_flags.scrollToSelectionAfterLayout) {
        _flags.scrollToSelectionAfterLayout = NO;
        [self scrollRangeToVisible:[self selectedRange]];
    }
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
        [_inputController _indexWhenMovingToBeginningOfDocumentFromIndex:[self selectedRange].location],
        0
    }];
    [self setSelectedRange:range];
}

- (void) scrollToEndOfDocument:(id)sender
{
    NSRange range = [self selectedRange];
    [self _setAndScrollToRange:(NSRange){
        [_inputController _indexWhenMovingToEndOfDocumentFromIndex:[self selectedRange].location],
        0
    }];
    [self setSelectedRange:range];
}


#pragma mark UIView

- (void) setBackgroundColor:(UIColor*)backgroundColor
{
    [super setBackgroundColor:backgroundColor];
    [_textContainerView setBackgroundColor:backgroundColor];
}

- (void) willMoveToWindow:(UIWindow*)window
{
    [super willMoveToWindow:window];
    if (window) {
        _interactionAssistant = [[_UITextInteractionAssistant alloc] initWithView:self];
        [_interactionAssistant addOneFingerTapRecognizerToView:self];
        [_interactionAssistant addOneFingerDoubleTapRecognizerToView:self];
    } else {
        [_interactionAssistant removeGestureRecognizersFromView:self];
        _interactionAssistant = nil;
    }
}

#pragma mark UIResponder

- (BOOL) acceptsFirstMouse
{
    return [self canBecomeFirstResponder];
}

- (void) windowDidBecomeKey
{
    [super windowDidBecomeKey];
    [_textContainerView setShouldShowInsertionPoint:[self isFirstResponder]];
}

- (void) windowDidResignKey
{
    [super windowDidResignKey];
    [_textContainerView setShouldShowInsertionPoint:NO];
}

- (BOOL) canBecomeFirstResponder
{
    return (self.window != nil) && [self isEditable] && (!_delegateHas.shouldBeginEditing || [[self delegate] textViewShouldBeginEditing:self]);
}

- (BOOL) becomeFirstResponder
{
    if ([super becomeFirstResponder]) {
        _flags.editing = YES;

        if (_delegateHas.didBeginEditing) {
            [[self delegate] textViewDidBeginEditing:self];
        }
        
        [_textContainerView setShouldShowInsertionPoint:YES];

        [[NSNotificationCenter defaultCenter] postNotificationName:UITextViewTextDidBeginEditingNotification object:self];
        return YES;
    }
    return NO;
}

- (BOOL) canResignFirstResponder
{
    return (!_delegateHas.shouldEndEditing || [[self delegate] textViewShouldEndEditing:self]);
}

- (BOOL) resignFirstResponder
{
    if ([super resignFirstResponder]) {
        [_textContainerView setShouldShowInsertionPoint:NO];
        
        if (_delegateHas.didEndEditing) {
            [[self delegate] textViewDidEndEditing:self];
        }
        
        [[NSNotificationCenter defaultCenter] postNotificationName:UITextViewTextDidEndEditingNotification object:self];
        
        [self setInputDelegate:nil];
        
        _flags.editing = NO;
        
        return YES;
    }
    return NO;
}

- (void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch* touch = [[event allTouches] anyObject];
    [self _setAndScrollToRange:(NSRange){
        [self _characterIndexAtPoint:[touch locationInView:_textContainerView]],
        0
    }];
    _stillSelecting = YES;
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
    [self setSelectedRange:range];
    [super touchesMoved:touches withEvent:event];
}

- (void) touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesEnded:touches withEvent:event];
    _stillSelecting = NO;
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
    UITextRange* range = [self selectedTextRange];
    if (!range || [range isEmpty]) {
        UITextPosition* fromPosition = [range start];
        UITextPosition* toPosition = [_inputController positionFromPosition:[range start] offset:1];
        if (!toPosition) {
            return;
        }
        range = [_inputController textRangeFromPosition:fromPosition toPosition:toPosition];
    }
    if (![_inputController shouldChangeTextInRange:range replacementText:@""]) {
        return;
    }
    [_inputController replaceRange:range withText:@""];
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
    UITextPosition* position = [[self selectedTextRange] start];
    UITextPosition* newPosition = [self positionFromPosition:position inDirection:UITextLayoutDirectionLeft offset:1];
    [self setSelectedTextRange:[self textRangeFromPosition:newPosition toPosition:newPosition]];
}

- (void) moveLeftAndModifySelection:(id)sender
{
    [self _modifySelectionWith:^NSInteger(NSInteger index) {
        return [_inputController _indexWhenMovingLeftFromIndex:index];
    }];
}

- (void) moveWordLeft:(id)sender
{
    [self _setAndScrollToRange:(NSRange){
        [_inputController _indexWhenMovingWordLeftFromIndex:[self selectedRange].location],
        0
    }];
}

- (void) moveWordLeftAndModifySelection:(id)sender
{
    [self _modifySelectionWith:^NSInteger(NSInteger index) {
        return [_inputController _indexWhenMovingWordLeftFromIndex:index];
    }];
}

- (void) moveRight:(id)sender
{
    UITextPosition* position = [[self selectedTextRange] start];
    UITextPosition* newPosition = [self positionFromPosition:position inDirection:UITextLayoutDirectionRight offset:1];
    [self setSelectedTextRange:[self textRangeFromPosition:newPosition toPosition:newPosition]];
}

- (void) moveRightAndModifySelection:(id)sender
{
    [self _modifySelectionWith:^NSInteger(NSInteger index) {
        return [_inputController _indexWhenMovingRightFromIndex:index];
    }];
}

- (void) moveWordRight:(id)sender
{
    [self _setAndScrollToRange:(NSRange){
        [_inputController _indexWhenMovingWordRightFromIndex:[self selectedRange].location],
        0
    }];
}

- (void) moveWordRightAndModifySelection:(id)sender
{
    [self _modifySelectionWith:^NSInteger(NSInteger index) {
        return [_inputController _indexWhenMovingWordRightFromIndex:index];
    }];
}

- (void) moveUp:(id)sender
{
    UITextPosition* position = [[self selectedTextRange] start];
    UITextPosition* newPosition = [self positionFromPosition:position inDirection:UITextLayoutDirectionUp offset:1];
    [self setSelectedTextRange:[self textRangeFromPosition:newPosition toPosition:newPosition]];
}

- (void) moveUpAndModifySelection:(id)sender
{
    [self _modifySelectionWith:^NSInteger(NSInteger index) {
        return [_inputController _indexWhenMovingUpFromIndex:index by:1];
    }];
}

- (void) moveDown:(id)sender
{
    UITextPosition* position = [[self selectedTextRange] start];
    UITextPosition* newPosition = [self positionFromPosition:position inDirection:UITextLayoutDirectionDown offset:1];
    [self setSelectedTextRange:[self textRangeFromPosition:newPosition toPosition:newPosition]];
}

- (void) moveDownAndModifySelection:(id)sender
{
    [self _modifySelectionWith:^NSInteger(NSInteger index) {
        return [_inputController _indexWhenMovingDownFromIndex:index by:index];
    }];
}

- (void) moveToBeginningOfLine:(id)sender
{
    [self _setAndScrollToRange:(NSRange){
        [_inputController _indexWhenMovingToBeginningOfLineFromIndex:[self selectedRange].location],
        0
    }];
}

- (void) moveToBeginningOfLineAndModifySelection:(id)sender
{
    [self _modifySelectionWith:^NSInteger(NSInteger index) {
        return [_inputController _indexWhenMovingToBeginningOfLineFromIndex:index];
    }];
}

- (void) moveToEndOfLine:(id)sender
{
    [self _setAndScrollToRange:(NSRange){
        [_inputController _indexWhenMovingToEndOfLineFromIndex:NSMaxRange([self selectedRange])],
        0
    }];
}

- (void) moveToEndOfLineAndModifySelection:(id)sender
{
    [self _modifySelectionWith:^NSInteger(NSInteger index) {
        return [_inputController _indexWhenMovingToEndOfLineFromIndex:index];
    }];    
}

- (void) moveToBeginningOfParagraph:(id)sender
{
    [self _setAndScrollToRange:(NSRange){
        [_inputController _indexWhenMovingToBeginningOfParagraphFromIndex:[self selectedRange].location],
        0
    }];
}

- (void) moveParagraphBackwardAndModifySelection:(id)sender
{
    [self _modifySelectionWith:^NSInteger(NSInteger index) {
        return [_inputController _indexWhenMovingToBeginningOfParagraphFromIndex:index];
    }];
}

- (void) moveToBeginningOfParagraphOrMoveUp:(id)sender
{
    if ([_inputController _isLocationAtBeginningOfParagraph]) {
        [self moveUp:self];
    } else {
        [self moveToBeginningOfParagraph:self];
    }
}

- (void) moveParagraphBackwardOrMoveUpAndModifySelection:(id)sender
{
    if ([_inputController _isLocationAtBeginningOfParagraph]) {
        [self moveUpAndModifySelection:self];
    } else {
        [self moveParagraphBackwardAndModifySelection:self];
    }
}

- (void) moveToEndOfParagraph:(id)sender
{
    [self _setAndScrollToRange:(NSRange){
        [_inputController _indexWhenMovingToEndOfParagraphFromIndex:[self selectedRange].location],
        0
    }];
}

- (void) moveToEndOfParagraphOrMoveDown:(id)sender
{
    if ([_inputController _isLocationAtEndOfParagraph]) {
        [self moveDown:self];
    } else {
        [self moveToEndOfParagraph:self];
    }
}

- (void) moveParagraphForwardAndModifySelection:(id)sender
{
    [self _modifySelectionWith:^NSInteger(NSInteger index) {
        return [_inputController _indexWhenMovingToEndOfParagraphFromIndex:index];
    }];
}

- (void) moveParagraphForwardOrMoveDownAndModifySelection:(id)sender
{
    if ([_inputController _isLocationAtEndOfParagraph]) {
        [self moveDownAndModifySelection:self];
    } else {
        [self moveParagraphForwardAndModifySelection:self];
    }
}

- (void) moveToBeginningOfDocument:(id)sender
{
    [self _setAndScrollToRange:(NSRange){
        [_inputController _indexWhenMovingToBeginningOfDocumentFromIndex:[self selectedRange].location],
        0
    }];
}

- (void) moveToBeginningOfDocumentAndModifySelection:(id)sender
{
    [self _modifySelectionWith:^NSInteger(NSInteger index) {
        return [_inputController _indexWhenMovingToBeginningOfDocumentFromIndex:index];
    }];
}

- (void) moveToEndOfDocument:(id)sender
{
    [self _setAndScrollToRange:(NSRange){
        [_inputController _indexWhenMovingToEndOfDocumentFromIndex:[self selectedRange].location],
        0
    }];
}

- (void) moveToEndOfDocumentAndModifySelection:(id)sender
{
    [self _modifySelectionWith:^NSInteger(NSInteger index) {
        return [_inputController _indexWhenMovingToEndOfDocumentFromIndex:index];
    }];
}

- (void) cut:(id)sender
{
    UITextRange* range = [self selectedTextRange];
    if (![range isEmpty]) {
        [[UIPasteboard generalPasteboard] setString:[_inputController textInRange:range]];
        [_inputController replaceRange:range withText:@""];
    }
}

- (void) copy:(id)sender
{
    UITextRange* range = [self selectedTextRange];
    if (![range isEmpty]) {
        [[UIPasteboard generalPasteboard] setString:[_inputController textInRange:range]];
    }
}

- (void) paste:(id)sender
{
    [_inputController replaceRange:[_inputController selectedTextRange] withText:[[UIPasteboard generalPasteboard] string]];
}

- (void) insertNewline:(id)sender
{
    [self insertText:@"\n"];
}


#pragma mark UIKeyInput

- (BOOL) hasText
{
    return [_inputController hasText];
}

- (void) insertText:(NSString*)text
{
    _flags.scrollToSelectionAfterLayout = YES;
    [_inputController insertText:text];
}

- (void) deleteBackward
{
    _flags.scrollToSelectionAfterLayout = YES;
    [_inputController deleteBackward];
}


#pragma mark UITextInput

- (NSString*) textInRange:(UITextRange*)range
{
    return [_inputController textInRange:range];
}

- (void) replaceRange:(UITextRange*)range withText:(NSString*)text
{
    [_inputController replaceRange:range withText:text];
}

- (BOOL) shouldChangeTextInRange:(UITextRange*)range replacementText:(NSString*)text
{
    return [_inputController shouldChangeTextInRange:range replacementText:text];
}

- (UITextRange*) selectedTextRange
{
    return [_inputController selectedTextRange];
}

- (void) setSelectedTextRange:(UITextRange*)selectedTextRange
{
    [_inputController setSelectedTextRange:selectedTextRange];
}

- (UITextRange*) markedTextRange
{
    return [_inputController markedTextRange];
}

- (void) setMarkedText:(NSString*)markedText selectedRange:(NSRange)selectedRange
{
    [_inputController setMarkedText:markedText selectedRange:selectedRange];
}

- (void) unmarkText
{
    [_inputController unmarkText];
}

- (UITextRange*) textRangeFromPosition:(UITextPosition*)fromPosition toPosition:(UITextPosition*)toPosition
{
    return [_inputController textRangeFromPosition:fromPosition toPosition:toPosition];
}

- (UITextPosition*) positionFromPosition:(UITextPosition*)position offset:(NSInteger)offset
{
    return [_inputController positionFromPosition:position offset:offset];
}

- (UITextPosition*) positionFromPosition:(UITextPosition*)position inDirection:(UITextLayoutDirection)direction offset:(NSInteger)offset
{
    return [_inputController positionFromPosition:position inDirection:direction offset:offset];
}

- (UITextPosition*) beginningOfDocument
{
    return [_inputController beginningOfDocument];
}

- (UITextPosition*) endOfDocument
{
    return [_inputController endOfDocument];
}

- (NSComparisonResult) comparePosition:(UITextPosition*)position toPosition:(UITextPosition*)other
{
    return [_inputController comparePosition:position toPosition:other];
}

- (NSInteger) offsetFromPosition:(UITextPosition*)fromPosition toPosition:(UITextPosition*)toPosition
{
    return [_inputController offsetFromPosition:fromPosition toPosition:toPosition];
}

- (UITextPosition*) positionWithinRange:(UITextRange*)range farthestInDirection:(UITextLayoutDirection)direction
{
    return [_inputController positionWithinRange:range farthestInDirection:direction];
}

- (UITextRange*) characterRangeByExtendingPosition:(UITextPosition*)position inDirection:(UITextLayoutDirection)direction
{
    return [_inputController characterRangeByExtendingPosition:position inDirection:direction];
}

- (UITextWritingDirection) baseWritingDirectionForPosition:(UITextPosition*)position inDirection:(UITextStorageDirection)direction
{
    return [_inputController baseWritingDirectionForPosition:position inDirection:direction];
}

- (void) setBaseWritingDirection:(UITextWritingDirection)writingDirection forRange:(UITextRange*)range
{
    [_inputController setBaseWritingDirection:writingDirection forRange:range];
}

- (CGRect) firstRectForRange:(UITextRange*)range
{
    return [_inputController firstRectForRange:range];
}

- (CGRect) caretRectForPosition:(UITextPosition*)position
{
    return [_inputController caretRectForPosition:position];
}

- (NSArray*) selectionRectsForRange:(UITextRange*)range
{
    return [_inputController selectionRectsForRange:range];
}

- (UITextPosition*) closestPositionToPoint:(CGPoint)point
{
    return [_inputController closestPositionToPoint:point];
}

- (UITextPosition*) closestPositionToPoint:(CGPoint)point withinRange:(UITextRange*)range
{
    return [_inputController closestPositionToPoint:point withinRange:range];
}

- (UITextRange*) characterRangeAtPoint:(CGPoint)point
{
    return [_inputController characterRangeAtPoint:point];
}


#pragma mark _UITextInputPlus

- (void) beginSelectionChange
{
    if (_inputDelegateHas.selectionWillChange) {
        [[self inputDelegate] selectionWillChange:self];
    }
}

- (void) endSelectionChange
{
    if (_inputDelegateHas.selectionDidChange) {
        [[self inputDelegate] selectionDidChange:self];
    }
}

- (UITextRange*) textRangeOfWordContainingPosition:(UITextPosition*)position
{
    return [_inputController textRangeOfWordContainingPosition:position];
}


#pragma mark _UITextInputController

- (NSRange) textInput:(_UITextInputController*)controller willChangeSelectionFromCharacterRange:(NSRange)fromRange toCharacterRange:(NSRange)toRange
{
    [self beginSelectionChange];
    if (!_stillSelecting && !toRange.length) {
        _selectionOrigin = toRange.location;
    }
    NSLayoutManager* layoutManager = [self layoutManager];
    if (fromRange.length) {
        [layoutManager removeTemporaryAttribute:NSBackgroundColorAttributeName forCharacterRange:fromRange];
    }
    return toRange;
}

- (void) textInputDidChangeSelection:(_UITextInputController*)controller
{
    NSLayoutManager* layoutManager = [self layoutManager];
    NSRange selectedRange = [controller selectedRange];
    _textContainerView.selectedRange = selectedRange;
    if (selectedRange.length) {
        [layoutManager addTemporaryAttribute:NSBackgroundColorAttributeName value:[NSColor selectedTextBackgroundColor] forCharacterRange:selectedRange];
    }
    if (_delegateHas.didChangeSelection) {
        [[self delegate] textViewDidChangeSelection:self];
    }
    [self endSelectionChange];
}

- (void) textInputDidChange:(_UITextInputController*)controller
{
    [self _didChangeText];
}

- (void) textInput:(_UITextInputController*)controller prepareAttributedTextForInsertion:(id)text
{
    [text setAttributes:[self _stringAttributes] range:(NSRange){ 0, [text length] }];
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

- (void) _didChangeText
{
    [self setNeedsLayout];
    if (_delegateHas.didChange) {
        [[self delegate] textViewDidChange:self];
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:UITextViewTextDidChangeNotification object:self];
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
    if (_selectedRange.length != selectedRange.length) {
        [self setNeedsDisplay];
    }
    _selectedRange = selectedRange;
    [self _updateInsertionPointPosition];
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

