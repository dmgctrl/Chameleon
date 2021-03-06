
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

#import <QuartzCore/CALayer.h>
//
#import <UIKit/UIView.h>
#import <UIKit/UIWindow.h>
#import <UIKit/UIGraphics.h>
#import <UIKit/UIColor.h>
#import <UIKit/UIViewAnimationGroup.h>
#import <UIKit/UIViewBlockAnimationDelegate.h>
#import <UIKit/UIViewController.h>
#import <UIKit/UIAppearanceInstance.h>
#import <UIKit/UIScreen.h>
#import <UIKit/UIGeometry.h>
#import <UIKit/UIColorRep.h>
//
#import "UIView+UIPrivate.h"
#import "UIViewController+UIPrivate.h"
#import "UIView+AppKit.h"
#import "UIApplication+UIPrivate.h"
#import "UIGestureRecognizer+UIPrivate.h"
#import "UIColor+UIPrivate.h"
#import "_UIViewLayoutManager.h"

@class NSWindow;

NSString* const UIViewFrameDidChangeNotification = @"UIViewFrameDidChangeNotification";
NSString* const UIViewBoundsDidChangeNotification = @"UIViewBoundsDidChangeNotification";
NSString* const UIViewDidMoveToSuperviewNotification = @"UIViewDidMoveToSuperviewNotification";
NSString* const UIViewHiddenDidChangeNotification = @"UIViewHiddenDidChangeNotification";

static NSString* const kUIAlphaKey = @"UIAlpha";
static NSString* const kUIAutoresizeSubviewsKey = @"UIAutoresizeSubviews";
static NSString* const kUIAutoresizingMaskKey = @"UIAutoresizingMask";
static NSString* const kUIBackgroundColorKey = @"UIBackgroundColor";
static NSString* const kUIBoundsKey = @"UIBounds";
static NSString* const kUICenterKey = @"UICenter";
static NSString* const kUIClearsContextBeforeDrawingKey = @"UIClearsContextBeforeDrawing";
static NSString* const kUIClipsToBoundsKey = @"UIClipsToBounds";
static NSString* const kUIContentModeKey = @"UIContentMode";
static NSString* const kUIContentStretchKey = @"UIContentStretch";
static NSString* const kUIHiddenKey = @"UIHidden";
static NSString* const kUIMultipleTouchEnabledKey = @"UIMultipleTouchEnabled";
static NSString* const kUIOpaqueKey = @"UIOpaque";
static NSString* const kUITagKey = @"UITag";
static NSString* const kUIUserInteractionDisabledKey = @"UIUserInteractionDisabled";
static NSString* const kUISubviewsKey = @"UISubviews";

static NSMutableArray* _animationGroups;
static BOOL _animationsEnabled = YES;

typedef void DrawRectMethod(id, SEL, CGRect);
typedef void DisplayLayerMethod(id, SEL, CALayer*);

@implementation UIView {
    BOOL _needsDidAppearOrDisappear;

    NSMutableSet* _subviews;
    UIViewController* _viewController;
    NSMutableSet* _gestureRecognizers;
    DrawRectMethod* ourDrawRect_;
    
    struct {
        BOOL overridesDisplayLayer : 1;
        BOOL clearsContextBeforeDrawing : 1;
        BOOL multipleTouchEnabled : 1;
        BOOL exclusiveTouch : 1;
        BOOL userInteractionEnabled : 1;
        BOOL autoresizesSubviews : 1;
        BOOL layerHasContentScale : 1;
    } _flags;
}

static SEL drawRectSelector;
static SEL displayLayerSelector;
static DrawRectMethod* defaultImplementationOfDrawRect;
static DisplayLayerMethod* defaultImplementationOfDisplayLayer;

+ (void) initialize
{
    if (self == [UIView class]) {
        _animationGroups = [[NSMutableArray alloc] init];
        drawRectSelector = @selector(drawRect:);
        displayLayerSelector = @selector(displayLayer:);
        defaultImplementationOfDrawRect = (DrawRectMethod*)[UIView instanceMethodForSelector:drawRectSelector];
        defaultImplementationOfDisplayLayer = (DisplayLayerMethod*)[UIView instanceMethodForSelector:displayLayerSelector];
    }
}

- (void) dealloc
{
    [[_subviews allObjects] makeObjectsPerformSelector:@selector(removeFromSuperview)];
    _layer.layoutManager = nil;
    _layer.delegate = nil;
    [_layer removeFromSuperlayer];
    _layer = nil;
}


#pragma mark Initialization

- (void) _commonInitForUIView
{
    _flags.overridesDisplayLayer = (defaultImplementationOfDisplayLayer != (DisplayLayerMethod*)[[self class] instanceMethodForSelector:displayLayerSelector]);
    
    DrawRectMethod* ourDrawRect = (DrawRectMethod*)[[self class] instanceMethodForSelector:drawRectSelector];
    if (ourDrawRect != defaultImplementationOfDrawRect) {
        ourDrawRect_ = ourDrawRect;
    }
    
    _flags.clearsContextBeforeDrawing = YES;
    _flags.autoresizesSubviews = YES;
    _flags.userInteractionEnabled = YES;
    
    _subviews = [[NSMutableSet alloc] init];
    _gestureRecognizers = [[NSMutableSet alloc] init];
    
    _layer = [[[[self class] layerClass] alloc] init];
    _layer.delegate = self;
    _layer.layoutManager = [_UIViewLayoutManager layoutManager];
    _flags.layerHasContentScale = [_layer respondsToSelector:@selector(setContentsScale:)];
    
    self.alpha = 1;
    self.opaque = YES;
    [self setNeedsDisplay];
}

- (id) init
{
    return [self initWithFrame:CGRectZero];
}

