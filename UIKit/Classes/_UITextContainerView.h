#import <UIKit/UIView.h>

@class NSTextContainer;

@interface _UITextContainerView : UIView

@property (nonatomic) NSTextContainer* textContainer;
@property (nonatomic) NSRange selectedRange;
@property (nonatomic) BOOL shouldShowInsertionPoint;

- (NSRect) _viewRectForCharacterRange:(NSRange)range;

@end
