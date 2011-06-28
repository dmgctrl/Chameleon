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

#import "UITableViewCell+UIPrivate.h"
#import "UITableViewCellSeparator.h"
#import "UIColor.h"
#import "UILabel.h"
#import "UIImageView.h"
#import "UIFont.h"
#import "UIGraphics.h"
#import "UITableView.h"
#import "UITableViewCellBackgroundView.h"
#import "UITableViewCellSelectedBackgroundView.h"
#import "UITableViewCellLayoutManager.h"


extern CGFloat _UITableViewDefaultRowHeight;


@interface UITableViewCell (UITableViewCellInternal)
- (UITableViewCellLayoutManager*) layoutManager;
- (void) _setSeparatorStyle:(UITableViewCellSeparatorStyle)theStyle color:(UIColor*)theColor;
- (void) _setTableViewStyle:(NSUInteger)tableViewStyle;
- (void) _setHighlighted:(BOOL)highlighted forViews:(id)subviews;
- (void) _updateSelectionState;
@end


@implementation UITableViewCell {
    UITableViewCellLayoutManager* _layoutManager;
}
@synthesize accessoryType=_accessoryType; 
@synthesize accessoryView=_accessoryView;
@synthesize backgroundView=_backgroundView;
@synthesize contentView=_contentView;
@synthesize detailTextLabel = _detailTextLabel;
@synthesize editing = _editing;
@synthesize editingAccessoryType=_editingAccessoryType;
@synthesize highlighted=_highlighted;
@synthesize imageView=_imageView;
@synthesize indentationLevel=_indentationLevel;
@synthesize indentationWidth=_indentationWidth;
@synthesize reuseIdentifier=_reuseIdentifier;
@synthesize sectionLocation=_sectionLocation;
@synthesize selected=_selected;
@synthesize selectedBackgroundView=_selectedBackgroundView;
@synthesize selectionStyle=_selectionStyle;
@synthesize showingDeleteConfirmation = _showingDeleteConfirmation;
@synthesize textLabel=_textLabel;

- (void) dealloc
{
	[_separatorView release];
	[_contentView release];
    [_accessoryView release];
	[_textLabel release];
    [_detailTextLabel release];
	[_imageView release];
	[_backgroundView release];
	[_selectedBackgroundView release];
	[_accessoryView release];
	[_reuseIdentifier release];
	
	[super dealloc];
}

- (id) initWithFrame:(CGRect)frame
{
	if (nil != (self = [super initWithFrame:frame])) {
        _indentationWidth = 10;
		_style = UITableViewCellStyleDefault;
		
		super.backgroundColor = [UIColor whiteColor];
		self.accessoryType = UITableViewCellAccessoryNone;
		self.editingAccessoryType = UITableViewCellAccessoryNone;
		self.selectionStyle = UITableViewCellSelectionStyleBlue;
	}
	return self;
}

- (id) initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString*)reuseIdentifier
{
	if (nil != (self = [self initWithFrame:CGRectMake(0,0,320,_UITableViewDefaultRowHeight)])) {
		_style = style;
		_reuseIdentifier = [reuseIdentifier copy];
        _layoutManager = [[UITableViewCellLayoutManager layoutManagerForTableViewCellStyle:style] retain];
	}
	return self;
}


#pragma mark Reusing Cells

- (void) prepareForReuse
{
}


#pragma mark Managing Text as Cell Content

- (UILabel*) textLabel
{
    if (!_textLabel) {
        _textLabel = [[UILabel alloc] init];
        _textLabel.backgroundColor = [UIColor clearColor];
        _textLabel.textColor = [UIColor blackColor];
        _textLabel.highlightedTextColor = [UIColor whiteColor];
        _textLabel.font = [UIFont boldSystemFontOfSize:17];
        [self.contentView addSubview:_textLabel];
    }
    return _textLabel;
}

- (UILabel*) detailTextLabel
{
    if (!_detailTextLabel && _style == UITableViewCellStyleSubtitle) {
        _detailTextLabel = [[UILabel alloc] init];
        _detailTextLabel.backgroundColor = [UIColor clearColor];
        _detailTextLabel.textColor = [UIColor grayColor];
        _detailTextLabel.highlightedTextColor = [UIColor whiteColor];
        _detailTextLabel.font = [UIFont boldSystemFontOfSize:14];
        [self.contentView addSubview:_detailTextLabel];
    }
    return _detailTextLabel;
}


