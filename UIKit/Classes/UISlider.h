//
//  UISlider.h
//  UIKit
//
//  Created by Peter Steinberger on 24.03.11.
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

#import <UIKit/UIControl.h>

@class UIImage;

@interface UISlider : UIControl <NSCoding>

#pragma mark Accessing the Slider’s Value

@property (nonatomic) float value;
- (void) setValue:(float)value animated:(BOOL)animated;


#pragma mark Changing the Slider’s Appearance

@property (nonatomic) float minimumValue;
@property (nonatomic) float maximumValue;


#pragma mark Modifying the Slider’s Behavior

@property (nonatomic, getter=isContinuous) BOOL continuous;


#pragma mark Changing the Slider’s Appearance

@property (nonatomic, retain) UIImage* minimumValueImage;
@property (nonatomic, retain) UIImage* maximumValueImage;
@property (nonatomic, retain) UIColor* minimumTrackTintColor;
@property (nonatomic, readonly) UIImage* currentMinimumTrackImage;
- (UIImage*) minimumTrackImageForState:(UIControlState)state;
- (void) setMinimumTrackImage:(UIImage*)image forState:(UIControlState)state;
@property (nonatomic, retain) UIColor* maximumTrackTintColor;
@property (nonatomic, readonly) UIImage* currentMaximumTrackImage;
- (UIImage*) maximumTrackImageForState:(UIControlState)state;
- (void) setMaximumTrackImage:(UIImage*)image forState:(UIControlState)state;
@property (nonatomic, retain) UIColor* thumbTintColor;
@property (nonatomic, readonly) UIImage* currentThumbImage;
- (UIImage*) thumbImageForState:(UIControlState)state;
- (void) setThumbImage:(UIImage*)image forState:(UIControlState)state;


#pragma mark Overrides for Subclasses

- (CGRect) maximumValueImageRectForBounds:(CGRect)bounds;
- (CGRect) minimumValueImageRectForBounds:(CGRect)bounds;
- (CGRect) trackRectForBounds:(CGRect)bounds;
- (CGRect) thumbRectForBounds:(CGRect)bounds trackRect:(CGRect)rect value:(float)value;

@end
