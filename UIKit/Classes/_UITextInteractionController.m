#import "_UITextInteractionController.h"
#import "_UITextInputPlus.h"
#import "_UITextInputModel.h"
//
#import <UIKit/UIView.h>
#import <UIKit/UIPasteboard.h>
#import <UIKit/UIGestureRecognizer.h>
#import <UIKit/UITapGestureRecognizer.h>
#import <UIKit/UITouch.h>


@interface UIView (XXX_Temporary) <_UITextInteractionControllerDelegate>
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
        bool textInteractionControllerDidChangeSelection : 1;
        bool textInteractionControllerEditorDidChangeSelection : 1;
        bool textInteractionControllerWillChangeSelectionFromCharacterRangeToCharacterRange : 1;
        bool textInteractionControllerDidChangeCaretPosition : 1;
    } _viewHas;

    BOOL _stillSelecting;
    NSUInteger _selectionOrigin;
//    NSSelectionGranularity _selectionGranularity;
}

- (instancetype) initWithView:(UIResponder<UITextInput>*)view inputModel:(_UITextInputModel*)inputModel
{
    NSAssert(nil != view, @"???");
    NSAssert(nil != inputModel, @"???");
    if (nil != (self = [super init])) {
        _selectedRange = (NSRange){ NSNotFound, 0 };
        _view = (UIView<_UITextInputPlus>*)view;
        _viewHas.beginSelectionChange = [view respondsToSelector:@selector(beginSelectionChange)];
        _viewHas.endSelectionChange = [view respondsToSelector:@selector(endSelectionChange)];
        _viewHas.textRangeOfWordContainingPosition = [view respondsToSelector:@selector(textRangeOfWordContainingPosition:)];
        _viewHas.textInteractionControllerDidChangeSelection = [view respondsToSelector:@selector(textInteractionControllerDidChangeSelection:)];
        _viewHas.textInteractionControllerWillChangeSelectionFromCharacterRangeToCharacterRange = [view respondsToSelector:@selector(textInteractionController:willChangeSelectionFromCharacterRange:toCharacterRange:)];
        _viewHas.textInteractionControllerEditorDidChangeSelection = [view respondsToSelector:@selector(textInteractionControllerEditorDidChangeSelection:)];
        _viewHas.textInteractionControllerDidChangeCaretPosition = [view respondsToSelector:@selector(textInteractionController:didChangeCaretPosition:)];
        _inputModel = inputModel;
        _gestureRecognizers = [[NSMutableArray alloc] init];
    }
    return self;
}


#pragma mark Public Methods

- (void) setSelectedRange:(NSRange)selectedRange
{
    if ((_selectedRange.location != selectedRange.location) || (_selectedRange.length != selectedRange.length)) {
        if (_viewHas.textInteractionControllerWillChangeSelectionFromCharacterRangeToCharacterRange) {
            selectedRange = [_view textInteractionController:self willChangeSelectionFromCharacterRange:_selectedRange toCharacterRange:selectedRange];
        }
        if (!_stillSelecting && !selectedRange.length) {
            _selectionOrigin = selectedRange.location;
        }
        _selectedRange = selectedRange;
        if (_viewHas.textInteractionControllerDidChangeSelection) {
            [_view textInteractionControllerDidChangeSelection:self];
        }
    }
}

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

- (void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch* touch = [[event allTouches] anyObject];
    [self _setAndScrollToRange:[_inputModel characterRangeAtPoint:[touch locationInView:_view]]];
    _stillSelecting = YES;
}

- (void) touchesMoved:(NSSet*)touches withEvent:(UIEvent *)event
{
    UITouch* touch = [[event allTouches] anyObject];
    NSUInteger index = [_inputModel characterRangeAtPoint:[touch locationInView:_view]].location;
    NSRange range;
    if (_selectionOrigin > index) {
        range = (NSRange){ index, _selectionOrigin - index };
    } else {
        range = (NSRange){ _selectionOrigin, index - _selectionOrigin };
    }
    [self _setAndScrollToRange:range upstream:_selectionOrigin > index];
}

- (void) touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    _stillSelecting = NO;
}



#pragma mark Basic Input

- (void) insertText:(NSString*)text
{
    NSRange range = [self selectedRange];
    [_inputModel replaceRange:range withText:text];
    [self setSelectedRange:(NSRange){ range.location + [text length], 0 }];
}

- (void) deleteBackward
{
    NSRange range = [self selectedRange];
    if (!range.length) {
        NSInteger end = range.location;
        NSInteger start = [_inputModel positionFromPosition:range.location offset:-1];
        if (start <= end) {
            range = (NSRange){
                .location = start,
                .length = end - start
            };
        }
    }
    if (![_inputModel shouldChangeTextInRange:range replacementText:@""]) {
        return;
    }
    [_inputModel replaceRange:range withText:@""];
    [self setSelectedRange:(NSRange){ range.location, 0 }];
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
    [self deleteBackward];
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
    [self _modifySelectionWith:^NSInteger(NSInteger index) {
        return [_inputModel _indexWhenMovingLeftFromIndex:index];
    }];
}

