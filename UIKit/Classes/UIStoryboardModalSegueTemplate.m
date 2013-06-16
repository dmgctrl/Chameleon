#import "UIStoryboardModalSegueTemplate.h"


static NSString* const kUIModalTransitionStyleKey   = @"UIModalTransitionStyle";
static NSString* const kUIModalPresentationStyleKey = @"UIModalPresentationStyle";
static NSString* const kUIAnimatesKey               = @"UIAnimates";


@implementation UIStoryboardModalSegueTemplate

- (id) initWithCoder:(NSCoder*)coder
{
    if (nil != (self = [super initWithCoder:coder])) {
        if ([coder containsValueForKey:kUIModalTransitionStyleKey]) {
            _modalTransitionStyle = [coder decodeIntForKey:kUIModalTransitionStyleKey];
        } else {
            _useDefaultModalTransitionStyle = YES;
        }

        if ([coder containsValueForKey:kUIModalPresentationStyleKey]) {
            _modalPresentationStyle = [coder decodeIntForKey:kUIModalPresentationStyleKey];
        } else {
            _useDefaultModalPresentationStyle = YES;
        }

        if ([coder containsValueForKey:kUIAnimatesKey]) {
            _animates = [coder decodeBoolForKey:kUIAnimatesKey];
        } else {
            _animates = YES;
        }
    }
    return self;
}

@end
