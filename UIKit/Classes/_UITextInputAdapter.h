#import <UIKit/UITextInput.h>
@class _UITextModel;
@class _UITextInteractionController;


@interface _UITextInputAdapter : NSObject <UITextInput>
- (instancetype) initWithInputModel:(_UITextModel*)model interactionController:(_UITextInteractionController*)interactionController;

@end
