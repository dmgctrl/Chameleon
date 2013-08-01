#import <Foundation/Foundation.h>
#import <UIKit/UITextInput.h>

@class NSLayoutManager;
@class NSTextContainer;
@class _UITextInputController;


UIKIT_HIDDEN
@protocol _UITextInputControllerDelegate <NSObject>
@optional
- (void) textInputDidChangeSelection:(_UITextInputController*)controller;
- (NSRange) textInput:(_UITextInputController*)controller willChangeSelectionFromCharacterRange:(NSRange)fromRange toCharacterRange:(NSRange)toRange;
- (void) textInputDidChange:(_UITextInputController*)controller;
- (void) textInput:(_UITextInputController*)controller prepareAttributedTextForInsertion:(id)text;
- (BOOL) textInput:(_UITextInputController*)controller shouldChangeCharactersInRange:(NSRange)range replacementText:(id)text;
- (BOOL) textInputShouldBeginEditing:(_UITextInputController*)controller;
@end


UIKIT_HIDDEN
@interface _UITextInputController : NSObject <UITextInput>

@property (nonatomic) NSRange selectedRange;
@property (nonatomic, readonly) NSLayoutManager* layoutManager;
@property (nonatomic, readonly) NSTextContainer* textContainer;
@property (nonatomic) id <_UITextInputControllerDelegate> delegate;

- (instancetype) initWithLayoutManager:(NSLayoutManager*)layoutManager;

- (UITextRange*) textRangeOfWordContainingPosition:(UITextPosition*)position;

@end
