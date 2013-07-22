#import <UIKit/UITextInputTraits.h>
#import <UIKit/UIResponder.h>
#import <UIKit/UIKitDefines.h>


@protocol UIKeyInput <UITextInputTraits>

- (BOOL) hasText;
- (void) insertText:(NSString*)text;
- (void) deleteBackward;

@end


@class NSTextAlternatives;
@class UITextPosition;
@class UITextRange;
@class UITextSelectionRect;

@protocol UITextInputTokenizer;
@protocol UITextInputDelegate;


typedef NS_ENUM(NSInteger, UITextStorageDirection) {
    UITextStorageDirectionForward = 0,
    UITextStorageDirectionBackward
};

typedef NS_ENUM(NSInteger, UITextLayoutDirection) {
    UITextLayoutDirectionRight = 2,
    UITextLayoutDirectionLeft,
    UITextLayoutDirectionUp,
    UITextLayoutDirectionDown
};

typedef NSInteger UITextDirection;

typedef NS_ENUM(NSInteger, UITextWritingDirection) {
    UITextWritingDirectionNatural = -1,
    UITextWritingDirectionLeftToRight = 0,
    UITextWritingDirectionRightToLeft,
};

typedef NS_ENUM(NSInteger, UITextGranularity) {
    UITextGranularityCharacter,
    UITextGranularityWord,
    UITextGranularitySentence,
    UITextGranularityParagraph,
    UITextGranularityLine,
    UITextGranularityDocument
};


@interface UIDictationPhrase : NSObject

@property (nonatomic, readonly) NSString* text;
@property (nonatomic, readonly) NSArray* alternativeInterpretations;

@end

@protocol UITextInput <UIKeyInput>
@required

- (NSString *)textInRange:(UITextRange*) range;
- (void)replaceRange:(UITextRange*) range withText:(NSString*)text;

@property (readwrite, copy) UITextRange* selectedTextRange;

@property (nonatomic, readonly) UITextRange* markedTextRange;
@property (nonatomic, copy) NSDictionary* markedTextStyle;
- (void) setMarkedText:(NSString*)markedText selectedRange:(NSRange)selectedRange;
- (void) unmarkText;

#pragma mark The end and beginning of the the text document
@property (nonatomic, readonly) UITextPosition* beginningOfDocument;
@property (nonatomic, readonly) UITextPosition* endOfDocument;

#pragma mark Methods for creating ranges and positions
- (UITextRange*) textRangeFromPosition:(UITextPosition*)fromPosition toPosition:(UITextPosition*)toPosition;
- (UITextPosition*) positionFromPosition:(UITextPosition*)position offset:(NSInteger)offset;
- (UITextPosition*) positionFromPosition:(UITextPosition*)position inDirection:(UITextLayoutDirection)direction offset:(NSInteger)offset;

#pragma mark Simple evaluation of positions
- (NSComparisonResult) comparePosition:(UITextPosition*)position toPosition:(UITextPosition*)other;
- (NSInteger) offsetFromPosition:(UITextPosition*)from toPosition:(UITextPosition*)toPosition;

@property (nonatomic, assign) id <UITextInputDelegate> inputDelegate;

@property (nonatomic, readonly) id <UITextInputTokenizer> tokenizer;

#pragma mark Layout questions
- (UITextPosition*) positionWithinRange:(UITextRange*)range farthestInDirection:(UITextLayoutDirection)direction;
- (UITextRange*) characterRangeByExtendingPosition:(UITextPosition*)position inDirection:(UITextLayoutDirection)direction;

#pragma mark Writing direction
- (UITextWritingDirection) baseWritingDirectionForPosition:(UITextPosition*)position inDirection:(UITextStorageDirection)direction;
- (void) setBaseWritingDirection:(UITextWritingDirection)writingDirection forRange:(UITextRange *)range;

