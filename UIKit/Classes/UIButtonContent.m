#import "UIButtonContent.h"
#import "UIColor.h"
#import "UIimage.h"

static NSString* const kUIBackgroundImageKey = @"UIBackgroundImage";
static NSString* const kUIImageKey = @"UIImage";
static NSString* const kUIShadowColorKey = @"UIShadowColor";
static NSString* const kUITitleKey = @"UITitle";
static NSString* const kUITitleColorKey = @"UITitleColor";

@implementation UIButtonContent

- (id) initWithCoder:(NSCoder*)coder
{
    if (nil != (self = [super init])) {
        if ([coder containsValueForKey:kUIBackgroundImageKey]) {
            self.backgroundImage = [coder decodeObjectForKey:kUIBackgroundImageKey];
        }
        if ([coder containsValueForKey:kUIImageKey]) {
            self.image = [coder decodeObjectForKey:kUIImageKey];
        }
        if ([coder containsValueForKey:kUIShadowColorKey]) {
            self.shadowColor = [coder decodeObjectForKey:kUIShadowColorKey];
        }
        if ([coder containsValueForKey:kUIShadowColorKey]) {
            self.title = [coder decodeObjectForKey:kUITitleKey];
        }
        if ([coder containsValueForKey:kUITitleColorKey]) {
            self.titleColor = [coder decodeObjectForKey:kUITitleColorKey];
        }
    }
    return self;
}

- (void) encodeWithCoder:(NSCoder*)coder
{
    [self doesNotRecognizeSelector:_cmd];
}

- (id) copyWithZone:(NSZone*)zone
{
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

@end
