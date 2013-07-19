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
#import <UIKit/UIApplication.h>
#import <UIKit/UISearchDisplayController.h>
#import <UIKit/UITabBarItem.h>
#import <UIKit/UIStateRestoration.h>

@class UITabBarController;

typedef enum {
    UIModalPresentationFullScreen = 0,
    UIModalPresentationPageSheet,
    UIModalPresentationFormSheet,
    UIModalPresentationCurrentContext,
} UIModalPresentationStyle;

typedef enum {
    UIModalTransitionStyleCoverVertical = 0,
    UIModalTransitionStyleFlipHorizontal,
    UIModalTransitionStyleCrossDissolve,
    UIModalTransitionStylePartialCurl,
} UIModalTransitionStyle;

@class UINavigationItem;
@class UINavigationController;
@class UIBarButtonItem;
@class UISplitViewController;
@class UIStoryboard;
@class UIStoryboardSegue;


@interface UIViewController : UIResponder <NSCoding>

#pragma mark Creating a View Controller Using Nib Files
- (instancetype) initWithNibName:(NSString*)nibName bundle:(NSBundle*)nibBundle;
@property (nonatomic, readonly, copy) NSString* nibName;
@property (nonatomic, readonly, strong) NSBundle* nibBundle;

#pragma mark Using a Storyboard
- (BOOL) shouldPerformSegueWithIdentifier:(NSString*)identifier sender:(id)sender;
- (void) performSegueWithIdentifier:(NSString*)identifier sender:(id)sender;
- (void) prepareForSegue:(UIStoryboardSegue*)segue sender:(id)sender;
@property (nonatomic, readonly, retain) UIStoryboard* storyboard;

#pragma mark Managing the View
@property (nonatomic, strong) UIView* view;
- (BOOL) isViewLoaded;
- (void) loadView;
- (void) viewDidLoad;
@property (nonatomic, copy) NSString* title;
- (void) viewDidUnload UIKIT_DEPRECATED;
- (void) viewWillUnload UIKIT_DEPRECATED;

#pragma mark Handling Memory Warnings
- (void) didReceiveMemoryWarning;

#pragma mark Responding to View Events
- (void) viewWillAppear:(BOOL)animated;
- (void) viewDidAppear:(BOOL)animated;
- (void) viewWillDisappear:(BOOL)animated;
- (void) viewDidDisappear:(BOOL)animated;
- (void) viewWillLayoutSubviews;
- (void) viewDidLayoutSubviews;

#pragma mark Testing for Specific Kinds of View Transitions
- (BOOL) isMovingFromParentViewController;
- (BOOL) isMovingToParentViewController;
- (BOOL) isBeingPresented;
- (BOOL) isBeingDismissed;

#pragma mark Configuring the View’s Layout Behavior
- (void) updateViewConstraints;
@property (nonatomic, assign) BOOL wantsFullScreenLayout;

#pragma mark Configuring the View Rotation Settings
- (BOOL) shouldAutorotate;
- (NSUInteger) supportedInterfaceOrientations;
- (UIInterfaceOrientation) preferredInterfaceOrientationForPresentation;
@property (nonatomic, readonly) UIInterfaceOrientation interfaceOrientation;
+ (void) attemptRotationToDeviceOrientation;
- (UIView*) rotatingHeaderView;
- (UIView*) rotatingFooterView;
- (BOOL) shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation UIKIT_DEPRECATED;

#pragma mark Responding to View Rotation Events
- (void) willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration;
- (void) willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation duration:(NSTimeInterval)duration;
- (void) didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation;

#pragma mark Responding to Containment Events
- (void) willMoveToParentViewController:(UIViewController*)parent;
- (void) didMoveToParentViewController:(UIViewController*)parent;

#pragma mark Adding Editing Behaviors to Your View Controller
@property (nonatomic, getter=isEditing) BOOL editing;
- (void) setEditing:(BOOL)editing animated:(BOOL)animated;

#pragma mark Managing State Restoration
@property (nonatomic, copy) NSString* restorationIdentifier;
@property (nonatomic, readwrite, assign) Class<UIViewControllerRestoration> restorationClass;
- (void) encodeRestorableStateWithCoder:(NSCoder*)coder;
- (void) decodeRestorableStateWithCoder:(NSCoder*)coder;

#pragma mark Presenting Another View Controller’s Content
- (void) presentViewController:(UIViewController*)viewControllerToPresent animated:(BOOL)flag completion:(void(^)(void))completion;
- (void) dismissViewControllerAnimated:(BOOL)flag completion:(void(^)(void))completion;
@property (nonatomic, assign) UIModalTransitionStyle modalTransitionStyle;
@property (nonatomic, assign) UIModalPresentationStyle modalPresentationStyle;
@property (nonatomic, assign) BOOL definesPresentationContext;
@property (nonatomic, assign) BOOL providesPresentationContextTransitionStyle;
- (void) presentModalViewController:(UIViewController*)modalViewController animated:(BOOL)animated UIKIT_DEPRECATED;
- (void) dismissModalViewControllerAnimated:(BOOL)animated UIKIT_DEPRECATED;

#pragma mark Getting Other Related View Controllers
@property (nonatomic, readonly) UIViewController* presentingViewController;
@property (nonatomic, readonly) UIViewController* presentedViewController;
@property (nonatomic, readonly) UIViewController* parentViewController;
@property (nonatomic, readonly, strong) UINavigationController* navigationController;
@property (nonatomic, readonly, strong) UISplitViewController* splitViewController;
@property (nonatomic, readonly, strong) UITabBarController* tabBarController;
@property (nonatomic, readonly, strong) UISearchDisplayController* searchDisplayController;
@property (nonatomic, readonly) UIViewController* modalViewController;

#pragma mark Managing Child View Controllers in a Custom Container
@property (nonatomic, readonly) NSArray* childViewControllers;
- (void) addChildViewController:(UIViewController*)childController;
- (void) removeFromParentViewController;
- (BOOL) shouldAutomaticallyForwardRotationMethods;
- (BOOL) shouldAutomaticallyForwardAppearanceMethods;
- (void) transitionFromViewController:(UIViewController*)fromViewController toViewController:(UIViewController*)toViewController duration:(NSTimeInterval)duration options:(UIViewAnimationOptions)options animations:(void(^)(void))animations completion:(void(^)(BOOL finished))completion;
- (void) beginAppearanceTransition:(BOOL)isAppearing animated:(BOOL)animated;
- (void) endAppearanceTransition;

#pragma mark Configuring a Navigation Interface
@property (nonatomic, readonly, strong) UINavigationItem* navigationItem;
- (UIBarButtonItem*) editButtonItem;
@property (nonatomic) BOOL hidesBottomBarWhenPushed;
- (void) setToolbarItems:(NSArray*)toolbarItems animated:(BOOL)animated;
@property (nonatomic, strong) NSArray* toolbarItems;

#pragma mark Configuring Tab Bar Items
@property (nonatomic, strong) UITabBarItem *tabBarItem;

#pragma mark Configuring Display in a Popover Controller
@property (nonatomic, readwrite) CGSize contentSizeForViewInPopover;
@property (nonatomic, readwrite, getter=isModalInPopover) BOOL modalInPopover;

@end
