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

#import <UIKit/UIApplication.h>
#import <UIKit/UIColor.h>
#import <UIKit/UINib.h>
#import <UIKit/UIStoryboard.h>
#import <UIKit/NSEvent+UIKit.h>
#import <UIKit/UIKitView.h>
#import <UIKit/UIApplication+AppKit.h>
#import <UIKit/UIApplication+UIPrivate.h>
#import "UIBackgroundTask.h"
#import <UIKit/UIEvent+UIPrivate.h>
#import <UIKit/UIKey+UIPrivate.h>
#import <UIKit/UIPopoverController+UIPrivate.h>
#import <UIKit/UIResponder+AppKit.h>
#import <UIKit/UIScreen+AppKit.h>
#import <UIKit/UIScreen+UIPrivate.h>
#import <UIKit/UITouch+UIPrivate.h>
#import <UIKit/UIWindow+UIPrivate.h>
#import <Cocoa/Cocoa.h>

#pragma mark Constants

NSString* const UIApplicationWillChangeStatusBarOrientationNotification = @"UIApplicationWillChangeStatusBarOrientationNotification";
NSString* const UIApplicationDidChangeStatusBarOrientationNotification = @"UIApplicationDidChangeStatusBarOrientationNotification";
NSString* const UIApplicationWillEnterForegroundNotification = @"UIApplicationWillEnterForegroundNotification";
NSString* const UIApplicationWillTerminateNotification = @"UIApplicationWillTerminateNotification";
NSString* const UIApplicationWillResignActiveNotification = @"UIApplicationWillResignActiveNotification";
NSString* const UIApplicationDidEnterBackgroundNotification = @"UIApplicationDidEnterBackgroundNotification";
NSString* const UIApplicationDidBecomeActiveNotification = @"UIApplicationDidBecomeActiveNotification";
NSString* const UIApplicationDidFinishLaunchingNotification = @"UIApplicationDidFinishLaunchingNotification";
NSString* const UIApplicationNetworkActivityIndicatorChangedNotification = @"UIApplicationNetworkActivityIndicatorChangedNotification";
NSString* const UIApplicationLaunchOptionsURLKey = @"UIApplicationLaunchOptionsURLKey";
NSString* const UIApplicationLaunchOptionsSourceApplicationKey = @"UIApplicationLaunchOptionsSourceApplicationKey";
NSString* const UIApplicationLaunchOptionsRemoteNotificationKey = @"UIApplicationLaunchOptionsRemoteNotificationKey";
NSString* const UIApplicationLaunchOptionsAnnotationKey = @"UIApplicationLaunchOptionsAnnotationKey";
NSString* const UIApplicationLaunchOptionsLocalNotificationKey = @"UIApplicationLaunchOptionsLocalNotificationKey";
NSString* const UIApplicationLaunchOptionsLocationKey = @"UIApplicationLaunchOptionsLocationKey";
NSString* const UIApplicationDidReceiveMemoryWarningNotification = @"UIApplicationDidReceiveMemoryWarningNotification";
NSString* const UITrackingRunLoopMode = @"UITrackingRunLoopMode";
const UIBackgroundTaskIdentifier UIBackgroundTaskInvalid = NSUIntegerMax;
const NSTimeInterval UIMinimumKeepAliveTimeout = 0;
static UIApplication* _theApplication = nil;


@interface _UIApplicationDelegate : NSObject <NSApplicationDelegate>
@end


@implementation _UIApplicationDelegate

- (void) applicationWillFinishLaunching:(NSNotification*) notification
{
    UIApplication* app = [UIApplication sharedApplication];

    NSBundle* bundle = [NSBundle mainBundle];
    NSString* storyboardName = [[bundle infoDictionary] objectForKey:@"UIMainStoryboardFile"];
    if (storyboardName) {
        UIStoryboard* storyboard = [UIStoryboard storyboardWithName:storyboardName bundle:bundle];
        [[app keyWindow] setRootViewController:[storyboard instantiateInitialViewController]];
    } else {
        NSString* nibName = [[bundle infoDictionary] objectForKey:@"NSMainNibFile"];
        if (nibName) {
            UINib* nib = [UINib nibWithNibName:nibName bundle:bundle];
            [nib instantiateWithOwner:_theApplication options:nil];
        }
    }
    [[app delegate] application:app didFinishLaunchingWithOptions:nil];
}

