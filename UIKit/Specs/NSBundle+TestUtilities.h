#import <Foundation/Foundation.h>

@interface NSBundle (TestUtilities)

+ (void) pushMainBundle:(NSBundle*)mainBundle;
+ (void) popMainBundle;

@end
