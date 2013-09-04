#import <Foundation/Foundation.h>

@class UIViewController;

@protocol UIViewControllerRestoration
+ (UIViewController*) viewControllerWithRestorationIdentifierPath:(NSArray*)identifierComponents coder:(NSCoder*)coder;
@end

