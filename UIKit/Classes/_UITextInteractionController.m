#import "_UITextInteractionController.h"
#import "_UITextInputPlus.h"
#import "_UITextModel.h"
//
#import <UIKit/UIView.h>
#import <UIKit/UIPasteboard.h>
#import <UIKit/UIGestureRecognizer.h>
#import <UIKit/UIPanGestureRecognizer.h>
#import <UIKit/UITapGestureRecognizer.h>
#import <UIKit/UITouch.h>


@interface UIView (XXX_Temporary) <_UITextInteractionControllerDelegate>
@end


@interface _UITextInteractionController () <UIGestureRecognizerDelegate>
@end


@implementation _UITextInteractionController {
    UIView<_UITextInputPlus>* _view;
    _UITextModel* _model;
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

    struct {
        bool hasSetInsertionPoint : 1;
    } _flags;
    
    BOOL _stillSelecting;
    NSUInteger _selectionOrigin;
//    NSSelectionGranularity _selectionGranularity;
}

- (instancetype) initWithView:(UIResponder<UITextInput>*)view model:(_UITextModel*)model
{
    NSAssert(nil != view, @"???");
    NSAssert(nil != model, @"???");
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
        _model = model;
        _gestureRecognizers = [[NSMutableArray alloc] init];
    }
    return self;
}


#pragma mark Public Methods

- (void) setSelectedRange:(NSRange)selectedRange
{
    [self setSelectedRange:selectedRange upstream:YES];
}

- (void) setSelectedRange:(NSRange)selectedRange upstream:(BOOL)upstream
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
        _selectionAffinity = upstream ? UITextStorageDirectionBackward : UITextStorageDirectionForward;
        [self setInsertionPoint:upstream ? selectedRange.location : NSMaxRange(selectedRange)];
    }
}

