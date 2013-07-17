#import <UIKit/UIPrintFormatter.h>

@class UIView;

@interface UIViewPrintFormatter : UIPrintFormatter

@property(nonatomic, readonly) UIView *view;

@end