@end


UIKIT_EXTERN int UIApplicationMain(int argc, char* argv[], NSString* principalClassName, NSString* delegateClassName)
{
    NSApplication* application = [NSApplication sharedApplication];
    static id<NSApplicationDelegate> nsappdelegate;
    nsappdelegate = [[_UIApplicationDelegate alloc] init];
    [application setDelegate:nsappdelegate];
    Class principalClass = principalClassName ? NSClassFromString(principalClassName) : [UIApplication class];
    _theApplication = [[principalClass alloc] init];

    if (delegateClassName) {
        Class delegateClass = NSClassFromString(delegateClassName);
        if (delegateClass) {
            static id<UIApplicationDelegate> uiappdelegate;
            uiappdelegate = [[delegateClass alloc] init];
            [_theApplication setDelegate:uiappdelegate];
        }
    }
    [[[NSNib alloc] initWithNibNamed:@"MainMenu" bundle:[NSBundle bundleForClass:[UIApplication class]]] instantiateWithOwner:application topLevelObjects:NULL];
    UIKitView* contentView = [[UIKitView alloc] initWithFrame:(NSRect){ 0, 0, 320, 568 }];
    NSWindow* window = [[NSWindow alloc] initWithContentRect:[contentView bounds] styleMask:NSTitledWindowMask | NSClosableWindowMask | NSMiniaturizableWindowMask backing:NSBackingStoreBuffered defer:YES];
    [window setContentView:contentView];
    [window center];
    [window makeKeyAndOrderFront:nil];
    [[contentView UIWindow] makeKeyAndVisible];
    [NSApp run];
    return 0;
}

static CGPoint ScrollDeltaFromNSEvent(NSEvent* theNSEvent)
{
    double dx, dy;
    CGEventRef cgEvent = [theNSEvent CGEvent];
    const int64_t isContinious = CGEventGetIntegerValueField(cgEvent, kCGScrollWheelEventIsContinuous);

    if (isContinious == 0) {
        CGEventSourceRef source = CGEventCreateSourceFromEvent(cgEvent);
        const double pixelsPerLine = CGEventSourceGetPixelsPerLine(source);
        dx = CGEventGetDoubleValueField(cgEvent, kCGScrollWheelEventFixedPtDeltaAxis2)*  pixelsPerLine;
        dy = CGEventGetDoubleValueField(cgEvent, kCGScrollWheelEventFixedPtDeltaAxis1)*  pixelsPerLine;
		CFRelease(source);
    } else {
        dx = CGEventGetIntegerValueField(cgEvent, kCGScrollWheelEventPointDeltaAxis2);
        dy = CGEventGetIntegerValueField(cgEvent, kCGScrollWheelEventPointDeltaAxis1);
    }
    return CGPointMake(-dx, -dy);
}

static BOOL TouchIsActiveGesture(UITouch* touch)
{
    return (touch.phase == _UITouchPhaseGestureBegan || touch.phase == _UITouchPhaseGestureChanged);
}

static BOOL TouchIsActiveNonGesture(UITouch* touch)
{
    return (touch.phase == UITouchPhaseBegan || touch.phase == UITouchPhaseMoved || touch.phase == UITouchPhaseStationary);
}


@implementation UIApplication {
    UIEvent* _currentEvent;
    NSMutableSet* _visibleWindows;
    BOOL _networkActivityIndicatorVisible;
    NSUInteger _ignoringInteractionEvents;
    NSDate* _backgroundTasksExpirationDate;
    NSMutableArray* _backgroundTasks;
}

#pragma mark Getting the Application Instance

+ (UIApplication*)  sharedApplication
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (!_theApplication) {
            _theApplication = [[UIApplication alloc] init];
        }
    });
    return _theApplication;
}


#pragma mark Getting Application Windows

- (NSArray*)  windows
{
    NSSortDescriptor* sort = [[NSSortDescriptor alloc] initWithKey:@"windowLevel" ascending:YES];
    return [[_visibleWindows valueForKey:@"nonretainedObjectValue"] sortedArrayUsingDescriptors:@[sort]];
}


