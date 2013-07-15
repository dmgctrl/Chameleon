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

#import "UITextField.h"
#import "UITextLayer.h"
#import "UIColor.h"
#import "UIFont.h"
#import "UIImage+UIPrivate.h"
#import "UIBezierPath.h"
#import "UIGraphics.h"
#import "UILabel.h"
#import "UIWindow+UIPrivate.h"


#import "UIImage.h"
#import <AppKit/NSCursor.h>


NSString* const UITextFieldTextDidBeginEditingNotification = @"UITextFieldTextDidBeginEditingNotification";
NSString* const UITextFieldTextDidChangeNotification = @"UITextFieldTextDidChangeNotification";
NSString* const UITextFieldTextDidEndEditingNotification = @"UITextFieldTextDidEndEditingNotification";


static NSString* const kUIPlaceholderKey = @"UIPlaceholder";
static NSString* const kUITextAlignmentKey = @"UITextAlignment";
static NSString* const kUITextKey = @"UIText";
static NSString* const kUITextFieldBackgroundKey = @"UITextFieldBackground";
static NSString* const kUITextFieldDisabledBackgroundKey = @"UITextFieldDisabledBackground";
static NSString* const kUIBorderStyleKey = @"UIBorderStyle";
static NSString* const kUIClearsOnBeginEditingKey = @"UIClearsOnBeginEditing";
static NSString* const kUIMinimumFontSizeKey = @"UIMinimumFontSize";
static NSString* const kUIFontKey = @"UIFont";
static NSString* const kUIClearButtonModeKey = @"UIClearButtonMode";
static NSString* const kUIClearButtonOffsetKey = @"UIClearButtonOffset";
static NSString* const kUIAutocorrectionTypeKey = @"UIAutocorrectionType";
static NSString* const kUISpellCheckingTypeKey = @"UISpellCheckingType";
static NSString* const kUIKeyboardAppearanceKey = @"UIKeyboardAppearance";
static NSString* const kUIKeyboardTypeKey = @"UIKeyboardType";
static NSString* const kUIReturnKeyTypeKey = @"UIReturnKeyType";
static NSString* const kUIEnablesReturnKeyAutomaticallyKey = @"UIEnablesReturnKeyAutomatically";
static NSString* const kUISecureTextEntryKey = @"UISecureTextEntry";


@interface UIControl () <UITextLayerContainerViewProtocol>
@end


@interface UITextField () <UITextLayerTextDelegate>
@property (nonatomic, readonly) NSLayoutManager* layoutManager;
@property (nonatomic, readonly) NSTextContainer* textContainer;
@property (nonatomic, readonly) NSTextStorage* textStorage;
@end


@interface NSObject (UITextFieldDelegate)
- (BOOL) textField:(UITextField*)textField doCommandBySelector:(SEL)selector;
@end


@implementation UITextField {
    NSTextStorage* _textStorage;
    NSTextContainer* _textContainer;
    NSLayoutManager* _layoutManager;

    UITextLayer* _textLayer;
	UITextLayer* _placeholderTextLayer;
    
    UILabel* _placeholderTextLabel;
    UILabel* _textLabel;
    
    struct {
        bool shouldBeginEditing : 1;
        bool didBeginEditing : 1;
        bool shouldEndEditing : 1;
        bool didEndEditing : 1;
        bool shouldChangeCharacters : 1;
        bool shouldClear : 1;
        bool shouldReturn : 1;
        bool doCommandBySelector : 1;
    } _delegateHas;
    
    struct {
        bool didBeginEditing : 1;
    } _flags;
}

- (void) dealloc
{
	[_placeholderTextLayer removeFromSuperlayer];
    [_textLayer removeFromSuperlayer];
}

