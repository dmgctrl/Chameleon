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

#import "UIPopoverController+UIPrivate.h"
#import "UIViewController.h"
#import "UIWindow.h"
#import "UIScreen+UIPrivate.h"
#import "UIScreen+AppKit.h"
#import "UIKitView.h"
#import "UITouch.h"
#import "UIApplication+UIPrivate.h"
#import "UIPopoverView.h"
#import "UIPopoverNSWindow.h"
#import "UIPopoverOverlayNSView.h"
#import "UIPopoverNSView.h"
#import "UIImage+UIPrivate.h"


@implementation UIPopoverController {
    UIPopoverView *_popoverView;
    UIWindow* _presentingWindow;
    BOOL _isTouchValid;
    UIPopoverNSWindow* _popoverWindow;
    NSWindow* _overlayWindow;
    UIPopoverTheme _theme;
    /**/
    CGRect _desktopScreenRect;
    UIPopoverNSView* _popoverContainerView;
    UIPopoverArrowDirection _arrowDirections;

    struct {
        BOOL popoverControllerDidDismissPopover : 1;
        BOOL popoverControllerShouldDismissPopover : 1;
    } _delegateHas;	
}

- (id)init
{
    if ((self=[super init])) {
        _popoverArrowDirection = UIPopoverArrowDirectionUnknown;
    }
    return self;
}

- (id)initWithContentViewController:(UIViewController *)viewController
{
    if ((self=[self init])) {
        self.contentViewController = viewController;
    }
    return self;
}

- (void)dealloc
{
    [self dismissPopoverAnimated:NO];
    [self setContentViewController:nil];
}

- (void)setDelegate:(id<UIPopoverControllerDelegate>)newDelegate
{
    _delegate = newDelegate;
    _delegateHas.popoverControllerDidDismissPopover = [_delegate respondsToSelector:@selector(popoverControllerDidDismissPopover:)];
    _delegateHas.popoverControllerShouldDismissPopover = [_delegate respondsToSelector:@selector(popoverControllerShouldDismissPopover:)];
}

- (void)setContentViewController:(UIViewController *)controller animated:(BOOL)animated
{
    if (controller != _contentViewController) {
        if ([self isPopoverVisible]) {
            [_popoverView setContentView:controller.view animated:animated];
        }
        if (_contentViewController) {
            [_contentViewController removeObserver:self forKeyPath:@"contentSizeForViewInPopover"];
        }
        _contentViewController = controller;
        if (_contentViewController) {
            [_contentViewController addObserver:self forKeyPath:@"contentSizeForViewInPopover" options:NSKeyValueObservingOptionNew context:NULL];
        }
    }
}

- (void)setContentViewController:(UIViewController *)viewController
{
    [self setContentViewController:viewController animated:NO];
}

- (void)presentPopoverFromRect:(CGRect)rect inView:(UIView *)view permittedArrowDirections:(UIPopoverArrowDirection)arrowDirections animated:(BOOL)animated
{
    [self presentPopoverFromRect:rect inView:view permittedArrowDirections:arrowDirections animated:animated makeKey:YES];
}

