#import "_UITextInteractionAssistant.h"
#import "_UITextInputPlus.h"
//
#import <UIKit/UIView.h>
#import <UIKit/UIGestureRecognizer.h>
#import <UIKit/UITapGestureRecognizer.h>


@interface _UITextInteractionAssistant () <UIGestureRecognizerDelegate>
@end


@implementation _UITextInteractionAssistant {
    UIView<_UITextInputPlus>* _view;
    UITapGestureRecognizer* _singleTapGesture;
    struct {
        bool beginSelectionChange : 1;
        bool endSelectionChange : 1;
    } _viewHas;
}

- (instancetype) initWithView:(UIView<UITextInput>*)view
{
    NSAssert(nil != view, @"???");
    if (nil != (self = [super init])) {
        _view = (UIView<_UITextInputPlus>*)view;
        _viewHas.beginSelectionChange = [view respondsToSelector:@selector(beginSelectionChange)];
        _viewHas.endSelectionChange = [view respondsToSelector:@selector(endSelectionChange)];
    }
    return self;
}


#pragma mark Properties

- (UITapGestureRecognizer*) singleTapGesture
{
    if (!_singleTapGesture) {
        _singleTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(oneFingerTap:)];
    }
    return _singleTapGesture;
}


#pragma mark Gesture Handlers

- (void) oneFingerTap:(UIGestureRecognizer*)gestureRecognizer
{
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


#pragma Private Methods

- (void) setFirstResponderIfNecessary
{
    if (![_view isFirstResponder]) {
        [_view becomeFirstResponder];
    }
}

@end