#pragma mark Managing the Default Interface Orientations

- (NSUInteger) supportedInterfaceOrientationsForWindow:(UIWindow*)window
{
#warning implement -supportedInterfaceOrientationsForWindow:window
    UIKIT_STUB_W_RETURN(@"-supportedInterfaceOrientationsForWindow:");
}


#pragma mark Controlling and Handling Events

- (void) sendEvent:(UIEvent*) event
{
    for (UITouch* touch in [event allTouches]) {
        [touch.window sendEvent:event];
    }
}

- (BOOL) sendAction:(SEL)action to:(id)target from:(id)sender forEvent:(UIEvent*)event
{
    if (!target) {
        id responder = [_keyWindow _firstResponder] ?: sender;

        while (responder) {
            if ([responder respondsToSelector:action]) {
                target = responder;
                break;
            } else if ([responder respondsToSelector:@selector(nextResponder)]) {
                responder = [responder nextResponder];
            } else {
                responder = nil;
            }
        }
    }
    if (target) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
        [target performSelector:action withObject:sender withObject:event];
#pragma clang diagnostic pop
        return YES;
    } else {
        return NO;
    }
}

- (void) beginIgnoringInteractionEvents
{
    _ignoringInteractionEvents++;
}

- (void) endIgnoringInteractionEvents
{
    _ignoringInteractionEvents--;
}

- (BOOL) isIgnoringInteractionEvents
{
    return (_ignoringInteractionEvents > 0);
}


#pragma mark Opening a URL Resource

- (BOOL) openURL:(NSURL*) url
{
    return url? [[NSWorkspace sharedWorkspace] openURL:url] : NO;
}

- (BOOL) canOpenURL:(NSURL*) url
{
    return (url? [[NSWorkspace sharedWorkspace] URLForApplicationToOpenURL:url] : nil) != nil;
}


#pragma mark Registering for Remote Notifications

- (void) registerForRemoteNotificationTypes:(UIRemoteNotificationType)types
{
#warning implement -registerForRemoteNotificationTypes:
    UIKIT_STUB(@"-registerForRemoteNotificationTypes:");
}

- (void) unregisterForRemoteNotifications
{
#warning implement -unregisterForRemoteNotifications
    UIKIT_STUB(@"-unregisterForRemoteNotifications");
}

- (UIRemoteNotificationType) enabledRemoteNotificationTypes
{
#warning implement -enabledRemoteNotificationTypes
    UIKIT_STUB_W_RETURN(@"-enabledRemoteNotificationTypes");
}


#pragma mark Managing Background Execution

- (NSTimeInterval) backgroundTimeRemaining
{
    return [_backgroundTasksExpirationDate timeIntervalSinceNow];
}

- (UIBackgroundTaskIdentifier) beginBackgroundTaskWithExpirationHandler:(void(^)(void))handler
{
    UIBackgroundTask* task = [[UIBackgroundTask alloc] initWithExpirationHandler:handler];
    [_backgroundTasks addObject:task];
    return task.taskIdentifier;
}

- (void) endBackgroundTask:(UIBackgroundTaskIdentifier)identifier
{
    for (UIBackgroundTask* task in _backgroundTasks) {
        if (task.taskIdentifier == identifier) {
            [_backgroundTasks removeObject:task];
            break;
        }
    }
}

- (BOOL) setKeepAliveTimeout:(NSTimeInterval)timeout handler:(void(^)(void))keepAliveHandler
{
#warning implement -setKeepAliveTimeout:handler:
    UIKIT_STUB_W_RETURN(@"-setKeepAliveTimeout:handler:");
}

- (void) clearKeepAliveTimeout
{
#warning implement -clearKeepAliveTimeout
    UIKIT_STUB(@"-clearKeepAliveTimeout");
}


#pragma mark Performing State Restoration Asynchronously

- (void) extendStateRestoration
{
#warning implement -extendStateRestoration
    UIKIT_STUB(@"-extendStateRestoration");
}

- (void) completeStateRestoration
{
#warning implement -completeStateRestoration
    UIKIT_STUB(@"-completeStateRestoration");
}


#pragma mark Registering for Local Notifications

