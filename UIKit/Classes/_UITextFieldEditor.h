#import <UIKit/UIScrollView.h>
#import <UIKit/NSLayoutManager.h>

@interface _UITextFieldEditor : UIScrollView

@property (nonatomic, readonly) NSLayoutManager* layoutManager;
@property (nonatomic, readonly) NSTextContainer* textContainer;
@property (nonatomic, readonly) NSTextStorage* textStorage;

@end