#pragma mark Managing Images as Cell Content

- (UIImageView*) imageView
{
    if (!_imageView) {
        _imageView = [[UIImageView alloc] init];
        _imageView.contentMode = UIViewContentModeCenter;
        [self.contentView addSubview:_imageView];
    }
    return _imageView;
}


#pragma mark Managing Accessory Views

- (void) setAccessoryView:(UIView*)accessoryView 
{
	if (_accessoryView != accessoryView) {
		[_accessoryView removeFromSuperview];
		[_accessoryView release], _accessoryView = [accessoryView retain];
        [self.contentView addSubview:_accessoryView];
	}
}


#pragma mark Accessing Views of the Cell Object

- (UIView*) contentView
{
    if (!_contentView) {
        _contentView = [[UIView alloc] init];
		_contentView.backgroundColor = [UIColor clearColor];
        [self addSubview:_contentView];
    }
    return _contentView;
}

- (UIView*) backgroundView
{
    if (!_backgroundView && _tableCellFlags.tableViewStyleIsGrouped) {
        _backgroundView = [[UITableViewCellBackgroundView alloc] init];
        [self insertSubview:_backgroundView atIndex:0];
    }
    return _backgroundView;
}

- (void) setBackgroundView:(UIView*)backgroundView
{
	if (backgroundView != _backgroundView) {
		[_backgroundView removeFromSuperview];
		[_backgroundView release];
		_backgroundView = [backgroundView retain];
        [self insertSubview:_backgroundView atIndex:0];
	}
}

- (UIView*) selectedBackgroundView
{
    if (!_selectedBackgroundView && _tableCellFlags.tableViewStyleIsGrouped) {
        _selectedBackgroundView = [[UITableViewCellSelectedBackgroundView alloc] init];
    }
    return _selectedBackgroundView;
}

- (void) setSelectedBackgroundView:(UIView*)selectedBackgroundView
{
	if (selectedBackgroundView != _selectedBackgroundView) {
		[_selectedBackgroundView removeFromSuperview];
		[_selectedBackgroundView release];
		_selectedBackgroundView = [selectedBackgroundView retain];
        if (self.selected) {
            if (_backgroundView) {
                [self insertSubview:_selectedBackgroundView aboveSubview:_backgroundView];
            } else {
                [self insertSubview:_selectedBackgroundView atIndex:0];
            }
        }
	}
}


#pragma mark Managing Accessory Views

- (void) setSelected:(BOOL)selected
{
	[self setSelected:selected animated:NO];
}

- (void) setSelected:(BOOL)selected animated:(BOOL)animated
{
	if (selected != _selected) {
		_selected = selected;
		[self _updateSelectionState];
	}
}

- (void) setHighlighted:(BOOL)highlighted
{
	[self setHighlighted:highlighted animated:NO];
}

- (void) setHighlighted:(BOOL)highlighted animated:(BOOL)animated
{
	if (_highlighted != highlighted) {
		_highlighted = highlighted;
		[self _updateSelectionState];
	}
}


#pragma mark Overridden

- (UIColor*) backgroundColor
{
    return self.backgroundView.backgroundColor;
}

- (void) setBackgroundColor:(UIColor*)backgroundColor
{
    self.backgroundView.backgroundColor = backgroundColor;
}

