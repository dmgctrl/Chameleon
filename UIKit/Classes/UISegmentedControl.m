//
//  SSSegmentedControl.m
//  SSToolkit
//
//  Created by Sam Soffes on 2/7/11.
//  Copyright 2011 Sam Soffes. All rights reserved.
//

#import "UISegmentedControl.h"
#import "UISegment.h"
#import "UITouch.h"
#import "UIColor.h"
#import "UIStringDrawing.h"
#import "UIGraphics.h"

static NSString *kSSSegmentedControlEnabledKey = @"enabled";

static NSString* const kUISegmentsKey = @"UISegments";
static NSString* const kUISegmentedControlStyleKey = @"UISegmentedControlStyle";
static NSString* const kUISegmentedControlTintColorKey = @"UISegmentedControlTintColor";
static NSString* const kUISelectedSegmentIndexKey = @"UISelectedSegmentIndex";
static NSString* const kUIMomentaryKey = @"UIMomentary";


@interface UISegmentedControl ()
@property (nonatomic, strong) UIImage *buttonImage;
@property (nonatomic, strong) UIImage *highlightedButtonImage;
@property (nonatomic, strong) UIImage *dividerImage;
@property (nonatomic, strong) UIImage *highlightedDividerImage;

@property (nonatomic, strong) UIFont *font;
@property (nonatomic, strong) UIColor *textColor;
@property (nonatomic, strong) UIColor *disabledTextColor;
@property (nonatomic, strong) UIColor *textShadowColor;
@property (nonatomic, assign) CGSize textShadowOffset;
@property (nonatomic, assign) UIEdgeInsets textEdgeInsets;

- (void)_commonInitForUISegmentedControl;

- (NSMutableDictionary *)_metaForSegmentIndex:(NSUInteger)index;
- (id)_metaValueForKey:(NSString *)key segmentIndex:(NSUInteger)index;
- (void)_setMetaValue:(id)value forKey:(NSString *)key segmentIndex:(NSUInteger)index;
@end

@implementation UISegmentedControl {
    NSMutableArray *_segments;
    NSMutableDictionary *_segmentMeta;
}

#pragma mark NSObject


- (id) initWithCoder:(NSCoder*)coder
{
    if (nil != (self = [super initWithCoder:coder])) {
        [self _commonInitForUISegmentedControl];
        if ([coder containsValueForKey:kUISegmentsKey]) {
            NSArray *segments = [coder decodeObjectForKey:kUISegmentsKey];
            for (UISegment *segment in segments) {
                if (segment.image) {
                    [self setImage:segment.image forSegmentAtIndex:segment.position];
                }
                if (segment.title) {
                    [self setTitle:segment.title forSegmentAtIndex:segment.position];
                }
            }
        }
        if ([coder containsValueForKey:kUISegmentedControlStyleKey]) {
            self.segmentedControlStyle = [coder decodeIntegerForKey:kUISegmentedControlStyleKey];
        }
        if ([coder containsValueForKey:kUISegmentedControlTintColorKey]) {
            self.tintColor = [coder decodeObjectForKey:kUISegmentedControlTintColorKey];
        }
        if ([coder containsValueForKey:kUISelectedSegmentIndexKey]) {
            self.selectedSegmentIndex = [coder decodeIntegerForKey:kUISelectedSegmentIndexKey];
        }
        if ([coder containsValueForKey:kUIMomentaryKey]) {
            self.momentary = [coder decodeBoolForKey:kUIMomentaryKey];
        }
    }
    return self;
}

- (void) encodeWithCoder:(NSCoder*)coder
{
    [self doesNotRecognizeSelector:_cmd];
}

#pragma mark UIResponder

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    CGFloat x = [touch locationInView:self].x;
    
    // Ignore touches that don't matter
    if (x < 0 || x > self.frame.size.width) {
        return;
    }
    
    NSUInteger index = (NSUInteger)floorf((CGFloat)x / (self.frame.size.width / (CGFloat)[self numberOfSegments]));
    if ([self isEnabledForSegmentAtIndex:index]) {
        self.selectedSegmentIndex = (NSInteger)index;
    }
}


- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (!_momentary) {
        return;
    }
    
    _selectedSegmentIndex = UISegmentedControlNoSegment;
    [self setNeedsDisplay];
}


#pragma mark UIView

- (id)initWithFrame:(CGRect)frame
{
    if ((self = [super initWithFrame:frame])) {
        [self _commonInitForUISegmentedControl];
    }
    return self;
}

- (void)_commonInitForUISegmentedControl
{
    self.backgroundColor = [UIColor clearColor];
    
    _segments = [[NSMutableArray alloc] init];
    _momentary = NO;
    
    // TODO: add images
    self.buttonImage = [[UIImage imageNamed:@"UISegmentBarButton.png"] stretchableImageWithLeftCapWidth:6 topCapHeight:0];
    self.highlightedButtonImage = [[UIImage imageNamed:@"UISegmentBarButtonHighlighted.png"] stretchableImageWithLeftCapWidth:6 topCapHeight:0];
    self.dividerImage = [UIImage imageNamed:@"UISegmentBarDivider.png"];
    self.highlightedDividerImage = [UIImage imageNamed:@"UISegmentBarDividerHighlighted.png"];
    self.selectedSegmentIndex = UISegmentedControlNoSegment;
    
    _font = [UIFont boldSystemFontOfSize:12.0f];
    _textColor = [UIColor whiteColor];
    _disabledTextColor = [UIColor colorWithWhite:0.561f alpha:1.0f];
    _textShadowColor = [UIColor colorWithWhite:0.0f alpha:0.5f];
    _textShadowOffset = CGSizeMake(0.0f, -1.0f);
    _textEdgeInsets = UIEdgeInsetsMake(-1.0f, 0.0f, 0.0f, 0.0f);
}

- (void)drawRect:(CGRect)frame
{
    static CGFloat dividerWidth = 1.0f;
    
    NSInteger count = (NSInteger)[self numberOfSegments];
    CGSize size = frame.size;
    CGFloat segmentWidth = roundf((size.width - count - 1) / (CGFloat)count);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    for (NSInteger i = 0; i < count; i++) {
        CGContextSaveGState(context);
        
        id item = [_segments objectAtIndex:(NSUInteger)i];
        BOOL enabled = [self isEnabledForSegmentAtIndex:(NSUInteger)i];
        
        CGFloat x = (segmentWidth * (CGFloat)i + (((CGFloat)i + 1) * dividerWidth));
        
        // Draw dividers
        if (i > 0) {
            
            NSInteger p  = i - 1;
            UIImage *dividerImage = nil;
            
            // Selected divider
            if ((p >= 0 && p == _selectedSegmentIndex) || i == _selectedSegmentIndex) {
                dividerImage = _highlightedDividerImage;
            }
            
            // Normal divider
            else {
                dividerImage = _dividerImage;
            }
            
            [dividerImage drawInRect:CGRectMake(x - 1.0f, 0.0f, dividerWidth, size.height)];
        }
        
        CGRect segmentRect = CGRectMake(x, 0.0f, segmentWidth, size.height);
        CGContextClipToRect(context, segmentRect);
        
        // Background
        UIImage *backgroundImage = nil;
        CGRect backgroundRect = segmentRect;
        if (_selectedSegmentIndex == i) {
            backgroundImage = _highlightedButtonImage;
        } else {
            backgroundImage = _buttonImage;
        }
        
        CGFloat capWidth = backgroundImage.leftCapWidth;
        
        // First segment
        if (i == 0) {
            backgroundRect.size.width += capWidth;
        }
        
        // Last segment
        else if (i == count - 1) {
            backgroundRect = CGRectMake(backgroundRect.origin.x - capWidth, backgroundRect.origin.y,
                                        backgroundRect.size.width + capWidth, backgroundRect.size.height);
        }
        
        // Middle segment
        else {
            backgroundRect = CGRectMake(backgroundRect.origin.x - capWidth, backgroundRect.origin.y,
                                        backgroundRect.size.width + capWidth + capWidth, backgroundRect.size.height);
        }
        
        [backgroundImage drawInRect:backgroundRect];
        
        // Strings
        if ([item isKindOfClass:[NSString class]]) {
            NSString *string = (NSString *)item;
            CGSize textSize = [string sizeWithFont:_font constrainedToSize:CGSizeMake(segmentWidth, size.height) lineBreakMode:UILineBreakModeTailTruncation];
            CGRect textRect = CGRectMake(x, roundf((size.height - textSize.height) / 2.0f), segmentWidth, size.height);
            textRect = UIEdgeInsetsInsetRect(textRect, _textEdgeInsets);
            
            if (enabled) {
                [_textShadowColor set];                
                [string drawInRect:CGRectOffset(textRect, _textShadowOffset.width, _textShadowOffset.height) withFont:_font lineBreakMode:UILineBreakModeTailTruncation alignment:UITextAlignmentCenter];
                [_textColor set];
            } else {
                [_disabledTextColor set];
            }
            
            [string drawInRect:textRect withFont:_font lineBreakMode:UILineBreakModeTailTruncation alignment:UITextAlignmentCenter];
        }
        
        // Images
        else if ([item isKindOfClass:[UIImage class]]) {
            UIImage *image = (UIImage *)item;
            CGSize imageSize = image.size;
            CGRect imageRect = CGRectMake(x + roundf((segmentRect.size.width - imageSize.width) / 2.0f),
                                          roundf((segmentRect.size.height - imageSize.height) / 2.0f),
                                          imageSize.width, imageSize.height);
            [image drawInRect:imageRect blendMode:kCGBlendModeNormal alpha:enabled ? 1.0f : 0.5f];
        }
        
        CGContextRestoreGState(context);
    }
}


