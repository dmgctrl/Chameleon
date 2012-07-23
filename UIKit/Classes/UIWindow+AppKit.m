#import "UIWindow+AppKit.h"
#import "UIWindow+UIPrivate.h"
#import "UIView+AppKit.h"

@implementation UIWindow (UIWindowAppKitIntegration)

- (void) selectPreviousKeyView:(id)sender
{
    UIResponder* firstResponder = [self _firstResponder];
    UIView* prev = [firstResponder isKindOfClass:[UIView class]] ? [(UIView*)firstResponder previousValidKeyView] : nil;
    [prev becomeFirstResponder];
}

- (void) insertBacktab:(id)sender
{
    [self selectPreviousKeyView:sender];
}

- (void) selectNextKeyView:(id)sender
{
    UIResponder* firstResponder = [self _firstResponder];
    UIView* next = [firstResponder isKindOfClass:[UIView class]] ? [(UIView*)firstResponder nextValidKeyView] : nil;
    [next becomeFirstResponder];
}

- (void) insertTab:(id)sender
{
    [self selectNextKeyView:sender];
}


@end
