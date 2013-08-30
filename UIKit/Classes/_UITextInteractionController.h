#import <Foundation/NSObject.h>
#import <UIKit/UITextInput.h>

@class UIView;
@class UIPanGestureRecognizer;
@class UITapGestureRecognizer;
@class _UITextModel;
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

- (instancetype) initWithView:(UIResponder<UITextInput>*)view model:(_UITextModel*)model;

@property (readonly, nonatomic) UIResponder<UITextInput>* view;

@property (nonatomic) UITextStorageDirection selectionAffinity;
@property (nonatomic) NSRange selectedRange;
@property (nonatomic) NSInteger insertionPoint;

@property (nonatomic, copy) NSDictionary* markedTextStyle;
- (NSRange) markedTextRange;
- (void) setMarkedText:(NSString*)markedText selectedRange:(NSRange)selectedRange;
- (void) unmarkText;

- (UITapGestureRecognizer*) addOneFingerTapRecognizerToView:(UIView*)view;
- (UITapGestureRecognizer*) addOneFingerDoubleTapRecognizerToView:(UIView*)view;
- (UIPanGestureRecognizer*) addSelectionPanGestureRecognizerToView:(UIView*)view;

- (void) removeGestureRecognizersFromView:(UIView*)view;
- (void) removeGestureRecognizers;

- (void) insertText:(NSString*)text;
- (void) deleteBackward;
- (void) doCommandBySelector:(SEL)selector;

@end
