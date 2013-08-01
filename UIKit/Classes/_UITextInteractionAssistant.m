#import "_UITextInteractionAssistant.h"
#import "_UITextInputPlus.h"
//
#import <UIKit/UIView.h>
#import <UIKit/UIGestureRecognizer.h>
#import <UIKit/UITapGestureRecognizer.h>


@interface _UITextInteractionAssistant () <UIGestureRecognizerDelegate>
@end


@implementation _UITextInteractionAssistant {
    NSMutableArray* _gestureRecognizers;
    struct {
        bool beginSelectionChange : 1;
        bool endSelectionChange : 1;
        bool textRangeOfWordContainingPosition : 1;
    } _viewHas;
}

- (instancetype) initWithView:(UIResponder<UITextInput>*)view
{
    NSAssert(nil != view, @"???");
    if (nil != (self = [super init])) {
        _view = (UIView<_UITextInputPlus>*)view;
        _viewHas.beginSelectionChange = [view respondsToSelector:@selector(beginSelectionChange)];
        _viewHas.endSelectionChange = [view respondsToSelector:@selector(endSelectionChange)];
        _viewHas.textRangeOfWordContainingPosition = [view respondsToSelector:@selector(textRangeOfWordContainingPosition:)];
        _gestureRecognizers = [[NSMutableArray alloc] init];
    }
    return self;
}


#pragma mark Public Methods

- (UITapGestureRecognizer*) addOneFingerTapRecognizerToView:(UIView*)view
{
    UITapGestureRecognizer* gesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(oneFingerTap:)];
    [gesture setNumberOfTapsRequired:1];
    [gesture setNumberOfTouchesRequired:1];
    [view addGestureRecognizer:gesture];
    [_gestureRecognizers addObject:gesture];
    return gesture;
}

- (UITapGestureRecognizer*) addOneFingerDoubleTapRecognizerToView:(UIView*)view
{
    UITapGestureRecognizer* gesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(oneFingerDoubleTap:)];
    [gesture setNumberOfTapsRequired:2];
    [gesture setNumberOfTouchesRequired:1];
    [view addGestureRecognizer:gesture];
    [_gestureRecognizers addObject:gesture];
    return gesture;
}

- (void) removeGestureRecognizersFromView:(UIView*)view
{
    NSMutableArray* newGestureRecognizers = [[NSMutableArray alloc] initWithCapacity:[_gestureRecognizers count]];
    for (UIGestureRecognizer* gestureRecognizer in _gestureRecognizers) {
        if ([gestureRecognizer view] == view) {
            [view removeGestureRecognizer:gestureRecognizer];
        } else {
            [newGestureRecognizers addObject:gestureRecognizer];
        }
    }
    _gestureRecognizers = newGestureRecognizers;
}


#pragma mark Gesture Handlers

- (void) oneFingerTap:(UIGestureRecognizer*)gestureRecognizer
{
    if ([gestureRecognizer state] == UIGestureRecognizerStateEnded) {
        [self setFirstResponderIfNecessary];
        UIView<_UITextInputPlus>* view = (UIView<_UITextInputPlus>*)[self view];
        if (_viewHas.beginSelectionChange) {
            [view beginSelectionChange];
        }
        UITextPosition* position = [view closestPositionToPoint:[gestureRecognizer locationInView:view]];
        UITextRange* range = [view textRangeFromPosition:position toPosition:position];
        [view setSelectedTextRange:range];
        if (_viewHas.endSelectionChange) {
            [view endSelectionChange];
        }
    }
}

- (void) oneFingerDoubleTap:(UITapGestureRecognizer*)gestureRecognizer
{
    if ([gestureRecognizer state] == UIGestureRecognizerStateEnded) {
        [self setFirstResponderIfNecessary];
        if (_viewHas.textRangeOfWordContainingPosition) {
            UIView<_UITextInputPlus>* view = (UIView<_UITextInputPlus>*)[self view];
            if (_viewHas.beginSelectionChange) {
                [view beginSelectionChange];
            }
            UITextPosition* position = [view closestPositionToPoint:[gestureRecognizer locationInView:view]];
            UITextRange* range = [view textRangeOfWordContainingPosition:position];
            [view setSelectedTextRange:range];
            if (_viewHas.endSelectionChange) {
                [view endSelectionChange];
            }
        }
    }
}


#pragma Private Methods

- (void) setFirstResponderIfNecessary
{
    if (![_view isFirstResponder]) {
        [_view becomeFirstResponder];
    }
}

@end



