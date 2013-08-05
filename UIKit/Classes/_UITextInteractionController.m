#import "_UITextInteractionController.h"
#import "_UITextInputPlus.h"
#import "_UITextInputModel.h"
//
#import <UIKit/UIView.h>
#import <UIKit/UIPasteboard.h>
#import <UIKit/UIGestureRecognizer.h>
#import <UIKit/UITapGestureRecognizer.h>


@interface UIView (XXX_Temporary)
- (void) _modifySelectionWith:(NSInteger(^)(NSInteger))calculation;
- (void) _setAndScrollToRange:(NSRange)range;
- (NSRange) setSelectedRange:(NSRange)range;
- (NSRange) selectedRange;
@end


@interface _UITextInteractionController () <UIGestureRecognizerDelegate>
@end


@implementation _UITextInteractionController {
    UIView<_UITextInputPlus>* _view;
    _UITextInputModel* _inputModel;
    NSMutableArray* _gestureRecognizers;
    struct {
        bool beginSelectionChange : 1;
        bool endSelectionChange : 1;
        bool textRangeOfWordContainingPosition : 1;
    } _viewHas;
}

- (instancetype) initWithView:(UIResponder<UITextInput>*)view inputModel:(_UITextInputModel*)inputModel
{
    NSAssert(nil != view, @"???");
    NSAssert(nil != inputModel, @"???");
    if (nil != (self = [super init])) {
        _view = (UIView<_UITextInputPlus>*)view;
        _viewHas.beginSelectionChange = [view respondsToSelector:@selector(beginSelectionChange)];
        _viewHas.endSelectionChange = [view respondsToSelector:@selector(endSelectionChange)];
        _viewHas.textRangeOfWordContainingPosition = [view respondsToSelector:@selector(textRangeOfWordContainingPosition:)];
        _inputModel = inputModel;
        _gestureRecognizers = [[NSMutableArray alloc] init];
    }
    return self;
}


#pragma mark Public Methods

- (UITapGestureRecognizer*) addOneFingerTapRecognizerToView:(UIView*)view
{
    UITapGestureRecognizer* gesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(oneFingerTap:)];
    [gesture setNumberOfTapsRequired:1];
    [gesture setNumberOfTouchesRequired:1];
    [view addGestureRecognizer:gesture];
    [_gestureRecognizers addObject:gesture];
    return gesture;
}

- (UITapGestureRecognizer*) addOneFingerDoubleTapRecognizerToView:(UIView*)view
{
    UITapGestureRecognizer* gesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(oneFingerDoubleTap:)];
    [gesture setNumberOfTapsRequired:2];
    [gesture setNumberOfTouchesRequired:1];
    [view addGestureRecognizer:gesture];
    [_gestureRecognizers addObject:gesture];
    return gesture;
}

- (void) removeGestureRecognizersFromView:(UIView*)view
{
    NSMutableArray* newGestureRecognizers = [[NSMutableArray alloc] initWithCapacity:[_gestureRecognizers count]];
    for (UIGestureRecognizer* gestureRecognizer in _gestureRecognizers) {
        if ([gestureRecognizer view] == view) {
            [view removeGestureRecognizer:gestureRecognizer];
        } else {
            [newGestureRecognizers addObject:gestureRecognizer];
        }
    }
    _gestureRecognizers = newGestureRecognizers;
}


#pragma mark Gesture Handlers

- (void) oneFingerTap:(UIGestureRecognizer*)gestureRecognizer
{
    if ([gestureRecognizer state] == UIGestureRecognizerStateEnded) {
        [self setFirstResponderIfNecessary];
        UIView<_UITextInputPlus>* view = (UIView<_UITextInputPlus>*)[self view];
        if (_viewHas.beginSelectionChange) {
            [view beginSelectionChange];
        }
        UITextPosition* position = [view closestPositionToPoint:[gestureRecognizer locationInView:view]];
        UITextRange* range = [view textRangeFromPosition:position toPosition:position];
        [view setSelectedTextRange:range];
        if (_viewHas.endSelectionChange) {
            [view endSelectionChange];
        }
    }
}

- (void) oneFingerDoubleTap:(UITapGestureRecognizer*)gestureRecognizer
{
    if ([gestureRecognizer state] == UIGestureRecognizerStateEnded) {
        [self setFirstResponderIfNecessary];
        if (_viewHas.textRangeOfWordContainingPosition) {
            UIView<_UITextInputPlus>* view = (UIView<_UITextInputPlus>*)[self view];
            if (_viewHas.beginSelectionChange) {
                [view beginSelectionChange];
            }
            UITextPosition* position = [view closestPositionToPoint:[gestureRecognizer locationInView:view]];
            UITextRange* range = [view textRangeOfWordContainingPosition:position];
            [view setSelectedTextRange:range];
            if (_viewHas.endSelectionChange) {
                [view endSelectionChange];
            }
        }
    }
}


