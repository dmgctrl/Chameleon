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

#import "UISlider.h"
#import "UIImage+UIPrivate.h"
#import "UIButton.h"
#import "UIColor.h"
#import "UITouch.h"
#import "UIImageView.h"
#import <QuartzCore/QuartzCore.h>

static NSString* const kUIValueKey = @"UIValue";
static NSString* const kUIMinValueKey = @"UIMinValue";
static NSString* const kUIMaxValueKey = @"UIMaxValue";


@implementation UISlider {
    UIImageView* _minimumTrackView;
    UIImageView* _maximumTrackView;
    UIButton* _thumbView;
}
@synthesize value = _value;
@synthesize minimumValue = _minimumValue;
@synthesize maximumValue = _maximumValue;
@synthesize continuous = _continuous;

- (void) _commonInitForUISlider
{
    _continuous = YES;
    _minimumValue = 0.0;
    _maximumValue = 1.0;
    _value = 0.5;
    CALayer* layer = self.layer;
    layer.backgroundColor = [[UIColor clearColor] CGColor];
    
    _minimumTrackView = [[UIImageView alloc] initWithImage:[UIImage _sliderMinimumTrackImage]];
    _minimumTrackView.frame = CGRectMake(3, 7, 18, 9);
    [self addSubview:_minimumTrackView];
    
    _maximumTrackView = [[UIImageView alloc] initWithImage:[UIImage _sliderMaximumTrackImage]];
    _maximumTrackView.frame = CGRectMake(0, 7, 18, 9);
    [self addSubview:_maximumTrackView];
    
    _thumbView = [UIButton buttonWithType:UIButtonTypeCustom];
    _thumbView.userInteractionEnabled = NO;
    [_thumbView setBackgroundImage:[UIImage _sliderThumbImage] forState:UIControlStateNormal];
    _thumbView.frame = CGRectMake(0, 0, 23, 23);
    [self addSubview:_thumbView];
}

- (id) initWithFrame:(CGRect)frame
{
    if (nil != (self = [super initWithFrame:frame])) {
        [self _commonInitForUISlider];
	}
    return self;
}

- (id) initWithCoder:(NSCoder*)coder
{
    if (nil != (self = [super initWithCoder:coder])) {
        [self _commonInitForUISlider];
        if ([coder containsValueForKey:kUIValueKey]) {
            self.value = [coder decodeFloatForKey:kUIValueKey];
        }
        if ([coder containsValueForKey:kUIMinValueKey]) {
            self.minimumValue = [coder decodeFloatForKey:kUIMinValueKey];
        }
        if ([coder containsValueForKey:kUIMaxValueKey]) {
            self.maximumValue = [coder decodeFloatForKey:kUIMaxValueKey];
        }
	}
    return self;
}

- (void) setMinimumTrackImage:(UIImage*)image forState:(UIControlState)state
{
    CGRect minimumTrackRect = _minimumTrackView.frame;
    minimumTrackRect.size.height = MIN(9, image.size.height);
    minimumTrackRect.origin.y = floor(0.5*(23 - minimumTrackRect.size.height));
    _minimumTrackView.frame = minimumTrackRect;
    _minimumTrackView.image = image;
}

- (void) setMaximumTrackImage:(UIImage*)image forState:(UIControlState)state
{
    CGRect maximumTrackRect = _maximumTrackView.frame;
    maximumTrackRect.size.height = MIN(9, image.size.height);
    maximumTrackRect.origin.y = floor(0.5*(23 - maximumTrackRect.size.height));
    _maximumTrackView.frame = maximumTrackRect;
    _maximumTrackView.image = image;
}

- (void) setThumbImage:(UIImage*)image forState:(UIControlState)state
{
    CGRect thumbRect = _thumbView.frame;
    thumbRect.size.width = MIN(23, image.size.width);
    thumbRect.size.height = MIN(23, image.size.height);
    thumbRect.origin.y = floor(0.5*(23 - thumbRect.size.height));
    _thumbView.frame = thumbRect;
    [_thumbView setBackgroundImage:image forState:state];
}

- (void) layoutSubviews
{
    [super layoutSubviews];
    
    CGRect thumbRect = _thumbView.frame;
    CGFloat percentage = (_value - _minimumValue) / (_maximumValue - _minimumValue);
    CGFloat offset = thumbRect.size.width / 2.0;
    CGFloat maxX = self.bounds.size.width - (offset * 2.0);
    thumbRect.origin.x = MIN(maxX, MAX(0, percentage * maxX));
    _thumbView.frame = thumbRect;
    
    CGRect minimumTrackRect = _minimumTrackView.frame;
    minimumTrackRect.size.width = MAX(offset, MIN(self.bounds.size.width * percentage, self.bounds.size.width - offset));
    _minimumTrackView.frame = minimumTrackRect;
    
    CGRect maximumTrackRect = _maximumTrackView.frame;
    maximumTrackRect.origin.x = minimumTrackRect.size.width;
    maximumTrackRect.size.width = MAX(1, self.bounds.size.width - maximumTrackRect.origin.x) - 3;
    _maximumTrackView.frame = maximumTrackRect;
}

- (void) touchesBegan:(NSSet*)touches withEvent:(UIEvent*)event
{
	[super touchesBegan:touches withEvent:event];
    
    UITouch* touch = [touches anyObject];
    CGPoint point = [touch locationInView:_thumbView];
	if ([_thumbView pointInside:point withEvent:event]) {
        _thumbView.highlighted = YES;
    }
}

- (void) touchesMoved:(NSSet*)touches withEvent:(UIEvent*)event
{
	[super touchesMoved:touches withEvent:event];
    
	if (_thumbView.highlighted) {
        UITouch* touch = [touches anyObject];
        CGPoint point = [touch locationInView:self];
        CGFloat offset = _thumbView.frame.size.width / 2.0;
        CGFloat xValue = MAX(offset, point.x) - offset;
        CGFloat maxX = self.bounds.size.width - (offset * 2);
        CGFloat percentage = MIN(xValue, maxX) / maxX;
        float oldValue = _value;
        _value = _minimumValue + ((_maximumValue - _minimumValue) * percentage);
        if (_continuous && _value != oldValue) {
            [self sendActionsForControlEvents:UIControlEventValueChanged];
        }
        [self setNeedsLayout];
    }
}

- (void) touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
	[super touchesEnded:touches withEvent:event];
	
    _thumbView.highlighted = NO;
}

- (NSString*) description
{
    return [NSString stringWithFormat:@"<%@: %p; frame = (%.0f %.0f; %.0f %.0f); opaque = %@; layer = %@; value = %f>", [self className], self, self.frame.origin.x, self.frame.origin.y, self.frame.size.width, self.frame.size.height, (self.opaque ? @"YES" : @"NO"), self.layer, self.value];
}

@end