static void _commonInitForUITextField(UITextField* self)
{
    self->_placeholderTextLayer = [[UITextLayer alloc] initWithContainer:self isField:NO];
    self->_placeholderTextLayer.textColor = [UIColor colorWithWhite:0.6f alpha:1.0f];
    [self.layer addSublayer:self->_placeholderTextLayer];
    
    self->_textLayer = [[UITextLayer alloc] initWithContainer:self isField:YES];
    [self.layer addSublayer:self->_textLayer];
    
    self.textAlignment = UITextAlignmentLeft;
    self.font = [UIFont systemFontOfSize:17];
    self.borderStyle = UITextBorderStyleNone;
    self.textColor = [UIColor blackColor];
    self.clearButtonMode = UITextFieldViewModeNever;
    self.leftViewMode = UITextFieldViewModeNever;
    self.rightViewMode = UITextFieldViewModeNever;
    self.opaque = NO;
}

- (id) initWithFrame:(CGRect)frame
{
    if (nil != (self = [super initWithFrame:frame])) {
        _commonInitForUITextField(self);
    }
    return self;
}

- (id) initWithCoder:(NSCoder*)coder
{
    if (nil != (self = [super initWithCoder:coder])) {
        _commonInitForUITextField(self);
        if ([coder containsValueForKey:kUIPlaceholderKey]) {
            self.placeholder = [coder decodeObjectForKey:kUIPlaceholderKey];
        }
        if ([coder containsValueForKey:kUITextAlignmentKey]) {
            self.textAlignment = [coder decodeIntegerForKey:kUITextAlignmentKey];
        }
        if ([coder containsValueForKey:kUITextKey]) {
            self.text = [coder decodeObjectForKey:kUITextKey];
        }
        if ([coder containsValueForKey:kUITextFieldBackgroundKey]) {
            self.background = [coder decodeObjectForKey:kUITextFieldBackgroundKey];
        }
        if ([coder containsValueForKey:kUITextFieldDisabledBackgroundKey]) {
            self.disabledBackground = [coder decodeObjectForKey:kUITextFieldDisabledBackgroundKey];
        }
        if ([coder containsValueForKey:kUIBorderStyleKey]) {
            self.borderStyle = [coder decodeIntegerForKey:kUIBorderStyleKey];
        }
        if ([coder containsValueForKey:kUIClearsOnBeginEditingKey]) {
            self.clearsOnBeginEditing = [coder decodeBoolForKey:kUIClearsOnBeginEditingKey];
        }
        if ([coder containsValueForKey:kUIMinimumFontSizeKey]) {
            self.minimumFontSize = [coder decodeFloatForKey:kUIMinimumFontSizeKey];
        }
        if ([coder containsValueForKey:kUIFontKey]) {
            self.font = [coder decodeObjectForKey:kUIFontKey];
        }
        if ([coder containsValueForKey:kUIClearButtonModeKey]) {
            self.clearButtonMode = [coder decodeIntegerForKey:kUIClearButtonModeKey];
        }
        if ([coder containsValueForKey:kUIAutocorrectionTypeKey]) {
            self.autocorrectionType = [coder decodeIntegerForKey:kUIAutocorrectionTypeKey];
        }
        if ([coder containsValueForKey:kUIClearButtonOffsetKey]) {
            /* XXX: Implement Me */
        }
        if ([coder containsValueForKey:kUISpellCheckingTypeKey]) {
            /* XXX: Implement Me */
        }
        if ([coder containsValueForKey:kUIKeyboardAppearanceKey]) {
            /* XXX: Implement Me */
        }
        if ([coder containsValueForKey:kUIKeyboardTypeKey]) {
            /* XXX: Implement Me */
        }
        if ([coder containsValueForKey:kUIReturnKeyTypeKey]) {
            /* XXX: Implement Me */
        }
        if ([coder containsValueForKey:kUIEnablesReturnKeyAutomaticallyKey]) {
            /* XXX: Implement Me */
        }
        if ([coder containsValueForKey:kUISecureTextEntryKey]) {
            /* XXX: Implement Me */
        }
    }
    return self;
}

- (void) encodeWithCoder:(NSCoder*)coder
{
    [self doesNotRecognizeSelector:_cmd];
}


#pragma mark Layout

