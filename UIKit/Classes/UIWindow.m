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

#import <UIKit/UIViewController.h>
#import <UIKit/UIViewController+UIPrivate.h>
#import <UIKit/UIWindow+UIPrivate.h>
#import <UIKit/UIView+UIPrivate.h>
#import <UIKit/UIScreen+UIPrivate.h>
#import <UIKit/UIScreen+AppKit.h>
#import <UIKit/UIApplication+UIPrivate.h>
#import <UIKit/UIEvent.h>
#import <UIKit/UITouch+UIPrivate.h>
#import <UIKit/UIScreenMode.h>
#import <UIKit/UIResponder+AppKit.h>
#import <UIKit/UIView+AppKit.h>
#import <UIKit/UIKitView.h>
#import <UIKit/UIViewController.h>
#import <UIKit/UIGestureRecognizerSubclass.h>
#import <UIKit/UIGestureRecognizer+UIPrivate.h>
#import <AppKit/NSCursor.h>
#import <AppKit/NSHelpManager.h>
#import <AppKit/NSEvent.h>
#import <AppKit/NSWindow.h>
#import <AppKit/NSFont.h>
#import <AppKit/NSAttributedString.h>
#import <QuartzCore/QuartzCore.h>


#pragma mark Constants

const UIWindowLevel UIWindowLevelNormal = 0;
const UIWindowLevel UIWindowLevelStatusBar = 1000;
const UIWindowLevel UIWindowLevelAlert = 2000;

NSString* const UIKeyboardFrameBeginUserInfoKey = @"UIKeyboardFrameBeginUserInfoKey";
NSString* const UIKeyboardFrameEndUserInfoKey = @"UIKeyboardFrameEndUserInfoKey";
NSString* const UIKeyboardAnimationDurationUserInfoKey = @"UIKeyboardAnimationDurationUserInfoKey";
NSString* const UIKeyboardAnimationCurveUserInfoKey = @"UIKeyboardAnimationCurveUserInfoKey";

// deprecated
NSString* const UIKeyboardCenterBeginUserInfoKey = @"UIKeyboardCenterBeginUserInfoKey";
NSString* const UIKeyboardCenterEndUserInfoKey = @"UIKeyboardCenterEndUserInfoKey";
NSString* const UIKeyboardBoundsUserInfoKey = @"UIKeyboardBoundsUserInfoKey";


#pragma mark Notifications

NSString* const UIWindowDidBecomeVisibleNotification = @"UIWindowDidBecomeVisibleNotification";
NSString* const UIWindowDidBecomeHiddenNotification = @"UIWindowDidBecomeHiddenNotification";
NSString* const UIWindowDidBecomeKeyNotification = @"UIWindowDidBecomeKeyNotification";
NSString* const UIWindowDidResignKeyNotification = @"UIWindowDidResignKeyNotification";
NSString* const UIKeyboardWillShowNotification = @"UIKeyboardWillShowNotification";
NSString* const UIKeyboardDidShowNotification = @"UIKeyboardDidShowNotification";
NSString* const UIKeyboardWillHideNotification = @"UIKeyboardWillHideNotification";
NSString* const UIKeyboardDidHideNotification = @"UIKeyboardDidHideNotification";
NSString* const UIKeyboardWillChangeFrameNotification = @"UIKeyboardWillChangeFrameNotification";
NSString* const UIKeyboardDidChangeFrameNotification = @"UIKeyboardDidChangeFrameNotification";

@interface UIWindow ()
- (void) _showToolTipForView:(UIView*)view;
- (void) _hideCurrentToolTip;
- (void) _stopTrackingPotentiallyNewToolTip;
- (void) _toolTipViewDidChangeSuperview:(NSNotification*)notification;

@property (nonatomic, strong) UIView* currentToolTipView;
@property (nonatomic, strong) UIView* toolTipViewToShow;
@end


@implementation UIWindow {
    UIResponder* _firstResponder;
    UIResponder* _firstResponderWhenKeyLost;
    NSUndoManager* _undoManager;
}


#pragma mark Configuring Windows

