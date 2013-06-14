#import "UIStoryboard.h"

static NSInteger const kOldestSupportedVersion = 1;
static NSInteger const kNewestSupportedVersion = 1;

static NSString* const kUIStoryboardVersionKey = @"UIStoryboardVersion";
static NSString* const kUIViewControllerIdentifiersToNibNamesKey = @"UIViewControllerIdentifiersToNibNames";

@implementation UIStoryboard {
    NSBundle* _bundle;
    NSString* _relativePath;
    NSDictionary* _identifierToNibNameMap;
    NSString* _designatedEntryPointIdentifier;
}

+ (UIStoryboard*) storyboardWithName:(NSString*)name bundle:(NSBundle*)bundleOrNil
{
    NSAssert([name length] > 0, @"Invalid parameter not satisfying: [name length] > 0");

    NSBundle* bundle = bundleOrNil ?: [NSBundle mainBundle];
    NSString* absolutePath = [bundle pathForResource:name ofType:@"storyboardc"];
    if (!absolutePath) {
        return nil;
    }
    NSString* relativePath = [absolutePath substringFromIndex:[[bundle resourcePath] length] + 1];

    NSDictionary* info = [NSDictionary dictionaryWithContentsOfFile:[bundle pathForResource:@"Info" ofType:@"plist" inDirectory:relativePath]];
    if (!info) {
        return nil;
    }
    
    NSNumber* versionNumber = [info objectForKey:kUIStoryboardVersionKey];
    if (!versionNumber || ![versionNumber isKindOfClass:[NSNumber class]]) {
        return nil;
    } else if ([versionNumber integerValue] < kOldestSupportedVersion || [versionNumber integerValue] > kNewestSupportedVersion) {
        return nil;
    }
    
    NSDictionary* identifierToNibNameMap = [info objectForKey:kUIViewControllerIdentifiersToNibNamesKey];
    if (!identifierToNibNameMap || ![identifierToNibNameMap isKindOfClass:[NSDictionary class]]) {
        return nil;
    }

    NSString* designatedEntryPointIdentifier = [info objectForKey:@""];
    if (designatedEntryPointIdentifier && ![designatedEntryPointIdentifier isKindOfClass:[NSString class]]) {
        return nil;
    }

    return [[[self class] alloc] initWithBundle:bundle relativePathFromBundle:relativePath identifierToNibNameMap:identifierToNibNameMap designatedEntryPointIdentifier:designatedEntryPointIdentifier];
}

- (id) initWithBundle:(NSBundle*)bundle relativePathFromBundle:(NSString*)relativePath identifierToNibNameMap:(NSDictionary*)identifierToNibNameMap designatedEntryPointIdentifier:(NSString*)designatedEntryPointIdentifier
{
    NSAssert(nil != bundle, @"???");
    NSAssert(nil != relativePath, @"???");
    NSAssert(nil != identifierToNibNameMap, @"???");
    if (nil != (self = [super init])) {
        _bundle = bundle;
        _relativePath = relativePath;
        _identifierToNibNameMap = identifierToNibNameMap;
        _designatedEntryPointIdentifier = designatedEntryPointIdentifier;
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
