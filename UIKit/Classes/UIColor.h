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

@class UIImage;
@class CIColor;

@interface UIColor : NSObject <NSCoding>

#pragma mark Creating a UIColor Object from Component Values
+ (UIColor*) colorWithWhite:(CGFloat)white alpha:(CGFloat)alpha;
+ (UIColor*) colorWithHue:(CGFloat)hue saturation:(CGFloat)saturation brightness:(CGFloat)brightness alpha:(CGFloat)alpha;
+ (UIColor*) colorWithRed:(CGFloat)red green:(CGFloat)green blue:(CGFloat)blue alpha:(CGFloat)alpha;
+ (UIColor*) colorWithCGColor:(CGColorRef)ref;
+ (UIColor*) colorWithPatternImage:(UIImage*)patternImage;
+ (UIColor*) colorWithCIColor:(CIColor*)ciColor;
- (UIColor*) colorWithAlphaComponent:(CGFloat)alpha;

#pragma mark Initializing a UIColor Object
- (instancetype) initWithWhite:(CGFloat)white alpha:(CGFloat)alpha;
- (instancetype) initWithHue:(CGFloat)hue saturation:(CGFloat)saturation brightness:(CGFloat)brightness alpha:(CGFloat)alpha;
- (instancetype) initWithRed:(CGFloat)red green:(CGFloat)green blue:(CGFloat)blue alpha:(CGFloat)alpha;
- (instancetype) initWithCGColor:(CGColorRef)ref;
- (instancetype) initWithPatternImage:(UIImage*)patternImage;
- (instancetype) initWithCIColor:(CIColor*)ciColor;

#pragma mark Creating a UIColor with Preset Component Values
+ (UIColor*) blackColor;
+ (UIColor*) darkGrayColor;
+ (UIColor*) lightGrayColor;
+ (UIColor*) whiteColor;
+ (UIColor*) grayColor;
+ (UIColor*) redColor;
+ (UIColor*) greenColor;
+ (UIColor*) blueColor;
+ (UIColor*) cyanColor;
+ (UIColor*) yellowColor;
+ (UIColor*) magentaColor;
+ (UIColor*) orangeColor;
+ (UIColor*) purpleColor;
+ (UIColor*) brownColor;
+ (UIColor*) clearColor;

#pragma mark System Colors
+ (UIColor*) lightTextColor;
+ (UIColor*) darkTextColor;
+ (UIColor*) groupTableViewBackgroundColor;
+ (UIColor*) viewFlipsideBackgroundColor;
+ (UIColor*) scrollViewTexturedBackgroundColor;
+ (UIColor*) underPageBackgroundColor;

#pragma mark Retrieving Color Information
@property (nonatomic, readonly) CGColorRef CGColor;
@property (nonatomic, readonly) CIColor* CIColor;

#pragma mark Drawing Operations
- (void) set;
- (void) setFill;
- (void) setStroke;

@end
