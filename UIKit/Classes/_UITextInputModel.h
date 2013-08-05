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
@interface _UITextInputModel : NSObject

- (BOOL) hasText;

- (NSString*) textInRange:(NSRange)range;
- (void) replaceRange:(NSRange)range withText:(NSString*)text;

@property (nonatomic, copy) NSDictionary* markedTextStyle;
- (NSRange) markedTextRange;
- (void) setMarkedText:(NSString*)markedText selectedRange:(NSRange)selectedRange;
- (void) unmarkText;

- (NSInteger) beginningOfDocument;
- (NSInteger) endOfDocument;

- (NSRange) textRangeFromPosition:(NSInteger)fromPosition toPosition:(NSInteger)toPosition;
- (NSRange) textRangeOfWordContainingPosition:(NSInteger)position;

- (NSInteger) positionFromPosition:(NSInteger)position offset:(NSInteger)offset;
- (NSInteger) positionFromPosition:(NSInteger)position inDirection:(UITextLayoutDirection)direction offset:(NSInteger)offset;

- (NSInteger) positionWithinRange:(NSRange)range farthestInDirection:(UITextLayoutDirection)direction;

- (UITextWritingDirection) baseWritingDirectionForPosition:(NSInteger)position inDirection:(UITextStorageDirection)direction;
- (void) setBaseWritingDirection:(UITextWritingDirection)writingDirection forRange:(NSRange)range;

- (CGRect) firstRectForRange:(NSRange)range;
- (CGRect) caretRectForPosition:(NSInteger)position;
- (NSArray*) selectionRectsForRange:(NSRange)range;

- (NSInteger) closestPositionToPoint:(CGPoint)point;
- (NSInteger) closestPositionToPoint:(CGPoint)point withinRange:(NSRange)range;
- (NSRange) characterRangeAtPoint:(CGPoint)point;

- (BOOL) shouldChangeTextInRange:(NSRange)range replacementText:(NSString*)text;

- (NSDictionary*) textStylingAtPosition:(NSInteger)position inDirection:(UITextStorageDirection)direction;
- (NSInteger) positionWithinRange:(NSRange)range atCharacterOffset:(NSInteger)offset;
- (NSInteger) characterOffsetOfPosition:(NSInteger)position withinRange:(NSRange)range;

@property (nonatomic) UITextStorageDirection selectionAffinity;
@property (nonatomic) NSRange selectedRange;

@property (nonatomic, readonly) NSLayoutManager* layoutManager;
@property (nonatomic, readonly) NSTextContainer* textContainer;
@property (nonatomic) id <_UITextInputModelDelegate> delegate;

- (instancetype) initWithLayoutManager:(NSLayoutManager*)layoutManager;


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
