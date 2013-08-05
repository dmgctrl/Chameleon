#import <Foundation/NSObject.h>
#import <UIKit/UITextInput.h>

@class UIView;
@class UITapGestureRecognizer;
@class _UITextInputModel;
@class _UITextInteractionController;


UIKIT_HIDDEN
@protocol _UITextInteractionControllerDelegate <NSObject>
@optional
- (NSRange) textInteractionController:(_UITextInteractionController*)controller willChangeSelectionFromCharacterRange:(NSRange)fromRange toCharacterRange:(NSRange)toRange;
- (void) textInteractionControllerDidChangeSelection:(_UITextInteractionController*)controller;
- (void) textInteractionControllerEditorDidChangeSelection:(_UITextInteractionController*)controller;
- (void) textInteractionController:(_UITextInteractionController*)controller didChangeCaretPosition:(NSInteger)caretPosition;
@end


@interface _UITextInteractionController : NSObject

- (instancetype) initWithView:(UIResponder<UITextInput>*)view inputModel:(_UITextInputModel*)inputModel;

@property (readonly, nonatomic) UIResponder<UITextInput>* view;

@property (nonatomic) UITextStorageDirection selectionAffinity;
@property (nonatomic) NSRange selectedRange;

- (UITapGestureRecognizer*) addOneFingerTapRecognizerToView:(UIView*)view;
- (UITapGestureRecognizer*) addOneFingerDoubleTapRecognizerToView:(UIView*)view;
- (void) removeGestureRecognizersFromView:(UIView*)view;

- (void) insertText:(NSString*)text;
- (void) deleteBackward;
- (void) doCommandBySelector:(SEL)selector;

@end
