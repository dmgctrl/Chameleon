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

@class UIView;
@class UIGestureRecognizer;
@class UITouch;
@class UIEvent;

#pragma mark Constants

typedef enum {
    UIGestureRecognizerStatePossible,
    UIGestureRecognizerStateBegan,
    UIGestureRecognizerStateChanged,
    UIGestureRecognizerStateEnded,
    UIGestureRecognizerStateCancelled,
    UIGestureRecognizerStateFailed,
    UIGestureRecognizerStateRecognized = UIGestureRecognizerStateEnded
} UIGestureRecognizerState;


@protocol UIGestureRecognizerDelegate <NSObject>

@optional
- (BOOL) gestureRecognizerShouldBegin:(UIGestureRecognizer*)gestureRecognizer;
- (BOOL) gestureRecognizer:(UIGestureRecognizer*)gestureRecognizer shouldReceiveTouch:(UITouch*)touch;
- (BOOL) gestureRecognizer:(UIGestureRecognizer*)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer*)otherGestureRecognizer;

@end


@interface UIGestureRecognizer : NSObject

#pragma mark Initializing a Gesture Recognizer

- (id) initWithTarget:(id)target action:(SEL)action;


#pragma mark Adding and Removing Targets and Actions

- (void) addTarget:(id)target action:(SEL)action;
- (void) removeTarget:(id)target action:(SEL)action;


#pragma mark Getting the Touches and Location of a Gesture

- (CGPoint) locationInView:(UIView*)view;
- (CGPoint) locationOfTouch:(NSUInteger)touchIndex inView:(UIView*)view;
- (NSUInteger) numberOfTouches;


#pragma mark Getting the Recognizer’s State and View

@property (nonatomic, readonly) UIGestureRecognizerState state;
@property (assign, nonatomic, readonly) UIView *view;
@property (nonatomic, getter=isEnabled) BOOL enabled;


#pragma mark Canceling and Delaying Touches

@property (nonatomic) BOOL cancelsTouchesInView;
@property (nonatomic) BOOL delaysTouchesBegan;
@property (nonatomic) BOOL delaysTouchesEnded;


#pragma mark Specifying Dependencies Between Gesture Recognizers

- (void) requireGestureRecognizerToFail:(UIGestureRecognizer*)otherGestureRecognizer;


#pragma mark Setting and Getting the Delegate

@property (nonatomic, assign) id<UIGestureRecognizerDelegate> delegate;


#pragma mark Methods For Subclasses

- (void) touchesBegan:(NSSet*)touches withEvent:(UIEvent*)event;
- (void) touchesMoved:(NSSet*)touches withEvent:(UIEvent*)event;
- (void) touchesEnded:(NSSet*)touches withEvent:(UIEvent*)event;
- (void) touchesCancelled:(NSSet*)touches withEvent:(UIEvent*)event;
- (void) reset;
- (void) ignoreTouch:(UITouch*)touch forEvent:(UIEvent*)event;
- (BOOL) canBePreventedByGestureRecognizer:(UIGestureRecognizer*)preventingGestureRecognizer;
- (BOOL) canPreventGestureRecognizer:(UIGestureRecognizer*)preventedGestureRecognizer;

@end
