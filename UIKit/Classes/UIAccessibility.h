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

#import <Foundation/Foundation.h>
#import <UIKit/UIKitDefines.h>

typedef uint64_t UIAccessibilityTraits;

UIKIT_EXTERN UIAccessibilityTraits UIAccessibilityTraitNone;
UIKIT_EXTERN UIAccessibilityTraits UIAccessibilityTraitButton;
UIKIT_EXTERN UIAccessibilityTraits UIAccessibilityTraitLink;
UIKIT_EXTERN UIAccessibilityTraits UIAccessibilityTraitSearchField;
UIKIT_EXTERN UIAccessibilityTraits UIAccessibilityTraitImage;
UIKIT_EXTERN UIAccessibilityTraits UIAccessibilityTraitSelected;
UIKIT_EXTERN UIAccessibilityTraits UIAccessibilityTraitPlaysSound;
UIKIT_EXTERN UIAccessibilityTraits UIAccessibilityTraitKeyboardKey;
UIKIT_EXTERN UIAccessibilityTraits UIAccessibilityTraitStaticText;
UIKIT_EXTERN UIAccessibilityTraits UIAccessibilityTraitSummaryElement;
UIKIT_EXTERN UIAccessibilityTraits UIAccessibilityTraitNotEnabled;
UIKIT_EXTERN UIAccessibilityTraits UIAccessibilityTraitUpdatesFrequently;
UIKIT_EXTERN UIAccessibilityTraits UIAccessibilityTraitHeader;


typedef uint32_t UIAccessibilityNotifications;
UIKIT_EXTERN UIAccessibilityNotifications UIAccessibilityScreenChangedNotification;
UIKIT_EXTERN UIAccessibilityNotifications UIAccessibilityLayoutChangedNotification;
UIKIT_EXTERN UIAccessibilityNotifications UIAccessibilityAnnouncementNotification;
UIKIT_EXTERN UIAccessibilityNotifications UIAccessibilityPageScrolledNotification;


@interface NSObject (UIAccessibility)
@property (nonatomic) BOOL isAccessibilityElement;
@property (nonatomic) NSString *accessibilityLabel;
@property (nonatomic) NSString *accessibilityHint;
@property (nonatomic) NSString *accessibilityValue;
@property (nonatomic) UIAccessibilityTraits accessibilityTraits;
@property (nonatomic) CGRect accessibilityFrame;
@property (nonatomic) BOOL accessibilityViewIsModal;
@property (nonatomic) BOOL accessibilityElementsHidden;
@end

/*
@interface NSObject (UIAccessibilityContainer)
- (NSInteger)accessibilityElementCount;
- (id)accessibilityElementAtIndex:(NSInteger)index;
- (NSInteger)indexOfAccessibilityElement:(id)element;
@end
*/

UIKIT_EXTERN void UIAccessibilityPostNotification(UIAccessibilityNotifications notification, id argument);
UIKIT_EXTERN BOOL UIAccessibilityIsVoiceOverRunning(void);