- (BOOL) _isLeftViewVisible
{
    return _leftView && (_leftViewMode == UITextFieldViewModeAlways
                         || (_editing && _leftViewMode == UITextFieldViewModeWhileEditing)
                         || (!_editing && _leftViewMode == UITextFieldViewModeUnlessEditing));
}

- (BOOL) _isRightViewVisible
{
    return _rightView && (_rightViewMode == UITextFieldViewModeAlways
                         || (_editing && _rightViewMode == UITextFieldViewModeWhileEditing)
                         || (!_editing && _rightViewMode == UITextFieldViewModeUnlessEditing));
}

- (void) layoutSubviews
{
    [super layoutSubviews];
    const CGRect bounds = self.bounds;
    _textLayer.frame = [self textRectForBounds:bounds];
	_placeholderTextLayer.frame = [self textRectForBounds:bounds];

    if ([self _isLeftViewVisible]) {
        _leftView.hidden = NO;
        _leftView.frame = [self leftViewRectForBounds:bounds];
    } else {
        _leftView.hidden = YES;
    }

    if ([self _isRightViewVisible]) {
        _rightView.hidden = NO;
        _rightView.frame = [self rightViewRectForBounds:bounds];
    } else {
        _rightView.hidden = YES;
    }
    
    [_textLabel setFrame:[self textRectForBounds:bounds]];
}


#pragma mark Properties

- (void) setAttributedPlaceholder:(NSAttributedString*)attributedPlaceholder
{
    _attributedPlaceholder = attributedPlaceholder;
    [_placeholderTextLayer setText:[attributedPlaceholder string]];
    if (!_placeholderTextLabel) {
        _placeholderTextLabel = [[UILabel alloc] initWithFrame:[self textRectForBounds:[self bounds]]];
    }
    if (![self _isFirstResponder] && ![[self text] length]) {
        [self addSubview:_placeholderTextLabel];
    }
    [_placeholderTextLabel setAttributedText:attributedPlaceholder];
}

