#import "UIStoryboardSegueTemplate.h"


static NSString* const kUIDestinationViewControllerIdentifierKey = @"UIDestinationViewControllerIdentifier";
static NSString* const kUIIdentifierKey                          = @"UIIdentifier";


@implementation UIStoryboardSegueTemplate

- (instancetype) initWithCoder:(NSCoder*)coder
{
    if (nil != (self = [super init])) {
        _destinationViewControllerIdentifier = [coder decodeObjectForKey:kUIDestinationViewControllerIdentifierKey];
        _identifier = [coder decodeObjectForKey:kUIIdentifierKey];
    }
    return self;
}

- (void) encodeWithCoder:(NSCoder *)aCoder
{
    [self doesNotRecognizeSelector:_cmd];
}

- (Class) effectiveSegueClass
{
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

- (UIStoryboardSegue*) segueWithDestinationViewController:(UIViewController*)destinationViewController
{
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

@end