- (UIWindowLevel) windowLevel
{
    return self.layer.zPosition;
}

- (void) setWindowLevel:(UIWindowLevel)level
{
    self.layer.zPosition = level;
}

- (void) setScreen:(UIScreen*)theScreen
{
    if (theScreen != _screen) {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:UIScreenModeDidChangeNotification object:_screen];
        const BOOL wasHidden = self.hidden;
        [self _makeHidden];
        [self.layer removeFromSuperlayer];
        _screen = theScreen;
        [[_screen _layer] addSublayer:self.layer];
        if (!wasHidden) {
            [self _makeVisible];
        }
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_screenModeChangedNotification:) name:UIScreenModeDidChangeNotification object:_screen];
    }
}

- (void) setRootViewController:(UIViewController*)rootViewController
{
	if (rootViewController != _rootViewController) {
        [self.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
        _rootViewController = rootViewController;
        [self addSubview:[rootViewController view]];
	}
}


#pragma mark Making Windows Key

- (BOOL) isKeyWindow
{
    return ([UIApplication sharedApplication].keyWindow == self);
}

- (void) makeKeyAndVisible
{
    [self _makeVisible];
    [self makeKeyWindow];
}

- (void) becomeKeyWindow
{
    id firstResponder = [self _firstResponder] ?: _firstResponderWhenKeyLost;
    if ([firstResponder respondsToSelector:@selector(becomeKeyWindow)]) {
        [firstResponder becomeKeyWindow];
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:UIWindowDidBecomeKeyNotification object:self];
}

- (void) makeKeyWindow
{
    if (!self.isKeyWindow) {
        [[UIApplication sharedApplication].keyWindow resignKeyWindow];
        [[UIApplication sharedApplication] _setKeyWindow:self];
        [self becomeKeyWindow];
    }
}

- (void) resignKeyWindow
{
    id firstResponder = [self _firstResponder];
    if ([firstResponder respondsToSelector:@selector(resignKeyWindow)]) {
        [firstResponder resignKeyWindow];
    }
    [firstResponder resignFirstResponder];
    _firstResponderWhenKeyLost = firstResponder;
    [[UIApplication sharedApplication] _setKeyWindow:nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:UIWindowDidResignKeyNotification object:self];
}


#pragma mark Converting Coordinates

- (CGPoint) convertPoint:(CGPoint)toConvert toWindow:(UIWindow*)toWindow
{
    if (toWindow == self) {
        return toConvert;
    } else {
        toConvert.x += self.frame.origin.x;
        toConvert.y += self.frame.origin.y;

        if (toWindow) {
            toConvert = [self.screen convertPoint:toConvert toScreen:toWindow.screen];
            toConvert.x -= toWindow.frame.origin.x;
            toConvert.y -= toWindow.frame.origin.y;
        }
        return toConvert;
    }
}

- (CGPoint) convertPoint:(CGPoint)toConvert fromWindow:(UIWindow*)fromWindow
{
    if (fromWindow == self) {
        return toConvert;
    } else {
        
        if (fromWindow) {
            toConvert.x += fromWindow.frame.origin.x;
            toConvert.y += fromWindow.frame.origin.y;
            toConvert = [self.screen convertPoint:toConvert fromScreen:fromWindow.screen];
        }
        toConvert.x -= self.frame.origin.x;
        toConvert.y -= self.frame.origin.y;
        return toConvert;
    }
}

- (CGRect) convertRect:(CGRect)toConvert toWindow:(UIWindow*)toWindow
{
    CGPoint convertedOrigin = [self convertPoint:toConvert.origin toWindow:toWindow];
    return CGRectMake(convertedOrigin.x, convertedOrigin.y, toConvert.size.width, toConvert.size.height);
}

- (CGRect) convertRect:(CGRect)toConvert fromWindow:(UIWindow*)fromWindow
{
    CGPoint convertedOrigin = [self convertPoint:toConvert.origin fromWindow:fromWindow];
    return CGRectMake(convertedOrigin.x, convertedOrigin.y, toConvert.size.width, toConvert.size.height);
}


#pragma mark Sending Events

- (void) sendEvent:(UIEvent*)event
{
    if (event.type == UIEventTypeTouches) {
        NSSet* touches = [event touchesForWindow:self];
        NSMutableSet* gestureRecognizers = [NSMutableSet setWithCapacity:0];
        for (UITouch* touch in touches) {
            [gestureRecognizers addObjectsFromArray:touch.gestureRecognizers];
        }
        for (UIGestureRecognizer* recognizer in gestureRecognizers) {
            [recognizer _recognizeTouches:touches withEvent:event];
        }
        for (UITouch* touch in touches) {
            UIView* view = touch.view;
            const UITouchPhase phase = touch.phase;
            const _UITouchGesture gesture = [touch _gesture];

            if (phase == UITouchPhaseBegan) {
                [view touchesBegan:touches withEvent:event];
            } else if (phase == UITouchPhaseMoved) {
                [view touchesMoved:touches withEvent:event];
            } else if (phase == UITouchPhaseEnded) {
                [view touchesEnded:touches withEvent:event];
            } else if (phase == UITouchPhaseCancelled) {
                [view touchesCancelled:touches withEvent:event];
            } else if (phase == _UITouchPhaseDiscreteGesture && gesture == _UITouchDiscreteGestureMouseMove) {
                if ([view hitTest:[touch locationInView:view] withEvent:event]) {
                    [view mouseMoved:[touch _delta] withEvent:event];
                }
            } else if (phase == _UITouchPhaseDiscreteGesture && gesture == _UITouchDiscreteGestureRightClick) {
                [view rightClick:touch withEvent:event];
            } else if ((phase == _UITouchPhaseDiscreteGesture && gesture == _UITouchDiscreteGestureScrollWheel) ||
                       (phase == _UITouchPhaseGestureChanged && gesture == _UITouchGesturePan)) {
                [view scrollWheelMoved:[touch _delta] withEvent:event];
            }
            NSCursor* newCursor = [view mouseCursorForEvent:event] ?: [NSCursor arrowCursor];

            if ([NSCursor currentCursor] != newCursor) {
                [newCursor set];
            }

        }

		if(touches.count < 1) {
			[self _stopTrackingPotentiallyNewToolTip];
			[self _hideCurrentToolTip];
		}
    } else {
		[self _stopTrackingPotentiallyNewToolTip];
		[self _hideCurrentToolTip];
	}
}


#pragma mark UIView Overrides

- (id) initWithFrame:(CGRect)theFrame
{
    if ((self=[super initWithFrame:theFrame])) {
        _undoManager = [[NSUndoManager alloc] init];
        [self _makeHidden];
        self.screen = [UIScreen mainScreen];
        self.opaque = NO;
    }
    return self;
}

- (void) setHidden:(BOOL)hide
{
    if (hide) {
        [self _makeHidden];
    } else {
        [self _makeVisible];
    }
}

- (UIView*) superview
{
    return nil;
}

- (void) removeFromSuperview
{
    // does nothing
}

- (UIWindow*) window
{
    return self;
}


#pragma mark UIResponder Overrides

- (UIResponder*) nextResponder
{
    return [UIApplication sharedApplication];
}

- (NSUndoManager*) undoManager
{
    return _undoManager;
}

- (void) mouseExitedView:(UIView*)exited enteredView:(UIView*)entered withEvent:(UIEvent*)event {
	if(exited == nil || entered == nil) {
		[self _stopTrackingPotentiallyNewToolTip];
		[self _hideCurrentToolTip];
	}
	[super mouseExitedView:exited enteredView:entered withEvent:event];
}


#pragma mark NSObject Overrides

- (void) dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
	[self _stopTrackingPotentiallyNewToolTip];
	[self _hideCurrentToolTip];
    [self _makeHidden];
    _screen = nil;
    _undoManager = nil;
    _rootViewController = nil;

}