- (void) scheduleLocalNotification:(UILocalNotification*) notification
{
#warning implement -scheduleLocalNotification:
    UIKIT_STUB(@"-scheduleLocalNotification:");
}

- (void) presentLocalNotificationNow:(UILocalNotification*) notification
{
#warning implement -presentLocalNotificationNow:
    UIKIT_STUB(@"-presentLocalNotificationNow:");
}

- (void)cancelLocalNotification:(UILocalNotification*) notification
{
#warning implement -cancelLocalNotification:
    UIKIT_STUB(@"-cancelLocalNotification:");
}

- (void) cancelAllLocalNotifications
{
#warning implement -cancelAllLocalNotifications
    UIKIT_STUB(@"-cancelAllLocalNotifications");
}

- (NSArray*)  scheduledLocalNotifications
{
#warning implement -scheduledLocalNotifications
    UIKIT_STUB_W_RETURN(@"-scheduledLocalNotifications");
}

- (void) setScheduledLocalNotifications:(NSArray*)scheduledLocalNotifications
{
#warning implement -setScheduledLocalNotifications:
    UIKIT_STUB(@"-setScheduledLocalNotifications:");
}


#pragma mark Registering for Remote Control Events

- (void) beginReceivingRemoteControlEvents
{
#warning implement -beginReceivingRemoteControlEvents
    UIKIT_STUB(@"-beginReceivingRemoteControlEvents");
}

- (void) endReceivingRemoteControlEvents
{
#warning implement -endReceivingRemoteControlEvents
    UIKIT_STUB(@"-endReceivingRemoteControlEvents");
}


#pragma mark Managing Status Bar Orientation

- (void) setStatusBarOrientation:(UIInterfaceOrientation)interfaceOrientation animated:(BOOL)animated
{
#warning implement -setStatusBarOrientation:animated:
    UIKIT_STUB(@"-setStatusBarOrientation:animated:");
}

- (void) setStatusBarOrientation:(UIInterfaceOrientation)orientation
{
    #warning implement -setStatusBarOrientation:
    UIKIT_STUB(@"-setStatusBarOrientation:");
}

- (UIInterfaceOrientation) statusBarOrientation
{
#warning implement -statusBarOrientation
    UIKIT_STUB_W_RETURN(@"-statusBarOrientation");
}

- (NSTimeInterval) statusBarOrientationAnimationDuration
{
#warning implement -statusBarOrientationAnimationDuration
    UIKIT_STUB_W_RETURN(@"-statusBarOrientationAnimationDuration");
}


#pragma mark Controlling Application Appearance

- (void) setStatusBarHidden:(BOOL)hidden withAnimation:(UIStatusBarAnimation)animation
{
#warning implement -setStatusBarHidden:withAnimation:
    UIKIT_STUB(@"-setStatusBarHidden:withAnimation:");
}

- (BOOL) isStatusBarHidden
{
#warning implement -isStatusBarHidden
    UIKIT_STUB_W_RETURN(@"-isStatusBarHidden");
}

- (void) setStatusBarStyle:(UIStatusBarStyle)statusBarStyle animated:(BOOL)animated
{
#warning implement -setStatusBarStyle:animated:
    UIKIT_STUB(@"-setStatusBarStyle:animated:");
}

- (void) setStatusBarStyle:(UIStatusBarStyle)statusBarStyle
{
#warning implement -setStatusBarStyle:
    UIKIT_STUB(@"-setStatusBarStyle:");
}

- (UIStatusBarStyle) statusBarStyle
{
#warning implement -statusBarStyle
    UIKIT_STUB_W_RETURN(@"-statusBarStyle");
}

- (CGRect) statusBarFrame
{
#warning implement -statusBarFrame
    UIKIT_STUB(@"-statusBarFrame");
    return CGRectZero;
}

- (BOOL) isNetworkActivityIndicatorVisible
{
    return _networkActivityIndicatorVisible;
}

- (void) setNetworkActivityIndicatorVisible:(BOOL)b
{
    if (b != [self isNetworkActivityIndicatorVisible]) {
        _networkActivityIndicatorVisible = b;
        [[NSNotificationCenter defaultCenter] postNotificationName:UIApplicationNetworkActivityIndicatorChangedNotification object:self];
    }
}


