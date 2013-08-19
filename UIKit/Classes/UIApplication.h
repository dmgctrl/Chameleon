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

#import <UIKit/UIResponder.h>
#import <UIKit/UIDevice.h>
#import <UIKit/UIApplicationDelegate.h>

#pragma mark Constants

typedef enum {
    UIInterfaceOrientationPortrait           = UIDeviceOrientationPortrait,
    UIInterfaceOrientationPortraitUpsideDown = UIDeviceOrientationPortraitUpsideDown,
    UIInterfaceOrientationLandscapeLeft      = UIDeviceOrientationLandscapeRight,
    UIInterfaceOrientationLandscapeRight     = UIDeviceOrientationLandscapeLeft
} UIInterfaceOrientation;

typedef enum {
    UIInterfaceOrientationMaskPortrait = (1 << UIInterfaceOrientationPortrait),
    UIInterfaceOrientationMaskLandscapeLeft = (1 << UIInterfaceOrientationLandscapeLeft),
    UIInterfaceOrientationMaskLandscapeRight = (1 << UIInterfaceOrientationLandscapeRight),
    UIInterfaceOrientationMaskPortraitUpsideDown = (1 << UIInterfaceOrientationPortraitUpsideDown),
    UIInterfaceOrientationMaskLandscape =
    (UIInterfaceOrientationMaskLandscapeLeft | UIInterfaceOrientationMaskLandscapeRight),
    UIInterfaceOrientationMaskAll =
    (UIInterfaceOrientationMaskPortrait | UIInterfaceOrientationMaskLandscapeLeft |
     UIInterfaceOrientationMaskLandscapeRight | UIInterfaceOrientationMaskPortraitUpsideDown),
    UIInterfaceOrientationMaskAllButUpsideDown =
    (UIInterfaceOrientationMaskPortrait | UIInterfaceOrientationMaskLandscapeLeft |
     UIInterfaceOrientationMaskLandscapeRight),
} UIInterfaceOrientationMask;

typedef enum {
    UIUserInterfaceLayoutDirectionLeftToRight,
    UIUserInterfaceLayoutDirectionRightToLeft,
} UIUserInterfaceLayoutDirection;

typedef enum {
    UIStatusBarStyleDefault,
    UIStatusBarStyleBlackTranslucent,
    UIStatusBarStyleBlackOpaque
} UIStatusBarStyle;

typedef enum {
    UIStatusBarAnimationNone,
    UIStatusBarAnimationFade,
    UIStatusBarAnimationSlide,
} UIStatusBarAnimation;

NSString* const UITrackingRunLoopMode;
NSString* const UIApplicationStatusBarOrientationUserInfoKey;
NSString* const UIApplicationStatusBarFrameUserInfoKey;

typedef enum {
    UIRemoteNotificationTypeNone    = 0,
    UIRemoteNotificationTypeBadge   = 1 << 0,
    UIRemoteNotificationTypeSound   = 1 << 1,
    UIRemoteNotificationTypeAlert   = 1 << 2,
    UIRemoteNotificationTypeNewsstandContentAvailability = 1 << 3
} UIRemoteNotificationType;

typedef NSUInteger UIBackgroundTaskIdentifier;

UIKIT_EXTERN const UIBackgroundTaskIdentifier UIBackgroundTaskInvalid;
UIKIT_EXTERN const NSTimeInterval UIMinimumKeepAliveTimeout;