#pragma mark Private Methods

- (BOOL) _acceptsFirstResponder
{
    return _firstResponder || _firstResponderWhenKeyLost;
}

- (UIResponder*) _firstResponder
{
    return _firstResponder;
}

- (void) _setFirstResponder:(UIResponder*)newFirstResponder
{
    _firstResponderWhenKeyLost = nil;
    _firstResponder = newFirstResponder;
}

- (void) _hideCurrentToolTip {
	if(self.currentToolTipView == nil) return;

	[[NSNotificationCenter defaultCenter] removeObserver:self name:UIViewDidMoveToSuperviewNotification object:self.currentToolTipView];
	[[NSHelpManager sharedHelpManager] removeContextHelpForObject:self.currentToolTipView];
	NSEvent	*newEvent = [NSEvent mouseEventWithType:NSLeftMouseDown location:[NSEvent mouseLocation] modifierFlags:0 timestamp:0 windowNumber:[[self.screen.UIKitView window] windowNumber] context:[[self.screen.UIKitView window] graphicsContext] eventNumber:0 clickCount:1 pressure:0];
	[NSApp postEvent:newEvent atStart:NO];
	newEvent = [NSEvent mouseEventWithType:NSLeftMouseUp location:[NSEvent mouseLocation] modifierFlags:0 timestamp:0 windowNumber:[[self.screen.UIKitView window] windowNumber] context:[[self.screen.UIKitView window] graphicsContext] eventNumber:0 clickCount:1 pressure:0];
	[NSApp postEvent:newEvent atStart:NO];
	self.currentToolTipView = nil;
}

