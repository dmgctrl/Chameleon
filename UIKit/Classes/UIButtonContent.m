#import "UIButtonContent.h"
#import "UIColor.h"
#import "UIimage.h"

static NSString* const kUIBackgroundImageKey = @"UIBackgroundImage";
static NSString* const kUIImageKey = @"UIImage";
static NSString* const kUIShadowColorKey = @"UIShadowColor";
static NSString* const kUITitleKey = @"UITitle";
static NSString* const kUITitleColorKey = @"UITitleColor";

@implementation UIButtonContent
@synthesize shadowColor = _shadowColor;
@synthesize titleColor = _titleColor;
@synthesize backgroundImage = _backgroundImage;
@synthesize image = _image;
@synthesize title = _title;


- (id) initWithCoder:(NSCoder*)coder
{
    if (nil != (self = [super init])) {
        self.backgroundImage = [coder decodeObjectForKey:kUIBackgroundImageKey];
        self.image = [coder decodeObjectForKey:kUIImageKey];
        self.shadowColor = [coder decodeObjectForKey:kUIShadowColorKey];
        self.title = [coder decodeObjectForKey:kUITitleKey];
        self.titleColor = [coder decodeObjectForKey:kUITitleColorKey];
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