- (void)willMoveToSuperview:(UIView *)newSuperview
{
    [super willMoveToSuperview:newSuperview];
    
    if (newSuperview) {
        [self addObserver:self forKeyPath:@"buttonImage" options:NSKeyValueObservingOptionNew context:nil];
        [self addObserver:self forKeyPath:@"highlightedButtonImage" options:NSKeyValueObservingOptionNew context:nil];
        [self addObserver:self forKeyPath:@"dividerImage" options:NSKeyValueObservingOptionNew context:nil];
        [self addObserver:self forKeyPath:@"highlightedDividerImage" options:NSKeyValueObservingOptionNew context:nil];
        [self addObserver:self forKeyPath:@"font" options:NSKeyValueObservingOptionNew context:nil];
        [self addObserver:self forKeyPath:@"textColor" options:NSKeyValueObservingOptionNew context:nil];
        [self addObserver:self forKeyPath:@"disabledTextColor" options:NSKeyValueObservingOptionNew context:nil];
        [self addObserver:self forKeyPath:@"textShadowColor" options:NSKeyValueObservingOptionNew context:nil];
        [self addObserver:self forKeyPath:@"textShadowOffset" options:NSKeyValueObservingOptionNew context:nil];
        [self addObserver:self forKeyPath:@"textEdgeInsets" options:NSKeyValueObservingOptionNew context:nil];
    } else {
        [self removeObserver:self forKeyPath:@"buttonImage"];
        [self removeObserver:self forKeyPath:@"highlightedButtonImage"];
        [self removeObserver:self forKeyPath:@"dividerImage"];
        [self removeObserver:self forKeyPath:@"highlightedDividerImage"];
        [self removeObserver:self forKeyPath:@"font"];
        [self removeObserver:self forKeyPath:@"textColor"];
        [self removeObserver:self forKeyPath:@"disabledTextColor"];
        [self removeObserver:self forKeyPath:@"textShadowColor"];
        [self removeObserver:self forKeyPath:@"textShadowOffset"];
        [self removeObserver:self forKeyPath:@"textEdgeInsets"];
    }
}


#pragma mark Initializer

- (id)initWithItems:(NSArray *)items
{
    if ((self = [self initWithFrame:CGRectZero])) {
        NSInteger index = 0;
        for (id item in items) {
            if ([item isKindOfClass:[NSString class]]) {
                [self setTitle:item forSegmentAtIndex:(NSUInteger)index];
                index++;
            } else if ([item isKindOfClass:[UIImage class]]) {
                [self setImage:item forSegmentAtIndex:(NSUInteger)index];
                index++;
            }
        }
    }
    return self;
}


#pragma mark Segments

- (NSUInteger)numberOfSegments
{
    return [_segments count];
}