- (void) moveWordLeft:(id)sender
{
    [self _setAndScrollToRange:(NSRange){
        [_inputModel _indexWhenMovingWordLeftFromIndex:[self selectedRange].location],
        0
    }];
}

- (void) moveWordLeftAndModifySelection:(id)sender
{
    [self _modifySelectionWith:^NSInteger(NSInteger index) {
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
    [self _modifySelectionWith:^NSInteger(NSInteger index) {
        return [_inputModel _indexWhenMovingRightFromIndex:index];
    }];
}

- (void) moveWordRight:(id)sender
{
    [self _setAndScrollToRange:(NSRange){
        [_inputModel _indexWhenMovingWordRightFromIndex:[self selectedRange].location],
        0
    }];
}

- (void) moveWordRightAndModifySelection:(id)sender
{
    [self _modifySelectionWith:^NSInteger(NSInteger index) {
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
    [self _modifySelectionWith:^NSInteger(NSInteger index) {
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
    [self _modifySelectionWith:^NSInteger(NSInteger index) {
        return [_inputModel _indexWhenMovingDownFromIndex:index by:index];
    }];
}

- (void) moveToBeginningOfLine:(id)sender
{
    [self _setAndScrollToRange:(NSRange){
        [_inputModel _indexWhenMovingToBeginningOfLineFromIndex:[self selectedRange].location],
        0
    }];
}

- (void) moveToBeginningOfLineAndModifySelection:(id)sender
{
    [self _modifySelectionWith:^NSInteger(NSInteger index) {
        return [_inputModel _indexWhenMovingToBeginningOfLineFromIndex:index];
    }];
}

- (void) moveToEndOfLine:(id)sender
{
    [self _setAndScrollToRange:(NSRange){
        [_inputModel _indexWhenMovingToEndOfLineFromIndex:NSMaxRange([self selectedRange])],
        0
    }];
}

- (void) moveToEndOfLineAndModifySelection:(id)sender
{
    [self _modifySelectionWith:^NSInteger(NSInteger index) {
        return [_inputModel _indexWhenMovingToEndOfLineFromIndex:index];
    }];
}

- (void) moveToBeginningOfParagraph:(id)sender
{
    [self _setAndScrollToRange:(NSRange){
        [_inputModel _indexWhenMovingToBeginningOfParagraphFromIndex:[self selectedRange].location],
        0
    }];
}

- (void) moveParagraphBackwardAndModifySelection:(id)sender
{
    [self _modifySelectionWith:^NSInteger(NSInteger index) {
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
    [self _setAndScrollToRange:(NSRange){
        [_inputModel _indexWhenMovingToEndOfParagraphFromIndex:[self selectedRange].location],
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
    [self _modifySelectionWith:^NSInteger(NSInteger index) {
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
    [self _setAndScrollToRange:(NSRange){
        [_inputModel _indexWhenMovingToBeginningOfDocumentFromIndex:[self selectedRange].location],
        0
    }];
}

- (void) moveToBeginningOfDocumentAndModifySelection:(id)sender
{
    [self _modifySelectionWith:^NSInteger(NSInteger index) {
        return [_inputModel _indexWhenMovingToBeginningOfDocumentFromIndex:index];
    }];
}

- (void) moveToEndOfDocument:(id)sender
{
    [self _setAndScrollToRange:(NSRange){
        [_inputModel _indexWhenMovingToEndOfDocumentFromIndex:[self selectedRange].location],
        0
    }];
}

- (void) moveToEndOfDocumentAndModifySelection:(id)sender
{
    [self _modifySelectionWith:^NSInteger(NSInteger index) {
        return [_inputModel _indexWhenMovingToEndOfDocumentFromIndex:index];
    }];
}

- (void) insertNewline:(id)sender
{
    [self insertText:@"\n"];
}


#pragma Private Methods

- (void) setFirstResponderIfNecessary
{
    if (![_view isFirstResponder]) {
        [_view becomeFirstResponder];
    }
}



#pragma mark Cursor Calculations

- (void) _setAndScrollToRange:(NSRange)range upstream:(BOOL)upstream
{
    [self setSelectedRange:range];
    if (_viewHas.textInteractionControllerDidChangeCaretPosition) {
        NSInteger caretPosition = upstream ? range.location : NSMaxRange(range);
        [_view textInteractionController:self didChangeCaretPosition:caretPosition];
    }
}

- (void) _setAndScrollToRange:(NSRange)range
{
    [self _setAndScrollToRange:range upstream:YES];
}

- (void) _modifySelectionWith:(NSInteger(^)(NSInteger))calculation
{
    NSRange range = [self selectedRange];
    NSInteger start = range.location;
    NSInteger end = NSMaxRange(range);
    BOOL upstream = (end <= _selectionOrigin);
    NSInteger index = calculation(upstream ? start : end);
    if (index > _selectionOrigin) {
        range.location = _selectionOrigin;
        range.length = index - _selectionOrigin;
    } else {
        range.location = index;
        range.length = _selectionOrigin - index;
    }
    [self _setAndScrollToRange:range upstream:upstream];
}

@end



