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


@interface UIScrollView () <UITextLayerContainerViewProtocol>
@end


@interface UITextView () <UITextLayerTextDelegate>
@end


@interface _UITextContainerView : UIView
@property (nonatomic) NSTextContainer* textContainer;
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
}
@dynamic delegate;

- (void) dealloc
{
    [_textLayer removeFromSuperlayer];
}

static void _commonInitForUITextView(UITextView* self)
{
    self->_textLayer = [[UITextLayer alloc] initWithContainer:self isField:NO];
    self->_textLayer.opacity = 0.3;
    self->_textLayer.delegate = self;
    [self.layer insertSublayer:self->_textLayer atIndex:0];
    
    self.textColor = [UIColor blackColor];
    self.font = [UIFont systemFontOfSize:17];
    self.dataDetectorTypes = UIDataDetectorTypeAll;
    self.editable = YES;
    self.contentMode = UIViewContentModeScaleToFill;
    self.clipsToBounds = YES;
    
    if (!self->_textContainer) {
        self->_textContainer = [[NSTextContainer alloc] initWithContainerSize:(CGSize){ [self bounds].size.width, CGFLOAT_MAX }];
    }
    self->_textStorage = [[UITextStorage alloc] init];
    self->_layoutManager = [[NSLayoutManager alloc] init];
    [self->_layoutManager addTextContainer:self->_textContainer];
    [self->_textStorage addLayoutManager:self->_layoutManager];

    self->_textContainerView = [[_UITextContainerView alloc] initWithFrame:CGRectZero];
    [self addSubview:self->_textContainerView];
    [self->_textContainerView setTextContainer:self->_textContainer];
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
    [self setNeedsDisplay];
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

- (BOOL) isSecureTextEntry
{
    return [_textLayer isSecureTextEntry];
}

- (void) setSecureTextEntry:(BOOL)secure
{
    [_textLayer setSecureTextEntry:secure];
}

- (NSRange) selectedRange
{
    return _textLayer.selectedRange;
}

- (void) setSelectedRange:(NSRange)range
{
    _textLayer.selectedRange = range;
}

- (void) setText:(NSString*)text
{
    _textLayer.text = text;
    _text = text;
    if (text) {
        [self setAttributedText:[[NSAttributedString alloc] initWithString:text attributes:[self _synthesizedAttributes]]];
    } else {
        [self setAttributedText:nil];
    }
}

- (void) setTextAlignment:(UITextAlignment)textAlignment
{
    _textLayer.textAlignment = textAlignment;
    _textAlignment = textAlignment;
}

- (void) setTextColor:(UIColor*)textColor
{
    _textLayer.textColor = textColor;
    _textColor = textColor;
    [_textStorage addAttribute:(id)kCTForegroundColorAttributeName value:textColor range:(NSRange){ 0, [_textStorage length] }];
}

- (NSTextStorage*) textStorage
{
    return [[[self textContainer] layoutManager] textStorage];
}


#pragma mark Layout

- (void) layoutSubviews
{
    [super layoutSubviews];
    _textLayer.frame = self.bounds;
    [_textContainer setContainerSize:(CGSize){ [self contentSize].width, CGFLOAT_MAX }];
}


#pragma mark Scrolling

- (void) scrollRangeToVisible:(NSRange)range
{
    [_textLayer scrollRangeToVisible:range];
}


#pragma mark Public Methods

- (BOOL) hasText
{
    return [_textLayer.text length] > 0;
}


#pragma mark UIResponder

- (BOOL) canBecomeFirstResponder
{
    return (self.window != nil);
}

- (BOOL) becomeFirstResponder
{
    if ([super becomeFirstResponder] ){
        return [_textLayer becomeFirstResponder];
    } else {
        return NO;
    }
}

- (BOOL) resignFirstResponder
{
    if ([super resignFirstResponder]) {
        return [_textLayer resignFirstResponder];
    } else {
        return NO;
    }
}


#pragma mark Private Methods

- (NSDictionary*) _synthesizedAttributes
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

- (BOOL) _textShouldBeginEditing
{
    return _delegateHas.shouldBeginEditing? [self.delegate textViewShouldBeginEditing:self] : YES;
}

- (void) _textDidBeginEditing
{
    if (_delegateHas.didBeginEditing) {
        [self.delegate textViewDidBeginEditing:self];
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:UITextViewTextDidBeginEditingNotification object:self];
}

- (BOOL) _textShouldEndEditing
{
    return _delegateHas.shouldEndEditing? [self.delegate textViewShouldEndEditing:self] : YES;
}

- (void) _textDidEndEditing
{
    if (_delegateHas.didEndEditing) {
        [self.delegate textViewDidEndEditing:self];
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:UITextViewTextDidEndEditingNotification object:self];
}

- (BOOL) _textShouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    return _delegateHas.shouldChangeText? [self.delegate textView:self shouldChangeTextInRange:range replacementText:text] : YES;
}

- (void) _textDidChange
{
    if (_delegateHas.didChange) {
        [self.delegate textViewDidChange:self];
    }
    [self setText:_textLayer.text];
    [self setNeedsDisplay];
    [[NSNotificationCenter defaultCenter] postNotificationName:UITextViewTextDidChangeNotification object:self];
}

- (void) _textDidChangeSelection
{
    if (_delegateHas.didChangeSelection) {
        [self.delegate textViewDidChangeSelection:self];
    }
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


@implementation _UITextContainerView

- (void) drawRect:(CGRect)rect
{
    NSTextContainer* textContainer = [self textContainer];
    NSLayoutManager* layoutManager = [textContainer layoutManager];
    NSRange glyphRange = [layoutManager glyphRangeForTextContainer:textContainer];
    if (glyphRange.length) {
        CGContextRef c = UIGraphicsGetCurrentContext();
        [NSGraphicsContext saveGraphicsState];
        [NSGraphicsContext setCurrentContext:[NSGraphicsContext graphicsContextWithGraphicsPort:c flipped:YES]];
        
        CGPoint p = CGRectInset([self bounds], 4, 9).origin;
        [layoutManager drawBackgroundForGlyphRange:glyphRange atPoint:p];
        [layoutManager drawGlyphsForGlyphRange:glyphRange atPoint:p];
        
        [NSGraphicsContext restoreGraphicsState];
    }
}

@end