#pragma mark Basic Input

- (void) insertText:(NSString*)text
{
    [_view replaceRange:[_view selectedTextRange] withText:text];
}

- (void) deleteBackward
{
    UITextRange* range = [_view selectedTextRange];
    if (!range || [range isEmpty]) {
        UITextPosition* toPosition = [range start];
        UITextPosition* fromPosition = [_view positionFromPosition:[range start] offset:-1];
        if (!fromPosition) {
            return;
        }
        range = [_view textRangeFromPosition:fromPosition toPosition:toPosition];
    }
    if (![_view shouldChangeTextInRange:range replacementText:@""]) {
        return;
    }
    [_view replaceRange:range withText:@""];
}


#pragma mark Keyboard Handling

- (void) doCommandBySelector:(SEL)selector
{
    if ([self respondsToSelector:selector]) {
        void (*command)(id, SEL, id) = (void*)[[self class] instanceMethodForSelector:selector];
        command(self, selector, self);
    }
}

- (void) deleteBackward:(id)sender
{
    [_view deleteBackward];
}

- (void) deleteForward:(id)sender
{
    UITextRange* range = [_view selectedTextRange];
    if (!range || [range isEmpty]) {
        UITextPosition* fromPosition = [range start];
        UITextPosition* toPosition = [_view positionFromPosition:[range start] offset:1];
        if (!toPosition) {
            return;
        }
        range = [_view textRangeFromPosition:fromPosition toPosition:toPosition];
    }
    if (![_view shouldChangeTextInRange:range replacementText:@""]) {
        return;
    }
    [_view replaceRange:range withText:@""];
}

- (void) deleteWordBackward:(id)sender
{
    if ([[_view selectedTextRange] isEmpty]) {
        [self moveWordLeftAndModifySelection:self];
    }
    [self deleteBackward:self];
}

- (void) moveLeft:(id)sender
{
    UITextPosition* position = [[_view selectedTextRange] start];
    UITextPosition* newPosition = [_view positionFromPosition:position inDirection:UITextLayoutDirectionLeft offset:1];
    [_view setSelectedTextRange:[_view textRangeFromPosition:newPosition toPosition:newPosition]];
}

- (void) moveLeftAndModifySelection:(id)sender
{
    [_view _modifySelectionWith:^NSInteger(NSInteger index) {
        return [_inputModel _indexWhenMovingLeftFromIndex:index];
    }];
}

- (void) moveWordLeft:(id)sender
{
    [_view _setAndScrollToRange:(NSRange){
        [_inputModel _indexWhenMovingWordLeftFromIndex:[_view selectedRange].location],
        0
    }];
}

- (void) moveWordLeftAndModifySelection:(id)sender
{
    [_view _modifySelectionWith:^NSInteger(NSInteger index) {
        return [_inputModel _indexWhenMovingWordLeftFromIndex:index];
    }];
}

- (void) moveRight:(id)sender
{
    UITextPosition* position = [[_view selectedTextRange] start];
    UITextPosition* newPosition = [_view positionFromPosition:position inDirection:UITextLayoutDirectionRight offset:1];
    [_view setSelectedTextRange:[_view textRangeFromPosition:newPosition toPosition:newPosition]];
}

- (void) moveRightAndModifySelection:(id)sender
{
    [_view _modifySelectionWith:^NSInteger(NSInteger index) {
        return [_inputModel _indexWhenMovingRightFromIndex:index];
    }];
}

- (void) moveWordRight:(id)sender
{
    [_view _setAndScrollToRange:(NSRange){
        [_inputModel _indexWhenMovingWordRightFromIndex:[_view selectedRange].location],
        0
    }];
}

- (void) moveWordRightAndModifySelection:(id)sender
{
    [_view _modifySelectionWith:^NSInteger(NSInteger index) {
        return [_inputModel _indexWhenMovingWordRightFromIndex:index];
    }];
}

- (void) moveUp:(id)sender
{
    UITextPosition* position = [[_view selectedTextRange] start];
    UITextPosition* newPosition = [_view positionFromPosition:position inDirection:UITextLayoutDirectionUp offset:1];
    [_view setSelectedTextRange:[_view textRangeFromPosition:newPosition toPosition:newPosition]];
}

- (void) moveUpAndModifySelection:(id)sender
{
    [_view _modifySelectionWith:^NSInteger(NSInteger index) {
        return [_inputModel _indexWhenMovingUpFromIndex:index by:1];
    }];
}

- (void) moveDown:(id)sender
{
    UITextPosition* position = [[_view selectedTextRange] start];
    UITextPosition* newPosition = [_view positionFromPosition:position inDirection:UITextLayoutDirectionDown offset:1];
    [_view setSelectedTextRange:[_view textRangeFromPosition:newPosition toPosition:newPosition]];
}

