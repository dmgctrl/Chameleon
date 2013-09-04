#import <UIKit/UITextInput.h>


@interface _UITextViewPosition : UITextPosition
+ (instancetype) positionWithOffset:(NSInteger)offset;
- (instancetype) initWithOffset:(NSInteger)offset;
@property (nonatomic, assign) NSInteger offset;
@end
