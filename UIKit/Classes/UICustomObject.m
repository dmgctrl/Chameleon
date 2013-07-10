#import "UICustomObject.h"

@implementation UICustomObject

- (id) initWithCoder:(NSCoder*)coder
{
    return self;
}

- (void) encodeWithCoder:(NSCoder*)coder
{
    [self doesNotRecognizeSelector:_cmd];
}

@end