- (id) initWithFrame:(CGRect)theFrame
{
    if (nil != (self = [super init])) {
        [self _commonInitForUIView];
        self.frame = theFrame;
        [self setNeedsDisplay];
    }
    return self;
}

- (id) initWithCoder:(NSCoder*)coder
{
    if (nil != (self = [super init])) {
        [self _commonInitForUIView];
        if ([coder containsValueForKey:kUIAlphaKey]) {
            self.alpha = [coder decodeFloatForKey:kUIAlphaKey];
        }
        if ([coder containsValueForKey:kUIAutoresizeSubviewsKey]) {
            self.autoresizesSubviews = [coder decodeBoolForKey:kUIAutoresizeSubviewsKey];
        }
        if ([coder containsValueForKey:kUIAutoresizingMaskKey]) {
            self.autoresizingMask = [coder decodeIntegerForKey:kUIAutoresizingMaskKey];
        }
        if ([coder containsValueForKey:kUIBackgroundColorKey]) {
            self.backgroundColor = [coder decodeObjectForKey:kUIBackgroundColorKey];
        }
        if ([coder containsValueForKey:kUIBoundsKey]) {
            self.bounds = [coder decodeCGRectForKey:kUIBoundsKey];
        }
        if ([coder containsValueForKey:kUICenterKey]) {
            self.center = [coder decodeCGPointForKey:kUICenterKey];
        }
        if ([coder containsValueForKey:kUIClearsContextBeforeDrawingKey]) {
            self.clearsContextBeforeDrawing = [coder decodeBoolForKey:kUIClearsContextBeforeDrawingKey];
        }
        if ([coder containsValueForKey:kUIClipsToBoundsKey]) {
            self.clipsToBounds = [coder decodeBoolForKey:kUIClipsToBoundsKey];
        }
        if ([coder containsValueForKey:kUIContentModeKey]) {
            self.contentMode = [coder decodeIntegerForKey:kUIContentModeKey];
        }
        if ([coder containsValueForKey:kUIContentStretchKey]) {
            self.contentStretch = [coder decodeCGRectForKey:kUIContentStretchKey];
        }
        if ([coder containsValueForKey:kUIHiddenKey]) {
            self.hidden = [coder decodeBoolForKey:kUIHiddenKey];
        }
        if ([coder containsValueForKey:kUIMultipleTouchEnabledKey]) {
            self.multipleTouchEnabled = [coder decodeBoolForKey:kUIMultipleTouchEnabledKey];
        }
        if ([coder containsValueForKey:kUIOpaqueKey]) {
            self.opaque = [coder decodeBoolForKey:kUIOpaqueKey];
        }
        if ([coder containsValueForKey:kUITagKey]) {
            self.tag = [coder decodeIntegerForKey:kUITagKey];
        }
        if ([coder containsValueForKey:kUIUserInteractionDisabledKey]) {
            self.userInteractionEnabled = ![coder decodeBoolForKey:kUIUserInteractionDisabledKey];
        }
        for (UIView* subview in [coder decodeObjectForKey:kUISubviewsKey]) {
            [self addSubview:subview];
        }
        [self setNeedsDisplay];
    }
    return self;
}


#pragma mark Configuring a View’s Visual Appearance

- (void) setBackgroundColor:(UIColor*)backgroundColor
{
    if (_backgroundColor != backgroundColor) {
        _backgroundColor = backgroundColor;
        
        self.opaque = [_backgroundColor _isOpaque];
        
        if (!ourDrawRect_) {
            _layer.backgroundColor = [backgroundColor CGColor];
        }
    }
}

- (BOOL) isHidden
{
    return _layer.hidden;
}

- (void) setHidden:(BOOL)hidden
{
    if (hidden != _layer.hidden) {
        _layer.hidden = hidden;
        [[NSNotificationCenter defaultCenter] postNotificationName:UIViewHiddenDidChangeNotification object:self];
    }
}

- (CGFloat) alpha
{
    return _layer.opacity;
}

- (void) setAlpha:(CGFloat)alpha
{
    if (alpha != _layer.opacity) {
        _layer.opacity = alpha;
    }
}

- (BOOL) isOpaque
{
    return _layer.opaque;
}

- (void) setOpaque:(BOOL)opaque
{
    if (opaque != _layer.opaque) {
        _layer.opaque = opaque;
    }
}

- (BOOL) clipsToBounds
{
    return _layer.masksToBounds;
}

- (void) setClipsToBounds:(BOOL)clipsToBounds
{
    if (clipsToBounds != _layer.masksToBounds) {
        _layer.masksToBounds = clipsToBounds;
    }
}

- (BOOL) clearsContextBeforeDrawing
{
    return _flags.clearsContextBeforeDrawing;
}

- (void) setClearsContextBeforeDrawing:(BOOL)clearsContextBeforeDrawing
{
    _flags.clearsContextBeforeDrawing = clearsContextBeforeDrawing;
}

+ (Class) layerClass
{
    return [CALayer class];
}


#pragma mark Configuring the Event-Related Behavior

- (BOOL) isUserInteractionEnabled
{
    return _flags.userInteractionEnabled;
}

- (void) setUserInteractionEnabled:(BOOL)userInteractionEnabled
{
    _flags.userInteractionEnabled = userInteractionEnabled;
}

- (BOOL) isMultipleTouchEnabled
{
    return _flags.multipleTouchEnabled;
}

- (void) setMultipleTouchEnabled:(BOOL)multipleTouchEnabled
{
    _flags.multipleTouchEnabled = multipleTouchEnabled;
}


#pragma mark Configuring the Bounds and Frame Rectangles

- (CGRect) frame
{
    return _layer.frame;
}

- (void) setFrame:(CGRect)frame
{
    if (!CGRectEqualToRect(frame, _layer.frame)) {
        CGRect oldBounds = _layer.bounds;
        _layer.frame = frame;
        [self _boundsDidChangeFrom:oldBounds to:_layer.bounds];
        [[NSNotificationCenter defaultCenter] postNotificationName:UIViewFrameDidChangeNotification object:self];
    }
}

