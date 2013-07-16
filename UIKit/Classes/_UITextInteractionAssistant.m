#import "_UITextInteractionAssistant.h"
#import "UITapGestureRecognizer.h"


@implementation _UITextInteractionAssistant {
    UITapGestureRecognizer* _singleTapGesture;
}

- (instancetype) initWithView:(UIResponder<UITextInput>*)view
{
    NSAssert(nil != view, @"???");
    if (nil != (self = [super init])) {
        _view = view;
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

- (void) oneFingerTap:(id)sender
{
    [self setFirstResponderIfNecessary];
}


#pragma Private Methods

- (void) setFirstResponderIfNecessary
{
    if (![_view isFirstResponder]) {
        [_view becomeFirstResponder];
    }
}

@end