- (void) setAttributedText:(NSAttributedString*)attributedText
{
    _attributedText = attributedText;
    _textLayer.text = [attributedText string];
	_placeholderTextLayer.hidden = _textLayer.text.length > 0 || _editing;
    if (!_textLabel) {
        _textLabel = [[UILabel alloc] initWithFrame:[self textRectForBounds:[self bounds]]];
    }
    if (![self _isFirstResponder] && [[self text] length]) {
        [self addSubview:_textLabel];
    }
    [_textLabel setAttributedText:attributedText];
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

- (void) setBackground:(UIImage*)background
{
    if (background != _background) {
        _background = background;
        [self setNeedsDisplay];
    }
}

- (void) setBorderStyle:(UITextBorderStyle)borderStyle
{
    if (borderStyle != _borderStyle) {
        _borderStyle = borderStyle;
        [self setNeedsDisplay];
    }
}

- (void) setDelegate:(id<UITextFieldDelegate>)delegate
{
    if (delegate != _delegate) {
        _delegate = delegate;
        _delegateHas.shouldBeginEditing = [delegate respondsToSelector:@selector(textFieldShouldBeginEditing:)];
        _delegateHas.didBeginEditing = [delegate respondsToSelector:@selector(textFieldDidBeginEditing:)];
        _delegateHas.shouldEndEditing = [delegate respondsToSelector:@selector(textFieldShouldEndEditing:)];
        _delegateHas.didEndEditing = [delegate respondsToSelector:@selector(textFieldDidEndEditing:)];
        _delegateHas.shouldChangeCharacters = [delegate respondsToSelector:@selector(textField:shouldChangeCharactersInRange:replacementString:)];
        _delegateHas.shouldClear = [delegate respondsToSelector:@selector(textFieldShouldClear:)];
        _delegateHas.shouldReturn = [delegate respondsToSelector:@selector(textFieldShouldReturn:)];
		_delegateHas.doCommandBySelector = [delegate respondsToSelector:@selector(textField:doCommandBySelector:)];
    }
}

- (void) setDisabledBackground:(UIImage*)disabledBackground
{
    if (disabledBackground != _disabledBackground) {
        _disabledBackground = disabledBackground;
        [self setNeedsDisplay];
    }
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
    _textLayer.font = font;
	_placeholderTextLayer.font = font;
}

- (void) setFrame:(CGRect)frame
{
    if (!CGRectEqualToRect(frame,self.frame)) {
        [super setFrame:frame];
        [self setNeedsDisplay];
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

- (void) setLeftView:(UIView*)leftView
{
    if (leftView != _leftView) {
        if (_leftView) {
            [_leftView removeFromSuperview];
        }
        _leftView = leftView;
        if (leftView) {
            [self addSubview:leftView];
        }
    }
}

- (void) setPlaceholder:(NSString*)placeholder
{
    _placeholder = placeholder;
    [self setAttributedPlaceholder:[[NSAttributedString alloc] initWithString:placeholder attributes:nil]];
}

- (void) setRightView:(UIView*)rightView
{
    if (rightView != _rightView) {
        if (_rightView) {
            [_rightView removeFromSuperview];
        }
        _rightView = rightView;
        if (rightView) {
            [self addSubview:rightView];
        }
    }
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

- (NSString*) text
{
    return [_textLayer text];
}

- (void) setText:(NSString*)text
{
//    _text = text;
    [self setAttributedText:[[NSAttributedString alloc] initWithString:text attributes:nil]];
}

- (void) setTextAlignment:(UITextAlignment)textAlignment
{
    _textAlignment = textAlignment;
    _textLayer.textAlignment = textAlignment;
	_placeholderTextLayer.textAlignment = textAlignment;
}

- (void) setTextColor:(UIColor*)textColor
{
    _textColor = textColor;
    _textLayer.textColor = textColor;
}


#pragma mark Geometry

- (CGRect) borderRectForBounds:(CGRect)bounds
{
    return bounds;
}

- (CGRect) clearButtonRectForBounds:(CGRect)bounds
{
    return CGRectZero;
}

- (CGRect) editingRectForBounds:(CGRect)bounds
{
    return [self textRectForBounds:bounds];
}

- (CGRect) leftViewRectForBounds:(CGRect)bounds
{
    if (_leftView) {
        const CGRect frame = _leftView.frame;
        bounds.origin.x = 0;
        bounds.origin.y = (bounds.size.height / 2.f) - (frame.size.height/2.f);
        bounds.size = frame.size;
        return CGRectIntegral(bounds);
    } else {
        return CGRectZero;
    }
}

- (CGRect) placeholderRectForBounds:(CGRect)bounds
{
    return [self textRectForBounds:bounds];
}

- (CGRect) rightViewRectForBounds:(CGRect)bounds
{
    if (_rightView) {
        const CGRect frame = _rightView.frame;
        bounds.origin.x = bounds.size.width - frame.size.width;
        bounds.origin.y = (bounds.size.height / 2.f) - (frame.size.height/2.f);
        bounds.size = frame.size;
        return CGRectIntegral(bounds);
    } else {
        return CGRectZero;
    }
}

- (CGRect) textRectForBounds:(CGRect)bounds
{
    CGRect textRect;
    switch ([self borderStyle]) {
        case UITextBorderStyleRoundedRect: {
            textRect = CGRectOffset(CGRectInset(bounds, 7.0f, 2.0f), -1.0f, 0.0f);
            break;
        }
        case UITextBorderStyleBezel: {
            textRect = CGRectOffset(CGRectInset(bounds, 7.0f, 2.5f), 0.0f, 1.5f);
            break;
        }
        case UITextBorderStyleLine: {
            textRect = CGRectInset(bounds, 2.0f, 2.0f);
            break;
        }
        case UITextBorderStyleNone: {
            textRect = bounds;
            break;
        }
	}
    
    if ([self _isLeftViewVisible]) {
        CGRect overlap = CGRectIntersection(textRect, [self leftViewRectForBounds:bounds]);
        if (!CGRectIsNull(overlap)) {
            textRect = CGRectOffset(textRect, overlap.size.width, 0);
            textRect.size.width -= overlap.size.width;
        }
    }
    
    if ([self _isRightViewVisible]) {
        CGRect overlap = CGRectIntersection(textRect, [self rightViewRectForBounds:bounds]);
        if (!CGRectIsNull(overlap)) {
            textRect = CGRectOffset(textRect, -overlap.size.width, 0);
            textRect.size.width -= overlap.size.width;
        }
    }

    return textRect;
}


#pragma mark Drawing

- (void) drawPlaceholderInRect:(CGRect)rect
{
}

- (void) drawTextInRect:(CGRect)rect
{
}

- (void) drawRect:(CGRect)rect
{
    UIImage* currentBackgroundImage = nil;
	if ([self borderStyle] == UITextBorderStyleRoundedRect) {
		currentBackgroundImage = [UIImage _textFieldRoundedRectBackground];
	} else {
		currentBackgroundImage = [self isEnabled]? _background : _disabledBackground;
	}
	
	CGRect borderFrame = [self borderRectForBounds:[self bounds]];
	if (currentBackgroundImage) {
		[currentBackgroundImage drawInRect:borderFrame];
	} else {
		CGContextRef context = UIGraphicsGetCurrentContext();
		
		// TODO: draw the appropriate background for the borderStyle
		
		if(self.borderStyle == UITextBorderStyleBezel) {
			// bottom white highlight
			CGRect hightlightFrame = CGRectMake(0.0, 10.0, borderFrame.size.width, borderFrame.size.height-10.0);
			[[UIColor colorWithWhite:1.0 alpha:1.0] set];
			[[UIBezierPath bezierPathWithRoundedRect:hightlightFrame cornerRadius:3.6] fill];
			
			// top white highlight
			CGRect topHightlightFrame = CGRectMake(0.0, 0.0, borderFrame.size.width, borderFrame.size.height-10.0);
			[[UIColor colorWithWhite:0.7f alpha:1.0] set];
			[[UIBezierPath bezierPathWithRoundedRect:topHightlightFrame cornerRadius:3.6] fill];
			
			// black outline
			CGRect blackOutlineFrame = CGRectMake(0.0, 1.0, borderFrame.size.width, borderFrame.size.height-2.0);
			
			CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
			CGFloat locations[] = { 1.0f, 0.0f };
			CGGradientRef gradient = CGGradientCreateWithColors(colorSpace, (__bridge CFArrayRef) @[(id)[UIColor colorWithWhite:0.5 alpha:1.0].CGColor, (id)[UIColor colorWithWhite:0.65 alpha:1.0].CGColor], locations);
			
			CGContextSaveGState(context);
			CGContextAddPath(context, [UIBezierPath bezierPathWithRoundedRect:blackOutlineFrame cornerRadius:3.6f].CGPath);
			CGContextClip(context);
			
			CGContextDrawLinearGradient(context, gradient, CGPointMake(0.0f, CGRectGetMinY(blackOutlineFrame)), CGPointMake(0.0f, CGRectGetMaxY(blackOutlineFrame)), 0);
			CFRelease(colorSpace);
			CFRelease(gradient);
			
			CGContextRestoreGState(context);
						
			// top inner shadow
			CGRect shadowFrame = CGRectMake(1, 2, borderFrame.size.width-2.0, 10.0);
			[[UIColor colorWithWhite:0.88 alpha:1.0] set];
			[[UIBezierPath bezierPathWithRoundedRect:shadowFrame cornerRadius:2.9] fill];	
			
			// main white area
			CGRect whiteFrame = CGRectMake(1, 3, borderFrame.size.width-2.0, borderFrame.size.height-5.0);
			[[UIColor whiteColor] set];
			[[UIBezierPath bezierPathWithRoundedRect:whiteFrame cornerRadius:2.6] fill];
		} else if(self.borderStyle == UITextBorderStyleLine) {
			[[UIColor colorWithWhite:0.1f alpha:0.8f] set];
			CGContextStrokeRect(context, borderFrame);
			
			[[UIColor colorWithWhite:1.0f alpha:1.0f] set];
			CGContextFillRect(context, CGRectInset(borderFrame, 1.0f, 1.0f));
		}
	}
}


#pragma mark UIResponder

- (BOOL) canBecomeFirstResponder
{
    return ([self window] != nil);
}

- (BOOL) becomeFirstResponder
{
    if ([super becomeFirstResponder]) {
		[_placeholderTextLayer setHidden:YES];
        [_textLabel removeFromSuperview];
        [_placeholderTextLabel removeFromSuperview];
        return [_textLayer becomeFirstResponder];
    } else {
        return NO;
    }
}

- (BOOL) resignFirstResponder
{
    if ([super resignFirstResponder]) {
        if ([[self text] length]) {
            if (_textLabel) {
                [self addSubview:_textLabel];
            }
        } else {
            if (_placeholderTextLabel) {
                [self addSubview:_placeholderTextLabel];
            }
        }
        return [_textLayer resignFirstResponder];
    } else {
        return NO;
    }
}

- (BOOL) _isFirstResponder
{
    return self == [[self window] _firstResponder];
}


#pragma mark Events & Notification

- (BOOL) _textShouldBeginEditing
{
    return _delegateHas.shouldBeginEditing? [_delegate textFieldShouldBeginEditing:self] : YES;
}

- (void) _textDidBeginEditing
{
    BOOL shouldClear = _clearsOnBeginEditing;

    if (shouldClear && _delegateHas.shouldClear) {
        shouldClear = [_delegate textFieldShouldClear:self];
    }

    if (shouldClear) {
        // this doesn't work - it can cause an exception to trigger. hrm...
        // so... rather than worry too much about it right now, just gonna delay it :P
        //self.text = @"";
        [self performSelector:@selector(setText:) withObject:@"" afterDelay:0];
    }
	
	_placeholderTextLayer.hidden = YES;
    
    _editing = YES;
    [self setNeedsDisplay];
    [self setNeedsLayout];

    if (_delegateHas.didBeginEditing) {
        [_delegate textFieldDidBeginEditing:self];
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:UITextFieldTextDidBeginEditingNotification object:self];
}

- (BOOL) _textShouldEndEditing
{
    return _delegateHas.shouldEndEditing? [_delegate textFieldShouldEndEditing:self] : YES;
}

- (void) _textDidEndEditing
{
	_placeholderTextLayer.hidden = _textLayer.text.length > 0;
	
    _editing = NO;
    [self setNeedsDisplay];
    [self setNeedsLayout];
    
    if (_delegateHas.didEndEditing) {
        [_delegate textFieldDidEndEditing:self];
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:UITextFieldTextDidEndEditingNotification object:self];
}

- (BOOL) _textShouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    return _delegateHas.shouldChangeCharacters? [_delegate textField:self shouldChangeCharactersInRange:range replacementString:text] : YES;
}

- (void) _textDidChange
{
    [[NSNotificationCenter defaultCenter] postNotificationName:UITextFieldTextDidChangeNotification object:self];
}

- (void) _textDidReceiveReturnKey
{
    if (_delegateHas.shouldReturn) {
        [_delegate textFieldShouldReturn:self];
    }
}

- (BOOL) _textShouldDoCommandBySelector:(SEL)selector
{
	if(_delegateHas.doCommandBySelector) {
		return [(id)self.delegate textField:self doCommandBySelector:selector];
	} else {
		if(selector == @selector(insertNewline:) || selector == @selector(insertNewlineIgnoringFieldEditor:)) {
			[self _textDidReceiveReturnKey];
			return YES;
		}
	}
	
	return NO;
}


#pragma mark Misc.

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
    return [NSString stringWithFormat:@"<%@: %p; textAlignment = %@; editing = %@; textColor = %@; font = %@; delegate = %@>", [self className], self, textAlignment, (self.editing ? @"YES" : @"NO"), self.textColor, self.font, self.delegate];
}

- (id) mouseCursorForEvent:(UIEvent*)event
{
    return [NSCursor IBeamCursor];
}

@end
