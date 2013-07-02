#import <Foundation/Foundation.h>
#import <CoreText/CTParagraphStyle.h>
#import <UIKit/UIKitDefines.h>

#ifndef _APPKITDEFINES_H
typedef NS_ENUM(NSInteger, NSTextAlignment) {
    NSTextAlignmentLeft      = 0,
#if TARGET_OS_IPHONE
    NSTextAlignmentCenter    = 1,
    NSTextAlignmentRight     = 2,
#else /* !TARGET_OS_IPHONE */
    NSTextAlignmentRight     = 1,
    NSTextAlignmentCenter    = 2,
#endif
    NSTextAlignmentJustified = 3,
    NSTextAlignmentNatural   = 4,
};

typedef NS_ENUM(NSInteger, NSWritingDirection) {
    NSWritingDirectionNatural       = -1,
    NSWritingDirectionLeftToRight   =  0,
    NSWritingDirectionRightToLeft   =  1
};
#endif

UIKIT_EXTERN CTTextAlignment NSTextAlignmentToCTTextAlignment(NSTextAlignment nsTextAlignment);
UIKIT_EXTERN NSTextAlignment NSTextAlignmentFromCTTextAlignment(CTTextAlignment ctTextAlignment);

