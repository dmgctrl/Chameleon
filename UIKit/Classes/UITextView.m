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

#import "UITextView.h"
#import "UIColor.h"
#import "UIColor+AppKit.h"
#import "UIFont.h"
#import "UIFont+UIPrivate.h"
#import "UITextStorage.h"
#import "UIScrollView.h"
#import "UILabel.h"
#import "UIPasteboard.h"
#import "UIScreen.h"
#import "UIScreen+AppKit.h"
#import "UITouch.h"
#import "UIWindow.h"
#import "UIWindow+UIPrivate.h"
#import "UIKitView.h"
#import <QuartzCore/QuartzCore.h>
#import <AppKit/NSCursor.h>
#import <AppKit/NSColor.h>
#import <AppKit/NSTextContainer.h>
#import <AppKit/NSLayoutManager.h>
#import <AppKit/NSTextStorage.h>

#import "UIGraphics.h"
#import <AppKit/NSGraphicsContext.h>


NSString *const UITextViewTextDidBeginEditingNotification = @"UITextViewTextDidBeginEditingNotification";
NSString *const UITextViewTextDidChangeNotification = @"UITextViewTextDidChangeNotification";
NSString *const UITextViewTextDidEndEditingNotification = @"UITextViewTextDidEndEditingNotification";

static NSString* const kUIEditableKey = @"UIEditable";
static CGFloat const kMarginX = 4.0f;
static CGFloat const kMarginY = 9.0f;


@interface _UITextContainerView : UIView
@property (nonatomic) NSTextContainer* textContainer;
@property (nonatomic) NSRange selectedRange;
@property (nonatomic) BOOL shouldShowInsertionPoint;
- (NSUInteger) characterIndexAtPoint:(CGPoint)point;
@end


@protocol UITextViewDelegatePlus
- (BOOL) textView:(UITextView*)textView doCommandBySelector:(SEL)selector;
@end


@implementation UITextView {
    NSTextStorage* _textStorage;
    NSTextContainer* _textContainer;
    NSLayoutManager* _layoutManager;

    _UITextContainerView* _textContainerView;
    
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
    NSSelectionAffinity _selectionAffinity;
    NSSelectionGranularity _selectionGranularity;
}
@dynamic delegate;

static void _commonInitForUITextView(UITextView* self)
{
    self.textColor = [UIColor blackColor];
    self.font = [UIFont systemFontOfSize:17];
    self.dataDetectorTypes = UIDataDetectorTypeAll;
    self.editable = YES;
    self.contentMode = UIViewContentModeScaleToFill;
    self.clipsToBounds = YES;

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
    _font = font;
    NSTextStorage* textStorage = [self textStorage];
    [textStorage addAttribute:(id)kCTFontAttributeName value:(id)[font ctFontRef] range:(NSRange){ 0, [textStorage length] }];
    [_textContainerView setNeedsDisplay];
}

- (void) setFrame:(CGRect)frame
{
    [super setFrame:frame];
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
        _textStorage = [[UITextStorage alloc] init];
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
    [textContainer setContainerSize:(CGSize){
        bounds.size.width - (kMarginX * 2.0),
        CGFLOAT_MAX
    }];
    [layoutManager ensureLayoutForTextContainer:textContainer];
    CGSize contentSize = {
        bounds.size.width,
        [layoutManager usedRectForTextContainer:textContainer].size.height + (kMarginY * 2.0)
    };
    [self setContentSize:contentSize];
    [_textContainerView setFrame:(CGRect){
        .size = contentSize
    }];
}


#pragma mark Scrolling

- (void) scrollRangeToVisible:(NSRange)range
{
    NSLayoutManager* layoutManager = [self layoutManager];
    NSRange glyphRange = [layoutManager glyphRangeForCharacterRange:range actualCharacterRange:NULL];
    CGRect boundingRect = [layoutManager boundingRectForGlyphRange:glyphRange inTextContainer:[self textContainer]];
    [super scrollRectToVisible:boundingRect animated:NO];
}


#pragma mark Public Methods

- (BOOL) hasText
{
    return [[self textStorage] length] > 0;
}


#pragma mark UIResponder

