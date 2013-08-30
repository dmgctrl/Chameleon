#import <Foundation/Foundation.h>
#import <UIKit/UITextInput.h>

@class NSLayoutManager;
@class NSTextContainer;
@class _UITextModel;


UIKIT_HIDDEN
@protocol _UITextModelDelegate <NSObject>
@optional
- (void) textModelDidChange:(_UITextModel*)model;
- (void) textModel:(_UITextModel*)model prepareAttributedTextForInsertion:(id)text;
- (BOOL) textModel:(_UITextModel*)model shouldChangeCharactersInRange:(NSRange)range replacementText:(id)text;
- (BOOL) textModelShouldBeginEditing:(_UITextModel*)model;
@end


UIKIT_HIDDEN
@interface _UITextModel : NSObject

- (BOOL) hasText;

- (NSString*) textInRange:(NSRange)range;
- (void) replaceRange:(NSRange)range withText:(NSString*)text;

@property (nonatomic, strong) NSString* markedText;
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

@property (nonatomic, readonly) NSLayoutManager* layoutManager;
@property (nonatomic, readonly) NSTextContainer* textContainer;
@property (nonatomic) id <_UITextModelDelegate> delegate;

- (instancetype) initWithLayoutManager:(NSLayoutManager*)layoutManager;

- (NSInteger) positionWhenMovingRightFromPosition:(NSInteger)index;
- (NSInteger) positionWhenMovingRightFromPosition:(NSInteger)index by:(NSInteger)byNumberOfGlyphs;
- (NSInteger) positionWhenMovingLeftFromPosition:(NSInteger)index;
- (NSInteger) positionWhenMovingLeftFromPosition:(NSInteger)index by:(NSInteger)byNumberOfGlyphs;
- (NSInteger) positionWhenMovingWordLeftFromPosition:(NSInteger)index;
- (NSInteger) positionWhenMovingWordRightFromPosition:(NSInteger)index;
- (NSInteger) positionWhenMovingUpFromPosition:(NSInteger)index by:(NSInteger)numberOfLines;
- (NSInteger) positionWhenMovingDownFromPosition:(NSInteger)index by:(NSInteger)numberOfLines;
- (NSInteger) positionWhenMovingToBeginningOfLineFromPosition:(NSInteger)index;
- (NSInteger) positionWhenMovingToEndOfLineFromPosition:(NSInteger)index;
- (NSInteger) positionWhenMovingToBeginningOfParagraphFromPosition:(NSInteger)index;
- (NSInteger) positionWhenMovingToEndOfParagraphFromPosition:(NSInteger)index;

@end
