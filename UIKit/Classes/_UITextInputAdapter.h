#import <UIKit/UITextInput.h>
@class _UITextInputModel;
@class _UITextInteractionController;


@interface _UITextInputAdapter : NSObject <UITextInput>
- (instancetype) initWithInputModel:(_UITextInputModel*)inputModel interactionController:(_UITextInteractionController*)interactionController;

- (UITextRange*) textRangeOfWordContainingPosition:(UITextPosition*)position;

@end
