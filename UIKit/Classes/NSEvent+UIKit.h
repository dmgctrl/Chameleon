#import <AppKit/NSEvent.h>

@class UIScreen;

@interface NSEvent (UIKit)

- (CGPoint) locationInScreen:(UIScreen*)screen;

@end
