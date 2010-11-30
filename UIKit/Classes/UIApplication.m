//  Created by Sean Heber on 5/28/10.
#import "UIApplication+UIPrivate.h"
#import "UIScreen+UIPrivate.h"
#import "UIScreenAppKitIntegration.h"
#import "UIKitView.h"
#import "UIEvent.h"
#import "UITouch+UIPrivate.h"
#import "UIWindow.h"
#import "UIPopoverController+UIPrivate.h"
#import "UIResponderAppKitIntegration.h"
#import <Cocoa/Cocoa.h>

NSString *const UIApplicationWillChangeStatusBarOrientationNotification = @"UIApplicationWillChangeStatusBarOrientationNotification";
NSString *const UIApplicationDidChangeStatusBarOrientationNotification = @"UIApplicationDidChangeStatusBarOrientationNotification";
NSString *const UIApplicationWillEnterForegroundNotification = @"UIApplicationWillEnterForegroundNotification";
NSString *const UIApplicationWillTerminateNotification = @"UIApplicationWillTerminateNotification";
NSString *const UIApplicationWillResignActiveNotification = @"UIApplicationWillResignActiveNotification";
NSString *const UIApplicationDidEnterBackgroundNotification = @"UIApplicationDidEnterBackgroundNotification";
NSString *const UIApplicationDidBecomeActiveNotification = @"UIApplicationDidBecomeActiveNotification";
NSString *const UIApplicationDidFinishLaunchingNotification = @"UIApplicationDidFinishLaunchingNotification";

NSString *const UIApplicationLaunchOptionsURLKey = @"UIApplicationLaunchOptionsURLKey";
NSString *const UIApplicationLaunchOptionsSourceApplicationKey = @"UIApplicationLaunchOptionsSourceApplicationKey";
NSString *const UIApplicationLaunchOptionsRemoteNotificationKey = @"UIApplicationLaunchOptionsRemoteNotificationKey";
NSString *const UIApplicationLaunchOptionsAnnotationKey = @"UIApplicationLaunchOptionsAnnotationKey";
NSString *const UIApplicationLaunchOptionsLocalNotificationKey = @"UIApplicationLaunchOptionsLocalNotificationKey";
NSString *const UIApplicationLaunchOptionsLocationKey = @"UIApplicationLaunchOptionsLocationKey";

NSString *const UITrackingRunLoopMode = @"UITrackingRunLoopMode";

static UIApplication *_theApplication = nil;

static CGPoint ScreenLocationFromNSEvent(UIScreen *theScreen, NSEvent *theNSEvent)
{
	CGPoint screenLocation = NSPointToCGPoint([[theScreen UIKitView] convertPoint:[theNSEvent locationInWindow] fromView:nil]);
	if (![[theScreen UIKitView] isFlipped]) {
		// the y coord from the NSView might be inverted
		screenLocation.y = theScreen.bounds.size.height - screenLocation.y - 1;
	}
	return screenLocation;
}

static BOOL TouchIsActive(UITouch *touch)
{
	return (touch.phase == UITouchPhaseBegan || touch.phase == UITouchPhaseMoved || touch.phase == UITouchPhaseStationary);
}

@implementation UIApplication
@synthesize keyWindow=_keyWindow, delegate=_delegate, idleTimerDisabled=_idleTimerDisabled;

+ (void)initialize
{
	if (self == [UIApplication class]) {
		_theApplication = [[UIApplication alloc] init];
	}
}

+ (UIApplication *)sharedApplication
{
	return _theApplication;
}

- (id)init
{
	if ((self=[super init])) {
		_currentEvent = [[UIEvent alloc] init];
		_visibleWindows = [[NSMutableSet alloc] init];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_applicationWillTerminate:) name:NSApplicationWillTerminateNotification object:nil];
	}
	return self;
}

- (void)dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	[_currentEvent release];
	[_visibleWindows release];
	[super dealloc];
}

- (NSTimeInterval)statusBarOrientationAnimationDuration
{
	return 0.3;
}

- (BOOL)isStatusBarHidden
{
	return YES;
}

