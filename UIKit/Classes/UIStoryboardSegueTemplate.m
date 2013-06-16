#import "UIStoryboardSegueTemplate.h"


static NSString* const kUIDestinationViewControllerIdentifierKey = @"UIDestinationViewControllerIdentifier";
static NSString* const kUIIdentifierKey                          = @"UIIdentifier";


@implementation UIStoryboardSegueTemplate {
    NSString* _segueClassName;
    NSString* _destinationViewControllerIdentifier;
}

- (id) initWithCoder:(NSCoder*)coder
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

- (id) defaultSegueClassName
{
    return nil;
}

- (Class) effectiveSegueClass
{
    return nil;
}

- (void) perform:(id)perform
{
}

- (id) segueWithDestinationViewController:(UIViewController*)destinationViewController
{
    return nil;
}

@end