#pragma mark Setting the Icon of a Newsstand Application

- (void) setNewsstandIconImage:(UIImage*)image
{
#warning implement -setNewsstandIconImage:
    UIKIT_STUB(@"-setNewsstandIconImage:");
}


#pragma mark UIApplication+AppKit

- (NSApplicationTerminateReply) terminateApplicationBeforeDate:(NSDate*)timeoutDate
{
    [self _enterBackground];
    if ([_backgroundTasks count] == 0) {
        return NSTerminateNow;
    }
    _backgroundTasksExpirationDate = timeoutDate;
    void (^taskFinisher)(void) = ^{

        if ([_backgroundTasks count] > 0) {
            NSAlert* alert = [[NSAlert alloc] init];
            [alert setAlertStyle:NSInformationalAlertStyle];
            [alert setShowsSuppressionButton:NO];
            [alert setMessageText:@"Quitting"];
            [alert setInformativeText:@"Finishing some tasks..."];
            [alert addButtonWithTitle:@"Quit Now"];
            [alert layout];
            NSModalSession session = [NSApp beginModalSessionForWindow:alert.window];
            while ([NSApp runModalSession:session] == NSRunContinuesResponse) {
                if (![self _runRunLoopForBackgroundTasksBeforeDate:[NSDate dateWithTimeIntervalSinceNow:1]]) {
                    break;
                }
            }
            [NSApp endModalSession:session];
        }
        [self _cancelBackgroundTasks];
        _backgroundTasksExpirationDate = nil;
        [NSApp replyToApplicationShouldTerminate:YES];
    };
    [self performSelectorOnMainThread:@selector(_runBackgroundTasks:)
                           withObject:[taskFinisher copy]
                        waitUntilDone:NO
                                modes:@[NSModalPanelRunLoopMode, NSRunLoopCommonModes]];
    return NSTerminateLater;
}


#pragma mark NSObject method overrides

- (id) init
{
    if ((self=[super init])) {
        _currentEvent = [[UIEvent alloc] initWithEventType:UIEventTypeTouches];
        [_currentEvent _setTouch:[[UITouch alloc] init]];
        _visibleWindows = [[NSMutableSet alloc] init];
        _backgroundTasks = [[NSMutableArray alloc] init];
        _applicationState = UIApplicationStateActive;
        _applicationSupportsShakeToEdit = YES;
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_applicationWillTerminate:) name:NSApplicationWillTerminateNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_applicationWillResignActive:) name:NSApplicationWillResignActiveNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_applicationDidBecomeActive:) name:NSApplicationDidBecomeActiveNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_applicationWillResignActive:) name:NSWorkspaceScreensDidSleepNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_applicationDidBecomeActive:) name:NSWorkspaceScreensDidWakeNotification object:nil];
        [[[NSWorkspace sharedWorkspace] notificationCenter] addObserver:self selector:@selector(_applicationWillResignActive:) name:NSWorkspaceScreensDidSleepNotification object:nil];
        [[[NSWorkspace sharedWorkspace] notificationCenter] addObserver:self selector:@selector(_applicationDidBecomeActive:) name:NSWorkspaceScreensDidWakeNotification object:nil];
        [[[NSWorkspace sharedWorkspace] notificationCenter] addObserver:self selector:@selector(_computerWillSleep:) name:NSWorkspaceWillSleepNotification object:nil];
        [[[NSWorkspace sharedWorkspace] notificationCenter] addObserver:self selector:@selector(_computerDidWakeUp:) name:NSWorkspaceDidWakeNotification object:nil];
    }
    return self;
}

- (void) dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [[[NSWorkspace sharedWorkspace] notificationCenter] removeObserver:self];
}


#pragma mark UIResponder method overrides

- (UIResponder*) nextResponder
{
    return _delegate;
}


#pragma mark private methods

- (void) _applicationDidBecomeActive:(NSNotification*)note
{
    if (self.applicationState == UIApplicationStateInactive) {
        _applicationState = UIApplicationStateActive;
        if ([_delegate respondsToSelector:@selector(applicationDidBecomeActive:)]) {
            [_delegate applicationDidBecomeActive:self];
        }
        [[NSNotificationCenter defaultCenter] postNotificationName:UIApplicationDidBecomeActiveNotification object:self];
    }
}

