//
//  UITabBarItem.m
//  UIKit
//
//  Created by Peter Steinberger on 23.03.11.
//
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

#import <UIKit/UITabBarItem.h>
#import <UIKit/UIImage.h>

@implementation UITabBarItem 

- (UIImage*) finishedSelectedImage
{
#warning implement -finishedSelectedImage
    UIKIT_STUB_W_RETURN(@"-finishedSelectedImage");
}

- (UIImage*) finishedUnselectedImage
{
#warning implement -finishedUnselectedImage
    UIKIT_STUB_W_RETURN(@"-finishedUnselectedImage");
}

- (void) setFinishedSelectedImage:(UIImage*)selectedImage withFinishedUnselectedImage:(UIImage*)unselectedImage
{
#warning implement -setFinishedSelectedImage:withFinishedUnselectedImage:
    UIKIT_STUB(@"-setFinishedSelectedImage:withFinishedUnselectedImage:");
}

- (UIOffset) titlePositionAdjustment
{
#warning implement -titlePositionAdjustment
    UIKIT_STUB(@"-titlePositionAdjustment");
    return UIOffsetZero;
}

- (void) setTitlePositionAdjustment:(UIOffset)adjustment
{
#warning implement -setTitlePositionAdjustment:
    UIKIT_STUB(@"-setTitlePositionAdjustment:");
}

- (id)initWithTitle:(NSString *)title image:(UIImage *)image tag:(NSInteger)tag
{
    if ((self = [super init])) {
        self.title = title;
        self.image = image;
    }
    return self;
}

- (id)initWithTabBarSystemItem:(UITabBarSystemItem)systemItem tag:(NSInteger)tag
{
    if ((self = [super init])) {
    }
    return self;
}

@end
