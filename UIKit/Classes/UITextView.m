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
#import "UIFont.h"
#import "UIFont+UIPrivate.h"
#import "UITextLayer.h"
#import "UITextStorage.h"
#import "UIScrollView.h"
#import <AppKit/NSCursor.h>
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


@interface UIScrollView () <UITextLayerContainerViewProtocol>
@end


@interface UITextView () <UITextLayerTextDelegate>
@end


@interface _UITextContainerView : UIView
@property (nonatomic) NSTextContainer* textContainer;
@property (nonatomic) NSRange selectedRange;
@property (nonatomic) BOOL showInsertionPoint;
@end


@interface NSObject (UITextViewDelegate)
- (BOOL) textView:(UITextView*)textView doCommandBySelector:(SEL)selector;
@end


@implementation UITextView {
    NSTextStorage* _textStorage;
    NSTextContainer* _textContainer;
    NSLayoutManager* _layoutManager;

    UITextLayer *_textLayer;
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
}
@dynamic delegate;

- (void) dealloc
{
    [_textLayer removeFromSuperlayer];
}

static void _commonInitForUITextView(UITextView* self)
{
    self.textColor = [UIColor blackColor];
    self.font = [UIFont systemFontOfSize:17];
    self.dataDetectorTypes = UIDataDetectorTypeAll;
    self.editable = YES;
    self.contentMode = UIViewContentModeScaleToFill;
    self.clipsToBounds = YES;

//    self->_textLayer = [[UITextLayer alloc] initWithContainer:self isField:NO];
//    self->_textLayer.opacity = 0.3;
//    self->_textLayer.delegate = self;
//    [self.layer insertSublayer:self->_textLayer atIndex:0];

    self->_textContainerView = [[_UITextContainerView alloc] initWithFrame:CGRectZero];
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

- (void) setAttributedText:(NSAttributedString*)attributedText
{
    _attributedText = [attributedText copy];
    if (attributedText) {
        [_textStorage replaceCharactersInRange:(NSRange){ 0, [_textStorage length]} withAttributedString:attributedText];
    } else {
        [_textStorage deleteCharactersInRange:(NSRange){ 0, [_textStorage length]}];
    }
    [_textContainerView setNeedsDisplay];
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
    _textLayer.editable = editable;
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
    _textLayer.font = font;
    _font = font;
    [_textStorage addAttribute:(id)kCTFontAttributeName value:font range:(NSRange){ 0, [_textStorage length] }];
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
    if (_selectedRange.location != range.location || _selectedRange.length != range.length) {
        _selectedRange = range;
        _textContainerView.selectedRange = range;
        _textLayer.selectedRange = range;
    }
}

- (void) setText:(NSString*)text
{
    _textLayer.text = text;
    _text = text;
    if (text) {
        [self setAttributedText:[[NSAttributedString alloc] initWithString:text attributes:[self _stringAttributes]]];
    } else {
        [self setAttributedText:nil];
    }
}

- (void) setTextAlignment:(UITextAlignment)textAlignment
{
    _textLayer.textAlignment = textAlignment;
    _textAlignment = textAlignment;
    [_textContainerView setNeedsDisplay];
}

- (void) setTextColor:(UIColor*)textColor
{
    _textLayer.textColor = textColor;
    _textColor = textColor;
    [_textStorage addAttribute:(id)kCTForegroundColorAttributeName value:textColor range:(NSRange){ 0, [_textStorage length] }];
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
        [_textContainerView setTextContainer:_textContainer];
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

- (void) setContentOffset:(CGPoint)theOffset animated:(BOOL)animated
{
    [super setContentOffset:theOffset animated:animated];
    [_textLayer setContentOffset:theOffset];
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
    _textLayer.frame = self.bounds;

    CGRect bounds = [self bounds];
    NSTextContainer* textContainer = [self textContainer];
    NSLayoutManager* layoutManager = [textContainer layoutManager];
    [textContainer setContainerSize:(CGSize){
        bounds.size.width - (kMarginX * 2.0),
        CGFLOAT_MAX
    }];
    CGSize contentSize = {
        bounds.size.width,
        [layoutManager usedRectForTextContainer:textContainer].size.height + kMarginY
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
    if (glyphRange.length) {
        CGRect boundingRect = [layoutManager boundingRectForGlyphRange:glyphRange inTextContainer:[self textContainer]];
        [super scrollRectToVisible:boundingRect animated:NO];
    }
    [_textLayer setContentOffset:[self contentOffset]];
}


#pragma mark Public Methods

- (BOOL) hasText
{
    return [_textStorage length] > 0;
}


#pragma mark UIResponder

- (BOOL) canBecomeFirstResponder
{
    return (self.window != nil);
}

- (BOOL) becomeFirstResponder
{
    if ([super becomeFirstResponder]) {
        _flags.didBeginEditing = NO;
        [_textContainerView setShowInsertionPoint:YES];
        return YES;
    }
    return NO;
}

- (BOOL) resignFirstResponder
{
    if ([self _endEditingIfNecessary]) {
        if ([super resignFirstResponder]) {
            [_textContainerView setShowInsertionPoint:NO];
            return YES;
        }
    }
    return NO;
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
    } else {
        if (range.location > 0) {
            range.location--;
            if (![self _canChangeTextInRange:NSMakeRange(range.location, 1) replacementText:@""]) {
                return;
            }
            [self _replaceCharactersInRange:NSMakeRange(range.location,1) withString:@""];
            [self _didChangeText];
        }
    }
}

- (void) moveLeft:(id)sender
{
    NSRange range = [self selectedRange];
    if (range.length > 0) {
        range.length = 0;
    } else if (range.location > 0) {
        range.location--;
    }
    [self _setAndScrollToRange:range];
}

- (void) moveRight:(id)sender
{
    NSRange range = [self selectedRange];
    if (range.length > 0) {
        range.location = NSMaxRange(range);
        range.length = 0;
    } else {
        NSUInteger length = [_textStorage length];
        range.location++;
        if (range.location > length) {
            range.location = length;
        }
    }
    [self _setAndScrollToRange:range];
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
    if (_delegateHas.didChange) {
        [[self delegate] textViewDidChange:self];
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:UITextViewTextDidChangeNotification object:self];
}

- (void) _replaceCharactersInRange:(NSRange)range withString:(NSString*)string
{
    [_textStorage replaceCharactersInRange:range withString:string];
    [_textStorage setAttributes:[self _stringAttributes] range:NSMakeRange(range.location, [string length])];
    [self setSelectedRange:NSMakeRange(range.location + [string length], 0)];
    [_textContainerView setNeedsDisplay];
}

- (void) _setAndScrollToRange:(NSRange)range upstream:(BOOL)upstream
{
    if (_delegateHas.didChangeSelection) {
        [self.delegate textViewDidChangeSelection:self];
    }
    [self setSelectedRange:range];
    if (upstream) {
        [self scrollRangeToVisible:NSMakeRange(range.location, 0)];
    } else {
        [self scrollRangeToVisible:NSMakeRange(NSMaxRange(range), 0)];
    }
}

- (void) _setAndScrollToRange:(NSRange)range
{
    [self _setAndScrollToRange:range upstream:YES];
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

- (BOOL) _textShouldDoCommandBySelector:(SEL)selector
{
    if (_delegateHas.doCommandBySelector) {
        return [(id)self.delegate textView:self doCommandBySelector:selector];
    } else {
        return NO;
    }
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
        };
        [self.layer addSublayer:_insertionPoint];
    }
    return self;
}

- (CGPoint) origin
{
    return (CGPoint){ kMarginX, kMarginY };
}

- (void) drawRect:(CGRect)rect
{
    NSTextContainer* textContainer = [self textContainer];
    NSLayoutManager* layoutManager = [textContainer layoutManager];
    NSRange glyphRange = [layoutManager glyphRangeForTextContainer:textContainer];
    if (glyphRange.length) {
        CGContextRef c = UIGraphicsGetCurrentContext();
        [NSGraphicsContext saveGraphicsState];
        [NSGraphicsContext setCurrentContext:[NSGraphicsContext graphicsContextWithGraphicsPort:c flipped:YES]];
        
        CGPoint origin = [self origin];
        [layoutManager drawBackgroundForGlyphRange:glyphRange atPoint:origin];
        [layoutManager drawGlyphsForGlyphRange:glyphRange atPoint:origin];
        
        [NSGraphicsContext restoreGraphicsState];
    }
}

- (void) setSelectedRange:(NSRange)selectedRange
{
    _selectedRange = selectedRange;
    [self _updateInsertionPointPosition];
    [self setNeedsDisplay];
}

- (void) setShowInsertionPoint:(BOOL)showInsertionPoint
{
    if (_showInsertionPoint != showInsertionPoint) {
        _showInsertionPoint = showInsertionPoint;
        _insertionPoint.hidden = !showInsertionPoint;
        if (showInsertionPoint) {
            [self _updateInsertionPointPosition];
        }
    }
}

- (void) _updateInsertionPointPosition
{
    CGRect rect = [self _viewRectForCharacterRange:[self selectedRange]];
    rect.origin.x = floor(rect.origin.x);
    NSLog(@"%@", NSStringFromRect(rect));
    _insertionPoint.frame = rect;
}

- (NSRect) _viewRectForCharacterRange:(NSRange)range
{
    NSTextContainer* textContainer = [self textContainer];
    NSLayoutManager* layoutManager = [textContainer layoutManager];
    NSTextStorage* textStorage = [layoutManager textStorage];
    
    NSRect result = {};
    if (range.length == 0){
        if (range.location >= [textStorage length]) {
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