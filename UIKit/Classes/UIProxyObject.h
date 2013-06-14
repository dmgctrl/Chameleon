#import <Foundation/Foundation.h>

@interface UIProxyObject : NSObject <NSCoding>

@property (strong) NSString* proxiedObjectIdentifier;

- (id) initWithCoder:(NSCoder*)coder;
- (void)encodeWithCoder:(NSCoder*)coder;

@end
