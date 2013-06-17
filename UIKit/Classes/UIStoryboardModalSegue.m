#import "UIStoryboardModalSegue.h"


@implementation UIStoryboardModalSegue

- (void) perform
{
    UIViewController* destination = [self destinationViewController];
    if (![self useDefaultModalTransitionStyle]) {
        [destination setModalTransitionStyle:[self modalTransitionStyle]];
    }
    if (![self useDefaultModalPresentationStyle]) {
        [destination setModalPresentationStyle:[self modalPresentationStyle]];
    }
    [[self sourceViewController] presentModalViewController:[self destinationViewController] animated:[self animates]];
}

@end
