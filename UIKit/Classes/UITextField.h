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

#import <UIKit/UIControl.h>
#import <UIKit/UIStringDrawing.h>
#import <UIKit/UITextInputTraits.h>
#import <UIKit/UITextInput.h>


UIKIT_EXTERN NSString *const UITextFieldTextDidBeginEditingNotification;
UIKIT_EXTERN NSString *const UITextFieldTextDidChangeNotification;
UIKIT_EXTERN NSString *const UITextFieldTextDidEndEditingNotification;

typedef enum {
    UITextBorderStyleNone,
    UITextBorderStyleLine,
    UITextBorderStyleBezel,
    UITextBorderStyleRoundedRect
} UITextBorderStyle;

typedef enum {
    UITextFieldViewModeNever,
    UITextFieldViewModeWhileEditing,
    UITextFieldViewModeUnlessEditing,
    UITextFieldViewModeAlways
} UITextFieldViewMode;

@class UIImage;
@class NSTextStorage;
@class NSTextContainer;
@class NSLayoutManager;

@class UITextField;

@protocol UITextFieldDelegate <NSObject>
@optional
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField;
- (void)textFieldDidBeginEditing:(UITextField *)textField;
- (BOOL)textFieldShouldEndEditing:(UITextField *)textField;
- (void)textFieldDidEndEditing:(UITextField *)textField;

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string;
- (BOOL)textFieldShouldClear:(UITextField *)textField;
- (BOOL)textFieldShouldReturn:(UITextField *)textField;
@end

@interface UITextField : UIControl <UITextInputTraits, UITextInput>

#pragma mark Accessing the Text Attributes
@property (nonatomic, copy) NSString* text;
@property (nonatomic, copy) NSAttributedString* attributedText;
@property (nonatomic, copy) NSString* placeholder;
@property (nonatomic, copy) NSAttributedString* attributedPlaceholder;
@property (nonatomic, copy) NSDictionary* defaultTextAttributes;
@property (nonatomic, strong) UIFont* font;
@property (nonatomic, strong) UIColor* textColor;
@property (nonatomic, assign) UITextAlignment textAlignment;
@property (nonatomic, copy) NSDictionary* typingAttributes;

#pragma mark Sizing the Text Field’s Text
@property (nonatomic) BOOL adjustsFontSizeToFitWidth;
@property (nonatomic) CGFloat minimumFontSize;

#pragma mark Managing the Editing Behavior
@property (nonatomic, readonly, getter=isEditing) BOOL editing;
@property (nonatomic) BOOL clearsOnBeginEditing;
@property (nonatomic) BOOL clearsOnInsertion;
@property (nonatomic) BOOL allowsEditingTextAttributes;

#pragma mark Setting the View’s Background Appearance
@property (nonatomic) UITextBorderStyle borderStyle;
@property (nonatomic, strong) UIImage* background;
@property (nonatomic, strong) UIImage* disabledBackground;

#pragma mark Managing Overlay Views
@property (nonatomic) UITextFieldViewMode clearButtonMode;
@property (nonatomic, strong) UIView* leftView;
@property (nonatomic) UITextFieldViewMode leftViewMode;
@property (nonatomic, strong) UIView* rightView;
@property (nonatomic) UITextFieldViewMode rightViewMode;

#pragma mark Accessing the Delegate
@property (nonatomic, assign) id<UITextFieldDelegate> delegate;

#pragma mark Drawing and Positioning Overrides
- (CGRect) textRectForBounds:(CGRect)bounds;
- (void) drawTextInRect:(CGRect)rect;
- (CGRect) placeholderRectForBounds:(CGRect)bounds;
- (void) drawPlaceholderInRect:(CGRect)rect;
- (CGRect) borderRectForBounds:(CGRect)bounds;
- (CGRect) editingRectForBounds:(CGRect)bounds;
- (CGRect) clearButtonRectForBounds:(CGRect)bounds;
- (CGRect) leftViewRectForBounds:(CGRect)bounds;
- (CGRect) rightViewRectForBounds:(CGRect)bounds;

#pragma mark Replacing the System Input Views
@property (nonatomic, retain) UIView* inputAccessoryView;
@property (nonatomic, retain) UIView* inputView;

@end