- (void)setTitle:(NSString *)title forSegmentAtIndex:(NSUInteger)segment
{
    if ((NSInteger)([self numberOfSegments] - 1) < (NSInteger)segment) {
        [_segments addObject:title];
    } else {
        [_segments replaceObjectAtIndex:segment withObject:title];
    }
    
    [self setNeedsDisplay];
}


- (NSString *)titleForSegmentAtIndex:(NSUInteger)segment
{
    if ([self numberOfSegments] - 1 >= segment) {
        return nil;
    }
    
    id item = [_segments objectAtIndex:segment];
    if ([item isKindOfClass:[NSString class]]) {
        return item;
    }
    
    return nil;
}


- (void)setImage:(UIImage *)image forSegmentAtIndex:(NSUInteger)segment
{
    if ((NSInteger)([self numberOfSegments] - 1) < (NSInteger)segment) {
        [_segments addObject:image];
    } else {
        [_segments replaceObjectAtIndex:segment withObject:image];
    }
    
    [self setNeedsDisplay];
}


- (UIImage *)imageForSegmentAtIndex:(NSUInteger)segment
{
    if ([self numberOfSegments] - 1 >= segment) {
        return nil;
    }
    
    id item = [_segments objectAtIndex:segment];
    if ([item isKindOfClass:[UIImage class]]) {
        return item;
    }
    
    return nil;
}


- (void)setEnabled:(BOOL)enabled forSegmentAtIndex:(NSUInteger)segment
{
    [self _setMetaValue:[NSNumber numberWithBool:enabled] forKey:kSSSegmentedControlEnabledKey segmentIndex:segment];
    
}


- (BOOL)isEnabledForSegmentAtIndex:(NSUInteger)segment
{
    NSNumber *value = [self _metaValueForKey:kSSSegmentedControlEnabledKey segmentIndex:segment];
    if (!value) {
        return YES;
    }
    return [value boolValue];
}


#pragma mark Setters

- (void)setSelectedSegmentIndex:(NSInteger)index
{
    if (_selectedSegmentIndex == index) {
        return;
    }
    
    _selectedSegmentIndex = index;
    [self setNeedsDisplay];
    [self sendActionsForControlEvents:UIControlEventValueChanged];
}


#pragma mark Private Methods

- (NSMutableDictionary *)_metaForSegmentIndex:(NSUInteger)index
{
    if (!_segmentMeta) {
        return nil;
    }
    
    NSString *key = [NSString stringWithFormat:@"%li", index];
    return [_segmentMeta objectForKey:key];
}


- (id)_metaValueForKey:(NSString *)key segmentIndex:(NSUInteger)index
{
    NSMutableDictionary *meta = [self _metaForSegmentIndex:index];
    return [meta objectForKey:key];
}


- (void)_setMetaValue:(id)value forKey:(NSString *)key segmentIndex:(NSUInteger)index
{
    NSMutableDictionary *meta = [self _metaForSegmentIndex:index];
    if (!meta) {
        meta = [NSMutableDictionary dictionary];
    }
    
    [meta setValue:value forKey:key];
    
    if (!_segmentMeta) {
        _segmentMeta = [[NSMutableDictionary alloc] init];
    }
    
    [_segmentMeta setValue:meta forKey:[NSString stringWithFormat:@"%li", index]];
    [self setNeedsDisplay];
}


#pragma mark NSKeyValueObserving

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"buttonImage"] || [keyPath isEqualToString:@"highlightedButtonImage"] ||
        [keyPath isEqualToString:@"dividerImage"] || [keyPath isEqualToString:@"highlightedDividerImage"] ||
        [keyPath isEqualToString:@"font"] || [keyPath isEqualToString:@"textColor"] || [keyPath isEqualToString:@"textShadowColor"] ||
        [keyPath isEqualToString:@"textShadowOffset"] || [keyPath isEqualToString:@"textEdgeInsets"]) {
        [self setNeedsDisplay];
        return;
    }
    
    [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
}

#pragma mark Appearance

- (void)setTitleTextAttributes:(NSDictionary *)attributes forState:(UIControlState)state
{
}

- (NSDictionary *)titleTextAttributesForState:(UIControlState)state
{
    return nil;
}

@end