- (CGRect) bounds
{
    return _layer.bounds;
}

- (void) setBounds:(CGRect)bounds
{
    if (!CGRectEqualToRect(bounds, _layer.bounds)) {
        CGRect oldBounds = _layer.bounds;
        _layer.bounds = bounds;
        [self _boundsDidChangeFrom:oldBounds to:bounds];
        [[NSNotificationCenter defaultCenter] postNotificationName:UIViewBoundsDidChangeNotification object:self];
    }
}

- (CGPoint) center
{
    return _layer.position;
}

- (void) setCenter:(CGPoint)center
{
    if (!CGPointEqualToPoint(center, _layer.position)) {
        _layer.position = center;
    }
}

- (CGAffineTransform) transform
{
    return _layer.affineTransform;
}

- (void) setTransform:(CGAffineTransform)transform
{
    if (!CGAffineTransformEqualToTransform(transform, _layer.affineTransform)) {
        _layer.affineTransform = transform;
    }
}


#pragma mark Managing the View Hierarchy

- (NSArray*) subviews
{
    NSArray* sublayers = _layer.sublayers;
    NSMutableArray *subviews = [NSMutableArray arrayWithCapacity:[sublayers count]];

    // This builds the results from the layer instead of just using _subviews because I want the results to match
    // the order that CALayer has them. It's unclear in the docs if the returned order from this method is guarenteed or not,
    // however several other aspects of the system (namely the hit testing) depends on this order being correct.
    for (CALayer*layer in sublayers) {
        id potentialView = [layer delegate];
        if ([_subviews containsObject:potentialView]) {
            [subviews addObject:potentialView];
        }
    }
    
    return subviews;
}

- (UIWindow*) window
{
    return _superview.window;
}

- (void) addSubview:(UIView*)subview
{
    NSAssert((!subview || [subview isKindOfClass:[UIView class]]), @"the subview must be a UIView");
    
    if (subview && subview.superview != self) {
        UIWindow* oldWindow = subview.window;
        UIWindow* newWindow = self.window;
        
        if (newWindow) {
            [subview _willMoveFromWindow:oldWindow toWindow:newWindow];
        }
        [subview willMoveToSuperview:self];
        
        if (subview.superview) {
            [subview.layer removeFromSuperlayer];
            [subview.superview->_subviews removeObject:subview];
        }
        
        [subview willChangeValueForKey:@"superview"];
        [_subviews addObject:subview];
        subview->_superview = self;
        [_layer addSublayer:subview.layer];
        [subview didChangeValueForKey:@"superview"];
        
        if (oldWindow.screen != newWindow.screen) {
            [subview _didMoveToScreenWithScale:[[newWindow screen] scale]];
        }
        
        if (newWindow) {
            [subview _didMoveFromWindow:oldWindow toWindow:newWindow];
        }
        
        [subview didMoveToSuperview];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:UIViewDidMoveToSuperviewNotification object:subview];
        
        [self didAddSubview:subview];
    }
}

- (void) bringSubviewToFront:(UIView*)subview
{
    if (subview.superview == self) {
        [_layer insertSublayer:subview.layer above:[[_layer sublayers] lastObject]];
    }
}

- (void) sendSubviewToBack:(UIView*)subview
{
    if (subview.superview == self) {
        [_layer insertSublayer:subview.layer atIndex:0];
    }
}

- (void) removeFromSuperview
{
    if (_superview) {
        
        [[UIApplication sharedApplication] _removeViewFromTouches:self];
        
        UIWindow* oldWindow = self.window;
        
        [_superview willRemoveSubview:self];
        if (oldWindow) {
            [self _willMoveFromWindow:oldWindow toWindow:nil];
        }
        [self willMoveToSuperview:nil];
        
        [self willChangeValueForKey:@"superview"];
        [_layer removeFromSuperlayer];
        [_superview->_subviews removeObject:self];
        _superview = nil;
        [self didChangeValueForKey:@"superview"];
        
        if (oldWindow) {
            [self _didMoveFromWindow:oldWindow toWindow:nil];
        }
        [self didMoveToSuperview];
        [[NSNotificationCenter defaultCenter] postNotificationName:UIViewDidMoveToSuperviewNotification object:self];
        
    }
}

- (void) insertSubview:(UIView*)subview atIndex:(NSInteger)index
{
    [self addSubview:subview];
    [_layer insertSublayer:subview.layer atIndex:index];
}

- (void) insertSubview:(UIView*)subview aboveSubview:(UIView*)above
{
    [self addSubview:subview];
    [_layer insertSublayer:subview.layer above:above.layer];
}

- (void) insertSubview:(UIView*)subview belowSubview:(UIView*)below
{
    [self addSubview:subview];
    [_layer insertSublayer:subview.layer below:below.layer];
}

- (void) exchangeSubviewAtIndex:(NSInteger)index1 withSubviewAtIndex:(NSInteger)index2
{
    #warning Stub
    [self doesNotRecognizeSelector:_cmd];
}

- (BOOL) isDescendantOfView:(UIView*)view
{
    if (view) {
        UIView* testView = self;
        while (testView) {
            if (testView == view) {
                return YES;
            } else {
                testView = testView.superview;
            }
        }
    }
    return NO;
}


#pragma mark Configuring the Resizing Behavior

- (BOOL) autoresizesSubviews
{
    return _flags.autoresizesSubviews;
}

- (void) setAutoresizesSubviews:(BOOL)autoresizesSubviews
{
    _flags.autoresizesSubviews = autoresizesSubviews;
}