// whenever the NSApplication is no longer "active" from OSX's point of view, your UIApplication instance
// will switch to UIApplicationStateInactive. This happens when the app is no longer in the foreground, for instance.
// chameleon will also switch to the inactive state when the screen is put to sleep due to power saving mode.
// when the screen wakes up or the app is brought to the foreground, it is switched back to UIApplicationStateActive.
//
// UIApplicationStateBackground is now supported and your app will transition to this state in two possible ways.
// one is when the AppKitIntegration method -terminateApplicationBeforeDate: is called. that method is intended to be
// used when your NSApplicationDelegate is being asked to terminate. the application is also switched to
// UIApplicationStateBackground when the machine is put to sleep. when the machine is reawakened, it will transition
// back to UIApplicationStateInactive (as per the UIKit docs). The OS tends to reactive the app in the usual way if
// it happened to be the foreground app when the machine was put to sleep, so it should ultimately work out as expected.
//
// any registered background tasks are allowed to complete whenever the app switches into UIApplicationStateBackground
// mode, so that means that when -terminateApplicationBeforeDate: is called directly, we will wait on background tasks
// and also show an alert to the user letting them know what's happening. it also means we attempt to delay machine
// sleep whenever sleep is initiated for as long as we can until any pending background tasks are completed. (there is no
// alert in that case) this should allow your app time to do any of the usual things like sync with network services or
// save state. just as on iOS, there's no guarentee you'll have time to complete you background task and there's no
// guarentee that your expiration handler will even be called. additionally, the reliability of your network is certainly
// going to be suspect when entering sleep as well. so be aware - but basically these same constraints exist on iOS so
// in many respects it shouldn't affect your code much or at all.
typedef enum {
    UIApplicationStateActive,
    UIApplicationStateInactive,
    UIApplicationStateBackground
} UIApplicationState;

UIKIT_EXTERN NSString* const UIApplicationInvalidInterfaceOrientationException;
UIKIT_EXTERN NSString* const UIApplicationDidBecomeActiveNotification;
UIKIT_EXTERN NSString* const UIApplicationDidChangeStatusBarFrameNotification;
UIKIT_EXTERN NSString* const UIApplicationDidChangeStatusBarOrientationNotification;
UIKIT_EXTERN NSString* const UIApplicationDidEnterBackgroundNotification;
UIKIT_EXTERN NSString* const UIApplicationDidFinishLaunchingNotification;
UIKIT_EXTERN NSString* const UIApplicationLaunchOptionsURLKey;
UIKIT_EXTERN NSString* const UIApplicationLaunchOptionsSourceApplicationKey;
UIKIT_EXTERN NSString* const UIApplicationLaunchOptionsRemoteNotificationKey;
UIKIT_EXTERN NSString* const UIApplicationLaunchOptionsLocalNotificationKey;
UIKIT_EXTERN NSString* const UIApplicationDidReceiveMemoryWarningNotification;
UIKIT_EXTERN NSString* const UIApplicationProtectedDataDidBecomeAvailable;
UIKIT_EXTERN NSString* const UIApplicationProtectedDataWillBecomeUnavailable;
UIKIT_EXTERN NSString* const UIApplicationSignificantTimeChangeNotification;
UIKIT_EXTERN NSString* const UIApplicationWillChangeStatusBarOrientationNotification;
UIKIT_EXTERN NSString* const UIApplicationWillChangeStatusBarFrameNotification;
UIKIT_EXTERN NSString* const UIApplicationWillEnterForegroundNotification;
UIKIT_EXTERN NSString* const UIApplicationWillResignActiveNotification;
UIKIT_EXTERN NSString* const UIApplicationWillTerminateNotification;
UIKIT_EXTERN NSString* const UIApplicationLaunchOptionsAnnotationKey;
UIKIT_EXTERN NSString* const UIApplicationLaunchOptionsLocationKey;

#define UIInterfaceOrientationIsPortrait(orientation) \
((orientation) == UIInterfaceOrientationPortrait || \
(orientation) == UIInterfaceOrientationPortraitUpsideDown)

#define UIInterfaceOrientationIsLandscape(orientation) \
((orientation) == UIInterfaceOrientationLandscapeLeft || \
(orientation) == UIInterfaceOrientationLandscapeRight)


@class UIWindow;
@class UIApplication;
@class UILocalNotification;
@class UIImage;

@interface UIApplication : UIResponder


#pragma mark Getting the Application Instance

+ (UIApplication*) sharedApplication;


#pragma mark Setting and Getting the Delegate

@property (nonatomic, assign) id<UIApplicationDelegate> delegate;


#pragma mark Getting Application Windows

@property (assign, nonatomic, readonly) UIWindow* keyWindow;
@property (assign, nonatomic, readonly) NSArray* windows;


#pragma mark Managing the Default Interface Orientations

