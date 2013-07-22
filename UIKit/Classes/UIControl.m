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

#import <UIKit/UIControl+UIPrivate.h>
#import <UIKit/UIEvent.h>
#import <UIKit/UITouch.h>
#import <UIKit/UIApplication.h>
#import <UIKit/UIControlAction.h>

static NSString* const kUIDisabledKey = @"UIDisabled";
static NSString* const kUIContentHorizontalAlignmentKey = @"UIContentHorizontalAlignment";
static NSString* const kUIContentVerticalAlignmentKey = @"UIContentVerticalAlignment";

@implementation UIControl {
    NSMutableArray* _registeredActions;
}

#pragma mark Preparing and Sending Action Messages

- (void) sendAction:(SEL)action to:(id)target forEvent:(UIEvent*)event
{
    [[UIApplication sharedApplication] sendAction:action to:target from:self forEvent:event];
}

- (void) sendActionsForControlEvents:(UIControlEvents)controlEvents
{
    [self _sendActionsForControlEvents:controlEvents withEvent:nil];
}

- (void) addTarget:(id)target action:(SEL)action forControlEvents:(UIControlEvents)controlEvents
{
    UIControlAction* controlAction = [[UIControlAction alloc] init];
    controlAction.target = target;
    controlAction.action = action;
    controlAction.controlEvents = controlEvents;
    [_registeredActions addObject:controlAction];
}

- (void) removeTarget:(id)target action:(SEL)action forControlEvents:(UIControlEvents)controlEvents
{
    NSMutableArray* discard = [[NSMutableArray alloc] init];
    for (UIControlAction* controlAction in _registeredActions) {
        if (controlAction.target == target && (action == NULL || controlAction.controlEvents == controlEvents)) {
            [discard addObject:controlAction];
        }
    }
    [_registeredActions removeObjectsInArray:discard];
}

- (NSArray*) actionsForTarget:(id)target forControlEvent:(UIControlEvents)controlEvent
{
    NSMutableArray* actions = [[NSMutableArray alloc] init];
    for (UIControlAction* controlAction in _registeredActions) {
        if ((target == nil || controlAction.target == target) && (controlAction.controlEvents & controlEvent) ) {
            [actions addObject:NSStringFromSelector(controlAction.action)];
        }
    }
    if ([actions count] == 0) {
        return nil;
    } else {
        return actions;
    }
}

- (NSSet*) allTargets
{
    return [NSSet setWithArray:[_registeredActions valueForKey:@"target"]];
}

- (UIControlEvents) allControlEvents
{
    UIControlEvents allEvents = 0;
    for (UIControlAction* controlAction in _registeredActions) {
        allEvents |= controlAction.controlEvents;
    }
    return allEvents;
}


#pragma mark Setting and Getting Control Attributes

- (UIControlState) state
{
    UIControlState state = UIControlStateNormal;
    
    if (_highlighted)	state |= UIControlStateHighlighted;
    if (!_enabled)		state |= UIControlStateDisabled;
    if (_selected)		state |= UIControlStateSelected;
    
    return state;
}

- (void) setEnabled:(BOOL)newEnabled
{
    if (newEnabled != _enabled) {
		[self _stateWillChange];
        _enabled = newEnabled;
        [self _stateDidChange];
        self.userInteractionEnabled = _enabled;
    }
}

- (void) setSelected:(BOOL)newSelected
{
    if (newSelected != _selected) {
		[self _stateWillChange];
        _selected = newSelected;
        [self _stateDidChange];
    }
}

- (void) setHighlighted:(BOOL)newHighlighted
{
    if (newHighlighted != _highlighted) {
		[self _stateWillChange];
        _highlighted = newHighlighted;
        [self _stateDidChange];
    }
}


#pragma mark Tracking Touches and Redrawing Controls

- (BOOL) beginTrackingWithTouch:(UITouch*)touch withEvent:(UIEvent*)event
{
    return YES;
}

- (BOOL) continueTrackingWithTouch:(UITouch*)touch withEvent:(UIEvent*)event
{
    return YES;
}

- (void) endTrackingWithTouch:(UITouch*)touch withEvent:(UIEvent*)event
{
}

