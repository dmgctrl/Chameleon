#import "UIStoryboardSegue.h"

@interface UIStoryboardSegue ()

@property (copy, nonatomic) dispatch_block_t performHandler;

+ (instancetype) segueWithIdentifier:(NSString*)identifier source:(UIViewController*)source destination:(UIViewController*)destination performHandler:(dispatch_block_t)handler;

@end
