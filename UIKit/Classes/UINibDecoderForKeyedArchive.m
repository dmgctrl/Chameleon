#import "UINibDecoderForKeyedArchive.h"
#import "UIProxyObject.h"
#import "UIImageNibPlaceholder.h"


static NSString* const kIBFilesOwnerKey = @"IBFilesOwner";
static NSString* const kIBFirstResponderKey = @"IBFirstResponder";


@interface UINibDecoderKeyedUnarchiver : NSKeyedUnarchiver

- (id) initWithData:(NSData*)data bundle:(NSBundle*)bundle owner:(id)owner externalObjects:(NSDictionary*)externalObjects;

@end


@implementation UINibDecoderForKeyedArchive {
    NSData* _data;
    UINibDecoderKeyedUnarchiver* _inflationHelper;
}

- (id) initWithData:(NSData*)data
{
    assert(data);
    if (nil != (self = [super init])) {
        _data = data;
    }
    return self;
}

- (NSCoder*) instantiateCoderWithBundle:(NSBundle*)bundle owner:(id)owner externalObjects:(NSDictionary*)externalObjects
{
    return [[UINibDecoderKeyedUnarchiver alloc] initWithData:_data bundle:bundle owner:owner externalObjects:externalObjects];
}

@end


@implementation UINibDecoderKeyedUnarchiver {
    NSBundle* _bundle;
    id _owner;
    NSDictionary* _externalObjects;
}

static Class kClassForUIProxyObject;
static Class kClassForUIImageNibPlaceholder;

+ (void) initialize
{
    if (self == [UINibDecoderKeyedUnarchiver class]) {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            kClassForUIProxyObject = NSClassFromString(@"UIProxyObject");
            kClassForUIImageNibPlaceholder = NSClassFromString(@"UIImageNibPlaceholder");
        });
    }
    assert(kClassForUIProxyObject);
    assert(kClassForUIImageNibPlaceholder);
}


- (id) initWithData:(NSData*)data bundle:(NSBundle*)bundle owner:(id)owner externalObjects:(NSDictionary*)externalObjects
{
    if (nil != (self = [super initForReadingWithData:data])) {
        _bundle = bundle;
        _owner = owner;
        _externalObjects = externalObjects;
    }
    return self;
}

- (id) decodeObjectForKey:(NSString *)key
{
    return [self _postprocessObject:[super decodeObjectForKey:key]];
}

- (id) decodeObjectOfClass:(Class)aClass forKey:(NSString *)key
{
    return [self _postprocessObject:[super decodeObjectOfClass:aClass forKey:key]];
}

#pragma mark

- (id) _postprocessObject:(id)object
{
    Class class = [object class];
    if (class == kClassForUIProxyObject) {
        NSString* proxiedObjectIdentifier = [object proxiedObjectIdentifier];
        if ([proxiedObjectIdentifier isEqualToString:kIBFilesOwnerKey]) {
            return _owner; 
        } else if ([proxiedObjectIdentifier isEqualToString:kIBFirstResponderKey]) {
            return [NSNull null];
        } else {
            return [_externalObjects objectForKey:proxiedObjectIdentifier];
        }
    } else if (class == kClassForUIImageNibPlaceholder) {
        NSString* resourceName = [object resourceName];
        return [UIImage imageWithContentsOfFile:[_bundle pathForResource:resourceName ofType:nil]];
    }
    return object;
}

@end
