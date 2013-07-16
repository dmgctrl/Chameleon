#import <Foundation/Foundation.h>
#import <CoreGraphics/CoreGraphics.h>
#import <UIKit/UIKitDefines.h>
#import <UIKit/NSText.h>
#import <CoreText/CTParagraphStyle.h>


typedef NS_ENUM(NSInteger, NSLineBreakMode) {
    NSLineBreakByWordWrapping = 0,
    NSLineBreakByCharWrapping,
    NSLineBreakByClipping,
    NSLineBreakByTruncatingHead,
	NSLineBreakByTruncatingTail,
	NSLineBreakByTruncatingMiddle
};


@interface NSParagraphStyle : NSObject <NSCopying, NSMutableCopying, NSCoding>

+ (NSParagraphStyle*) defaultParagraphStyle;

+ (NSWritingDirection) defaultWritingDirectionForLanguage:(NSString*)languageName;

@property (readonly) CGFloat lineSpacing;
@property (readonly) CGFloat paragraphSpacing;
@property (readonly) NSTextAlignment alignment;
@property (readonly) CGFloat headIndent;
@property (readonly) CGFloat tailIndent;
@property (readonly) CGFloat firstLineHeadIndent;
@property (readonly) CGFloat minimumLineHeight;
@property (readonly) CGFloat maximumLineHeight;
@property (readonly) NSLineBreakMode lineBreakMode;
@property (readonly) NSWritingDirection baseWritingDirection;
@property (readonly) CGFloat lineHeightMultiple;
@property (readonly) CGFloat paragraphSpacingBefore;
@property (readonly) float hyphenationFactor;
@property (readonly) float tighteningFactorForTruncation;

@end


@interface NSMutableParagraphStyle : NSParagraphStyle

@property (readwrite) CGFloat lineSpacing;
@property (readwrite) CGFloat paragraphSpacing;
@property (readwrite) NSTextAlignment alignment;
@property (readwrite) CGFloat firstLineHeadIndent;
@property (readwrite) CGFloat headIndent;
@property (readwrite) CGFloat tailIndent;
@property (readwrite) NSLineBreakMode lineBreakMode;
@property (readwrite) CGFloat minimumLineHeight;
@property (readwrite) CGFloat maximumLineHeight;
@property (readwrite) NSWritingDirection baseWritingDirection;
@property (readwrite) CGFloat lineHeightMultiple;
@property (readwrite) CGFloat paragraphSpacingBefore;
@property (readwrite) float hyphenationFactor;
@property (readwrite) float tighteningFactorForTruncation;

@end