- (void) _applicationWillResignActive:(NSNotification*)note
{
    if (self.applicationState == UIApplicationStateActive) {
        if ([_delegate respondsToSelector:@selector(applicationWillResignActive:)]) {
            [_delegate applicationWillResignActive:self];
        }
        [[NSNotificationCenter defaultCenter] postNotificationName:UIApplicationWillResignActiveNotification object:self];
        _applicationState = UIApplicationStateInactive;
    }
}

- (void) _applicationWillTerminate:(NSNotification*)note
{
    if ([_delegate respondsToSelector:@selector(applicationWillTerminate:)]) {
        [_delegate applicationWillTerminate:self];
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:UIApplicationWillTerminateNotification object:self];
}

- (void) _cancelBackgroundTasks
{
    for (UIBackgroundTask* task in [_backgroundTasks copy]) {
        if (task.expirationHandler) {
            task.expirationHandler();
        }
    }
    [_backgroundTasks removeAllObjects];
}

- (void) _cancelTouches
{
    UITouch* touch = [[_currentEvent allTouches] anyObject];
    const BOOL wasActiveTouch = TouchIsActive(touch);
    [touch _setTouchPhaseCancelled];
    if (wasActiveTouch) {
        [self sendEvent:_currentEvent];
    }
}

- (void) _computerDidWakeUp:(NSNotification*)note
{
    [self _enterForeground];
}

- (void) _computerWillSleep:(NSNotification*)note
{
    if ([self _enterBackground]) {
        _backgroundTasksExpirationDate = [[NSDate alloc] initWithTimeIntervalSinceNow:29];
        for (;;) {
            if (![self _runRunLoopForBackgroundTasksBeforeDate:_backgroundTasksExpirationDate]) {
                break;
            }
        }
        [self _cancelBackgroundTasks];
        _backgroundTasksExpirationDate = nil;
    }
}

- (BOOL) _enterBackground
{
    if (self.applicationState != UIApplicationStateBackground) {
        _applicationState = UIApplicationStateBackground;
        if ([_delegate respondsToSelector:@selector(applicationDidEnterBackground:)]) {
            [_delegate applicationDidEnterBackground:self];
        }
        [[NSNotificationCenter defaultCenter] postNotificationName:UIApplicationDidEnterBackgroundNotification object:self];
        return YES;
    } else {
        return NO;
    }
}

- (void) _enterForeground
{
    if (self.applicationState == UIApplicationStateBackground) {
        if ([_delegate respondsToSelector:@selector(applicationWillEnterForeground:)]) {
            [_delegate applicationWillEnterForeground:self];
        }
        [[NSNotificationCenter defaultCenter] postNotificationName:UIApplicationWillEnterForegroundNotification object:self];
        _applicationState = UIApplicationStateInactive;
    }
}

- (BOOL) _firstResponderCanPerformAction:(SEL)action withSender:(id)sender fromScreen:(UIScreen*)theScreen
{
    return [[self _firstResponderForScreen:theScreen] canPerformAction:action withSender:sender];
}

- (UIResponder*)  _firstResponderForScreen:(UIScreen*)screen
{
    if (_keyWindow.screen == screen) {
        return [_keyWindow _firstResponder];
    } else {
        return self;
    }
}

- (void) _removeViewFromTouches:(UIView*)aView
{
    for (UITouch* touch in [_currentEvent allTouches]) {
        if (touch.view == aView) {
            [touch _removeFromView];
        }
    }
}

- (void) _runBackgroundTasks:(void(^)(void))run_tasks
{
    run_tasks();
}

- (BOOL) _runRunLoopForBackgroundTasksBeforeDate:(NSDate*)date
{
    if ([_backgroundTasks count] == 0) {
        return NO;
    }
    [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:date];
    if ([[NSDate date] timeIntervalSinceReferenceDate] >= [_backgroundTasksExpirationDate timeIntervalSinceReferenceDate]) {
        return NO;
    }
    return YES;
}

