#import <UIKit/UITextInput.h>

@protocol _UITextInputPlus <UITextInput>
@optional
- (void) beginSelectionChange;
- (void) endSelectionChange;
- (UITextRange*) textRangeOfWordContainingPosition:(UITextPosition*)position;
@end