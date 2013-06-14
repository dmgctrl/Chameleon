#import <Foundation/Foundation.h>
#import "UIRuntimeEventConnection.h"

@interface UIRuntimeOutletConnection : NSObject <NSCoding>

@property (strong, nonatomic) id target;
@property (strong, nonatomic) id value;
@property (strong, nonatomic) NSString* key;

- (void) connect;

@end