- (void) setInsertionPoint:(NSInteger)insertionPoint
{
    if (!_flags.hasSetInsertionPoint || _insertionPoint != insertionPoint) {
        _flags.hasSetInsertionPoint = YES;
        _insertionPoint = insertionPoint;
        if (_viewHas.textInteractionControllerDidChangeCaretPosition) {
            [_view textInteractionController:self didChangeCaretPosition:insertionPoint];
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

- (UIPanGestureRecognizer*) addSelectionPanGestureRecognizerToView:(UIView*)view
{
    UIPanGestureRecognizer* gesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(selectionPan:)];
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

- (void) removeGestureRecognizers
{
    for (UIGestureRecognizer* gestureRecognizer in _gestureRecognizers) {
        [[gestureRecognizer view] removeGestureRecognizer:gestureRecognizer];
    }
    [_gestureRecognizers removeAllObjects];
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

- (void) selectionPan:(UIPanGestureRecognizer*)gestureRecognizer
{
    switch ([gestureRecognizer state]) {
        case UIGestureRecognizerStatePossible: {
            break;
        }
            
        case UIGestureRecognizerStateBegan: {
            _selectionOrigin = [_model closestPositionToPoint:[gestureRecognizer translationInView:[gestureRecognizer view]]];
            _stillSelecting = YES;
            [self setSelectedRange:(NSRange){ _selectionOrigin, 0}];
            break;
        }
         
        case UIGestureRecognizerStateChanged: {
            NSRange characterRange = [_model characterRangeAtPoint:[gestureRecognizer translationInView:[gestureRecognizer view]]];
            NSRange range;
            bool upstream = _selectionOrigin >= characterRange.location;
            NSUInteger index = upstream ? characterRange.location : NSMaxRange(characterRange);
            if (upstream) {
                range = (NSRange){ index, _selectionOrigin - index };
            } else {
                range = (NSRange){ _selectionOrigin, index - _selectionOrigin };
            }
            [self setSelectedRange:range upstream:upstream];
            break;
        }
        
        case UIGestureRecognizerStateEnded:
        case UIGestureRecognizerStateFailed:
        case UIGestureRecognizerStateCancelled: {
            _stillSelecting = NO;
            break;
        }
    }
}


#pragma mark Basic Input

- (void) insertText:(NSString*)text
{
    NSRange range = [self selectedRange];
    [_model replaceRange:range withText:text];
    [self setSelectedRange:(NSRange){ range.location + [text length], 0 }];
}

- (void) deleteBackward
{
    NSRange range = [self selectedRange];
    if (!range.length) {
        NSInteger end = range.location;
        NSInteger start = [_model positionFromPosition:range.location offset:-1];
        if (start <= end) {
            range = (NSRange){
                .location = start,
                .length = end - start
            };
        }
    }
    if (![_model shouldChangeTextInRange:range replacementText:@""]) {
        return;
    }
    [_model replaceRange:range withText:@""];
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

- (void) selectAll:(id)sender
{
    NSInteger start = [_model beginningOfDocument];
    NSInteger end = [_model endOfDocument];
    [self setSelectedRange:(NSRange){ start, end - start }];
}

- (void) deleteBackward:(id)sender
{
    [self deleteBackward];
}

- (void) deleteForward:(id)sender
{
    NSRange range = [self selectedRange];
    if (!range.length) {
        NSInteger end = range.location;
        NSInteger start = [_model positionFromPosition:range.location offset:1];
        if (start <= end) {
            range = (NSRange){
                .location = start,
                .length = end - start
            };
        }
    }
    if (![_model shouldChangeTextInRange:range replacementText:@""]) {
        return;
    }
    [_model replaceRange:range withText:@""];
    [self setSelectedRange:(NSRange){ range.location, 0 }];
}

- (void) deleteWordBackward:(id)sender
{
    NSRange range = [self selectedRange];
    if (!range.length) {
        [self moveWordLeftAndModifySelection:self];
    }
    [self deleteBackward:self];
}

- (void) moveLeft:(id)sender
{
    [self _modifySelectionWithDirection:UITextStorageDirectionBackward calculation:^NSInteger(NSInteger index) {
        return [_model positionWhenMovingLeftFromPosition:index by:1];
    }];
}

- (void) moveLeftAndModifySelection:(id)sender
{
    [self _modifySelectionWith:^NSInteger(NSInteger index) {
        return [_model positionWhenMovingLeftFromPosition:index];
    }];
}

- (void) moveWordLeft:(id)sender
{
    [self _modifySelectionWithDirection:UITextStorageDirectionBackward calculation:^NSInteger(NSInteger index) {
        return [_model positionWhenMovingWordLeftFromPosition:index];
    }];
}

- (void) moveWordLeftAndModifySelection:(id)sender
{
    [self _modifySelectionWith:^NSInteger(NSInteger index) {
        return [_model positionWhenMovingWordLeftFromPosition:index];
    }];
}

- (void) moveRight:(id)sender
{
    [self _modifySelectionWithDirection:UITextStorageDirectionForward calculation:^NSInteger(NSInteger index) {
        return [_model positionWhenMovingRightFromPosition:index by:1];
    }];
}

- (void) moveRightAndModifySelection:(id)sender
{
    [self _modifySelectionWith:^NSInteger(NSInteger index) {
        return [_model positionWhenMovingRightFromPosition:index];
    }];
}

- (void) moveWordRight:(id)sender
{
    [self _modifySelectionWithDirection:UITextStorageDirectionForward calculation:^NSInteger(NSInteger index) {
        return [_model positionWhenMovingWordRightFromPosition:index];
    }];
}

- (void) moveWordRightAndModifySelection:(id)sender
{
    [self _modifySelectionWith:^NSInteger(NSInteger index) {
        return [_model positionWhenMovingWordRightFromPosition:index];
    }];
}

- (void) moveUp:(id)sender
{
    [self _modifySelectionWithDirection:UITextStorageDirectionBackward calculation:^NSInteger(NSInteger index) {
        return [_model positionWhenMovingUpFromPosition:index by:1];
    }];
}

- (void) moveUpAndModifySelection:(id)sender
{
    [self _modifySelectionWith:^NSInteger(NSInteger index) {
        return [_model positionWhenMovingUpFromPosition:index by:1];
    }];
}

- (void) moveDown:(id)sender
{
    [self _modifySelectionWithDirection:UITextStorageDirectionForward calculation:^NSInteger(NSInteger index) {
        return [_model positionWhenMovingDownFromPosition:index by:1];
    }];
}

- (void) moveDownAndModifySelection:(id)sender
{
    [self _modifySelectionWith:^NSInteger(NSInteger index) {
        return [_model positionWhenMovingDownFromPosition:index by:1];
    }];
}

- (void) moveToBeginningOfLine:(id)sender
{
    [self _modifySelectionWithDirection:UITextStorageDirectionBackward calculation:^NSInteger(NSInteger index) {
        return [_model positionWhenMovingToBeginningOfLineFromPosition:index];
    }];
}

- (void) moveToBeginningOfLineAndModifySelection:(id)sender
{
    [self _modifySelectionWith:^NSInteger(NSInteger index) {
        return [_model positionWhenMovingToBeginningOfLineFromPosition:index];
    }];
}

- (void) moveToEndOfLine:(id)sender
{
    [self _modifySelectionWithDirection:UITextStorageDirectionForward calculation:^NSInteger(NSInteger index) {
        return [_model positionWhenMovingToEndOfLineFromPosition:index];
    }];
}

- (void) moveToEndOfLineAndModifySelection:(id)sender
{
    [self _modifySelectionWith:^NSInteger(NSInteger index) {
        return [_model positionWhenMovingToEndOfLineFromPosition:index];
    }];
}

- (void) moveToBeginningOfParagraph:(id)sender
{
    [self _modifySelectionWithDirection:UITextStorageDirectionBackward calculation:^NSInteger(NSInteger index) {
        return [_model positionWhenMovingToBeginningOfParagraphFromPosition:index];
    }];
}

- (void) moveParagraphBackwardAndModifySelection:(id)sender
{
    [self _modifySelectionWith:^NSInteger(NSInteger index) {
        return [_model positionWhenMovingToBeginningOfParagraphFromPosition:index];
    }];
}

- (void) moveToBeginningOfParagraphOrMoveUp:(id)sender
{
    [self _modifySelectionWithDirection:UITextStorageDirectionBackward calculation:^NSInteger(NSInteger index) {
        NSInteger beginningOfParagraph = [_model positionWhenMovingToBeginningOfParagraphFromPosition:index];
        if (index != beginningOfParagraph) {
            return beginningOfParagraph;
        } else {
            return [_model positionWhenMovingUpFromPosition:index by:1];
        }
    }];
}

- (void) moveParagraphBackwardOrMoveUpAndModifySelection:(id)sender
{
    [self _modifySelectionWith:^NSInteger(NSInteger index) {
        NSInteger beginningOfParagraph = [_model positionWhenMovingToBeginningOfParagraphFromPosition:index];
        if (index != beginningOfParagraph) {
            return beginningOfParagraph;
        } else {
            return [_model positionWhenMovingUpFromPosition:index by:1];
        }
    }];
}

- (void) moveToEndOfParagraph:(id)sender
{
    [self _modifySelectionWithDirection:UITextStorageDirectionForward calculation:^NSInteger(NSInteger index) {
        return [_model positionWhenMovingToEndOfParagraphFromPosition:index];
    }];
}

- (void) moveToEndOfParagraphOrMoveDown:(id)sender
{
    [self _modifySelectionWithDirection:UITextStorageDirectionForward calculation:^NSInteger(NSInteger index) {
        NSInteger endOfParagraph = [_model positionWhenMovingToEndOfParagraphFromPosition:index];
        if (index != endOfParagraph) {
            return endOfParagraph;
        } else {
            return [_model positionWhenMovingDownFromPosition:index by:1];
        }
    }];
}

- (void) moveParagraphForwardAndModifySelection:(id)sender
{
    [self _modifySelectionWith:^NSInteger(NSInteger index) {
        return [_model positionWhenMovingToEndOfParagraphFromPosition:index];
    }];
}

- (void) moveParagraphForwardOrMoveDownAndModifySelection:(id)sender
{
    [self _modifySelectionWith:^NSInteger(NSInteger index) {
        NSInteger endOfParagraph = [_model positionWhenMovingToEndOfParagraphFromPosition:index];
        if (index != endOfParagraph) {
            return endOfParagraph;
        } else {
            return [_model positionWhenMovingDownFromPosition:index by:1];
        }
    }];
}

- (void) moveToBeginningOfDocument:(id)sender
{
    [self _modifySelectionWithDirection:UITextStorageDirectionBackward calculation:^NSInteger(NSInteger index) {
        return [_model beginningOfDocument];
    }];
}

- (void) moveToBeginningOfDocumentAndModifySelection:(id)sender
{
    [self _modifySelectionWith:^NSInteger(NSInteger index) {
        return [_model beginningOfDocument];
    }];
}

- (void) moveToEndOfDocument:(id)sender
{
    [self _modifySelectionWithDirection:UITextStorageDirectionForward calculation:^NSInteger(NSInteger index) {
        return [_model endOfDocument];
    }];
}

- (void) moveToEndOfDocumentAndModifySelection:(id)sender
{
    [self _modifySelectionWith:^NSInteger(NSInteger index) {
        return [_model endOfDocument];
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

- (void) _modifySelectionWithDirection:(UITextStorageDirection)direction calculation:(NSInteger(^)(NSInteger))calculation
{
    NSRange range = [self selectedRange];
    if (!range.length) {
        [self setSelectedRange:(NSRange){ calculation(range.location) } upstream:YES];
    } else {
        [self setSelectedRange:(NSRange){ (direction == UITextStorageDirectionBackward) ? range.location : NSMaxRange(range) } upstream:YES];
    }
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
    [self setSelectedRange:range upstream:upstream];
}

@end
