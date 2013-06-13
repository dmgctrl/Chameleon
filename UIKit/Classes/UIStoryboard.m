#import "UIStoryboard.h"

@implementation UIStoryboard

+ (UIStoryboard*) storyboardWithName:(NSString*)name bundle:(NSBundle*)bundleOrNil
{
    NSAssert([name length] > 0, @"Invalid parameter not satisfying: [name length] > 0");

    NSBundle* bundle = bundleOrNil ?: [NSBundle mainBundle];
    NSString* absolutePath = [bundle pathForResource:name ofType:@"storyboardc"];
    if (!absolutePath) {
        return nil;
    }
    NSString* relativePath = [absolutePath substringFromIndex:[[bundle bundlePath] length] + 1];

    return nil;
}

- (id) initWithBundle:(NSBundle*)bundle relativePathFromBundle:(NSString*)relativePath identifierToNibNameMap:(NSDictionary*)identifierToNibNameMap designatedEntryPointIdentifier:(NSString*)designatedEntryPointIdentifier
{
    if (nil != (self = [super init])) {
        
    }
    return self;
}

- (id) instantiateInitialViewController
{
    return nil;
}

- (id) instantiateViewControllerWithIdentifier:(NSString*)identifier
{
    return nil;
}

@end
