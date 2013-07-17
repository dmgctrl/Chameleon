#import "UIPrintFormatter.h"

@implementation UIPrintFormatter
#pragma mark Drawing the Content
- (void)drawInRect:(CGRect)rect forPageAtIndex:(NSInteger)pageIndex
{
}

- (CGRect)rectForPageAtIndex:(NSUInteger)pageIndex // documentation says (NSIndex)pageIndex;
{
    return CGRectNull;
}

#pragma mark Communicating with the Page Renderer
- (void)removeFromPrintPageRenderer
{
}

@end