- (NSUInteger) supportedInterfaceOrientationsForWindow:(UIWindow*)window;


#pragma mark Controlling and Handling Events

- (void) sendEvent:(UIEvent*)event;
- (BOOL) sendAction:(SEL)action to:(id)target from:(id)sender forEvent:(UIEvent*)event;
- (void) beginIgnoringInteractionEvents;
- (void) endIgnoringInteractionEvents;
- (BOOL) isIgnoringInteractionEvents;
@property (nonatomic) BOOL applicationSupportsShakeToEdit;


#pragma mark Registering for Remote Notifications
- (void) registerForRemoteNotificationTypes:(UIRemoteNotificationType)types;
- (void) unregisterForRemoteNotifications;
- (UIRemoteNotificationType) enabledRemoteNotificationTypes;


#pragma mark Opening a URL Resource

- (BOOL) openURL:(NSURL*)url;
- (BOOL) canOpenURL:(NSURL*)URL;


#pragma mark Managing Application Activity

@property (nonatomic, getter=isIdleTimerDisabled) BOOL idleTimerDisabled;


#pragma mark Managing Background Execution

@property (nonatomic, readonly) UIApplicationState applicationState;
@property (nonatomic, readonly) NSTimeInterval backgroundTimeRemaining;
- (UIBackgroundTaskIdentifier) beginBackgroundTaskWithExpirationHandler:(void (^)(void))handler;
- (void) endBackgroundTask:(UIBackgroundTaskIdentifier)identifier;
- (BOOL) setKeepAliveTimeout:(NSTimeInterval)timeout handler:(void (^)(void))keepAliveHandler;
- (void) clearKeepAliveTimeout;


#pragma mark Performing State Restoration Asynchronously

- (void) extendStateRestoration;
- (void) completeStateRestoration;


#pragma mark Registering for Local Notifications

- (void) scheduleLocalNotification:(UILocalNotification*)notification;
- (void) presentLocalNotificationNow:(UILocalNotification*)notification;
- (void) cancelLocalNotification:(UILocalNotification*)notification;
- (void) cancelAllLocalNotifications;
@property (nonatomic, copy) NSArray* scheduledLocalNotifications;


#pragma mark Determining the Availability of Protected Content

@property (nonatomic, readonly, getter=isProtectedDataAvailable) BOOL protectedDataAvailable;


#pragma mark Registering for Remote Control Events

- (void) beginReceivingRemoteControlEvents;
- (void) endReceivingRemoteControlEvents;


#pragma mark Managing Status Bar Orientation

- (void) setStatusBarOrientation:(UIInterfaceOrientation)interfaceOrientation animated:(BOOL)animated;
@property (nonatomic) UIInterfaceOrientation statusBarOrientation;
@property (nonatomic, readonly) NSTimeInterval statusBarOrientationAnimationDuration;


#pragma mark Controlling Application Appearance

- (void) setStatusBarHidden:(BOOL)hidden withAnimation:(UIStatusBarAnimation)animation;
@property (nonatomic, getter=isStatusBarHidden) BOOL statusBarHidden;
- (void) setStatusBarStyle:(UIStatusBarStyle)statusBarStyle animated:(BOOL)animated;
@property (nonatomic) UIStatusBarStyle statusBarStyle;
@property (nonatomic, readonly) CGRect statusBarFrame;
@property (nonatomic, getter=isNetworkActivityIndicatorVisible) BOOL networkActivityIndicatorVisible;
@property (nonatomic) NSInteger applicationIconBadgeNumber;
@property (nonatomic, readonly) UIUserInterfaceLayoutDirection userInterfaceLayoutDirection;


#pragma mark Setting the Icon of a Newsstand Application

- (void) setNewsstandIconImage:(UIImage*)image;

@end


@interface UIApplication(UIApplicationDeprecated)
- (void)setStatusBarHidden:(BOOL)hidden animated:(BOOL)animated __attribute__((deprecated)); // use -setStatusBarHidden:withAnimation:
@end


UIKIT_EXTERN int UIApplicationMain(int argc, char* argv[], NSString* principalClassName, NSString* delegateClassName);

