#import "_UITextViewRange.h"

@implementation _UITextViewRange
@synthesize start = _start;
@synthesize end = _end;

- (instancetype) initWithStart:(_UITextViewPosition*)start end:(_UITextViewPosition*)end
{
    if (nil != (self = [super init])) {
        _start = start;
        _end = end;
    }
    return self;
}

- (BOOL) isEmpty
{
    return [_start isEqual:_end];
}

- (NSString*) description
{
    return [NSString stringWithFormat:@"<%@: %p> (%ld, %ld)", NSStringFromClass([self class]), self, [_start offset], [_end offset] - [_start offset]];
}

@end