#import <Foundation/Foundation.h>
#import <UIKit/UIKitDefines.h>

enum {
    /* Typeface info (lower 16 bits of UIFontDescriptorSymbolicTraits) */
    UIFontDescriptorTraitItalic = 1 << 0,
    UIFontDescriptorTraitBold = 1 << 1,
    UIFontDescriptorTraitExpanded = 1 << 5,
    UIFontDescriptorTraitCondensed = 1 << 6,
    UIFontDescriptorTraitMonoSpace = 1 << 10,
    UIFontDescriptorTraitVertical = 1 << 11,
    UIFontDescriptorTraitUIOptimized = 1 << 12,
    
    /* Font appearance info (upper 16 bits of UIFontDescriptorSymbolicTraits */
    UIFontDescriptorClassMask = 0xF0000000,
    
    UIFontDescriptorClassUnknown = 0 << 28,
    UIFontDescriptorClassOldStyleSerifs = 1 << 28,
    UIFontDescriptorClassTransitionalSerifs = 2 << 28,
    UIFontDescriptorClassModernSerifs = 3 << 28,
    UIFontDescriptorClassClarendonSerifs = 4 << 28,
    UIFontDescriptorClassSlabSerifs = 5 << 28,
    UIFontDescriptorClassFreeformSerifs = 7 << 28,
    UIFontDescriptorClassSansSerif = 8 << 28,
    UIFontDescriptorClassOrnamentals = 9 << 28,
    UIFontDescriptorClassScripts = 10 << 28,
    UIFontDescriptorClassSymbolic = 12 << 28
};
typedef uint32_t UIFontDescriptorSymbolicTraits;

UIKIT_EXTERN NSString* const UIFontDescriptorFamilyAttribute;
UIKIT_EXTERN NSString* const UIFontDescriptorNameAttribute;
UIKIT_EXTERN NSString* const UIFontDescriptorFaceAttribute;
UIKIT_EXTERN NSString* const UIFontDescriptorSizeAttribute;
UIKIT_EXTERN NSString* const UIFontDescriptorVisibleNameAttribute;
UIKIT_EXTERN NSString* const UIFontDescriptorMatrixAttribute;
UIKIT_EXTERN NSString* const UIFontDescriptorVariationAttribute;
UIKIT_EXTERN NSString* const UIFontDescriptorCharacterSetAttribute;
UIKIT_EXTERN NSString* const UIFontDescriptorCascadeListAttribute;
UIKIT_EXTERN NSString* const UIFontDescriptorTraitsAttribute;
UIKIT_EXTERN NSString* const UIFontDescriptorFixedAdvanceAttribute;
UIKIT_EXTERN NSString* const UIFontDescriptorFeatureSettingsAttribute;
UIKIT_EXTERN NSString* const UIFontDescriptorTextStyleAttribute;

@interface UIFontDescriptor : NSObject <NSCopying, NSCoding>

+ (UIFontDescriptor*) preferredFontDescriptorWithTextStyle:(NSString*)style;
+ (UIFontDescriptor*) fontDescriptorWithFontAttributes:(NSDictionary*)attributes;
+ (UIFontDescriptor*) fontDescriptorWithName:(NSString*)fontName matrix:(CGAffineTransform)matrix;
+ (UIFontDescriptor*) fontDescriptorWithName:(NSString*)fontName size:(CGFloat)size;

- (UIFontDescriptor*) fontDescriptorByAddingAttributes:(NSDictionary*)attributes;
- (UIFontDescriptor*) fontDescriptorWithFace:(NSString*)newFace;
- (UIFontDescriptor*) fontDescriptorWithFamily:(NSString*)newFamily;
- (UIFontDescriptor*) fontDescriptorWithMatrix:(CGAffineTransform)matrix;
- (UIFontDescriptor*) fontDescriptorWithSize:(CGFloat)newPointSize;
- (UIFontDescriptor*) fontDescriptorWithSymbolicTraits:(UIFontDescriptorSymbolicTraits)symbolicTraits;

- (instancetype) initWithFontAttributes:(NSDictionary*)attributes;
- (NSArray*) matchingFontDescriptorsWithMandatoryKeys:(NSSet*)mandatoryKeys;

#pragma mark Querying a Font Descriptor
- (NSDictionary*) fontAttributes;
@property (nonatomic, readonly) CGAffineTransform matrix;
- (id) objectForKey:(NSString*)anAttribute;
@property (nonatomic, readonly) CGFloat pointSize;
@property (nonatomic, readonly) NSString* postscriptName;
@property (nonatomic, readonly) UIFontDescriptorSymbolicTraits symbolicTraits;

@end
