#import "UIRuntimeOutletConnection.h"


static NSString* const kUIDestinationKey = @"UIDestination";
static NSString* const kUILabelKey = @"UILabel";
static NSString* const kUISourceKey = @"UISource";


@implementation UIRuntimeOutletConnection 

- (id) initWithCoder:(NSCoder*)coder
{
    if (nil != (self = [super init])) {
        self.target = [coder decodeObjectForKey:kUISourceKey];
        self.value = [coder decodeObjectForKey:kUIDestinationKey];
        self.key = [coder decodeObjectForKey:kUILabelKey];
    }
    return self;
}

- (void) encodeWithCoder:(NSCoder*)coder
{
    [self doesNotRecognizeSelector:_cmd];
}

- (void) connect
{
    [_target setValue:_value forKey:_key];
}

@end
