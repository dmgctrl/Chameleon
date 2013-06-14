#import "UIProxyObject.h"


static NSString* const kUIProxiedObjectIdentifierKey = @"UIProxiedObjectIdentifier";


@implementation UIProxyObject

- (id) initWithCoder:(NSCoder*)coder
{
    if (nil != (self = [super init])) {
        self.proxiedObjectIdentifier = [coder decodeObjectForKey:kUIProxiedObjectIdentifierKey];
    }
    return self;
}

- (void) encodeWithCoder:(NSCoder*)coder
{
    [self doesNotRecognizeSelector:_cmd];
}

@end