- (void)presentPopoverFromRect:(CGRect)rect inView:(UIView *)view permittedArrowDirections:(UIPopoverArrowDirection)arrowDirections animated:(BOOL)animated makeKey:(BOOL)shouldMakeKey
{
    assert(view != nil);
    assert(arrowDirections != UIPopoverArrowDirectionUnknown);
    assert(!CGRectIsNull(rect));
    assert(!CGRectEqualToRect(rect,CGRectZero));
    
    NSWindow *viewNSWindow = [[view.window.screen UIKitView] window];
    
    // only create new stuff if the popover isn't already visible
    if (![self isPopoverVisible]) {
        _presentingWindow = view.window;
        
        // build an overlay window which will capture any clicks on the main window the popover is being presented from and then dismiss it.
        // this overlay can also be used to implement the pass-through views of the popover, but I'm not going to do that right now since
        // we don't need it. attach the overlay window to the "main" window.
        NSRect windowFrame = [viewNSWindow frame];
        NSRect overlayContentRect = NSMakeRect(0,0,windowFrame.size.width,windowFrame.size.height);

        _overlayWindow = [[NSWindow alloc] initWithContentRect:overlayContentRect styleMask:NSBorderlessWindowMask backing:NSBackingStoreBuffered defer:YES];
        [_overlayWindow setIgnoresMouseEvents:NO];
        [_overlayWindow setOpaque:NO];
        [_overlayWindow setBackgroundColor:[NSColor clearColor]];
        [_overlayWindow setFrameOrigin:windowFrame.origin];
        [_overlayWindow setContentView:[[UIPopoverOverlayNSView alloc] initWithFrame:overlayContentRect popoverController:self]];
        [viewNSWindow addChildWindow:_overlayWindow ordered:NSWindowAbove];

		[_contentViewController viewWillAppear:animated];
		
        // now build the actual popover view which represents the popover's chrome, and since it's a UIView, we need to build a UIKitView 
        // as well to put it in our NSWindow...
        _popoverView = [[UIPopoverView alloc] initWithContentView:_contentViewController.view size:_contentViewController.contentSizeForViewInPopover popoverController:self];
        _popoverView.theme = _theme;

        UIKitView *hostingView = [[UIKitView alloc] initWithFrame:NSRectFromCGRect([_popoverView bounds])];
        [[hostingView UIScreen] _setPopoverController:self];
        [[hostingView UIWindow] addSubview:_popoverView];
        [[hostingView UIWindow] setHidden:NO];
        if (shouldMakeKey) {
            [[hostingView UIWindow] makeKeyAndVisible];
        }

        // this prevents a visible flash from sometimes occuring due to the fact that the window is created and added as a child before it has the
        // proper origin set. this means it it ends up flashing at the bottom left corner of the screen sometimes before it
        // gets down farther in this method where the actual origin is calculated and set. since the window is transparent, simply setting the UIView
        // hidden gets around the problem since you then can't see any of the actual content that's in the window :)
        _popoverView.hidden = YES;

        // now finally make the actual popover window itself and attach it to the overlay window
        _popoverWindow = [[UIPopoverNSWindow alloc] initWithContentRect:[hostingView bounds] styleMask:NSBorderlessWindowMask backing:NSBackingStoreBuffered defer:YES];
        [_popoverWindow setPopoverController:self];
        [_popoverWindow setOpaque:NO];
        [_popoverWindow setHasShadow:YES];
        [_popoverWindow setBackgroundColor:[NSColor clearColor]];
        
        _popoverContainerView = [[UIPopoverNSView alloc] initWithFrame:overlayContentRect];
        [_popoverContainerView addSubview:hostingView];
        [_popoverWindow setContentView:_popoverContainerView];
        //[_popoverWindow setContentView:hostingView];
        [viewNSWindow addChildWindow:_popoverWindow ordered:NSWindowAbove];
        [_popoverWindow makeFirstResponder:hostingView];

    }
    
    // cancel current touches (if any) to prevent the main window from losing track of events (such as if the user was holding down the mouse
    // button and a timer triggered the appearance of this popover. the window would possibly then not receive the mouseUp depending on how
    // all this works out... I first ran into this problem with NSMenus. A NSWindow is a bit different, but I think this makes sense here
    // too so premptively doing it to avoid potential problems.)
    [[UIApplication sharedApplication] _cancelTouches];
    
    // now position the popover window according to the passed in parameters.
    CGRect windowRect = [view convertRect:rect toView:nil];
    CGRect screenRect = [view.window convertRect:windowRect toWindow:nil];
    _desktopScreenRect = [view.window.screen convertRect:screenRect toScreen:nil];
    _arrowDirections = arrowDirections;
    
    [self setPopoverContentSize:_contentViewController.contentSizeForViewInPopover];
    

    if (shouldMakeKey) {
        [_popoverWindow makeKeyWindow];
    }
    
    [_contentViewController viewDidAppear:animated];

    if (animated) {
        _popoverView.transform = CGAffineTransformMakeScale(0.98f,0.98f);
        _popoverView.alpha = 0.4f;
        
        [UIView animateWithDuration:0.08 
                         animations:^{
                             _popoverView.transform = CGAffineTransformIdentity;
                         }
         ];
        
        [UIView animateWithDuration:0.1
                         animations:^{
                             _popoverView.alpha = 1.f;
                         }
         ];
    }
}

