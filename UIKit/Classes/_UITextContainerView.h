#import <UIKit/UIView.h>

@class NSTextContainer;

@interface _UITextContainerView : UIView

@property (nonatomic) NSTextContainer* textContainer;
@property (nonatomic) NSRange selectedRange;
@property (nonatomic) BOOL shouldShowInsertionPoint;
@property (nonatomic) NSInteger caretPosition;

- (NSRect) _viewRectForCharacterRange:(NSRange)range;

@end