- (BOOL)isNetworkActivityIndicatorVisible
{
	return NO;  // lies!
}

- (void)setNetworkActivityIndicatorVisible:(BOOL)b
{
	// nothing!
}

- (void)beginIgnoringInteractionEvents
{
}

- (void)endIgnoringInteractionEvents
{
}

- (UIInterfaceOrientation)statusBarOrientation
{
	return UIInterfaceOrientationPortrait;
}

- (void)setStatusBarOrientation:(UIInterfaceOrientation)orientation
{
}

- (void)_setKeyWindow:(UIWindow *)newKeyWindow
{
	_keyWindow = newKeyWindow;
}

- (void)_windowDidBecomeVisible:(UIWindow *)theWindow
{
	[_visibleWindows addObject:[NSValue valueWithNonretainedObject:theWindow]];
}

- (void)_windowDidBecomeHidden:(UIWindow *)theWindow
{
	if (theWindow == _keyWindow) [self _setKeyWindow:nil];
	[_visibleWindows removeObject:[NSValue valueWithNonretainedObject:theWindow]];
}

- (NSArray *)windows
{
	NSSortDescriptor *sort = [[[NSSortDescriptor alloc] initWithKey:@"windowLevel" ascending:YES] autorelease];
	return [[_visibleWindows valueForKey:@"nonretainedObjectValue"] sortedArrayUsingDescriptors:[NSArray arrayWithObject:sort]];
}

- (BOOL)sendAction:(SEL)action to:(id)target from:(id)sender forEvent:(UIEvent *)event
{
	if (!target) {
		// The docs say this method will start with the first responder if target==nil. Initially I thought this meant that there was always a given
		// or set first responder (attached to the window, probably). However it doesn't appear that is the case. Instead it seems UIKit is perfectly
		// happy to function without ever having any UIResponder having had a becomeFirstResponder sent to it. This method seems to work by starting
		// with sender and traveling down the responder chain from there if target==nil. The first object that responds to the given action is sent
		// the message. (or no one is)
		
		// My confusion comes from the fact that motion events and keyboard events are supposed to start with the first responder - but what is that
		// if none was ever set? Apparently the answer is, if none were set, the message doesn't get delivered. If you expicitly set a UIResponder
		// using becomeFirstResponder, then it will receive keyboard/motion events but it does not receive any other messages from other views that
		// happen to end up calling this method with a nil target. So that's a seperate mechanism and I think it's confused a bit in the docs.
		
		// It seems that the reality of message delivery to "first responder" is that it depends a bit on the source. If the source is an external
		// event like motion or keyboard, then there has to have been an explicitly set first responder (by way of becomeFirstResponder) in order for
		// those events to even get delivered at all. If there is no responder defined, the action is simply never sent and thus never received.
		// This is entirely independent of what "first responder" means in the context of a UIControl. Instead, for a UIControl, the first responder
		// is the first UIResponder (including the UIControl itself) that responds to the action. It starts with the UIControl (sender) and not with
		// whatever UIResponder may have been set with becomeFirstResponder.
		
		id responder = sender;
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
		[target performSelector:action withObject:sender withObject:event];
		return YES;
	} else {
		return NO;
	}
}

- (void)sendEvent:(UIEvent *)event
{
	for (UITouch *touch in [event allTouches]) {
		[touch.window sendEvent:event];
	}
}

- (BOOL)openURL:(NSURL *)url
{
	return [[NSWorkspace sharedWorkspace] openURL:url];
}