- (void)presentPopoverFromBarButtonItem:(UIBarButtonItem *)item permittedArrowDirections:(UIPopoverArrowDirection)arrowDirections animated:(BOOL)animated
{
}

- (BOOL) isPopoverVisible
{
    return [_popoverWindow isVisible];
}

- (void)dismissPopoverAnimated:(BOOL)animated
{
    if ([self isPopoverVisible]) {
        id overlayWindow = _overlayWindow;
        id popoverWindow = _popoverWindow;
        UIView* popoverView = _popoverView;
        
        _overlayWindow = nil;
        _popoverWindow = nil;
        _popoverView = nil;
        _popoverArrowDirection = UIPopoverArrowDirectionUnknown;
        
        void(^animationBlock)(void) = ^{
            popoverView.alpha = 0;
        };
        void(^completionBlock)(BOOL) = ^(BOOL finished) {
            [popoverWindow orderOut:nil];
            [overlayWindow orderOut:nil];

            [[popoverWindow parentWindow] removeChildWindow:popoverWindow];
            [[overlayWindow parentWindow] removeChildWindow:overlayWindow];
        };
        
        if (animated) {
            [UIView animateWithDuration:0.2 
                animations:animationBlock
                completion:completionBlock
            ];
        } else {
            animationBlock();
            completionBlock(YES);
        }
    }
}

- (void)_closePopoverWindowIfPossible
{
    const BOOL shouldDismiss = _delegateHas.popoverControllerShouldDismissPopover? [_delegate popoverControllerShouldDismissPopover:self] : YES;

    if (shouldDismiss) {
        [self dismissPopoverAnimated:YES];

        if (_delegateHas.popoverControllerDidDismissPopover) {
            [_delegate popoverControllerDidDismissPopover:self];
        }
    }
}

- (void) _sendLeftMouseDownWithEvent:(NSEvent *)theNSEvent
{
    CGPoint screenLocation = ScreenLocationFromNSEvent([_presentingWindow screen], theNSEvent);
    if ([self _isPassthroughViewAtLocation:screenLocation]) {
        [[UIApplication sharedApplication] _sendMouseNSEvent:theNSEvent fromScreen:_presentingWindow.screen];
        _isTouchValid = YES;
    } else {
        [self _closePopoverWindowIfPossible];
    }
}

- (void)_sendLeftMouseDraggedWithEvent:(NSEvent *)theNSEvent
{
    if (_isTouchValid) {
        [[UIApplication sharedApplication] _sendMouseNSEvent:theNSEvent fromScreen:_presentingWindow.screen];
    }
}

- (void)_sendLeftMouseUpWithEvent:(NSEvent *)theNSEvent
{
    if (_isTouchValid) {
        [[UIApplication sharedApplication] _sendMouseNSEvent:theNSEvent fromScreen:_presentingWindow.screen];
    }
    _isTouchValid = NO;
}

- (void) _sendRightMouseDownWithEvent:(NSEvent *)theNSEvent
{
    CGPoint screenLocation = ScreenLocationFromNSEvent([_presentingWindow screen], theNSEvent);
    if ([self _isPassthroughViewAtLocation:screenLocation]) {
        [[UIApplication sharedApplication] _sendMouseNSEvent:theNSEvent fromScreen:_presentingWindow.screen];
        _isTouchValid = YES;
    }
}

- (void)_sendRightMouseDraggedWithEvent:(NSEvent *)theNSEvent
{
    if (_isTouchValid) {
        [[UIApplication sharedApplication] _sendMouseNSEvent:theNSEvent fromScreen:_presentingWindow.screen];
    }
}

- (void)_sendRightMouseUpWithEvent:(NSEvent *)theNSEvent
{
    if (_isTouchValid) {
        [[UIApplication sharedApplication] _sendMouseNSEvent:theNSEvent fromScreen:_presentingWindow.screen];
    }
    _isTouchValid = NO;
}

