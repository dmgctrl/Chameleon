#import <UIKit/UITextInput.h>
@class _UITextInputModel;


@interface _UITextInputModelAdapter : NSObject <UITextInput>
- (instancetype) initWithInputModel:(_UITextInputModel*)inputModel;
@end
