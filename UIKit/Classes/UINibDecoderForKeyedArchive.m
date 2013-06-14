#import "UINibDecoderForKeyedArchive.h"
#import "UIProxyObject.h"
#import "UIImageNibPlaceholder.h"


static NSString* const kIBFilesOwnerKey = @"IBFilesOwner";
static NSString* const kIBFirstResponderKey = @"IBFirstResponder";


@interface UIKeyedArchiveNibInflationHelper : NSObject <NSKeyedUnarchiverDelegate>

- (id) initWithBundle:(NSBundle*)bundle owner:(id)owner externalObjects:(NSDictionary*)externalObjects;

@end


@implementation UINibDecoderForKeyedArchive {
    NSData* _data;
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
    NSKeyedUnarchiver* coder = [[NSKeyedUnarchiver alloc] initForReadingWithData:_data];
    coder.delegate = [[UIKeyedArchiveNibInflationHelper alloc] initWithBundle:bundle owner:owner externalObjects:externalObjects]; 
    return coder;
}

@end


@implementation UIKeyedArchiveNibInflationHelper {
    NSBundle* _bundle;
    id _owner;
    NSDictionary* _externalObjects;
}

static Class kClassForUIProxyObject;
static Class kClassForUIImageNibPlaceholder;

+ (void) initialize
{
    if (self == [UIKeyedArchiveNibInflationHelper class]) {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            kClassForUIProxyObject = NSClassFromString(@"UIProxyObject");
            kClassForUIImageNibPlaceholder = NSClassFromString(@"UIImageNibPlaceholder");
        });
    }
    assert(kClassForUIProxyObject);
    assert(kClassForUIImageNibPlaceholder);
}


- (id) initWithBundle:(NSBundle*)bundle owner:(id)owner externalObjects:(NSDictionary*)externalObjects
{
    if (nil != (self = [super init])) {
        _bundle = bundle;
        _owner = owner;
        _externalObjects = externalObjects;
    }
    return self;
}


#pragma mark

- (id) unarchiver:(NSKeyedUnarchiver*)unarchiver didDecodeObject:(id)object
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
    return nil;
}

@end
