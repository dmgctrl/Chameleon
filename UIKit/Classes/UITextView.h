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

#import <UIKit/UIStringDrawing.h>
#import <UIKit/UIScrollView.h>
#import <UIKit/UIDataDetectors.h>
#import <UIKit/UITextInputTraits.h>

UIKIT_EXTERN NSString *const UITextViewTextDidBeginEditingNotification;
UIKIT_EXTERN NSString *const UITextViewTextDidChangeNotification;
UIKIT_EXTERN NSString *const UITextViewTextDidEndEditingNotification;

@class UIColor;
@class UIFont;
@class NSLayoutManager;
@class NSTextContainer;
@class NSTextStorage;

@class UITextView;
@protocol UITextViewDelegate <NSObject, UIScrollViewDelegate>
@optional
- (BOOL) textViewShouldBeginEditing:(UITextView*)textView;
- (void) textViewDidBeginEditing:(UITextView*)textView;
- (BOOL) textViewShouldEndEditing:(UITextView*)textView;
- (void) textViewDidEndEditing:(UITextView*)textView;
- (BOOL) textView:(UITextView*)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString*)text;
- (void) textViewDidChange:(UITextView*)textView;
- (void) textViewDidChangeSelection:(UITextView*)textView;
@end

@interface UITextView : UIScrollView <NSCoding, UITextInputTraits>

- (instancetype) initWithFrame:(CGRect)frame textContainer:(NSTextContainer*)textContainer;

#pragma mark Configuring the Text Attributes
@property (nonatomic, copy) NSString* text;
@property (nonatomic, copy) NSAttributedString* attributedText;
@property (nonatomic, strong) UIFont* font;
@property (nonatomic, strong) UIColor* textColor;
@property (nonatomic, getter=isEditable) BOOL editable;
@property (nonatomic) BOOL allowsEditingTextAttributes;
@property (nonatomic) UIDataDetectorTypes dataDetectorTypes;
@property (nonatomic) UITextAlignment textAlignment;
@property (nonatomic, copy) NSDictionary* typingAttributes;
@property (nonatomic, copy) NSDictionary* linkTextAttributes;
- (BOOL) hasText;

#pragma mark Working with the Selection
@property (nonatomic) NSRange selectedRange;
- (void) scrollRangeToVisible:(NSRange)range;
@property (nonatomic) BOOL clearsOnInsertion;

#pragma mark Accessing the Delegate
@property (nonatomic, assign) id<UITextViewDelegate> delegate;

#pragma mark Replacing the System Input Views
@property (nonatomic, readwrite, strong) UIView* inputAccessoryView;
@property (nonatomic, readwrite, strong) UIView* inputView;

#pragma mark Accessing Text Kit Objects
@property (nonatomic, readonly) NSLayoutManager* layoutManager;
@property (nonatomic, readonly) NSTextContainer* textContainer;
@property (nonatomic, readonly) NSTextStorage* textStorage;

@end
