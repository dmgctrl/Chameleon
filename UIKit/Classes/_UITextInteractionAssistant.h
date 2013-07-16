#import <Foundation/NSObject.h>
#import <UIKit/UIResponder.h>
#import <UIkit/UITextInput.h>
#import <UIKit/UIGestureRecognizer.h>

@class UITapGestureRecognizer;

@interface _UITextInteractionAssistant : NSObject <UIGestureRecognizerDelegate>

- (instancetype) initWithView:(UIResponder<UITextInput>*)view;

@property (readonly, nonatomic) UIResponder<UITextInput>* view;
@property (readonly, nonatomic) UITapGestureRecognizer* singleTapGesture;

@end