- (BOOL) _isPassthroughViewAtLocation:(CGPoint)location
{
    UIView* view = [_presentingWindow hitTest:location withEvent:nil];
    while (view && view != _presentingWindow) {
        if ([_passthroughViews containsObject:view]) {
            return YES;
        }
        view = [view superview];
    }
    return NO;
}

+ (UIEdgeInsets)insetForArrows
{
    return UIEdgeInsetsMake(17,12,8,12);
}

+ (CGRect)backgroundRectForBounds:(CGRect)bounds
{
    return UIEdgeInsetsInsetRect(bounds, [self insetForArrows]);
}

+ (CGRect)contentRectForBounds:(CGRect)bounds withNavigationBar:(BOOL)hasNavBar
{
    const CGFloat navBarOffset = hasNavBar? 32 : 0;
    return UIEdgeInsetsInsetRect(CGRectMake(14,9+navBarOffset,bounds.size.width-28,bounds.size.height-28-navBarOffset), [self insetForArrows]);
}

+ (CGSize)frameSizeForContentSize:(CGSize)contentSize withNavigationBar:(BOOL)hasNavBar
{
    UIEdgeInsets insets = [self insetForArrows];
    CGSize frameSize;
    
    frameSize.width = contentSize.width + 28 + insets.left + insets.right;
    frameSize.height = contentSize.height + 28 + (hasNavBar? 32 : 0) + insets.top + insets.bottom;
    
    return frameSize;
}

const CGFloat kMinimumPadding = 40;
const CGFloat kArrowPadding = 8;		

static BOOL SizeIsLessThanOrEqualSize(NSSize size1, NSSize size2)
{
    return (size1.width <= size2.width) && (size1.height <= size2.height);
}

static inline CGPoint CGPointForCenterOfRect(CGRect r)
{
    return (CGPoint){
        .x = CGRectGetMidX(r),
        .y = CGRectGetMidY(r),
    };
}

static inline CGPoint CGPointOffset(CGPoint p, CGFloat xOffset, CGFloat yOffset)
{
    return (CGPoint){
        .x = p.x + xOffset,
        .y = p.y + yOffset
    };
}

