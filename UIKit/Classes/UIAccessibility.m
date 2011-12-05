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

#import "UIAccessibility.h"
#import <objc/runtime.h>

UIAccessibilityTraits UIAccessibilityTraitNone = 0;
UIAccessibilityTraits UIAccessibilityTraitButton = 1;
UIAccessibilityTraits UIAccessibilityTraitLink = 2;
UIAccessibilityTraits UIAccessibilityTraitImage = 4;
UIAccessibilityTraits UIAccessibilityTraitSelected = 8;
UIAccessibilityTraits UIAccessibilityTraitPlaysSound = 16;
UIAccessibilityTraits UIAccessibilityTraitKeyboardKey = 32;
UIAccessibilityTraits UIAccessibilityTraitStaticText = 64;
UIAccessibilityTraits UIAccessibilityTraitSummaryElement = 128;
UIAccessibilityTraits UIAccessibilityTraitNotEnabled = 256;
UIAccessibilityTraits UIAccessibilityTraitUpdatesFrequently = 512;
UIAccessibilityTraits UIAccessibilityTraitSearchField = 1024;

UIAccessibilityNotifications UIAccessibilityScreenChangedNotification = 1000;
UIAccessibilityNotifications UIAccessibilityLayoutChangedNotification = 1001;
UIAccessibilityNotifications UIAccessibilityAnnouncementNotification = 1002;
UIAccessibilityNotifications UIAccessibilityPageScrolledNotification = 1003;


static NSString * const kUIAccessibilityIsAccessibilityElement = @"____kUIAccessibilityIsAccessibilityElement";
static NSString * const kUIAccessibilityAccessibilityLabel = @"____kUIAccessibilityAccessibilityLabel";
static NSString * const kUIAccessibilityTraits = @"____kUIAccessibilityTraits";
static NSString * const kUIAccessibilityAccessibilityHint = @"____kUIAccessibilityAccessibilityHint";
static NSString * const kUIAccessibilityAccessibilityValue = @"____kUIAccessibilityAccessibilityValue";

@implementation NSObject (UIAccessibility)
- (BOOL)isAccessibilityElement
{
    NSNumber *boolval = objc_getAssociatedObject(self,  &kUIAccessibilityIsAccessibilityElement);
    if (boolval) 
        return [boolval boolValue];
    
    return NO;
}

- (void)setIsAccessibilityElement:(BOOL)isElement
{
    objc_setAssociatedObject(self, &kUIAccessibilityIsAccessibilityElement, [NSNumber numberWithBool:isElement], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSString *)accessibilityLabel
{
    return objc_getAssociatedObject(self,  &kUIAccessibilityAccessibilityLabel);
}

- (void)setAccessibilityLabel:(NSString *)label
{
    objc_setAssociatedObject(self, &kUIAccessibilityAccessibilityLabel, label, OBJC_ASSOCIATION_COPY);
}

- (UIAccessibilityTraits)accessibilityTraits
{
    NSNumber *val = objc_getAssociatedObject(self,  &kUIAccessibilityTraits);
    if (val) 
        return (UIAccessibilityTraits)[val unsignedLongLongValue];
    
    return UIAccessibilityTraitNone; 
}

- (void)setAccessibilityTraits:(UIAccessibilityTraits)traits
{
     objc_setAssociatedObject(self, &kUIAccessibilityTraits, [NSNumber numberWithUnsignedLongLong:traits], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSString *)accessibilityHint {
    return objc_getAssociatedObject(self,  &kUIAccessibilityAccessibilityHint);
}
- (void)setAccessibilityHint:(NSString *)hint {
    objc_setAssociatedObject(self, &kUIAccessibilityAccessibilityValue, hint, OBJC_ASSOCIATION_COPY);
}
- (NSString *)accessibilityValue {
    return objc_getAssociatedObject(self,  &kUIAccessibilityAccessibilityValue);
}
- (void)setAccessibilityValue:(NSString *)value {
    objc_setAssociatedObject(self, &kUIAccessibilityAccessibilityValue, value, OBJC_ASSOCIATION_COPY);
}


- (CGRect)accessibilityFrame {
    return CGRectZero;//  objc_getAssociatedObject(self,  &kUIAccessibilityAccessibilityFrame);
}
- (void)setAccessibilityFrame:(CGRect)frame {
    //objc_setAssociatedObject(self, &kUIAccessibilityAccessibilityValue, value, OBJC_ASSOCIATION_COPY);
}

@end

void UIAccessibilityPostNotification(UIAccessibilityNotifications notification, id argument)
{
}

BOOL UIAccessibilityIsVoiceOverRunning()
{
    return NO;
}
