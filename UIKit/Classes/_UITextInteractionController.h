#import <Foundation/NSObject.h>
#import <UIKit/UITextInput.h>

@class UIView;
@class UITapGestureRecognizer;

@interface _UITextInteractionController : NSObject

- (instancetype) initWithView:(UIView<UITextInput>*)view;

@property (readonly, nonatomic) UIResponder<UITextInput>* view;

- (UITapGestureRecognizer*) addOneFingerTapRecognizerToView:(UIView*)view;
- (UITapGestureRecognizer*) addOneFingerDoubleTapRecognizerToView:(UIView*)view;
- (void) removeGestureRecognizersFromView:(UIView*)view;

@end