- (void)_screen:(UIScreen *)theScreen didReceiveNSEvent:(NSEvent *)theNSEvent
{
	UITouch *touch = [[_currentEvent allTouches] anyObject];
	BOOL isSupportedEvent = YES;

	const CGPoint screenLocation = ScreenLocationFromNSEvent(theScreen, theNSEvent);
	const NSTimeInterval timestamp = [theNSEvent timestamp];
	const CGPoint delta = CGPointMake([theNSEvent deltaX], [theNSEvent deltaY]);

	if (TouchIsActive(touch)) {
		switch ([theNSEvent type]) {
			case NSLeftMouseUp:
				[touch _setPhase:UITouchPhaseEnded screenLocation:screenLocation tapCount:touch.tapCount delta:delta timestamp:timestamp];
				break;
				
			case NSLeftMouseDragged:
				[touch _setPhase:UITouchPhaseMoved screenLocation:screenLocation tapCount:touch.tapCount delta:delta timestamp:timestamp];
				break;
				
			default:
				[touch _setPhase:UITouchPhaseStationary screenLocation:screenLocation tapCount:touch.tapCount delta:delta timestamp:timestamp];
				break;
		}
	} else {
		switch ([theNSEvent type]) {
			case NSLeftMouseDown:
				[touch _setPhase:UITouchPhaseBegan screenLocation:screenLocation tapCount:[theNSEvent clickCount] delta:delta timestamp:timestamp];
				break;
				
			case NSScrollWheel:
				[touch _setPhase:UITouchPhaseScrolled screenLocation:screenLocation tapCount:0 delta:delta timestamp:timestamp];
				break;
				
			case NSMouseMoved:
			case NSMouseEntered:
			case NSMouseExited:
				[touch _setPhase:UITouchPhaseHovered screenLocation:screenLocation tapCount:0 delta:delta timestamp:timestamp];
				break;
				
			case NSRightMouseDown:
				[touch _setPhase:UITouchPhaseRightClicked screenLocation:screenLocation tapCount:1 delta:delta timestamp:timestamp];
				break;
				
			default:
				isSupportedEvent = NO;
				break;
		}
		
		// handle mouse enter/exit view changes as well as setting the new view for the touch
		if (isSupportedEvent) {
			UIView *previousView = [touch.view retain];
			[touch _setView:[theScreen _hitTest:screenLocation event:_currentEvent]];

			if (touch.view != previousView) {
				[previousView mouseExitedView:previousView enteredView:touch.view withEvent:_currentEvent];
				[touch.view mouseExitedView:previousView enteredView:touch.view withEvent:_currentEvent];
			}
			
			[previousView release];
		}
	}
	
	if (isSupportedEvent) {
		[self sendEvent:_currentEvent];
	}
}

// this is used to cause an interruption/cancel of the current touch.
// (1) if aView is nil, it sends a mouse exit event to the last touched view, and sends a touch cancelled event if there was an "active" touch.
// (2) if aView is NOT nil, no event is sent, but if the last touched view is a decendant of aView, the touch is marked cancelled.
// Use (1) is for when a modal UI element appears (such as a native popup menu), or when a UIPopoverController appears. It seems to make the most sense
// to call _cancelTouchesInView: *after* the modal menu has been dismissed, as this causes UI elements to remain in their "pushed" state while the menu
// is being displayed. If that behavior isn't desired, the simple solution is to present the menu from touchesEnded: instead of touchesBegan:.
// Use (2) is specifically for when a UIView is removed from its superview. This case aborts touch handling if the view being removed is a part of
// the currently active touch. The real UIKit also aborts an active touch in this situation and no cancel events are ever sent as far as I can tell - it
// just seems to abort the whole thing immediately. If the removed view has nothing to do with the current touch event, nothing happens.
- (void)_cancelTouchesInView:(UIView *)aView
{
	UITouch *touch = [[_currentEvent allTouches] anyObject];
	UIView *touchedView = touch.view;
	const BOOL shouldCancelTouch = (!aView || [touchedView isDescendantOfView:aView]);
	
	if (shouldCancelTouch) {
		const BOOL wasActiveTouch = TouchIsActive(touch);

		[touch _setTouchPhaseCancelled];
		
		if (!aView && wasActiveTouch) {
			[self sendEvent:_currentEvent];
		}
	}
}

- (void)_applicationWillTerminate:(NSNotification *)note
{
	if ([_delegate respondsToSelector:@selector(applicationWillTerminate:)]) {
		[_delegate applicationWillTerminate:self];
	}
	
	[[NSNotificationCenter defaultCenter] postNotificationName:UIApplicationWillTerminateNotification object:self];
}

@end
