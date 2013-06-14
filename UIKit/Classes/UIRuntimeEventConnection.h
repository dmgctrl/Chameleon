#import <Foundation/Foundation.h>
#import "UIControl.h"

@interface UIRuntimeEventConnection : NSObject <NSCoding>

@property (strong, nonatomic) UIControl* control;
@property (strong, nonatomic) id target;
@property (assign, nonatomic) SEL action;
@property (assign, nonatomic) UIControlEvents eventMask;

- (void) connect;

@end