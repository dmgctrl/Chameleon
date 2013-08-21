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

#import <Foundation/Foundation.h>
#import <UIKit/UIKitDefines.h>

#pragma mark Constants

typedef enum {
    UIScreenOverscanCompensationScale,
    UIScreenOverscanCompensationInsetBounds,
    UIScreenOverscanCompensationInsetApplicationFrame,
} UIScreenOverscanCompensation;


#pragma mark Notifications

UIKIT_EXTERN NSString* const UIScreenDidConnectNotification;
UIKIT_EXTERN NSString* const UIScreenDidDisconnectNotification;
UIKIT_EXTERN NSString* const UIScreenModeDidChangeNotification;
UIKIT_EXTERN NSString* const UIScreenBrightnessDidChangeNotification;

@class UIScreenMode;
@class CADisplayLink;

@interface UIScreen : NSObject

#pragma mark Getting the Available Screens

+ (UIScreen*) mainScreen;
+ (NSArray*) screens;
@property (nonatomic, readonly, retain) UIScreen* mirroredScreen;


#pragma mark Getting the Bounds Information

@property (nonatomic, readonly) CGRect bounds;
@property (nonatomic, readonly) CGRect applicationFrame;
@property (nonatomic, readonly) CGFloat scale;


#pragma mark Accessing the Screen Modes

@property (nonatomic, readonly, retain) UIScreenMode* preferredMode;
@property (nonatomic, readonly, copy) NSArray* availableModes;
@property (nonatomic, strong) UIScreenMode* currentMode;


#pragma mark Getting a Display Link

- (CADisplayLink*) displayLinkWithTarget:(id)target selector:(SEL)sel;


#pragma mark Setting a Display’s Brightness

@property (nonatomic) CGFloat brightness;
@property (nonatomic) BOOL wantsSoftwareDimming;


#pragma mark Setting a Display’s Overscan Compensation

@property (nonatomic) UIScreenOverscanCompensation overscanCompensation;

@end