- (void) cancelTrackingWithEvent:(UIEvent*)event
{
}


#pragma mark UIView Protocol

- (id) initWithFrame:(CGRect)frame
{
    if (nil != (self = [super initWithFrame:frame])) {
        [self _commonInitForUIControl];
    }
    return self;
}


#pragma mark NSCoder Protocol

- (id) initWithCoder:(NSCoder*)coder
{
    if (nil != (self = [super initWithCoder:coder])) {
        [self _commonInitForUIControl];
        if ([coder containsValueForKey:kUIDisabledKey]) {
            [self setEnabled:![coder decodeBoolForKey:kUIDisabledKey]];
        }
    }
    return self;
}


#pragma mark UIAppearance Protocol

+ (id) appearance
{
#warning stub
    [self doesNotRecognizeSelector:_cmd];
    return @"";
}

+ (id) appearanceWhenContainedIn:(Class <UIAppearanceContainer>)ContainerClass, ... NS_REQUIRES_NIL_TERMINATION
{
#warning stub
    [self doesNotRecognizeSelector:_cmd];
    return @"";
}


#pragma mark UIResponder Overrides

- (void) touchesBegan:(NSSet*)touches withEvent:(UIEvent*)event
{
    UITouch* touch = [touches anyObject];
    _touchInside = YES;
    _tracking = [self beginTrackingWithTouch:touch withEvent:event];
    self.highlighted = YES;
    if (_tracking) {
        UIControlEvents currentEvents = UIControlEventTouchDown;
        if (touch.tapCount > 1) {
            currentEvents |= UIControlEventTouchDownRepeat;
        }
        [self _sendActionsForControlEvents:currentEvents withEvent:event];
    }
}

- (void) touchesMoved:(NSSet*)touches withEvent:(UIEvent*)event
{
    UITouch* touch = [touches anyObject];
    const BOOL wasTouchInside = _touchInside;
    _touchInside = [self pointInside:[touch locationInView:self] withEvent:event];
    self.highlighted = _touchInside;
    if (_tracking) {
        _tracking = [self continueTrackingWithTouch:touch withEvent:event];
        if (_tracking) {
            UIControlEvents currentEvents = ((_touchInside)? UIControlEventTouchDragInside : UIControlEventTouchDragOutside);
            
            if (!wasTouchInside && _touchInside) {
                currentEvents |= UIControlEventTouchDragEnter;
            } else if (wasTouchInside && !_touchInside) {
                currentEvents |= UIControlEventTouchDragExit;
            }
            
            [self _sendActionsForControlEvents:currentEvents withEvent:event];
        }
    }
}

- (void) touchesEnded:(NSSet*)touches withEvent:(UIEvent*)event
{
    UITouch* touch = [touches anyObject];
    _touchInside = [self pointInside:[touch locationInView:self] withEvent:event];
    self.highlighted = NO;
    if (_tracking) {
        [self endTrackingWithTouch:touch withEvent:event];
        [self _sendActionsForControlEvents:((_touchInside)? UIControlEventTouchUpInside : UIControlEventTouchUpOutside) withEvent:event];
    }
    _tracking = NO;
    _touchInside = NO;
}

- (void) touchesCancelled:(NSSet*)touches withEvent:(UIEvent*)event
{
    self.highlighted = NO;
    if (_tracking) {
        [self cancelTrackingWithEvent:event];
        [self _sendActionsForControlEvents:UIControlEventTouchCancel withEvent:event];
    }
    _touchInside = NO;
    _tracking = NO;
}


#pragma mark Private Methods

- (void) _commonInitForUIControl
{
    _registeredActions = [[NSMutableArray alloc] init];
    self.enabled = YES;
    self.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
    self.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
}


- (void) _sendActionsForControlEvents:(UIControlEvents)controlEvents withEvent:(UIEvent*)event
{
    for (UIControlAction* controlAction in _registeredActions) {
        if (controlAction.controlEvents & controlEvents) {
            [self sendAction:controlAction.action to:controlAction.target forEvent:event];
        }
    }
}

- (void) _stateWillChange
{
}

- (void) _stateDidChange
{
    [self setNeedsDisplay];
    [self setNeedsLayout];
}

@end
