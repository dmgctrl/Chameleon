#import "UIStoryboardPushSegue.h"
#import "UINavigationController.h"


@implementation UIStoryboardPushSegue

- (void) perform
{
    [[[self sourceViewController] navigationController] pushViewController:[self destinationViewController] animated:YES];
}

@end