- (void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self becomeFirstResponder];
    UITouch* touch = [[event allTouches] anyObject];
    [self _setAndScrollToRange:(NSRange){
        [_textContainerView characterIndexAtPoint:[self convertPoint:[touch locationInView:self] toView:_textContainerView]],
        0
    }];
    [super touchesBegan:touches withEvent:event];
}

- (void) touchesMoved:(NSSet*)touches withEvent:(UIEvent *)event
{
    UITouch* touch = [[event allTouches] anyObject];
    NSUInteger index = [_textContainerView characterIndexAtPoint:[self convertPoint:[touch locationInView:self] toView:_textContainerView]];
    NSRange range;
    if (_selectionOrigin > index) {
        range = (NSRange){ index, _selectionOrigin - index };
        [self scrollRangeToVisible:range];
    } else {
        range = (NSRange){ _selectionOrigin, index - _selectionOrigin };
        [self scrollRangeToVisible:(NSRange){ NSMaxRange(range), 0 }];
    }
    [self _setSelectedRange:range affinity:NSSelectByCharacter stillSelecting:YES];
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

- (BOOL) doCommandBySelector:(SEL)selector
{
    if (_delegateHas.doCommandBySelector) {
        return [(id<UITextViewDelegatePlus>)[self delegate] textView:self doCommandBySelector:selector];
    } else {
        return NO;
    }
}

- (void) selectAll:(id)sender
{
    [self setSelectedRange:NSMakeRange(0, [[self text] length])];
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

- (void) deleteBackward:(id)sender
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

- (void) deleteForward:(id)sender
{
    NSRange range = [self selectedRange];
    if (range.length > 0) {
        if (![self _canChangeTextInRange:range replacementText:@""]) {
            return;
        }
        [self _replaceCharactersInRange:range withString:@""];
        [self _didChangeText];
    } else if (range.location < [[self text]length]) {
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
        [self _indexWhenMovingUpFromIndex:[self selectedRange].location],
        0
    }];
}

- (void) moveUpAndModifySelection:(id)sender
{
    [self _modifySelectionWith:^NSInteger(NSInteger index) {
        return [self _indexWhenMovingUpFromIndex:index];
    }];
}

- (void) moveDown:(id)sender
{
    [self _setAndScrollToRange:(NSRange){
        [self _indexWhenMovingDownFromIndex:NSMaxRange([self selectedRange])],
        0
    }];
}

- (void) moveDownAndModifySelection:(id)sender
{
    [self _modifySelectionWith:^NSInteger(NSInteger index) {
        return [self _indexWhenMovingDownFromIndex:index];
    }];
}

- (void) moveToBeginningOfParagraph:(id)sender
{
    [self _setAndScrollToRange:(NSRange){
        [self _indexWhenMovingToBeginningOfParagraphFromIndex:[self selectedRange].location],
        0
    }];
}

- (void) moveToBeginningOfParagraphAndModifySelection:(id)sender
{
    [self _modifySelectionWith:^NSInteger(NSInteger index) {
        return [self _indexWhenMovingToBeginningOfParagraphFromIndex:index];
    }];
}

- (void) moveToEndOfParagraph:(id)sender
{
    [self _setAndScrollToRange:(NSRange){
        [self _indexWhenMovingToEndOfParagraphFromIndex:[self selectedRange].location],
        0
    }];
}

- (void) moveToEndOfParagraphAndModifySelection:(id)sender
{
    [self _modifySelectionWith:^NSInteger(NSInteger index) {
        return [self _indexWhenMovingToEndOfParagraphFromIndex:index];
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


#pragma mark Private Methods

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

- (void) _setSelectedRange:(NSRange)selectedRange affinity:(NSSelectionAffinity)affinity stillSelecting:(BOOL)stillSelecting
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
    NSMutableParagraphStyle* paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    [paragraphStyle setTighteningFactorForTruncation:0.0f];
    [paragraphStyle setAlignment:(NSTextAlignment)_textAlignment];
    
    return @{
        NSFontAttributeName: (id)[_font ctFontRef],
        NSKernAttributeName: @(0.0f),
        NSLigatureAttributeName: @(0.0f),
        NSParagraphStyleAttributeName: paragraphStyle,
        (id)kCTForegroundColorAttributeName: _textColor,
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
    NSInteger length = [[self textStorage] length];
    if (index < length) {
        return index + 1;
    } else {
        return index;
    }
}

- (NSInteger) _indexWhenMovingLeftFromIndex:(NSInteger)index
{
    if (index > 0) {
        return index - 1;
    } else {
        return index;
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

- (NSInteger) _indexWhenMovingUpFromIndex:(NSInteger)index
{
    NSTextStorage* textStorage = [self textStorage];
    NSInteger length = [textStorage length];
    NSString* string = [textStorage string];
    NSInteger newIndex = index;
    
    if (index <= length) {
        NSRange line = [string lineRangeForRange:(NSRange){ index, 0 }];
        if (line.location > 0) {
            NSRange prevLine = [string lineRangeForRange:(NSRange){ line.location - 1, 0 }];
            NSInteger offset = index - line.location;
            NSInteger prevLineMax = NSMaxRange(prevLine);
            newIndex = MIN(prevLine.location + offset, prevLineMax - 1);
        } else {
            newIndex = 0;
        }
    }
    
    return newIndex;
}

- (NSInteger) _indexWhenMovingDownFromIndex:(NSInteger)index
{
    NSTextStorage* textStorage = [self textStorage];
    NSUInteger length = [textStorage length];
    NSString* string = [textStorage string];
    NSInteger newIndex = index;
    
    if (index < length) {
        NSRange line = [string lineRangeForRange:(NSRange){ index, 0 }];
        NSInteger max = NSMaxRange(line);
        if (max < length) {
            NSRange nextLine = [string lineRangeForRange:(NSRange){ max, 0 }];
            NSInteger offset = index - line.location;
            NSInteger nextLineMax = NSMaxRange(nextLine);
            newIndex = MIN(nextLine.location + offset, nextLineMax - 1);
        } else {
            newIndex = length;
        }
    }

    return newIndex;
}

- (NSInteger) _indexWhenMovingToBeginningOfParagraphFromIndex:(NSInteger)index
{
    NSString* string = [[self textStorage] string];
    return [string lineRangeForRange:(NSRange){ index, 0 }].location;
}

- (NSInteger) _indexWhenMovingToEndOfParagraphFromIndex:(NSInteger)index
{
    NSString* string = [[self textStorage] string];
    NSInteger newIndex = NSMaxRange([string lineRangeForRange:(NSRange){ index, 0 }]);
    if (newIndex > 0 && [[NSCharacterSet newlineCharacterSet] characterIsMember:[string characterAtIndex:newIndex - 1]]) {
        newIndex--;
    }
    return newIndex;
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
        [self.layer addSublayer:_insertionPoint];
    }
    return self;
}

- (CGPoint) origin
{
    return (CGPoint){ kMarginX, kMarginY };
}

- (NSUInteger) characterIndexAtPoint:(CGPoint)point
{
    CGPoint offsetPoint = {
        .x = point.x - kMarginX,
        .y = point.y - kMarginY,
    };
    NSTextContainer* textContainer = [self textContainer];
    NSLayoutManager* layoutManager = [textContainer layoutManager];
    NSTextStorage* textStorage = [layoutManager textStorage];
    NSUInteger length = [textStorage length];

    CGFloat fraction = 0;
    NSUInteger index = [layoutManager characterIndexForPoint:offsetPoint inTextContainer:textContainer fractionOfDistanceBetweenInsertionPoints:&fraction];
    if (index >= length) {
        return length;
    } else if ([[NSCharacterSet newlineCharacterSet] characterIsMember:[[textStorage string] characterAtIndex:index]]) {
        return index;
    } else {
        return index + (fraction > 0.75);
    }
}

- (void) drawRect:(CGRect)rect
{
    NSTextContainer* textContainer = [self textContainer];
    NSLayoutManager* layoutManager = [textContainer layoutManager];
    NSRange glyphRange = [layoutManager glyphRangeForTextContainer:textContainer];
    if (glyphRange.length) {
        CGPoint origin = [self origin];
        [layoutManager drawBackgroundForGlyphRange:glyphRange atPoint:origin];
        [layoutManager drawGlyphsForGlyphRange:glyphRange atPoint:origin];
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
            NSRect* rectArray = [layoutManager rectArrayForCharacterRange:range withinSelectedCharacterRange:range inTextContainer:textContainer rectCount:&rectCount];
            if (rectCount) {
                result = rectArray[0];
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
    
    NSPoint origin = [self origin];
    return CGRectOffset(result, origin.x, origin.y);
}

@end