- (void) setContentMode:(UIViewContentMode)mode
{
    if (mode != _contentMode) {
        _contentMode = mode;

        BOOL needsDisplayOnBoundsChange = NO;
        switch(_contentMode) {
            case UIViewContentModeScaleToFill:
                _layer.contentsGravity = kCAGravityResize;
                break;
                
            case UIViewContentModeScaleAspectFit:
                _layer.contentsGravity = kCAGravityResizeAspect;
                break;
                
            case UIViewContentModeScaleAspectFill:
                _layer.contentsGravity = kCAGravityResizeAspectFill;
                break;
                
            case UIViewContentModeRedraw:
                needsDisplayOnBoundsChange = YES;
                break;
                
            case UIViewContentModeCenter:
                _layer.contentsGravity = kCAGravityCenter;
                break;
                
            case UIViewContentModeTop:
                _layer.contentsGravity = kCAGravityTop;
                break;
                
            case UIViewContentModeBottom:
                _layer.contentsGravity = kCAGravityBottom;
                break;
                
            case UIViewContentModeLeft:
                _layer.contentsGravity = kCAGravityLeft;
                break;
                
            case UIViewContentModeRight:
                _layer.contentsGravity = kCAGravityRight;
                break;
                
            case UIViewContentModeTopLeft:
                _layer.contentsGravity = kCAGravityTopLeft;
                break;
                
            case UIViewContentModeTopRight:
                _layer.contentsGravity = kCAGravityTopRight;
                break;
                
            case UIViewContentModeBottomLeft:
                _layer.contentsGravity = kCAGravityBottomLeft;
                break;
                
            case UIViewContentModeBottomRight:
                _layer.contentsGravity = kCAGravityBottomRight;
                break;
        }
        [_layer setNeedsDisplayOnBoundsChange:needsDisplayOnBoundsChange];
    }
}

- (CGSize) sizeThatFits:(CGSize)size
{
    return [self bounds].size;;
}

- (void) sizeToFit
{
    CGRect frame = [self frame];
    [self setFrame:(CGRect){
        .origin = frame.origin,
        .size = [self sizeThatFits:(CGSize){ CGFLOAT_MAX, CGFLOAT_MAX }]
    }];
}

- (CGRect) contentStretch
{
    return _layer.contentsCenter;
}

- (void) setContentStretch:(CGRect)rect
{
    if (!CGRectEqualToRect(rect,_layer.contentsCenter)) {
        _layer.contentsCenter = rect;
    }
}


#pragma mark Laying out Subviews

- (void) layoutSubviews
{
    // Intentionally Empty
}

- (void) setNeedsLayout
{
    [_layer setNeedsLayout];
}

- (void) layoutIfNeeded
{
    [_layer layoutIfNeeded];
}


#pragma mark Opting in to Constraint-Based Layout

+ (BOOL) requiresConstraintBasedLayout
{
    #warning Stub
    [self doesNotRecognizeSelector:_cmd];
    return NO;
}


- (BOOL) translatesAutoresizingMaskIntoConstraints
{
    #warning Stub
    [self doesNotRecognizeSelector:_cmd];
    return NO;
}

- (void) setTranslatesAutoresizingMaskIntoConstraints:(BOOL)flag;
{
    #warning Stub
    [self doesNotRecognizeSelector:_cmd];
}

#pragma mark Managing Constraints
- (NSArray*) constraints
{
#warning Stub
    [self doesNotRecognizeSelector:_cmd];
    return [NSArray array];
}

- (void) addConstraint:(NSLayoutConstraint*)constraint
{
#warning Stub
    [self doesNotRecognizeSelector:_cmd];
}

- (void) addConstraints:(NSArray*)constraints
{
#warning Stub
    [self doesNotRecognizeSelector:_cmd];
}

- (void) removeConstraint:(NSLayoutConstraint*)constraint
{
#warning Stub
    [self doesNotRecognizeSelector:_cmd];
}

- (void) removeConstraints:(NSArray*)constraints
{
#warning Stub
    [self doesNotRecognizeSelector:_cmd];
}


#pragma mark Measuring in Constraint-Based Layout

- (CGSize) systemLayoutSizeFittingSize:(CGSize)targetSize
{
#warning Stub
    [self doesNotRecognizeSelector:_cmd];
    return CGSizeZero;
}

- (CGSize) intrinsicContentSize
{
#warning Stub
    [self doesNotRecognizeSelector:_cmd];
    return CGSizeZero;
}

- (void) invalidateIntrinsicContentSize
{
#warning Stub
    [self doesNotRecognizeSelector:_cmd];
}

- (UILayoutPriority) contentCompressionResistancePriorityForAxis:(UILayoutConstraintAxis)axis
{
#warning Stub
    [self doesNotRecognizeSelector:_cmd];
    return 0;
}

- (void) setContentCompressionResistancePriority:(UILayoutPriority)priority forAxis:(UILayoutConstraintAxis)axis
{
#warning Stub
    [self doesNotRecognizeSelector:_cmd];
}

- (UILayoutPriority) contentHuggingPriorityForAxis:(UILayoutConstraintAxis)axis
{
#warning Stub
    [self doesNotRecognizeSelector:_cmd];
    return 0;
}

- (void) setContentHuggingPriority:(UILayoutPriority)priority forAxis:(UILayoutConstraintAxis)axis
{
#warning Stub
    [self doesNotRecognizeSelector:_cmd];
}

#pragma mark Aligning Views with Constraint-Based Layout
- (CGRect) alignmentRectForFrame:(CGRect)frame
{
#warning Stub
    [self doesNotRecognizeSelector:_cmd];
    return CGRectNull;
}

- (CGRect) frameForAlignmentRect:(CGRect)alignmentRect
{
#warning Stub
    [self doesNotRecognizeSelector:_cmd];
    return CGRectNull;
}

- (UIEdgeInsets) alignmentRectInsets
{
#warning Stub
    [self doesNotRecognizeSelector:_cmd];
    return UIEdgeInsetsZero;
}