- (BOOL) _sendActionToFirstResponder:(SEL)action withSender:(id)sender fromScreen:(UIScreen*)theScreen
{
    UIResponder* responder = [self _firstResponderForScreen:theScreen];
    while (responder) {
        if ([responder respondsToSelector:action]) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
            [responder performSelector:action withObject:sender];
#pragma clang diagnostic pop
            return YES;
        } else {
            responder = [responder nextResponder];
        }
    }
    return NO;
}

- (BOOL) _sendGlobalKeyboardNSEvent:(NSEvent*) theNSEvent fromScreen:(UIScreen*)theScreen
{
    if ([self isIgnoringInteractionEvents]) {
        return YES;
    }
    UIKey* key = [[UIKey alloc] initWithNSEvent:theNSEvent];
    if (key.type == UIKeyTypeEnter || (key.commandKeyPressed && key.type == UIKeyTypeReturn)) {
        if ([self _firstResponderCanPerformAction:@selector(commit:) withSender:key fromScreen:theScreen]) {
            return [self _sendActionToFirstResponder:@selector(commit:) withSender:key fromScreen:theScreen];
        }
    }
    return NO;
}

- (BOOL) _sendKeyboardNSEvent:(NSEvent*) theNSEvent fromScreen:(UIScreen*)theScreen
{
    if ([self isIgnoringInteractionEvents]) {
        return YES;
    }
    if (![self _sendGlobalKeyboardNSEvent:theNSEvent fromScreen:theScreen]) {
        UIResponder* firstResponder = [self _firstResponderForScreen:theScreen];

        if (firstResponder) {
            UIKey* key = [[UIKey alloc] initWithNSEvent:theNSEvent];
            UIEvent* event = [[UIEvent alloc] initWithEventType:UIEventTypeKeyPress];
            [event _setTimestamp:[theNSEvent timestamp]];
            return [firstResponder keyPressed:key withEvent:event];
        }
    }
    return NO;
}

