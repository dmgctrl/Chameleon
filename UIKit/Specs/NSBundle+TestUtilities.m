#import "NSBundle+TestUtilities.h"
#import <objc/runtime.h>


@implementation NSBundle (TestUtilities)

static NSMutableArray* mainBundleStack;

+ (NSBundle*) mainBundleAtTheTopOfTheStack
{
    return [mainBundleStack lastObject];
}

+ (void) load
{
    NSBundle* mainBundle = [self mainBundle];
    mainBundleStack = [[NSMutableArray alloc] initWithObjects:mainBundle, nil];
    Method mainBundleMethod = class_getClassMethod(self, @selector(mainBundle));
    method_setImplementation(mainBundleMethod, method_getImplementation(class_getClassMethod(self, @selector(mainBundleAtTheTopOfTheStack))));
}

+ (void) pushMainBundle:(NSBundle*)mainBundle
{
    NSAssert(mainBundle != nil, @"???");
    [mainBundleStack addObject:mainBundle];
}

+ (void) popMainBundle
{
    NSAssert([mainBundleStack count] > 1, @"???");
    [mainBundleStack removeLastObject];
}

@end