- (void)setPopoverContentSize:(CGSize)popoverContentSize
{
    if (![self isPopoverVisible]) {
        return;
    }
    assert(_contentViewController != nil);
    
    NSSize popoverSize = [[self class] frameSizeForContentSize:popoverContentSize withNavigationBar:NO];
    
    NSRect screenRect = [[_overlayWindow screen] visibleFrame];
    
    NSSize bq = NSMakeSize(screenRect.size.width, _desktopScreenRect.origin.y - screenRect.origin.y);
    NSSize tq = NSMakeSize(screenRect.size.width, screenRect.size.height - (_desktopScreenRect.origin.y - screenRect.origin.y + _desktopScreenRect.size.height));
    NSSize lq = NSMakeSize(_desktopScreenRect.origin.x - screenRect.origin.x, screenRect.size.height);
    NSSize rq = NSMakeSize(screenRect.size.width - (_desktopScreenRect.origin.x - screenRect.origin.x + _desktopScreenRect.size.width), screenRect.size.height);
    
    NSPoint pointTo = CGPointForCenterOfRect(_desktopScreenRect);
    NSPoint origin = CGPointOffset(pointTo, -popoverSize.width / 2.f, -popoverSize.height / 2.f);
    
    const BOOL allowTopOrBottom = (pointTo.x >= NSMinX(screenRect) + kMinimumPadding) && (pointTo.x <= NSMaxX(screenRect) - kMinimumPadding);
    const BOOL allowLeftOrRight = (pointTo.y >= NSMinY(screenRect) + kMinimumPadding) && (pointTo.y <= NSMaxY(screenRect) - kMinimumPadding);
    
    const BOOL allowTopQuad     = (_arrowDirections & UIPopoverArrowDirectionDown)  && tq.width > 0 && tq.height > 0 && allowTopOrBottom;
    const BOOL allowBottomQuad  = (_arrowDirections & UIPopoverArrowDirectionUp)    && bq.width > 0 && bq.height > 0 && allowTopOrBottom;
    const BOOL allowLeftQuad    = (_arrowDirections & UIPopoverArrowDirectionRight) && lq.width > 0 && lq.height > 0 && allowLeftOrRight;
    const BOOL allowRightQuad   = (_arrowDirections & UIPopoverArrowDirectionLeft)  && rq.width > 0 && rq.height > 0 && allowLeftOrRight;
    
    if (allowBottomQuad && SizeIsLessThanOrEqualSize(popoverSize, bq)) {
        pointTo.y = _desktopScreenRect.origin.y;
        origin.y = _desktopScreenRect.origin.y - popoverSize.height + kArrowPadding;
        _popoverContainerView.arrowDirection = _popoverArrowDirection = UIPopoverArrowDirectionUp;
    } else if (allowRightQuad && SizeIsLessThanOrEqualSize(popoverSize, rq)) {
        pointTo.x = _desktopScreenRect.origin.x + _desktopScreenRect.size.width;
        origin.x = pointTo.x - kArrowPadding;
        _popoverContainerView.arrowDirection = _popoverArrowDirection = UIPopoverArrowDirectionLeft;
    } else if (allowLeftQuad && SizeIsLessThanOrEqualSize(popoverSize, lq)) {
        pointTo.x = _desktopScreenRect.origin.x;
        origin.x = _desktopScreenRect.origin.x - popoverSize.width + kArrowPadding;
        _popoverContainerView.arrowDirection =  _popoverArrowDirection = UIPopoverArrowDirectionRight;
    } else if (allowTopQuad && SizeIsLessThanOrEqualSize(popoverSize, tq)) {
        pointTo.y = _desktopScreenRect.origin.y + _desktopScreenRect.size.height;
        origin.y = pointTo.y - kArrowPadding;
        _popoverContainerView.arrowDirection = _popoverArrowDirection = UIPopoverArrowDirectionDown;
    } else {
        CGFloat maxArea = -1;
        CGFloat popoverWidthDelta = -1;
        if (allowBottomQuad) {
            // TODO: need to handle bottom quad
        }
        if (allowRightQuad) {
            CGFloat area = rq.height * rq.width;
            if (area > maxArea) {
                popoverWidthDelta = -1;
                maxArea = area;
                NSInteger quadWidth = rq.width + _desktopScreenRect.size.width / 2.f;
                NSInteger popoverWidth = popoverSize.width + kArrowPadding;
                if (popoverWidth <= quadWidth) {
                    pointTo.x = _desktopScreenRect.origin.x + _desktopScreenRect.size.width / 2.f + (quadWidth - popoverWidth);
                } else {
                    popoverWidthDelta = popoverWidth - quadWidth;
                }
                origin.x = pointTo.x - kArrowPadding;
                _popoverContainerView.arrowDirection = _popoverArrowDirection = UIPopoverArrowDirectionLeft;
            }
        }
        if (allowLeftQuad) {
            CGFloat area = lq.height * lq.width;
            if (area > maxArea) {
                popoverWidthDelta = -1;
                maxArea = area;
                NSInteger quadWidth = lq.width + _desktopScreenRect.size.width/2.f;
                NSInteger popoverWidth = popoverSize.width + kArrowPadding;
                if (popoverWidth <= quadWidth) {
                    pointTo.x = _desktopScreenRect.origin.x + _desktopScreenRect.size.width/2.f - (quadWidth - popoverWidth);
                } else {
                    popoverWidthDelta = popoverWidth - quadWidth;
                }
                origin.x = pointTo.x - popoverSize.width + kArrowPadding;
                _popoverContainerView.arrowDirection = _popoverArrowDirection = UIPopoverArrowDirectionRight;
            }
        }
        if (allowTopQuad) {
            // TODO: need to handle top quad
        }
        if (-1 != popoverWidthDelta) {
            popoverSize.width -= popoverWidthDelta;
        }
        if (-1 == maxArea) {
            _popoverContainerView.arrowDirection = _popoverArrowDirection = UIPopoverArrowDirectionUnknown;
        }
    }
    
    NSRect windowRect = {
        .origin = origin,
        .size = popoverSize
    };
    
    if (NSMaxX(windowRect) > NSMaxX(screenRect)) {
        windowRect.origin.x = NSMaxX(screenRect) - popoverSize.width;
    }
    if (NSMinX(windowRect) < NSMinX(screenRect)) {
        windowRect.origin.x = NSMinX(screenRect);
    }
    if (NSMaxY(windowRect) > NSMaxY(screenRect)) {
        windowRect.origin.y = NSMaxY(screenRect) - popoverSize.height;
    }
    if (NSMinY(windowRect) < NSMinY(screenRect)) {
        windowRect.origin.y = NSMinY(screenRect);
    }
    
    if (!CGRectEqualToRect(windowRect, [_popoverWindow frame])) {
        CGRect popoverFrame = _popoverView.frame;
        popoverFrame.size = popoverSize;
        
        _popoverView.frame = popoverFrame;
        _popoverView.hidden = NO;
        
        UIKitView* hostingView = [_popoverWindow contentView];
        [hostingView setFrame:(CGRect){ .size = popoverSize }];    
        [_popoverWindow setFrame:windowRect display:NO animate:NO];
        
        _popoverContentSize = _contentViewController.view.bounds.size;
    }
    
    // the window has to be visible before these coordinate conversions will work correctly (otherwise the UIScreen isn't attached to anything
    // and blah blah blah...)
    // finally, set the arrow position so it points to the right place and looks all purty.
    if (_popoverArrowDirection != UIPopoverArrowDirectionUnknown) {
        CGPoint screenPointTo = [_popoverView.window.screen convertPoint:NSPointToCGPoint(pointTo) fromScreen:nil];
        CGPoint windowPointTo = [_popoverView.window convertPoint:screenPointTo fromWindow:nil];
        CGPoint viewPointTo = [_popoverView convertPoint:windowPointTo fromView:nil];
        [_popoverView pointTo:viewPointTo inView:_popoverView];
    }
}

