#import "UIStoryboardModalSegueTemplate.h"
#import "UIStoryboardModalSegue.h"
#import "UIStoryboardSegue+UIPrivate.h"


static NSString* const kUIModalTransitionStyleKey   = @"UIModalTransitionStyle";
static NSString* const kUIModalPresentationStyleKey = @"UIModalPresentationStyle";
static NSString* const kUIAnimatesKey               = @"UIAnimates";


@implementation UIStoryboardModalSegueTemplate

- (instancetype) initWithCoder:(NSCoder*)coder
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

- (Class) effectiveSegueClass
{
    return [UIStoryboardModalSegue class];
}

- (UIStoryboardSegue*) segueWithDestinationViewController:(UIViewController*)destinationViewController
{
    UIStoryboardModalSegue* segue = [[UIStoryboardModalSegue alloc] initWithIdentifier:[self identifier] source:[self viewController] destination:destinationViewController];
    [segue setAnimates:[self animates]];
    [segue setModalPresentationStyle:[self modalPresentationStyle]];
    [segue setModalTransitionStyle:[self modalTransitionStyle]];
    [segue setUseDefaultModalPresentationStyle:[self useDefaultModalPresentationStyle]];
    [segue setUseDefaultModalTransitionStyle:[self useDefaultModalTransitionStyle]];
    return segue;
}

@end