#pragma mark Geometry used to provide, for example, a correction rect
- (CGRect) firstRectForRange:(UITextRange*)range;
- (CGRect) caretRectForPosition:(UITextPosition*)position;
- (NSArray*) selectionRectsForRange:(UITextRange*)range;

#pragma Hit testing.
- (UITextPosition*) closestPositionToPoint:(CGPoint)point;
- (UITextPosition*) closestPositionToPoint:(CGPoint)point withinRange:(UITextRange*)range;
- (UITextRange*) characterRangeAtPoint:(CGPoint)point;

@optional

- (BOOL) shouldChangeTextInRange:(UITextRange*)range replacementText:(NSString*)text;

- (NSDictionary*) textStylingAtPosition:(UITextPosition*)position inDirection:(UITextStorageDirection)direction;
- (UITextPosition*) positionWithinRange:(UITextRange*)range atCharacterOffset:(NSInteger)offset;
- (NSInteger) characterOffsetOfPosition:(UITextPosition*)position withinRange:(UITextRange*)range;

@property (nonatomic, readonly) UIView* textInputView;
@property (nonatomic) UITextStorageDirection selectionAffinity;

- (void) insertDictationResult:(NSArray*)dictationResult;

- (void) dictationRecordingDidEnd;
- (void) dictationRecognitionFailed;

- (id) insertDictationResultPlaceholder;
- (CGRect) frameForDictationResultPlaceholder:(id)placeholder;

- (void) removeDictationResultPlaceholder:(id)placeholder willInsertResult:(BOOL)willInsertResult;

@end


UIKIT_EXTERN NSString* const UITextInputTextBackgroundColorKey;
UIKIT_EXTERN NSString* const UITextInputTextColorKey;
UIKIT_EXTERN NSString* const UITextInputTextFontKey;


@interface UITextPosition : NSObject
@end


@interface UITextRange : NSObject

@property (nonatomic, readonly, getter=isEmpty) BOOL empty;
@property (nonatomic, readonly) UITextPosition* start;
@property (nonatomic, readonly) UITextPosition* end;

@end


@interface UITextSelectionRect : NSObject

@property (nonatomic, readonly) CGRect rect;
@property (nonatomic, readonly) UITextWritingDirection writingDirection;
@property (nonatomic, readonly) BOOL containsStart;
@property (nonatomic, readonly) BOOL containsEnd;
@property (nonatomic, readonly) BOOL isVertical;

@end


@protocol UITextInputDelegate <NSObject>

- (void) selectionWillChange:(id <UITextInput>)textInput;
- (void) selectionDidChange:(id <UITextInput>)textInput;
- (void) textWillChange:(id <UITextInput>)textInput;
- (void) textDidChange:(id <UITextInput>)textInput;

@end


@protocol UITextInputTokenizer <NSObject>
@required

- (UITextRange*) rangeEnclosingPosition:(UITextPosition*)position withGranularity:(UITextGranularity)granularity inDirection:(UITextDirection)direction;
- (BOOL) isPosition:(UITextPosition*)position atBoundary:(UITextGranularity)granularity inDirection:(UITextDirection)direction;
- (UITextPosition*) positionFromPosition:(UITextPosition*)position toBoundary:(UITextGranularity)granularity inDirection:(UITextDirection)direction;
- (BOOL) isPosition:(UITextPosition*)position withinTextUnit:(UITextGranularity)granularity inDirection:(UITextDirection)direction;

@end


@interface UITextInputStringTokenizer : NSObject <UITextInputTokenizer>

- (id)initWithTextInput:(UIResponder <UITextInput> *)textInput;

@end

@interface UITextInputMode : NSObject <NSSecureCoding>

@property (nonatomic, readonly, retain) NSString* primaryLanguage;

+ (UITextInputMode*) currentInputMode;
+ (NSArray*) activeInputModes;

@end


UIKIT_EXTERN NSString* const UITextInputCurrentInputModeDidChangeNotification;