- (void) _makeHidden
{
    if (!self.hidden) {
        [super setHidden:YES];
        if (self.screen) {
            [[UIApplication sharedApplication] _windowDidBecomeHidden:self];
            [[NSNotificationCenter defaultCenter] postNotificationName:UIWindowDidBecomeHiddenNotification object:self];
        }
    }
}

- (void) _makeVisible
{
    if (self.hidden) {
        [super setHidden:NO];
        if (self.screen) {
            [[UIApplication sharedApplication] _windowDidBecomeVisible:self];
            [[NSNotificationCenter defaultCenter] postNotificationName:UIWindowDidBecomeVisibleNotification object:self];
        }
    }
}

- (void) _screenModeChangedNotification:(NSNotification*)note
{
    UIScreenMode* previousMode = [[note userInfo] objectForKey:@"_previousMode"];
    UIScreenMode* newMode = _screen.currentMode;

    if (!CGSizeEqualToSize(previousMode.size,newMode.size)) {
        [self _superviewSizeDidChangeFrom:previousMode.size to:newMode.size];
    }
}

- (void) _showToolTipForView:(UIView*)view {
	if(view == nil) return;
    
	NSMutableAttributedString* attributedToolTip = [[NSMutableAttributedString alloc] initWithString:view.toolTip];
	NSRange wholeStringRange = NSMakeRange(0, view.toolTip.length);
	[attributedToolTip addAttribute:NSFontAttributeName value:[NSFont systemFontOfSize:11.0f] range:wholeStringRange];
	NSMutableParagraphStyle* paragraphStyle = [[NSMutableParagraphStyle alloc] init];
	[paragraphStyle setAlignment:NSLeftTextAlignment];
	[attributedToolTip addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:wholeStringRange];
	[[NSHelpManager sharedHelpManager] setContextHelp:attributedToolTip forObject:view];
	[[NSHelpManager sharedHelpManager] showContextHelpForObject:view locationHint:[NSEvent mouseLocation]];
	self.currentToolTipView = view;
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_toolTipViewDidChangeSuperview:) name:UIViewDidMoveToSuperviewNotification object:self.currentToolTipView];
	self.toolTipViewToShow = nil;
}

- (void) _stopTrackingPotentiallyNewToolTip {
	[[self class] cancelPreviousPerformRequestsWithTarget:self selector:@selector(_showToolTipForView:) object:self.toolTipViewToShow];
	self.toolTipViewToShow = nil;
}

- (void) _toolTipViewDidChangeSuperview:(NSNotification*)notification {
	if(self.currentToolTipView.window.screen.UIKitView.superview == nil || self.currentToolTipView.superview == nil) {
		[self _hideCurrentToolTip];
	}
}

@end