- (void) _sendMouseNSEvent:(NSEvent*) theNSEvent fromScreen:(UIScreen*)theScreen
{
    UITouch* touch = [[_currentEvent allTouches] anyObject];
    [_currentEvent _setTimestamp:[theNSEvent timestamp]];
    const NSTimeInterval timestamp = [theNSEvent timestamp];
    const CGPoint screenLocation = [theNSEvent locationInScreen:theScreen];
    if (TouchIsActiveGesture(touch) && ([theNSEvent type] == NSLeftMouseDown || [theNSEvent type] == NSRightMouseDown)) {
        [touch _updatePhase:_UITouchPhaseGestureEnded screenLocation:screenLocation timestamp:timestamp];
        [self sendEvent:_currentEvent];
    } else if (TouchIsActiveNonGesture(touch)) {
        switch ([theNSEvent type]) {
            case NSLeftMouseUp:
                [touch _updatePhase:UITouchPhaseEnded screenLocation:screenLocation timestamp:timestamp];
                [self sendEvent:_currentEvent];
                break;
            case NSLeftMouseDragged:
                [touch _updatePhase:UITouchPhaseMoved screenLocation:screenLocation timestamp:timestamp];
                [self sendEvent:_currentEvent];
                break;
        }
    } else if (TouchIsActiveGesture(touch)) {
        switch ([theNSEvent type]) {
            case NSEventTypeEndGesture:
                [touch _updatePhase:_UITouchPhaseGestureEnded screenLocation:screenLocation timestamp:timestamp];
                [self sendEvent:_currentEvent];
                break;
            case NSScrollWheel:
                [touch _updateGesture:_UITouchGesturePan screenLocation:screenLocation delta:ScrollDeltaFromNSEvent(theNSEvent) rotation:0 magnification:0 timestamp:timestamp];
                [self sendEvent:_currentEvent];
                break;
            case NSEventTypeMagnify:
                [touch _updateGesture:_UITouchGesturePinch screenLocation:screenLocation delta:CGPointZero rotation:0 magnification:[theNSEvent magnification] timestamp:timestamp];
                [self sendEvent:_currentEvent];
                break;
            case NSEventTypeRotate:
                [touch _updateGesture:_UITouchGestureRotation screenLocation:screenLocation delta:CGPointZero rotation:[theNSEvent rotation] magnification:0 timestamp:timestamp];
                [self sendEvent:_currentEvent];
                break;
            case NSEventTypeSwipe:
                [touch _updateGesture:_UITouchGestureSwipe screenLocation:screenLocation delta:ScrollDeltaFromNSEvent(theNSEvent) rotation:0 magnification:0 timestamp:timestamp];
                [self sendEvent:_currentEvent];
                break;
        }
    } else if (![self isIgnoringInteractionEvents]) {
        switch ([theNSEvent type]) {
            case NSLeftMouseDown:
                if ([theNSEvent modifierFlags] & NSControlKeyMask) {
                    [touch _setDiscreteGesture:_UITouchDiscreteGestureRightClick screenLocation:screenLocation tapCount:[theNSEvent clickCount] delta:CGPointZero timestamp:timestamp];
                } else {
                    [touch _setPhase:UITouchPhaseBegan screenLocation:screenLocation tapCount:[theNSEvent clickCount] timestamp:timestamp];
                }
                [self _setCurrentEventTouchedViewWithNSEvent:theNSEvent fromScreen:theScreen];
                [self sendEvent:_currentEvent];
                break;
            case NSEventTypeBeginGesture:
                [touch _setPhase:_UITouchPhaseGestureBegan screenLocation:screenLocation tapCount:0 timestamp:timestamp];
                [self _setCurrentEventTouchedViewWithNSEvent:theNSEvent fromScreen:theScreen];
                [self sendEvent:_currentEvent];
                break;
            case NSScrollWheel:
                [touch _setDiscreteGesture:_UITouchDiscreteGestureScrollWheel screenLocation:screenLocation tapCount:0 delta:ScrollDeltaFromNSEvent(theNSEvent) timestamp:timestamp];
                [self _setCurrentEventTouchedViewWithNSEvent:theNSEvent fromScreen:theScreen];
                [self sendEvent:_currentEvent];
                break;
            case NSRightMouseDown:
                [touch _setDiscreteGesture:_UITouchDiscreteGestureRightClick screenLocation:screenLocation tapCount:[theNSEvent clickCount] delta:CGPointZero timestamp:timestamp];
                [self _setCurrentEventTouchedViewWithNSEvent:theNSEvent fromScreen:theScreen];
                [self sendEvent:_currentEvent];
                break;
            case NSMouseMoved:
            case NSMouseEntered:
            case NSMouseExited:
                [touch _setDiscreteGesture:_UITouchDiscreteGestureMouseMove screenLocation:screenLocation tapCount:0 delta:ScrollDeltaFromNSEvent(theNSEvent) timestamp:timestamp];
                [self _setCurrentEventTouchedViewWithNSEvent:theNSEvent fromScreen:theScreen];
                [self sendEvent:_currentEvent];
                break;
        }
    }
}

- (void) _setCurrentEventTouchedViewWithNSEvent:(NSEvent*) theNSEvent fromScreen:(UIScreen*)theScreen
{
    const CGPoint screenLocation = [theNSEvent locationInScreen:theScreen];
    UITouch* touch = [[_currentEvent allTouches] anyObject];
    UIView* previousView = touch.view;
    [touch _setTouchedView:[theScreen _hitTest:screenLocation event:_currentEvent]];
    if (touch.view != previousView) {
        [previousView mouseExitedView:previousView enteredView:touch.view withEvent:_currentEvent];
        [touch.view mouseExitedView:previousView enteredView:touch.view withEvent:_currentEvent];
    }
}

- (void) _setKeyWindow:(UIWindow*)newKeyWindow
{
    _keyWindow = newKeyWindow;
}

static BOOL TouchIsActive(UITouch* touch)
{
    return TouchIsActiveGesture(touch) || TouchIsActiveNonGesture(touch);
}

- (void) _windowDidBecomeHidden:(UIWindow*)theWindow
{
    if (theWindow == _keyWindow) [self _setKeyWindow:nil];
    [_visibleWindows removeObject:[NSValue valueWithNonretainedObject:theWindow]];
}

- (void) _windowDidBecomeVisible:(UIWindow*)theWindow
{
    [_visibleWindows addObject:[NSValue valueWithNonretainedObject:theWindow]];
}

@end


@implementation UIApplication(UIApplicationDeprecated)

- (void)setStatusBarHidden:(BOOL)hidden animated:(BOOL)animated
{
}

@end
