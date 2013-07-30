#import <Foundation/NSObject.h>
#import <UIKit/UITextInput.h>

@class UIView;
@class UITapGestureRecognizer;

@interface _UITextInteractionAssistant : NSObject

- (instancetype) initWithView:(UIView<UITextInput>*)view;

@property (readonly, nonatomic) UIResponder<UITextInput>* view;
@property (readonly, nonatomic) UITapGestureRecognizer* singleTapGesture;

@end
