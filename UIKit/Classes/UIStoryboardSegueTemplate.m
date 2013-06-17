#import "UIStoryboardSegueTemplate.h"
#import "UIStoryboardSegue.h"


static NSString* const kUIDestinationViewControllerIdentifierKey = @"UIDestinationViewControllerIdentifier";
static NSString* const kUIIdentifierKey                          = @"UIIdentifier";
static NSString* const kUISegueClassNameKey                      = @"UISegueClassName";


@implementation UIStoryboardSegueTemplate {
    NSString* _segueClassName;
}

- (instancetype) initWithCoder:(NSCoder*)coder
{
    if (nil != (self = [super init])) {
        _destinationViewControllerIdentifier = [coder decodeObjectForKey:kUIDestinationViewControllerIdentifierKey];
        _identifier = [coder decodeObjectForKey:kUIIdentifierKey];
        _segueClassName = [coder decodeObjectForKey:kUISegueClassNameKey];
    }
    return self;
}

- (void) encodeWithCoder:(NSCoder *)aCoder
{
    [self doesNotRecognizeSelector:_cmd];
}

- (Class) effectiveSegueClass
{
    return NSClassFromString(_segueClassName);
}

- (UIStoryboardSegue*) segueWithDestinationViewController:(UIViewController*)destinationViewController
{
    return [[[self effectiveSegueClass] alloc] initWithIdentifier:[self identifier] source:[self viewController] destination:destinationViewController];
}

@end
