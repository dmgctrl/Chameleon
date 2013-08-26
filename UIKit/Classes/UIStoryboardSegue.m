#import <UIKit/UIStoryboardSegue.h>
#import <UIKit/UIStoryboardSegue+UIPrivate.h>


@implementation UIStoryboardSegue

#pragma mark Initializing a Storyboard Segue

- (id) initWithIdentifier:(NSString*)identifier source:(UIViewController*)source destination:(UIViewController*)destination
{
    if (nil != (self = [super init])) {
        _identifier = identifier;
        _sourceViewController = source;
        _destinationViewController = destination;
    }
    return self;
}


#pragma mark Performing the Segue

- (void) perform
{
    if (_performHandler) {
        _performHandler();
    } else {
        [NSException raise:NSInternalInconsistencyException format:@"Subclasses of UIStoryboardSegue must override -perform."];
    }
}


#pragma mark Creating a Custom Segue

+ (id) segueWithIdentifier:(NSString*)identifier source:(UIViewController*)source destination:(UIViewController*)destination performHandler:(dispatch_block_t)handler
{
    UIStoryboardSegue* segue = [[[self class] alloc] initWithIdentifier:identifier source:source destination:destination];
    [segue setPerformHandler:handler];
    return segue;
}

@end