- (void) moveDownAndModifySelection:(id)sender
{
    [_view _modifySelectionWith:^NSInteger(NSInteger index) {
        return [_inputModel _indexWhenMovingDownFromIndex:index by:index];
    }];
}

- (void) moveToBeginningOfLine:(id)sender
{
    [_view _setAndScrollToRange:(NSRange){
        [_inputModel _indexWhenMovingToBeginningOfLineFromIndex:[_view selectedRange].location],
        0
    }];
}

- (void) moveToBeginningOfLineAndModifySelection:(id)sender
{
    [_view _modifySelectionWith:^NSInteger(NSInteger index) {
        return [_inputModel _indexWhenMovingToBeginningOfLineFromIndex:index];
    }];
}

- (void) moveToEndOfLine:(id)sender
{
    [_view _setAndScrollToRange:(NSRange){
        [_inputModel _indexWhenMovingToEndOfLineFromIndex:NSMaxRange([_view selectedRange])],
        0
    }];
}

- (void) moveToEndOfLineAndModifySelection:(id)sender
{
    [_view _modifySelectionWith:^NSInteger(NSInteger index) {
        return [_inputModel _indexWhenMovingToEndOfLineFromIndex:index];
    }];
}

- (void) moveToBeginningOfParagraph:(id)sender
{
    [_view _setAndScrollToRange:(NSRange){
        [_inputModel _indexWhenMovingToBeginningOfParagraphFromIndex:[_view selectedRange].location],
        0
    }];
}

- (void) moveParagraphBackwardAndModifySelection:(id)sender
{
    [_view _modifySelectionWith:^NSInteger(NSInteger index) {
        return [_inputModel _indexWhenMovingToBeginningOfParagraphFromIndex:index];
    }];
}

- (void) moveToBeginningOfParagraphOrMoveUp:(id)sender
{
    if ([_inputModel _isLocationAtBeginningOfParagraph]) {
        [self moveUp:self];
    } else {
        [self moveToBeginningOfParagraph:self];
    }
}

- (void) moveParagraphBackwardOrMoveUpAndModifySelection:(id)sender
{
    if ([_inputModel _isLocationAtBeginningOfParagraph]) {
        [self moveUpAndModifySelection:self];
    } else {
        [self moveParagraphBackwardAndModifySelection:self];
    }
}

- (void) moveToEndOfParagraph:(id)sender
{
    [_view _setAndScrollToRange:(NSRange){
        [_inputModel _indexWhenMovingToEndOfParagraphFromIndex:[_view selectedRange].location],
        0
    }];
}

- (void) moveToEndOfParagraphOrMoveDown:(id)sender
{
    if ([_inputModel _isLocationAtEndOfParagraph]) {
        [self moveDown:self];
    } else {
        [self moveToEndOfParagraph:self];
    }
}

- (void) moveParagraphForwardAndModifySelection:(id)sender
{
    [_view _modifySelectionWith:^NSInteger(NSInteger index) {
        return [_inputModel _indexWhenMovingToEndOfParagraphFromIndex:index];
    }];
}

- (void) moveParagraphForwardOrMoveDownAndModifySelection:(id)sender
{
    if ([_inputModel _isLocationAtEndOfParagraph]) {
        [self moveDownAndModifySelection:self];
    } else {
        [self moveParagraphForwardAndModifySelection:self];
    }
}

- (void) moveToBeginningOfDocument:(id)sender
{
    [_view _setAndScrollToRange:(NSRange){
        [_inputModel _indexWhenMovingToBeginningOfDocumentFromIndex:[_view selectedRange].location],
        0
    }];
}

- (void) moveToBeginningOfDocumentAndModifySelection:(id)sender
{
    [_view _modifySelectionWith:^NSInteger(NSInteger index) {
        return [_inputModel _indexWhenMovingToBeginningOfDocumentFromIndex:index];
    }];
}

- (void) moveToEndOfDocument:(id)sender
{
    [_view _setAndScrollToRange:(NSRange){
        [_inputModel _indexWhenMovingToEndOfDocumentFromIndex:[_view selectedRange].location],
        0
    }];
}

- (void) moveToEndOfDocumentAndModifySelection:(id)sender
{
    [_view _modifySelectionWith:^NSInteger(NSInteger index) {
        return [_inputModel _indexWhenMovingToEndOfDocumentFromIndex:index];
    }];
}

- (void) insertNewline:(id)sender
{
    [_view insertText:@"\n"];
}


#pragma Private Methods

- (void) setFirstResponderIfNecessary
{
    if (![_view isFirstResponder]) {
        [_view becomeFirstResponder];
    }
}

@end



