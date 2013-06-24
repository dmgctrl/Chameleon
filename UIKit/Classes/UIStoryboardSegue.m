#import "UIStoryboardSegue.h"
#import "UIStoryboardSegue+UIPrivate.h"


@implementation UIStoryboardSegue

+ (id) segueWithIdentifier:(NSString*)identifier source:(UIViewController*)source destination:(UIViewController*)destination performHandler:(dispatch_block_t)handler
{
    UIStoryboardSegue* segue = [[[self class] alloc] initWithIdentifier:identifier source:source destination:destination];
    [segue setPerformHandler:handler];
    return segue;
}

- (id) initWithIdentifier:(NSString*)identifier source:(UIViewController*)source destination:(UIViewController*)destination
{
    if (nil != (self = [super init])) {
        _identifier = identifier;
        _sourceViewController = source;
        _destinationViewController = destination;
    }
    return self;
}

- (void) perform
{
    if (_performHandler) {
        _performHandler();
    } else {
        [NSException raise:NSInternalInconsistencyException format:@"Subclasses of UIStoryboardSegue must override -perform."];
    }
}

@end
