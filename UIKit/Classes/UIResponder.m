/*
 * Copyright (c) 2011, The Iconfactory. All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are met:
 *
 * 1. Redistributions of source code must retain the above copyright
 *    notice, this list of conditions and the following disclaimer.
 *
 * 2. Redistributions in binary form must reproduce the above copyright notice,
 *    this list of conditions and the following disclaimer in the documentation
 *    and/or other materials provided with the distribution.
 *
 * 3. Neither the name of The Iconfactory nor the names of its contributors may
 *    be used to endorse or promote products derived from this software without
 *    specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
 * ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
 * WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
 * DISCLAIMED. IN NO EVENT SHALL THE ICONFACTORY BE LIABLE FOR ANY DIRECT,
 * INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING,
 * BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
 * DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
 * LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE
 * OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF
 * ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

#import <UIKit/UIResponder.h>
#import <UIKit/UIWindow+UIPrivate.h>

@implementation UIResponder

#pragma mark Managing the Responder Chain
- (UIResponder*) nextResponder
{
    return nil;
}

- (BOOL) isFirstResponder
{
    return ([[self _responderWindow] _firstResponder] == self);
}

- (BOOL) canBecomeFirstResponder
{
    return NO;
}

- (BOOL) becomeFirstResponder
{
    if ([self isFirstResponder]) {
        return YES;
    } else {
        UIWindow *window = [self _responderWindow];
        UIResponder *firstResponder = [window _firstResponder];
        
        if (window && [self canBecomeFirstResponder]) {
            BOOL willBecomeFirstResponder = NO;
            
            if (firstResponder && [firstResponder canResignFirstResponder]) {
                willBecomeFirstResponder = [firstResponder resignFirstResponder];
            } else {
                willBecomeFirstResponder = YES;
            }
            
            if (willBecomeFirstResponder) {
                [window _setFirstResponder:self];
                return YES;
            }
        }
        return NO;
    }
}

- (BOOL) canResignFirstResponder
{
    return YES;
}

- (BOOL) resignFirstResponder
{
    if ([self isFirstResponder]) {
        if ([self canResignFirstResponder]) {
            [[self _responderWindow] _setFirstResponder:nil];
            return YES;
        }
    }
    return NO;
}

#pragma mark Managing Input Views
- (UIView*) inputView
{
    return nil;
}

- (UIView*) inputAccessoryView
{
    return nil;
}

- (void) reloadInputViews
{
#warning stub
    [self doesNotRecognizeSelector:_cmd];
}


#pragma mark Responding to Touch Events
- (void) touchesBegan:(NSSet*)touches withEvent:(UIEvent*)event
{
    id responder = [self nextResponder];
    if ([responder respondsToSelector:@selector(touchesBegan:withEvent:)]) {
        [responder touchesBegan:touches withEvent:event];
    }
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent*)event
{
    id responder = [self nextResponder];
    if ([responder respondsToSelector:@selector(touchesMoved:withEvent:)]) {
        [responder touchesMoved:touches withEvent:event];
    }
}

- (void)touchesEnded:(NSSet*)touches withEvent:(UIEvent*)event
{
    id responder = [self nextResponder];
    if ([responder respondsToSelector:@selector(touchesEnded:withEvent:)]) {
        [responder touchesEnded:touches withEvent:event];
    }
}

- (void)touchesCancelled:(NSSet*)touches withEvent:(UIEvent*)event
{
    id responder = [self nextResponder];
    if ([responder respondsToSelector:@selector(touchesCancelled:withEvent:)]) {
        [responder touchesCancelled:touches withEvent:event];
    }
}

#pragma mark Responding to Motion Events
- (void) motionBegan:(UIEventSubtype)motion withEvent:(UIEvent*)event
{
#warning stub
    [self doesNotRecognizeSelector:_cmd];
}

- (void) motionEnded:(UIEventSubtype)motion withEvent:(UIEvent*)event
{
#warning stub
    [self doesNotRecognizeSelector:_cmd];
}

- (void) motionCancelled:(UIEventSubtype)motion withEvent:(UIEvent*)event
{
#warning stub
    [self doesNotRecognizeSelector:_cmd];
}

#pragma mark Responding to Remote-Control Events
- (void)remoteControlReceivedWithEvent:(UIEvent *)event
{
#warning stub
    [self doesNotRecognizeSelector:_cmd];
}

#pragma mark Getting the Undo Manager
- (NSUndoManager *)undoManager
{
    return [[self nextResponder] undoManager];
}

#pragma mark Validating Commands
- (BOOL)canPerformAction:(SEL)action withSender:(id)sender
{
    if ([[self class] instancesRespondToSelector:action]) {
        return YES;
    } else {
        UIResponder* nextResponder = [self nextResponder];
        if ([nextResponder isKindOfClass:[UIResponder class]]) {
            return [[self nextResponder] canPerformAction:action withSender:sender];
        } else {
            return NO;
        }
    }
}

#pragma mark private methods
- (UIWindow *)_responderWindow
{
    if ([self isKindOfClass:[UIView class]]) {
        return [(UIView *)self window];
    } else {
        return [[self nextResponder] _responderWindow];
    }
}

@end
