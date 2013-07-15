#import "UIFontDescriptor.h"
#import "UIGeometry.h"


NSString* const UIFontDescriptorFamilyAttribute = @"";
NSString* const UIFontDescriptorNameAttribute = @"NSFontNameAttribute";
NSString* const UIFontDescriptorFaceAttribute = @"";
NSString* const UIFontDescriptorSizeAttribute = @"NSFontSizeAttribute";
NSString* const UIFontDescriptorVisibleNameAttribute = @"";
NSString* const UIFontDescriptorMatrixAttribute = @"";
NSString* const UIFontDescriptorVariationAttribute = @"";
NSString* const UIFontDescriptorCharacterSetAttribute = @"";
NSString* const UIFontDescriptorCascadeListAttribute = @"";
NSString* const UIFontDescriptorTraitsAttribute = @"";
NSString* const UIFontDescriptorFixedAdvanceAttribute = @"";
NSString* const UIFontDescriptorFeatureSettingsAttribute = @"";
NSString* const UIFontDescriptorTextStyleAttribute = @"";

static NSString* const kUIFontDescriptorAttributesKey = @"UIFontDescriptorAttributes";


@implementation UIFontDescriptor {
    NSDictionary* _fontAttributes;
}

+ (UIFontDescriptor*) fontDescriptorWithFontAttributes:(NSDictionary*)attributes
{
    return [[[self class] alloc] initWithFontAttributes:attributes];
}

+ (UIFontDescriptor*) fontDescriptorWithName:(NSString *)fontName matrix:(CGAffineTransform)matrix
{
    return [[[self class] alloc] initWithFontAttributes:@{
        UIFontDescriptorNameAttribute: fontName,
        UIFontDescriptorMatrixAttribute: [NSValue valueWithCGAffineTransform:matrix],
    }];
}

+ (UIFontDescriptor*) fontDescriptorWithName:(NSString *)fontName size:(CGFloat)size
{
    return [[[self class] alloc] initWithFontAttributes:@{
        UIFontDescriptorNameAttribute: fontName,
        UIFontDescriptorSizeAttribute: @(size),
    }];
}

- (instancetype) initWithCoder:(NSCoder*)coder
{
    if (nil != (self = [super init])) {
        _fontAttributes = [coder decodeObjectForKey:kUIFontDescriptorAttributesKey];
    }
    return self;
}

- (instancetype) initWithFontAttributes:(NSDictionary*)fontAttributes
{
    NSAssert(nil != fontAttributes, @"???");
    if (nil != (self = [super init])) {
        _fontAttributes = fontAttributes;
    }
    return self;
}

- (void) encodeWithCoder:(NSCoder*)aCoder
{
    [self doesNotRecognizeSelector:_cmd];
}

- (id) copyWithZone:(NSZone*)zone
{
    return self;
}

- (id) objectForKey:(NSString*)key
{
    return [_fontAttributes objectForKey:key];
}

- (NSDictionary*) fontAttributes
{
    return _fontAttributes;
}

- (CGAffineTransform) matrix
{
    return [[_fontAttributes objectForKey:UIFontDescriptorNameAttribute] CGAffineTransformValue];
}

- (CGFloat) pointSize
{
    return [[_fontAttributes objectForKey:UIFontDescriptorSizeAttribute] floatValue];
}

- (NSString*) postscriptName
{
    return nil;
}

- (UIFontDescriptorSymbolicTraits) symbolicTraits
{
    return [[_fontAttributes objectForKey:UIFontDescriptorTraitsAttribute] unsignedIntegerValue];
}

@end
