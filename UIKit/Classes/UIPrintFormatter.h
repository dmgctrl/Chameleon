#import <Foundation/Foundation.h>
#import <UIKit/UIGeometry.h>

@class UIPrintPageRenderer;
@interface UIPrintFormatter : NSObject

#pragma mark Laying Out the Content
@property(nonatomic) UIEdgeInsets contentInsets;
@property(nonatomic) CGFloat maximumContentHeight;
@property(nonatomic) CGFloat maximumContentWidth;

#pragma mark Managing Pagination
@property(nonatomic) NSInteger startPage;
@property(nonatomic, readonly) NSInteger pageCount;

#pragma mark Drawing the Content
- (void)drawInRect:(CGRect)rect forPageAtIndex:(NSInteger)pageIndex;
- (CGRect)rectForPageAtIndex:(NSUInteger)pageIndex;
#pragma mark Communicating with the Page Renderer
- (void)removeFromPrintPageRenderer;
@property(readonly) UIPrintPageRenderer* printPageRenderer;

@end
