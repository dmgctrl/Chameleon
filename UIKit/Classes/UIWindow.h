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

#import <UIKit/UIView.h>

@class UIScreen;
@class UIViewController;

#pragma mark Constants

typedef CGFloat UIWindowLevel;
UIKIT_EXTERN const UIWindowLevel UIWindowLevelNormal;
UIKIT_EXTERN const UIWindowLevel UIWindowLevelAlert;
UIKIT_EXTERN const UIWindowLevel UIWindowLevelStatusBar;
UIKIT_EXTERN NSString* const UIKeyboardFrameBeginUserInfoKey;
UIKIT_EXTERN NSString* const UIKeyboardFrameEndUserInfoKey;
UIKIT_EXTERN NSString* const UIKeyboardAnimationDurationUserInfoKey;
UIKIT_EXTERN NSString* const UIKeyboardAnimationCurveUserInfoKey;
// deprecated
UIKIT_EXTERN NSString* const UIKeyboardCenterBeginUserInfoKey;
UIKIT_EXTERN NSString* const UIKeyboardCenterEndUserInfoKey;
UIKIT_EXTERN NSString* const UIKeyboardBoundsUserInfoKey;


#pragma mark Notifications

UIKIT_EXTERN NSString* const UIWindowDidBecomeVisibleNotification;
UIKIT_EXTERN NSString* const UIWindowDidBecomeHiddenNotification;
UIKIT_EXTERN NSString* const UIWindowDidBecomeKeyNotification;
UIKIT_EXTERN NSString* const UIWindowDidResignKeyNotification;
UIKIT_EXTERN NSString* const UIKeyboardWillShowNotification;
UIKIT_EXTERN NSString* const UIKeyboardDidShowNotification;
UIKIT_EXTERN NSString* const UIKeyboardWillHideNotification;
UIKIT_EXTERN NSString* const UIKeyboardDidHideNotification;
UIKIT_EXTERN NSString* const UIKeyboardWillChangeFrameNotification;
UIKIT_EXTERN NSString* const UIKeyboardDidChangeFrameNotification;


@interface UIWindow : UIView 

#pragma mark Configuring Windows

@property (nonatomic, assign) UIWindowLevel windowLevel;
@property (nonatomic, strong) UIScreen* screen;
@property (nonatomic,strong) UIViewController* rootViewController;


#pragma mark Making Windows Key

@property (nonatomic, readonly, getter=isKeyWindow) BOOL keyWindow;
- (void) makeKeyAndVisible;
- (void) becomeKeyWindow;
- (void) makeKeyWindow;
- (void) resignKeyWindow;


#pragma mark Converting Coordinates

- (CGPoint) convertPoint:(CGPoint)toConvert toWindow:(UIWindow*)toWindow;
- (CGPoint) convertPoint:(CGPoint)toConvert fromWindow:(UIWindow*)fromWindow;
- (CGRect) convertRect:(CGRect)toConvert toWindow:(UIWindow*)toWindow;
- (CGRect) convertRect:(CGRect)toConvert fromWindow:(UIWindow*)fromWindow;


#pragma mark Sending Events

- (void) sendEvent:(UIEvent*)event;


@end
