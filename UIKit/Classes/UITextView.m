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
#import "_UITextInputModel.h"
#import "_UITextInputModelAdapter.h"
#import "_UITextInputPlus.h"
#import "_UITextInteractionController.h"
#import "_UITextContainerView.h"
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

    _UITextInteractionController* _interactionController;
    _UITextInputModel* _inputModel;
    _UITextInputModelAdapter* _inputModelAdapter;
    
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
    
    self->_inputModel = [[_UITextInputModel alloc] initWithLayoutManager:self->_layoutManager];
    [self->_inputModel setDelegate:self];
    
    self->_inputModelAdapter = [[_UITextInputModelAdapter alloc] initWithInputModel:self->_inputModel];
    
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
    return [_inputModel selectedRange];
}

- (void) setSelectedRange:(NSRange)range
{
    [_inputModel setSelectedRange:range];
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
        [_inputModel _indexWhenMovingToBeginningOfDocumentFromIndex:[self selectedRange].location],
        0
    }];
    [self setSelectedRange:range];
}

- (void) scrollToEndOfDocument:(id)sender
{
    NSRange range = [self selectedRange];
    [self _setAndScrollToRange:(NSRange){
        [_inputModel _indexWhenMovingToEndOfDocumentFromIndex:[self selectedRange].location],
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
        _interactionController = [[_UITextInteractionController alloc] initWithView:self inputModel:_inputModel];
        [_interactionController addOneFingerTapRecognizerToView:self];
        [_interactionController addOneFingerDoubleTapRecognizerToView:self];
    } else {
        [_interactionController removeGestureRecognizersFromView:self];
        _interactionController = nil;
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
    } else {
        [_interactionController doCommandBySelector:selector];
    }
}


#pragma mark UIResponderStandardEditActions

- (void) copy:(id)sender
{
    UITextRange* range = [self selectedTextRange];
    if (![range isEmpty]) {
        [[UIPasteboard generalPasteboard] setString:[self textInRange:range]];
    }
}

- (void) cut:(id)sender
{
    UITextRange* range = [self selectedTextRange];
    if (![range isEmpty]) {
        [[UIPasteboard generalPasteboard] setString:[self textInRange:range]];
        [_inputModel replaceRange:range withText:@""];
    }
}

- (void) paste:(id)sender
{
    [self replaceRange:[self selectedTextRange] withText:[[UIPasteboard generalPasteboard] string]];
}

- (void) selectAll:(id)sender
{
    [self setSelectedRange:NSMakeRange(0, [_inputModel _endOfDocument])];
}


#pragma mark UIKeyInput

- (BOOL) hasText
{
    return [_inputModelAdapter hasText];
}

- (void) insertText:(NSString*)text
{
    _flags.scrollToSelectionAfterLayout = YES;
    [_inputModelAdapter insertText:text];
}

- (void) deleteBackward
{
    _flags.scrollToSelectionAfterLayout = YES;
    [_inputModelAdapter deleteBackward];
}


#pragma mark UITextInput

- (NSString*) textInRange:(UITextRange*)range
{
    return [_inputModelAdapter textInRange:range];
}

- (void) replaceRange:(UITextRange*)range withText:(NSString*)text
{
    [_inputModelAdapter replaceRange:range withText:text];
}

- (BOOL) shouldChangeTextInRange:(UITextRange*)range replacementText:(NSString*)text
{
    return [_inputModelAdapter shouldChangeTextInRange:range replacementText:text];
}

- (UITextRange*) selectedTextRange
{
    return [_inputModelAdapter selectedTextRange];
}

- (void) setSelectedTextRange:(UITextRange*)selectedTextRange
{
    [_inputModelAdapter setSelectedTextRange:selectedTextRange];
}

- (UITextRange*) markedTextRange
{
    return [_inputModelAdapter markedTextRange];
}

- (void) setMarkedText:(NSString*)markedText selectedRange:(NSRange)selectedRange
{
    [_inputModelAdapter setMarkedText:markedText selectedRange:selectedRange];
}

- (void) unmarkText
{
    [_inputModelAdapter unmarkText];
}

- (UITextRange*) textRangeFromPosition:(UITextPosition*)fromPosition toPosition:(UITextPosition*)toPosition
{
    return [_inputModelAdapter textRangeFromPosition:fromPosition toPosition:toPosition];
}

- (UITextPosition*) positionFromPosition:(UITextPosition*)position offset:(NSInteger)offset
{
    return [_inputModelAdapter positionFromPosition:position offset:offset];
}

- (UITextPosition*) positionFromPosition:(UITextPosition*)position inDirection:(UITextLayoutDirection)direction offset:(NSInteger)offset
{
    return [_inputModelAdapter positionFromPosition:position inDirection:direction offset:offset];
}

- (UITextPosition*) beginningOfDocument
{
    return [_inputModelAdapter beginningOfDocument];
}

- (UITextPosition*) endOfDocument
{
    return [_inputModelAdapter endOfDocument];
}

- (NSComparisonResult) comparePosition:(UITextPosition*)position toPosition:(UITextPosition*)other
{
    return [_inputModelAdapter comparePosition:position toPosition:other];
}

- (NSInteger) offsetFromPosition:(UITextPosition*)fromPosition toPosition:(UITextPosition*)toPosition
{
    return [_inputModelAdapter offsetFromPosition:fromPosition toPosition:toPosition];
}

- (UITextPosition*) positionWithinRange:(UITextRange*)range farthestInDirection:(UITextLayoutDirection)direction
{
    return [_inputModelAdapter positionWithinRange:range farthestInDirection:direction];
}

- (UITextRange*) characterRangeByExtendingPosition:(UITextPosition*)position inDirection:(UITextLayoutDirection)direction
{
    return [_inputModelAdapter characterRangeByExtendingPosition:position inDirection:direction];
}

- (UITextWritingDirection) baseWritingDirectionForPosition:(UITextPosition*)position inDirection:(UITextStorageDirection)direction
{
    return [_inputModelAdapter baseWritingDirectionForPosition:position inDirection:direction];
}

- (void) setBaseWritingDirection:(UITextWritingDirection)writingDirection forRange:(UITextRange*)range
{
    [_inputModelAdapter setBaseWritingDirection:writingDirection forRange:range];
}

- (CGRect) firstRectForRange:(UITextRange*)range
{
    return [_inputModelAdapter firstRectForRange:range];
}

- (CGRect) caretRectForPosition:(UITextPosition*)position
{
    return [_inputModelAdapter caretRectForPosition:position];
}

- (NSArray*) selectionRectsForRange:(UITextRange*)range
{
    return [_inputModelAdapter selectionRectsForRange:range];
}

- (UITextPosition*) closestPositionToPoint:(CGPoint)point
{
    return [_inputModelAdapter closestPositionToPoint:point];
}

- (UITextPosition*) closestPositionToPoint:(CGPoint)point withinRange:(UITextRange*)range
{
    return [_inputModelAdapter closestPositionToPoint:point withinRange:range];
}

- (UITextRange*) characterRangeAtPoint:(CGPoint)point
{
    return [_inputModelAdapter characterRangeAtPoint:point];
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
    return [_inputModel textRangeOfWordContainingPosition:position];
}


#pragma mark _UITextInputController

- (NSRange) textInput:(_UITextInputModel*)controller willChangeSelectionFromCharacterRange:(NSRange)fromRange toCharacterRange:(NSRange)toRange
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

- (void) textInputDidChangeSelection:(_UITextInputModel*)controller
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

- (void) textInputDidChange:(_UITextInputModel*)controller
{
    [self _didChangeText];
}

- (void) textInput:(_UITextInputModel*)controller prepareAttributedTextForInsertion:(id)text
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