- (UIView*) viewForBaselineLayout
{
#warning Stub
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}


#pragma mark Triggering Constraint-Based Layout

- (BOOL) needsUpdateConstraints
{
#warning Stub
    [self doesNotRecognizeSelector:_cmd];
    return NO;
}

- (void) setNeedsUpdateConstraints
{
#warning Stub
    [self doesNotRecognizeSelector:_cmd];
}

- (void) updateConstraints
{
#warning Stub
    [self doesNotRecognizeSelector:_cmd];
}

- (void) updateConstraintsIfNeeded
{
#warning Stub
    [self doesNotRecognizeSelector:_cmd];
}


#pragma mark Debugging Constraint-Based Layout

- (NSArray*) constraintsAffectingLayoutForAxis:(UILayoutConstraintAxis)axis
{
#warning Stub
    [self doesNotRecognizeSelector:_cmd];
    return [NSArray array];
}

- (BOOL) hasAmbiguousLayout
{
#warning Stub
    [self doesNotRecognizeSelector:_cmd];
    return NO;
}

- (void) exerciseAmbiguityInLayout
{
#warning Stub
    [self doesNotRecognizeSelector:_cmd];
}


#pragma mark Drawing and Updating the View

- (void) drawRect:(CGRect)rect
{
#warning Stub
    [self doesNotRecognizeSelector:_cmd];
}

- (void) setNeedsDisplay
{
    [_layer setNeedsDisplay];
}

- (void) setNeedsDisplayInRect:(CGRect)invalidRect
{
    [_layer setNeedsDisplayInRect:invalidRect];
}

- (CGFloat) contentScaleFactor
{
    return _flags.layerHasContentScale ? [_layer contentsScale] : 1;
}

- (void) setContentScaleFactor:(CGFloat)scale
{
    if (scale <= 0 && ourDrawRect_) {
        scale = [UIScreen mainScreen].scale;
    }
    
    if (scale > 0 && scale != self.contentScaleFactor) {
        if (_flags.layerHasContentScale) {
            [_layer setContentsScale:scale];
            [self setNeedsDisplay];
        }
    }
}


#pragma mark Formatting Printed View Content

- (UIViewPrintFormatter*) viewPrintFormatter
{
#warning Stub
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

- (void) drawRect:(CGRect)area forViewPrintFormatter:(UIViewPrintFormatter*)formatter
{
#warning Stub
    [self doesNotRecognizeSelector:_cmd];
}


#pragma mark Managing Gesture Recognizers

- (void) addGestureRecognizer:(UIGestureRecognizer*)gestureRecognizer
{
    if (![_gestureRecognizers containsObject:gestureRecognizer]) {
        [gestureRecognizer.view removeGestureRecognizer:gestureRecognizer];
        [_gestureRecognizers addObject:gestureRecognizer];
        [gestureRecognizer _setView:self];
    }
}

- (void) removeGestureRecognizer:(UIGestureRecognizer*)gestureRecognizer
{
    if ([_gestureRecognizers containsObject:gestureRecognizer]) {
        [gestureRecognizer _setView:nil];
        [_gestureRecognizers removeObject:gestureRecognizer];
    }
}

- (NSArray*) gestureRecognizers
{
    return [_gestureRecognizers allObjects];
}

- (void) setGestureRecognizers:(NSArray*)newRecognizers
{
    for (UIGestureRecognizer *gesture in [_gestureRecognizers allObjects]) {
        [self removeGestureRecognizer:gesture];
    }
    
    for (UIGestureRecognizer *gesture in newRecognizers) {
        [self addGestureRecognizer:gesture];
    }
}

- (BOOL) gestureRecognizerShouldBegin:(UIGestureRecognizer*)gestureRecognizer
{
#warning Stub
    [self doesNotRecognizeSelector:_cmd];
    return NO;
}


#pragma mark Animating Views with Blocks

+ (void) animateWithDuration:(NSTimeInterval)duration delay:(NSTimeInterval)delay options:(UIViewAnimationOptions)options animations:(void (^)(void))animations completion:(void (^)(BOOL finished))completion
{
    const BOOL ignoreInteractionEvents = !((options & UIViewAnimationOptionAllowUserInteraction) == UIViewAnimationOptionAllowUserInteraction);
    const BOOL repeatAnimation = ((options & UIViewAnimationOptionRepeat) == UIViewAnimationOptionRepeat);
    const BOOL autoreverseRepeat = ((options & UIViewAnimationOptionAutoreverse) == UIViewAnimationOptionAutoreverse);
    const BOOL beginFromCurrentState = ((options & UIViewAnimationOptionBeginFromCurrentState) == UIViewAnimationOptionBeginFromCurrentState);
    UIViewAnimationCurve animationCurve;
    
    if ((options & UIViewAnimationOptionCurveEaseInOut) == UIViewAnimationOptionCurveEaseInOut) {
        animationCurve = UIViewAnimationCurveEaseInOut;
    } else if ((options & UIViewAnimationOptionCurveEaseIn) == UIViewAnimationOptionCurveEaseIn) {
        animationCurve = UIViewAnimationCurveEaseIn;
    } else if ((options & UIViewAnimationOptionCurveEaseOut) == UIViewAnimationOptionCurveEaseOut) {
        animationCurve = UIViewAnimationCurveEaseOut;
    } else {
        animationCurve = UIViewAnimationCurveLinear;
    }
    
    // NOTE: As of iOS 5 this is only supposed to block interaction events for the views being animated, not the whole app.
    if (ignoreInteractionEvents) {
        [[UIApplication sharedApplication] beginIgnoringInteractionEvents];
    }
    
    UIViewBlockAnimationDelegate *delegate = [[UIViewBlockAnimationDelegate alloc] init];
    delegate.completion = completion;
    delegate.ignoreInteractionEvents = ignoreInteractionEvents;
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationCurve:animationCurve];
    [UIView setAnimationDelay:delay];
    [UIView setAnimationDuration:duration];
    [UIView setAnimationBeginsFromCurrentState:beginFromCurrentState];
    [UIView setAnimationDelegate:delegate];	// this is retained here
    [UIView setAnimationDidStopSelector:@selector(animationDidStop:finished:)];
    [UIView setAnimationRepeatCount:(repeatAnimation? FLT_MAX : 0)];
    [UIView setAnimationRepeatAutoreverses:autoreverseRepeat];
    
    @try {
        animations();
    } @finally {
        [UIView commitAnimations];
        delegate = nil;
    }
}

