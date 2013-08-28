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

#import <UIKit/UITouch+UIPrivate.h>
#import <UIKit/UIWindow.h>
#import <UIKit/UIGestureRecognizerSubclass.h>
#import <Cocoa/Cocoa.h>

static NSArray* GestureRecognizersForView(UIView* view)
{
    NSMutableArray* recognizers = [[NSMutableArray alloc] initWithCapacity:0];
    while (view) {
        [recognizers addObjectsFromArray:view.gestureRecognizers];
        view = [view superview];
    }
    return recognizers;
}

@implementation UITouch {
    _UITouchGesture _gesture;
    CGPoint _delta;
    CGFloat _rotation;
    CGFloat _magnification;
    CGPoint _location;
    CGPoint _previousLocation;
}

#pragma mark Getting the Location of Touches

- (CGPoint) locationInView:(UIView*)inView
{
    return [self _convertLocationPoint:_location toView:inView];
}

- (CGPoint) previousLocationInView:(UIView*)inView
{
    return [self _convertLocationPoint:_previousLocation toView:inView];
}

- (UIWindow*) window
{
    return _window;
}

@synthesize view = _view;
@synthesize window = _window;


#pragma mark NSObject Protocol

- (NSString*) description
{
    NSString* phase = @"";
    switch (self.phase) {
        case UITouchPhaseBegan:
            phase = @"Began";
            break;
        case UITouchPhaseMoved:
            phase = @"Moved";
            break;
        case UITouchPhaseStationary:
            phase = @"Stationary";
            break;
        case UITouchPhaseEnded:
            phase = @"Ended";
            break;
        case UITouchPhaseCancelled:
            phase = @"Cancelled";
            break;
        case _UITouchPhaseGestureBegan:
            phase = @"GestureBegan";
            break;
        case _UITouchPhaseGestureChanged:
            phase = @"GestureChanged";
            break;
        case _UITouchPhaseGestureEnded:
            phase = @"GestureEnded";
            break;
        case _UITouchPhaseDiscreteGesture:
            phase = @"DiscreteGesture";
            break;
    }
    return [NSString stringWithFormat:@"<%@: %p; timestamp = %e; tapCount = %ld; phase = %@; view = %@; window = %@>", [self className], self, self.timestamp, self.tapCount, phase, self.view, self.window];
}


#pragma mark NSObject Overrides

- (id) init
{
    if ((self=[super init])) {
        _phase = UITouchPhaseCancelled;
        _gesture = _UITouchGestureUnknown;
    }
    return self;
}


#pragma mark Private Methods

- (CGPoint) _convertLocationPoint:(CGPoint)thePoint toView:(UIView*)inView
{
    UIWindow* window = self.window;
    CGPoint point = [window convertPoint:thePoint fromWindow:nil];
    if (inView) {
        point = [inView convertPoint:point fromView:window];
    }
    return point;
}

- (CGPoint) _delta
{
    return _delta;
}

- (_UITouchGesture) _gesture
{
    return _gesture;
}

- (CGFloat) _magnification
{
    return _magnification;
}

- (void) _removeFromView
{
    NSMutableArray* remainingRecognizers = [_gestureRecognizers mutableCopy];

    for (UIGestureRecognizer* recognizer in _gestureRecognizers) {
        if (recognizer.view == _view) {
            if (recognizer.state == UIGestureRecognizerStateBegan || recognizer.state == UIGestureRecognizerStateChanged) {
                recognizer.state = UIGestureRecognizerStateCancelled;
            }
            [remainingRecognizers removeObject:recognizer];
        }
    }
    _gestureRecognizers = [remainingRecognizers copy];
    _view = nil;
}

- (CGFloat) _rotation
{
    return _rotation;
}

- (void) _setDiscreteGesture:(_UITouchGesture)gesture screenLocation:(CGPoint)screenLocation tapCount:(NSUInteger)tapCount delta:(CGPoint)delta timestamp:(NSTimeInterval)timestamp;
{
    _phase = _UITouchPhaseDiscreteGesture;
    _gesture = gesture;
    _previousLocation = _location = screenLocation;
    _tapCount = tapCount;
    _delta = delta;
    _timestamp = timestamp;
    _rotation = 0;
    _magnification = 0;
}

- (void) _setPhase:(UITouchPhase)phase screenLocation:(CGPoint)screenLocation tapCount:(NSUInteger)tapCount timestamp:(NSTimeInterval)timestamp;
{
    _phase = phase;
    _gesture = _UITouchGestureUnknown;
    _previousLocation = _location = screenLocation;
    _tapCount = tapCount;
    _timestamp = timestamp;
    _rotation = 0;
    _magnification = 0;
}

- (void) _setTouchedView:(UIView*)view
{
    if (_view != view) {
        _view = view;
    }
    if (_window != view.window) {
        _window = view.window;
    }
    _gestureRecognizers = [GestureRecognizersForView(_view) copy];
}

- (void) _setTouchPhaseCancelled
{
    _phase = UITouchPhaseCancelled;
}

- (void) _updateGesture:(_UITouchGesture)gesture screenLocation:(CGPoint)screenLocation delta:(CGPoint)delta rotation:(CGFloat)rotation magnification:(CGFloat)magnification timestamp:(NSTimeInterval)timestamp;
{
    if (!CGPointEqualToPoint(screenLocation, _location)) {
        _previousLocation = _location;
        _location = screenLocation;
    }
    _phase = _UITouchPhaseGestureChanged;
    _gesture = gesture;
    _delta = delta;
    _rotation = rotation;
    _magnification = magnification;
    _timestamp = timestamp;
}

- (void) _updatePhase:(UITouchPhase)phase screenLocation:(CGPoint)screenLocation timestamp:(NSTimeInterval)timestamp;
{
    if (!CGPointEqualToPoint(screenLocation, _location)) {
        _previousLocation = _location;
        _location = screenLocation;
    }
    _phase = phase;
    _timestamp = timestamp;
}

@end
