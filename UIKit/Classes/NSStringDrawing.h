#import <UIKit/NSAttributedString.h>
#import <UIKit/UIKitDefines.h>


@interface NSStringDrawingContext : NSObject

@property (nonatomic) CGFloat minimumScaleFactor;
@property (nonatomic) CGFloat minimumTrackingAdjustment;

@property (nonatomic, readonly) CGFloat actualScaleFactor;
@property (nonatomic, readonly) CGFloat actualTrackingAdjustment;
@property (nonatomic, readonly) CGRect totalBounds;

@end

#ifndef _APPKITDEFINES_H
@interface NSAttributedString (NSStringDrawing)
- (CGSize) size;
- (void) drawAtPoint:(CGPoint)point;
- (void) drawInRect:(CGRect)rect;
@end

typedef NS_ENUM(NSInteger, NSStringDrawingOptions) {
    NSStringDrawingTruncatesLastVisibleLine = 1 << 5,
    NSStringDrawingUsesLineFragmentOrigin = 1 << 0,
    NSStringDrawingUsesFontLeading = 1 << 1,
    NSStringDrawingUsesDeviceMetrics = 1 << 3,
};
#endif

@interface NSAttributedString (NSExtendedStringDrawing_UIKit)
- (void) drawWithRect:(CGRect)rect options:(NSStringDrawingOptions)options context:(NSStringDrawingContext*)context;
- (CGRect) boundingRectWithSize:(CGSize)size options:(NSStringDrawingOptions)options context:(NSStringDrawingContext*)context;
@end
