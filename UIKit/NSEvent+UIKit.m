#import "NSEvent+UIKit.h"
#import "UIScreen+AppKit.h"
#import "UIKitView.h"


@implementation NSEvent (UIKit)

- (CGPoint) locationInScreen:(UIScreen*)screen
{
    CGPoint screenLocation = [[screen UIKitView] convertPoint:[self locationInWindow] fromView:nil];
    if (![[screen UIKitView] isFlipped]) {
        screenLocation.y = screen.bounds.size.height - screenLocation.y - 1;
    }
    return screenLocation;
}

@end