+ (void) animateWithDuration:(NSTimeInterval)duration animations:(void (^)(void))animations completion:(void (^)(BOOL finished))completion
{
    [self animateWithDuration:duration
                        delay:0
                      options:UIViewAnimationOptionCurveEaseInOut | UIViewAnimationOptionTransitionNone
                   animations:animations
                   completion:completion];
}

+ (void) animateWithDuration:(NSTimeInterval)duration animations:(void (^)(void))animations
{
    [self animateWithDuration:duration animations:animations completion:NULL];
}

+ (void) transitionWithView:(UIView*)view duration:(NSTimeInterval)duration options:(UIViewAnimationOptions)options animations:(void (^)(void))animations completion:(void (^)(BOOL finished))completio
{
#warning Stub
    [self doesNotRecognizeSelector:_cmd];
}

+ (void) transitionFromView:(UIView*)fromView toView:(UIView*)toView duration:(NSTimeInterval)duration options:(UIViewAnimationOptions)options completion:(void (^)(BOOL finished))completion
{
#warning Stub
    [self doesNotRecognizeSelector:_cmd];
}


#pragma mark Animating Views

+ (void) beginAnimations:(NSString*)animationID context:(void*)context
{
    [_animationGroups addObject:[UIViewAnimationGroup animationGroupWithName:animationID context:context]];
}

+ (void) commitAnimations
{
    if ([_animationGroups count] > 0) {
        [[_animationGroups lastObject] commit];
        [_animationGroups removeLastObject];
    }
}

+ (void) setAnimationStartDate:(NSDate*)startTime
{
#warning Stub
    [self doesNotRecognizeSelector:_cmd];
}

+ (void) setAnimationsEnabled:(BOOL)enabled
{
    _animationsEnabled = enabled;
}

+ (void) setAnimationDelegate:(id)delegate
{
    [[_animationGroups lastObject] setAnimationDelegate:delegate];
}

+ (void) setAnimationWillStartSelector:(SEL)selector
{
    [[_animationGroups lastObject] setAnimationWillStartSelector:selector];
}

+ (void) setAnimationDidStopSelector:(SEL)selector
{
    [[_animationGroups lastObject] setAnimationDidStopSelector:selector];
}

+ (void) setAnimationDuration:(NSTimeInterval)duration
{
    [[_animationGroups lastObject] setAnimationDuration:duration];
}

+ (void) setAnimationDelay:(NSTimeInterval)delay
{
    [[_animationGroups lastObject] setAnimationDelay:delay];
}

+ (void) setAnimationCurve:(UIViewAnimationCurve)curve
{
    [(UIViewAnimationGroup*)[_animationGroups lastObject] setAnimationCurve:curve];
}

+ (void) setAnimationRepeatCount:(float)repeatCount
{
    [[_animationGroups lastObject] setAnimationRepeatCount:repeatCount];
}

+ (void) setAnimationRepeatAutoreverses:(BOOL)repeatAutoreverses
{
    [[_animationGroups lastObject] setAnimationRepeatAutoreverses:repeatAutoreverses];
}

+ (void) setAnimationBeginsFromCurrentState:(BOOL)beginFromCurrentState
{
    [[_animationGroups lastObject] setAnimationBeginsFromCurrentState:beginFromCurrentState];
}

+ (void) setAnimationTransition:(UIViewAnimationTransition)transition forView:(UIView*)view cache:(BOOL)cache
{
    [[_animationGroups lastObject] setAnimationTransition:transition forView:view cache:cache];
}

+ (BOOL) areAnimationsEnabled
{
    return _animationsEnabled;
}


#pragma mark Preserving and Restoring State

- (void) encodeRestorableStateWithCoder:(NSCoder*)coder
{
#warning Stub
    [self doesNotRecognizeSelector:_cmd];
}

- (void) decodeRestorableStateWithCoder:(NSCoder*)coder
{
#warning Stub
    [self doesNotRecognizeSelector:_cmd];
}


#pragma mark Identifying the View at Runtime

- (UIView*) viewWithTag:(NSInteger)tagToFind
{
    UIView* foundView = nil;
    
    if (self.tag == tagToFind) {
        foundView = self;
    } else {
        for (UIView* view in [self.subviews reverseObjectEnumerator]) {
            foundView = [view viewWithTag:tagToFind];
            if (foundView) {
                break;
            }
        }
    }
    
    return foundView;
}


#pragma mark Converting Between View Coordinate Systems

- (CGPoint) convertPoint:(CGPoint)toConvert toView:(UIView*)toView
{
    assert(!toView || toView.window == self.window);
    if (self == toView) {
        return toConvert;
    } else if (toView) {
        return [self.layer convertPoint:toConvert toLayer:toView.layer];
    } else {
        return [self.layer convertPoint:toConvert toLayer:self.window.layer];
    }
}

- (CGPoint) convertPoint:(CGPoint)toConvert fromView:(UIView*)fromView
{
    assert(!fromView || fromView.window == self.window);
    if (fromView) {
        return [fromView.layer convertPoint:toConvert toLayer:self.layer];
    } else {
        return [self.window.layer convertPoint:toConvert toLayer:self.layer];
    }
}