- (void) observeValueForKeyPath:(NSString*)keyPath ofObject:(id)object change:(NSDictionary*)change context:(void*)context
{
    if (object == _contentViewController) {
        if ([keyPath isEqualToString:@"contentSizeForViewInPopover"]) {
            CGSize size = [[change objectForKey:NSKeyValueChangeNewKey] sizeValue];
            [self setPopoverContentSize:size];
        }
    }
}

+ (UIImage *)backgroundImageForTheme:(UIPopoverTheme)theme {
    switch (theme) {
        case UIPopoverThemeDefault:
            return [UIImage _popoverBackgroundImage];
            break;
        case UIPopoverThemeLion:
            return [UIImage _popoverLionBackgroundImage];
            break;
    }
	return nil;
}

+ (UIImage *)leftArrowImageForTheme:(UIPopoverTheme)theme {
    switch (theme) {
        case UIPopoverThemeDefault:
            return [UIImage _leftPopoverArrowImage];
            break;
        case UIPopoverThemeLion:
            return [UIImage _leftLionPopoverArrowImage];
            break;
    }
	return nil;
}

+ (UIImage *)rightArrowImageForTheme:(UIPopoverTheme)theme {
    switch (theme) {
        case UIPopoverThemeDefault:
            return [UIImage _rightPopoverArrowImage];
            break;
        case UIPopoverThemeLion:
            return [UIImage _rightLionPopoverArrowImage];
            break;
    }
	return nil;
}

+ (UIImage *)topArrowImageForTheme:(UIPopoverTheme)theme {
    switch (theme) {
        case UIPopoverThemeDefault:
            return [UIImage _topPopoverArrowImage];
            break;
        case UIPopoverThemeLion:
            return [UIImage _topLionPopoverArrowImage];
            break;
    }
	return nil;
}

+ (UIImage *)bottomArrowImageForTheme:(UIPopoverTheme)theme {
    switch (theme) {
        case UIPopoverThemeDefault:
            return [UIImage _bottomPopoverArrowImage];
            break;
        case UIPopoverThemeLion:
            return [UIImage _bottomLionPopoverArrowImage];
            break;
    }
	return nil;
}

- (void) setTheme:(UIPopoverTheme)theme
{
    if (_theme != theme) {
        _theme = theme;
        _popoverView.theme = _theme;
    }
}

- (UIPopoverTheme) theme
{
    return _theme;
}

@end
