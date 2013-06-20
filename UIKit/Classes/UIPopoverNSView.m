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

#import "UIPopoverNSView.h"
#import "UIPopoverController.h"
#import <AppKit/AppKit.h>

/** The arrow height **/
#define INPOPOVER_ARROW_HEIGHT 12.0
/** The arrow width **/
#define INPOPOVER_ARROW_WIDTH 23.0
/** Corner radius to use when drawing popover corners **/
#define INPOPOVER_CORNER_RADIUS 4.0

@implementation UIPopoverNSView

@synthesize arrowDirection = arrowDirection_;

- (void)drawRect:(NSRect)dirtyRect
{
    [[NSColor clearColor] set];
    NSRectFill([self frame]);
    
    float borderWidth = 1;
    NSColor* color = [NSColor colorWithCalibratedWhite:0.94 alpha:0.92];
    NSColor* borderColor = [NSColor colorWithCalibratedWhite:1.0 alpha:0.92];
    
    NSRect bounds = [self bounds];
    if ( ( (int)borderWidth % 2 ) == 1) // Remove draw glitch on odd border width
        bounds = NSInsetRect(bounds, 0.5f, 0.5f);
    
	NSBezierPath *path = [self _popoverBezierPathWithRect:bounds];
	[color set];
	[path fill];
	
	[path setLineWidth:borderWidth];
	[borderColor set];
	[path stroke];
    
    
    //[[self window] display];
    [[self window] setHasShadow:NO];
    [[self window] setHasShadow:YES];
}

#pragma mark -
#pragma mark Private

- (NSBezierPath*)_popoverBezierPathWithRect:(NSRect)aRect
{
	CGFloat radius = INPOPOVER_CORNER_RADIUS;
	CGFloat inset = radius + INPOPOVER_ARROW_HEIGHT;
	NSRect drawingRect = NSInsetRect(aRect, inset, inset);
	CGFloat minX = NSMinX(drawingRect);
	CGFloat maxX = NSMaxX(drawingRect);
	CGFloat minY = NSMinY(drawingRect);
	CGFloat maxY = NSMaxY(drawingRect);
	
	NSBezierPath *path = [NSBezierPath bezierPath];
	[path setLineJoinStyle:NSRoundLineJoinStyle];
	
	// Bottom left corner
	[path appendBezierPathWithArcWithCenter:NSMakePoint(minX, minY) radius:radius startAngle:180.0 endAngle:270.0];
	if (self.arrowDirection == UIPopoverArrowDirectionDown) {
		CGFloat midX = NSMidX(drawingRect);
		NSPoint points[3];
		points[0] = NSMakePoint(floor(midX - (INPOPOVER_ARROW_WIDTH / 2.0)), minY - radius); // Starting point
		points[1] = NSMakePoint(floor(midX), points[0].y - INPOPOVER_ARROW_HEIGHT); // Arrow tip
		points[2] = NSMakePoint(floor(midX + (INPOPOVER_ARROW_WIDTH / 2.0)), points[0].y); // Ending point
		[path appendBezierPathWithPoints:points count:3];
	}
	// Bottom right corner
	[path appendBezierPathWithArcWithCenter:NSMakePoint(maxX, minY) radius:radius startAngle:270.0 endAngle:360.0];
    if (self.arrowDirection == UIPopoverArrowDirectionRight) {
		CGFloat midY = NSMidY(drawingRect);
		NSPoint points[3];
		points[0] = NSMakePoint(maxX + radius, floor(midY - (INPOPOVER_ARROW_WIDTH / 2.0)));
		points[1] = NSMakePoint(points[0].x + INPOPOVER_ARROW_HEIGHT, floor(midY));
		points[2] = NSMakePoint(points[0].x, floor(midY + (INPOPOVER_ARROW_WIDTH / 2.0)));
		[path appendBezierPathWithPoints:points count:3];
	}
	// Top right corner
	[path appendBezierPathWithArcWithCenter:NSMakePoint(maxX, maxY) radius:radius startAngle:0.0 endAngle:90.0];
    if (self.arrowDirection == UIPopoverArrowDirectionUp) {
		CGFloat midX = NSMidX(drawingRect);
		NSPoint points[3];
		points[0] = NSMakePoint(floor(midX + (INPOPOVER_ARROW_WIDTH / 2.0)), maxY + radius);
		points[1] = NSMakePoint(floor(midX), points[0].y + INPOPOVER_ARROW_HEIGHT);
		points[2] = NSMakePoint(floor(midX - (INPOPOVER_ARROW_WIDTH / 2.0)), points[0].y);
		[path appendBezierPathWithPoints:points count:3];
	}
	// Top left corner
	[path appendBezierPathWithArcWithCenter:NSMakePoint(minX, maxY) radius:radius startAngle:90.0 endAngle:180.0];
	if (self.arrowDirection == UIPopoverArrowDirectionLeft) {
		CGFloat midY = NSMidY(drawingRect);
		NSPoint points[3];
		points[0] = NSMakePoint(minX - radius, floor(midY + (INPOPOVER_ARROW_WIDTH / 2.0)));
		points[1] = NSMakePoint(points[0].x - INPOPOVER_ARROW_HEIGHT, floor(midY));
		points[2] = NSMakePoint(points[0].x, floor(midY - (INPOPOVER_ARROW_WIDTH / 2.0)));
		[path appendBezierPathWithPoints:points count:3];
	}
	[path closePath];
	
	return path;
}

@end