- (CGRect) convertRect:(CGRect)toConvert toView:(UIView*)toView
{
    CGRect newRect = {
        .origin = [self convertPoint:toConvert.origin toView:toView],
        .size = toConvert.size
    };
    return newRect;
}

- (CGRect) convertRect:(CGRect)toConvert fromView:(UIView*)fromView
{
    CGRect newRect = {
        .origin = [self convertPoint:toConvert.origin fromView:fromView],
        .size = toConvert.size
    };
    return newRect;
}

#pragma mark Hit Testing in a View

- (UIView*) hitTest:(CGPoint)point withEvent:(UIEvent*)event
{
    if (self.hidden || !self.userInteractionEnabled || self.alpha < 0.01 || ![self pointInside:point withEvent:event]) {
        return nil;
    } else {
        for (UIView *subview in [self.subviews reverseObjectEnumerator]) {
            UIView *hitView = [subview hitTest:[subview convertPoint:point fromView:self] withEvent:event];
            if (hitView) {
                return hitView;
            }
        }
        return self;
    }
}

- (BOOL) pointInside:(CGPoint)point withEvent:(UIEvent*)event
{
    return CGRectContainsPoint(self.bounds, point);
}


#pragma mark Ending a View Editing Session

- (BOOL) endEditing:(BOOL)force
{
#warning Stub
    [self doesNotRecognizeSelector:_cmd];
    return NO;
}


#pragma mark Observing View-Related Changes

- (void) didAddSubview:(UIView*)subview
{
    // Intentionally Empty
}

- (void) willRemoveSubview:(UIView*)subview
{
    // Intentionally Empty
}

- (void) willMoveToSuperview:(UIView*)newSuperview
{
    // Intentionally Empty
}

- (void) didMoveToSuperview
{
    // Intentionally Empty
}

- (void) willMoveToWindow:(UIWindow*)newWindow
{
    // Intentionally Empty
}

- (void) didMoveToWindow
{
    // Intentionally Empty
}


#pragma Overridden UIResponder Methods

- (UIResponder*) nextResponder
{
    return (UIResponder*)[self _viewController] ?: (UIResponder*)_superview;
}


#pragma mark CALayer Delegate

- (void) displayLayer:(CALayer*)theLayer
{
}

- (void) drawLayer:(CALayer*)layer inContext:(CGContextRef)c
{
    // We only get here if the UIView subclass implements drawRect:. To do this without a drawRect: is a huge waste of memory.
    // See the discussion in drawLayer: above.
    NSAssert(ourDrawRect_, @"???");
    
    const CGRect bounds = CGContextGetClipBoundingBox(c);
    
    UIGraphicsPushContext(c);
    CGContextSaveGState(c);
    
    if (_backgroundColor) {
        [_backgroundColor setFill];
        CGContextFillRect(c, bounds);
    } else if (_flags.clearsContextBeforeDrawing) {
        CGContextClearRect(c, bounds);
    }
    
    const BOOL shouldSmoothFonts = (_backgroundColor && (CGColorGetAlpha(_backgroundColor.CGColor) == 1)) || self.opaque;
    CGContextSetShouldSmoothFonts(c, shouldSmoothFonts);
    CGContextSetShouldSubpixelPositionFonts(c, YES);
    CGContextSetShouldSubpixelQuantizeFonts(c, YES);
    
    [[UIColor blackColor] set];
    ourDrawRect_(self, drawRectSelector, bounds);
    
    CGContextRestoreGState(c);
    UIGraphicsPopContext();
}

- (void) layoutSublayersOfLayer:(CALayer*)layer
{
#warning Stub
    [self doesNotRecognizeSelector:_cmd];
}

- (id) actionForLayer:(CALayer*)theLayer forKey:(NSString*)event
{
    if (_animationsEnabled && [_animationGroups lastObject] && theLayer == _layer) {
        return [[_animationGroups lastObject] actionForView:self forKey:event] ?: (id)[NSNull null];
    } else {
        return [NSNull null];
    }
}


#pragma mark NSObject Protocol

- (BOOL) respondsToSelector:(SEL)aSelector
{
    // For notes about why this is done, see displayLayer: above.
    if (aSelector == @selector(drawLayer:inContext:)) {
        return nil != ourDrawRect_;
    } else if (aSelector == @selector(displayLayer:)) {
        return _flags.overridesDisplayLayer || nil == ourDrawRect_;
    } else {
        return [super respondsToSelector:aSelector];
    }
}

#pragma mark NSCoding Protocol

- (void) encodeWithCoder:(NSCoder*)coder
{
#warning Stub
    [self doesNotRecognizeSelector:_cmd];
}


#pragma mark NSLayerDelegateContentsScaleUpdating Protocol Reference

- (BOOL) layer:(CALayer*)layer shouldInheritContentsScale:(CGFloat)newScale fromWindow:(NSWindow *)window
{
    _layer.backgroundColor = [self.backgroundColor _bestRepresentationForProposedScale:self.window.screen.scale].CGColor;
    [self setNeedsDisplay];
    return YES;
}


#pragma mark Misc.

+ (NSSet*) keyPathsForValuesAffectingFrame
{
    return [NSSet setWithObject:@"center"];
}

- (NSString*) description
{
    return [NSString stringWithFormat:@"<%@: %p; frame = %@; hidden = %@; layer = %@>", [self className], self, NSStringFromCGRect(self.frame), (self.hidden ? @"YES" : @"NO"), self.layer];
}

#pragma mark private methods

- (void) _willMoveFromWindow:(UIWindow*)fromWindow toWindow:(UIWindow*)toWindow
{
    if (fromWindow != toWindow) {
        if ([self isFirstResponder]) {
            [self resignFirstResponder];
        }
        
        [_viewController _viewWillMoveToWindow:toWindow];
        [self _setAppearanceNeedsUpdate];
        [self willMoveToWindow:toWindow];

        for (UIView*subview in self.subviews) {
            [subview _willMoveFromWindow:fromWindow toWindow:toWindow];
        }
    }
}

