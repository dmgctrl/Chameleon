#import "_UITextViewPosition.h"


@implementation _UITextViewPosition

static NSUInteger hashForTextPosition;

+ (void) initialize
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        hashForTextPosition = [[_UITextViewPosition class] hash];
    });
}

+ (instancetype) positionWithOffset:(NSInteger)offset
{
    return [[_UITextViewPosition alloc] initWithOffset:offset];
}

- (instancetype) initWithOffset:(NSInteger)offset
{
    if (nil != (self = [super init])) {
        _offset = offset;
    }
    return self;
}

- (BOOL) isEqual:(id)object
{
    return self == object || ([object isKindOfClass:[_UITextViewPosition class]] && [((_UITextViewPosition*)object) offset] == [self offset]);
}

- (NSUInteger) hash
{
    return (37 * _offset) ^ hashForTextPosition;
}

- (NSString*) description
{
    return [NSString stringWithFormat:@"<%@: %p> %ld", NSStringFromClass([self class]), self, _offset];
}

@end