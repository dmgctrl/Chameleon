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
#import <UIKit/UIGeometry.h>
#import <UIKit/UIAppearance.h>

@class UIColor;
@class CALayer;
@class UIViewController;
@class UIGestureRecognizer;
@class NSLayoutConstraint;
@class UIViewPrintFormatter;

// really belongs to NSLayoutConstraint
enum {
    UILayoutPriorityRequired = 1000,
    UILayoutPriorityDefaultHigh = 750,
    UILayoutPriorityDefaultLow = 250,
    UILayoutPriorityFittingSizeLevel = 50,
};
typedef float UILayoutPriority;

#pragma mark Constants
enum {
    UIViewAnimationOptionLayoutSubviews            = 1 <<  0,
    UIViewAnimationOptionAllowUserInteraction      = 1 <<  1,
    UIViewAnimationOptionBeginFromCurrentState     = 1 <<  2,
    UIViewAnimationOptionRepeat                    = 1 <<  3,
    UIViewAnimationOptionAutoreverse               = 1 <<  4,
    UIViewAnimationOptionOverrideInheritedDuration = 1 <<  5,
    UIViewAnimationOptionOverrideInheritedCurve    = 1 <<  6,
    UIViewAnimationOptionAllowAnimatedContent      = 1 <<  7,
    UIViewAnimationOptionShowHideTransitionViews   = 1 <<  8,
    
    UIViewAnimationOptionCurveEaseInOut            = 0 << 16,
    UIViewAnimationOptionCurveEaseIn               = 1 << 16,
    UIViewAnimationOptionCurveEaseOut              = 2 << 16,
    UIViewAnimationOptionCurveLinear               = 3 << 16,
    
    UIViewAnimationOptionTransitionNone            = 0 << 20,
    UIViewAnimationOptionTransitionFlipFromLeft    = 1 << 20,
    UIViewAnimationOptionTransitionFlipFromRight   = 2 << 20,
    UIViewAnimationOptionTransitionCurlUp          = 3 << 20,
    UIViewAnimationOptionTransitionCurlDown        = 4 << 20,
    UIViewAnimationOptionTransitionCrossDissolve   = 5 << 20,
    UIViewAnimationOptionTransitionFlipFromTop     = 6 << 20,
    UIViewAnimationOptionTransitionFlipFromBottom  = 7 << 20,
};
typedef NSUInteger UIViewAnimationOptions;

typedef enum {
    UIViewAnimationCurveEaseInOut,
    UIViewAnimationCurveEaseIn,
    UIViewAnimationCurveEaseOut,
    UIViewAnimationCurveLinear
} UIViewAnimationCurve;

typedef enum {
    UIViewContentModeScaleToFill,
    UIViewContentModeScaleAspectFit,
    UIViewContentModeScaleAspectFill,
    UIViewContentModeRedraw,
    UIViewContentModeCenter,
    UIViewContentModeTop,
    UIViewContentModeBottom,
    UIViewContentModeLeft,
    UIViewContentModeRight,
    UIViewContentModeTopLeft,
    UIViewContentModeTopRight,
    UIViewContentModeBottomLeft,
    UIViewContentModeBottomRight,
} UIViewContentMode;

enum {
    UILayoutConstraintAxisHorizontal = 0,
    UILayoutConstraintAxisVertical = 1
};
typedef NSInteger UILayoutConstraintAxis;

const CGSize UILayoutFittingCompressedSize;
const CGSize UILayoutFittingExpandedSize;
const CGFloat UIViewNoIntrinsicMetric;

enum {
    UIViewAutoresizingNone                 = 0,
    UIViewAutoresizingFlexibleLeftMargin   = 1 << 0,
    UIViewAutoresizingFlexibleWidth        = 1 << 1,
    UIViewAutoresizingFlexibleRightMargin  = 1 << 2,
    UIViewAutoresizingFlexibleTopMargin    = 1 << 3,
    UIViewAutoresizingFlexibleHeight       = 1 << 4,
    UIViewAutoresizingFlexibleBottomMargin = 1 << 5
};
typedef NSUInteger UIViewAutoresizing;

typedef enum {
    UIViewAnimationTransitionNone,
    UIViewAnimationTransitionFlipFromLeft,
    UIViewAnimationTransitionFlipFromRight,
    UIViewAnimationTransitionCurlUp,
    UIViewAnimationTransitionCurlDown,
} UIViewAnimationTransition;

@interface UIView : UIResponder <NSCoding>

#pragma mark Initializing a View Object
- (id) initWithFrame:(CGRect)aRect;