- (void) layoutSubviews
{
	[super layoutSubviews];
	CGRect bounds = self.bounds;
	
	CGRect contentFrame = {
        .origin = { 
            .x = 0.0,
            .y = 0.0,
        },
        .size = {
            .width = bounds.size.width,
            .height = bounds.size.height - (_separatorView ? 1.0 : 0.0)
        }
    };
    
	if (_accessoryView) {
		CGSize accessorySize = [_accessoryView sizeThatFits:bounds.size];
        CGRect accessoryFrame = {
            .origin = { 
                .x = bounds.size.width - accessorySize.width,
                .y = round(0.5 * (bounds.size.height - accessorySize.height)),
            },
            .size = accessorySize
        };
		_accessoryView.frame = accessoryFrame;
		contentFrame.size.width = accessoryFrame.origin.x - 1.0;
	}
		
	if (_backgroundView) {
        _backgroundView.frame = contentFrame;
	}
    if (_selectedBackgroundView) {
        _selectedBackgroundView.frame = contentFrame;
    }
    if (_contentView) {
        _contentView.frame = contentFrame;
	}
	if (_separatorView) {
		_separatorView.frame = CGRectMake(0.0, bounds.size.height - 1.0, bounds.size.width, 1.0);
	}
	
	if (_style == UITableViewCellStyleDefault) {
		const CGFloat padding = 5.0;
		
        if (_imageView) {
            _imageView.frame = CGRectMake(padding, 0.0, 30.0, contentFrame.size.height);
        }
		
		CGRect textRect;
		textRect.origin = CGPointMake(padding+_imageView.frame.size.width+padding,0);
		textRect.size = CGSizeMake(MAX(0,contentFrame.size.width-textRect.origin.x-padding),contentFrame.size.height);
		_textLabel.frame = textRect;
	} else if (_style == UITableViewCellStyleSubtitle) {
		const CGFloat padding = 5;
		
		BOOL showImage = (_imageView.image != nil);
		_imageView.frame = CGRectMake(padding,0,(showImage? 30:0),contentFrame.size.height);
		
		CGSize textSize = [_textLabel.text sizeWithFont:_textLabel.font];
		
		CGRect textRect;
		textRect.origin = CGPointMake(padding+_imageView.frame.size.width+padding,round(-0.5*textSize.height));
		textRect.size = CGSizeMake(MAX(0,contentFrame.size.width-textRect.origin.x-padding),contentFrame.size.height);
		_textLabel.frame = textRect;
		
		CGSize detailTextSize = [_detailTextLabel.text sizeWithFont:_detailTextLabel.font];
		
		CGRect detailTextRect;
		detailTextRect.origin = CGPointMake(padding+_imageView.frame.size.width+padding,round(0.5*detailTextSize.height));
		detailTextRect.size = CGSizeMake(MAX(0,contentFrame.size.width-textRect.origin.x-padding),contentFrame.size.height);
		_detailTextLabel.frame = detailTextRect;
	}
}


#pragma mark Internals

- (UITableViewCellLayoutManager*) layoutManager
{
    return nil;
}

- (void) _setSeparatorStyle:(UITableViewCellSeparatorStyle)style color:(UIColor*)color
{
    switch (style) {
        case UITableViewCellSeparatorStyleNone: {
            if (_separatorView) {
                [_separatorView removeFromSuperview];
                [_separatorView release], _separatorView = nil;
                [self setNeedsLayout];
            }
            break;
        }
            
        case UITableViewCellSeparatorStyleSingleLine:
        case UITableViewCellSeparatorStyleSingleLineEtched: {
            if (!_separatorView) {
                _separatorView = [[UITableViewCellSeparator alloc] init];
                _separatorView.autoresizingMask = NSViewWidthSizable | NSViewMinXMargin;
                [self addSubview:_separatorView];
                [self setNeedsLayout];
            }
            _separatorView.color = color;
            _separatorView.style = style;
            break;
        }
    }
}

- (void) _setTableViewStyle:(NSUInteger)tableViewStyle
{
    if (_tableCellFlags.tableViewStyleIsGrouped != tableViewStyle) {
        _tableCellFlags.tableViewStyleIsGrouped = tableViewStyle;
        [self setNeedsLayout];
    }
}

- (void) _setHighlighted:(BOOL)highlighted forViews:(id)subviews
{
	for (id view in subviews) {
		if ([view respondsToSelector:@selector(setHighlighted:)]) {
			[view setHighlighted:highlighted];
		}
		[self _setHighlighted:highlighted forViews:[view subviews]];
	}
}

- (void) _updateSelectionState
{
	BOOL shouldHighlight = (_highlighted || _selected);
	[self _setHighlighted:shouldHighlight forViews:[self.contentView subviews]];
}

@end
