#import <Foundation/Foundation.h>
#import <UIKit/UITextInput.h>

@class NSLayoutManager;
@class NSTextContainer;
@class _UITextInputModel;


UIKIT_HIDDEN
@protocol _UITextInputModelDelegate <NSObject>
@optional
- (void) textInputDidChangeSelection:(_UITextInputModel*)controller;
- (NSRange) textInput:(_UITextInputModel*)controller willChangeSelectionFromCharacterRange:(NSRange)fromRange toCharacterRange:(NSRange)toRange;
- (void) textInputDidChange:(_UITextInputModel*)controller;
- (void) textInput:(_UITextInputModel*)controller prepareAttributedTextForInsertion:(id)text;
- (BOOL) textInput:(_UITextInputModel*)controller shouldChangeCharactersInRange:(NSRange)range replacementText:(id)text;
- (BOOL) textInputShouldBeginEditing:(_UITextInputModel*)controller;
@end


UIKIT_HIDDEN
@interface _UITextInputModel : NSObject <UITextInput>

@property (nonatomic) NSRange selectedRange;
@property (nonatomic, readonly) NSLayoutManager* layoutManager;
@property (nonatomic, readonly) NSTextContainer* textContainer;
@property (nonatomic) id <_UITextInputModelDelegate> delegate;

- (instancetype) initWithLayoutManager:(NSLayoutManager*)layoutManager;

- (UITextRange*) textRangeOfWordContainingPosition:(UITextPosition*)position;

- (NSInteger) _indexWhenMovingRightFromIndex:(NSInteger)index;
- (NSInteger) _indexWhenMovingRightFromIndex:(NSInteger)index by:(NSInteger)byNumberOfGlyphs;
- (NSInteger) _indexWhenMovingLeftFromIndex:(NSInteger)index;
- (NSInteger) _indexWhenMovingLeftFromIndex:(NSInteger)index by:(NSInteger)byNumberOfGlyphs;
- (NSInteger) _indexWhenMovingWordLeftFromIndex:(NSInteger)index;
- (NSInteger) _indexWhenMovingWordRightFromIndex:(NSInteger)index;
- (NSInteger) _indexWhenMovingUpFromIndex:(NSInteger)index by:(NSInteger)numberOfLines;
- (NSInteger) _indexWhenMovingDownFromIndex:(NSInteger)index by:(NSInteger)numberOfLines;
- (NSInteger) _indexWhenMovingToBeginningOfLineFromIndex:(NSInteger)index;
- (NSInteger) _indexWhenMovingToEndOfLineFromIndex:(NSInteger)index;
- (BOOL) _isLocationAtBeginningOfParagraph;
- (BOOL) _isLocationAtEndOfParagraph;
- (NSInteger) _indexWhenMovingToBeginningOfParagraphFromIndex:(NSInteger)index;
- (NSInteger) _indexWhenMovingToEndOfParagraphFromIndex:(NSInteger)index;
- (NSInteger) _indexWhenMovingToBeginningOfDocumentFromIndex:(NSInteger)index;
- (NSInteger) _indexWhenMovingToEndOfDocumentFromIndex:(NSInteger)index;
- (NSInteger) _endOfDocument;

@end