#pragma mark Configuring a View’s Visual Appearance
@property (nonatomic, copy) UIColor* backgroundColor;
@property (nonatomic, getter=isHidden) BOOL hidden;
@property (nonatomic) CGFloat alpha;
@property (nonatomic, getter=isOpaque) BOOL opaque;
@property (nonatomic) BOOL clipsToBounds;
@property (nonatomic) BOOL clearsContextBeforeDrawing;
+ (Class) layerClass;
@property (nonatomic, readonly, retain) CALayer *layer;

#pragma mark Configuring the Event-Related Behavior
@property (nonatomic, getter=isUserInteractionEnabled) BOOL userInteractionEnabled;
@property (nonatomic, getter=isMultipleTouchEnabled) BOOL multipleTouchEnabled;
@property (nonatomic, getter=isExclusiveTouch) BOOL exclusiveTouch;

#pragma mark Configuring the Bounds and Frame Rectangles
@property (nonatomic) CGRect frame;
@property (nonatomic) CGRect bounds;
@property (nonatomic) CGPoint center;
@property (nonatomic) CGAffineTransform transform;

#pragma mark Managing the View Hierarchy
@property (nonatomic, readonly) UIView* superview;
@property (nonatomic, readonly, copy) NSArray* subviews;
@property (nonatomic, readonly) UIWindow* window;
- (void) addSubview:(UIView*)view;
- (void) bringSubviewToFront:(UIView*)view;
- (void) sendSubviewToBack:(UIView*)view;
- (void) removeFromSuperview;
- (void) insertSubview:(UIView*)view atIndex:(NSInteger)index;
- (void) insertSubview:(UIView*)view aboveSubview:(UIView*)siblingSubview;
- (void) insertSubview:(UIView*)view belowSubview:(UIView*)siblingSubview;
- (void) exchangeSubviewAtIndex:(NSInteger)index1 withSubviewAtIndex:(NSInteger)index2;
- (BOOL) isDescendantOfView:(UIView*)view;

#pragma mark Configuring the Resizing Behavior
@property (nonatomic) UIViewAutoresizing autoresizingMask;
@property (nonatomic) BOOL autoresizesSubviews;
@property (nonatomic) UIViewContentMode contentMode;
- (CGSize) sizeThatFits:(CGSize)size;
- (void) sizeToFit;

#pragma mark Laying out Subviews
- (void) layoutSubviews;
- (void) setNeedsLayout;
- (void) layoutIfNeeded;

#pragma mark Opting in to Constraint-Based Layout
+ (BOOL) requiresConstraintBasedLayout;
- (BOOL) translatesAutoresizingMaskIntoConstraints;
- (void) setTranslatesAutoresizingMaskIntoConstraints:(BOOL)flag;

#pragma mark Managing Constraints
- (NSArray*) constraints;
- (void) addConstraint:(NSLayoutConstraint*)constraint;
- (void) addConstraints:(NSArray*)constraints;
- (void) removeConstraint:(NSLayoutConstraint*)constraint;
- (void) removeConstraints:(NSArray*)constraints;

#pragma mark Measuring in Constraint-Based Layout
- (CGSize) systemLayoutSizeFittingSize:(CGSize)targetSize;
- (CGSize) intrinsicContentSize;
- (void) invalidateIntrinsicContentSize;
- (UILayoutPriority) contentCompressionResistancePriorityForAxis:(UILayoutConstraintAxis)axis;
- (void) setContentCompressionResistancePriority:(UILayoutPriority)priority forAxis:(UILayoutConstraintAxis)axis;
- (UILayoutPriority) contentHuggingPriorityForAxis:(UILayoutConstraintAxis)axis;
- (void) setContentHuggingPriority:(UILayoutPriority)priority forAxis:(UILayoutConstraintAxis)axis;

#pragma mark Aligning Views with Constraint-Based Layout
- (CGRect) alignmentRectForFrame:(CGRect)frame;
- (CGRect) frameForAlignmentRect:(CGRect)alignmentRect;
- (UIEdgeInsets) alignmentRectInsets;
- (UIView*) viewForBaselineLayout;

#pragma mark Triggering Constraint-Based Layout
- (BOOL) needsUpdateConstraints;
- (void) setNeedsUpdateConstraints;
- (void) updateConstraints;
- (void) updateConstraintsIfNeeded;

#pragma mark Debugging Constraint-Based Layout
- (NSArray*) constraintsAffectingLayoutForAxis:(UILayoutConstraintAxis)axis;
- (BOOL) hasAmbiguousLayout;
- (void) exerciseAmbiguityInLayout;