- (void) _didMoveFromWindow:(UIWindow*)fromWindow toWindow:(UIWindow*)toWindow
{
    if (fromWindow != toWindow) {
        [_viewController _viewDidMoveToWindow:toWindow];
        [self didMoveToWindow];
		
        for (UIView *subview in self.subviews) {
            [subview _didMoveFromWindow:fromWindow toWindow:toWindow];
        }
    }
}

- (void) _didMoveToScreenWithScale:(CGFloat)scale
{
    if (ourDrawRect_ && self.contentScaleFactor != scale) {
        self.contentScaleFactor = scale;
    } else {
        [self setNeedsDisplay];
    }
    for (UIView *subview in self.subviews) {
        [subview _didMoveToScreenWithScale:scale];
    }
}

- (void) _setViewController:(UIViewController*)theViewController
{
    _viewController = theViewController;
}

- (UIViewController*) _viewController
{
    return _viewController;
}

- (id) _appearanceContainer
{
    return self.superview;
}

- (void) _superviewSizeDidChangeFrom:(CGSize)oldSize to:(CGSize)newSize
{
    if (_autoresizingMask != UIViewAutoresizingNone) {
        CGRect frame = self.frame;
        const CGSize delta = CGSizeMake(newSize.width-oldSize.width, newSize.height-oldSize.height);
        
#define hasAutoresizingFor(x) ((_autoresizingMask & (x)) == (x))
        
        /*
         
         top + bottom + height      => y = floor(y + (y / HEIGHT * delta)); height = floor(height + (height / HEIGHT * delta))
         top + height               => t = y + height; y = floor(y + (y / t * delta); height = floor(height + (height / t * delta);
         bottom + height            => height = floor(height + (height / (HEIGHT - y) * delta))
         top + bottom               => y = floor(y + (delta / 2))
         height                     => height = floor(height + delta)
         top                        => y = floor(y + delta)
         bottom                     => y = floor(y)
         
         */
        
        if (hasAutoresizingFor(UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleBottomMargin)) {
            frame.origin.y = floorf(frame.origin.y + (frame.origin.y / oldSize.height * delta.height));
            frame.size.height = floorf(frame.size.height + (frame.size.height / oldSize.height * delta.height));
        } else if (hasAutoresizingFor(UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleHeight)) {
            const CGFloat t = frame.origin.y + frame.size.height;
            frame.origin.y = floorf(frame.origin.y + (frame.origin.y / t * delta.height));
            frame.size.height = floorf(frame.size.height + (frame.size.height / t * delta.height));
        } else if (hasAutoresizingFor(UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleHeight)) {
            frame.size.height = floorf(frame.size.height + (frame.size.height / (oldSize.height - frame.origin.y) * delta.height));
        } else if (hasAutoresizingFor(UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleTopMargin)) {
            frame.origin.y = floorf(frame.origin.y + (delta.height / 2.f));
        } else if (hasAutoresizingFor(UIViewAutoresizingFlexibleHeight)) {
            frame.size.height = floorf(frame.size.height + delta.height);
        } else if (hasAutoresizingFor(UIViewAutoresizingFlexibleTopMargin)) {
            frame.origin.y = floorf(frame.origin.y + delta.height);
        } else if (hasAutoresizingFor(UIViewAutoresizingFlexibleBottomMargin)) {
            frame.origin.y = floorf(frame.origin.y);
        }
        
        if (hasAutoresizingFor(UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleRightMargin)) {
            frame.origin.x = floorf(frame.origin.x + (frame.origin.x / oldSize.width * delta.width));
            frame.size.width = floorf(frame.size.width + (frame.size.width / oldSize.width * delta.width));
        } else if (hasAutoresizingFor(UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleWidth)) {
            const CGFloat t = frame.origin.x + frame.size.width;
            frame.origin.x = floorf(frame.origin.x + (frame.origin.x / t * delta.width));
            frame.size.width = floorf(frame.size.width + (frame.size.width / t * delta.width));
        } else if (hasAutoresizingFor(UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleWidth)) {
            frame.size.width = floorf(frame.size.width + (frame.size.width / (oldSize.width - frame.origin.x) * delta.width));
        } else if (hasAutoresizingFor(UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleLeftMargin)) {
            frame.origin.x = floorf(frame.origin.x + (delta.width / 2.f));
        } else if (hasAutoresizingFor(UIViewAutoresizingFlexibleWidth)) {
            frame.size.width = floorf(frame.size.width + delta.width);
        } else if (hasAutoresizingFor(UIViewAutoresizingFlexibleLeftMargin)) {
            frame.origin.x = floorf(frame.origin.x + delta.width);
        } else if (hasAutoresizingFor(UIViewAutoresizingFlexibleRightMargin)) {
            frame.origin.x = floorf(frame.origin.x);
        }
        
        self.frame = frame;
    }
}

- (void) _boundsDidChangeFrom:(CGRect)oldBounds to:(CGRect)newBounds
{
    if (CGRectEqualToRect(oldBounds, newBounds)) {
        return;
    }
    if (!CGSizeEqualToSize(oldBounds.size, newBounds.size)) {
        if (_flags.autoresizesSubviews) {
            for (UIView* subview in _subviews) {
                [subview _superviewSizeDidChangeFrom:oldBounds.size to:newBounds.size];
            }
        }
    }
}

- (void) _layoutSubviews
{
    [self _updateAppearanceIfNeeded];
    [[self _viewController] viewWillLayoutSubviews];
    [self layoutSubviews];
    [[self _viewController] viewDidLayoutSubviews];
}

@end
