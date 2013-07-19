#import <UIKit/UIControl.h>

@interface UIRefreshControl : UIControl <NSCoding, UIAppearance, UIAppearanceContainer>

#pragma mark Initializing a Refresh Control
- (instancetype) init;

#pragma mark Accessing the Control Attributes
@property (nonatomic, retain) UIColor* tintColor;
@property (nonatomic, retain) NSAttributedString* attributedTitle;

#pragma mark Managing the Refresh Status
- (void) beginRefreshing;
- (void) endRefreshing;
@property (nonatomic, readonly, getter=isRefreshing) BOOL refreshing;

@end