#pragma mark Drawing and Updating the View
- (void) drawRect:(CGRect)rect;
- (void) setNeedsDisplay;
- (void) setNeedsDisplayInRect:(CGRect)invalidRect;
@property (nonatomic) CGFloat contentScaleFactor;

#pragma mark Formatting Printed View Content
//– (UIViewPrintFormatter*) viewPrintFormatter;
- (void)drawRect:(CGRect)area forViewPrintFormatter:(UIViewPrintFormatter*)formatter;

#pragma mark Managing Gesture Recognizers
- (void) addGestureRecognizer:(UIGestureRecognizer*) gestureRecognizer;
- (void) removeGestureRecognizer:(UIGestureRecognizer*) gestureRecognizer;
@property (nonatomic, copy) NSArray* gestureRecognizers;
- (BOOL) gestureRecognizerShouldBegin:(UIGestureRecognizer*) gestureRecognizer;

#pragma mark Animating Views with Blocks
+ (void) animateWithDuration:(NSTimeInterval)duration delay:(NSTimeInterval)delay options:(UIViewAnimationOptions)options animations:(void (^)(void))animations completion:(void (^)(BOOL finished))completion;
+ (void) animateWithDuration:(NSTimeInterval)duration animations:(void (^)(void))animations completion:(void (^)(BOOL finished))completion;
+ (void) animateWithDuration:(NSTimeInterval)duration animations:(void (^)(void))animations;
+ (void) transitionWithView:(UIView*)view duration:(NSTimeInterval)duration options:(UIViewAnimationOptions)options animations:(void (^)(void))animations completion:(void (^)(BOOL finished))completion;
+ (void) transitionFromView:(UIView*)fromView toView:(UIView*)toView duration:(NSTimeInterval)duration options:(UIViewAnimationOptions)options completion:(void (^)(BOOL finished))completion;

#pragma mark Animating Views
+ (void) beginAnimations:(NSString*)animationID context:(void *)context;
+ (void) commitAnimations;
+ (void) setAnimationStartDate:(NSDate*)startTime;
+ (void) setAnimationsEnabled:(BOOL)enabled;
+ (void) setAnimationDelegate:(id)delegate;
+ (void) setAnimationWillStartSelector:(SEL)selector;
+ (void) setAnimationDidStopSelector:(SEL)selector;
+ (void) setAnimationDuration:(NSTimeInterval)duration;
+ (void) setAnimationDelay:(NSTimeInterval)delay;
+ (void) setAnimationCurve:(UIViewAnimationCurve)curve;
+ (void) setAnimationRepeatCount:(float)repeatCount;
+ (void) setAnimationRepeatAutoreverses:(BOOL)repeatAutoreverses;
+ (void) setAnimationBeginsFromCurrentState:(BOOL)fromCurrentState;
+ (void) setAnimationTransition:(UIViewAnimationTransition)transition forView:(UIView*)view cache:(BOOL)cache;
+ (BOOL) areAnimationsEnabled;

#pragma mark Preserving and Restoring State
@property (nonatomic, copy) NSString* restorationIdentifier;
- (void) encodeRestorableStateWithCoder:(NSCoder*)coder;
- (void) decodeRestorableStateWithCoder:(NSCoder*)coder;

#pragma mark Identifying the View at Runtime
@property (nonatomic) NSInteger tag;
- (UIView*) viewWithTag:(NSInteger)tag;

#pragma mark Converting Between View Coordinate Systems
- (CGPoint) convertPoint:(CGPoint)point toView:(UIView*)view;
- (CGPoint) convertPoint:(CGPoint)point fromView:(UIView*)view;
- (CGRect) convertRect:(CGRect)rect toView:(UIView*)view;
- (CGRect) convertRect:(CGRect)rect fromView:(UIView*)view;

#pragma mark Hit Testing in a View
- (UIView*) hitTest:(CGPoint)point withEvent:(UIEvent*)event;
- (BOOL) pointInside:(CGPoint)point withEvent:(UIEvent*)event;

#pragma mark Ending a View Editing Session
- (BOOL) endEditing:(BOOL)force;

#pragma mark Observing View-Related Changes
- (void) didAddSubview:(UIView*)subview;
- (void) willRemoveSubview:(UIView*)subview;
- (void) willMoveToSuperview:(UIView*)newSuperview;
- (void) didMoveToSuperview;
- (void) willMoveToWindow:(UIWindow*)newWindow;
- (void) didMoveToWindow;

@end