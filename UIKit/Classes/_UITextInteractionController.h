#import <Foundation/NSObject.h>
#import <UIKit/UITextInput.h>

@class UIView;
@class UITapGestureRecognizer;
@class _UITextInputModel;

@interface _UITextInteractionController : NSObject

- (instancetype) initWithView:(UIResponder<UITextInput>*)view inputModel:(_UITextInputModel*)inputModel;

@property (readonly, nonatomic) UIResponder<UITextInput>* view;

- (UITapGestureRecognizer*) addOneFingerTapRecognizerToView:(UIView*)view;
- (UITapGestureRecognizer*) addOneFingerDoubleTapRecognizerToView:(UIView*)view;
- (void) removeGestureRecognizersFromView:(UIView*)view;

- (void) insertText:(NSString*)text;
- (void) deleteBackward;
- (void) doCommandBySelector:(SEL)selector;

@end
