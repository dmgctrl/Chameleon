#import <UIKit/UIView.h>
#import <UIKit/UIAppearance.h>

@class UILabel;

@interface UITableViewHeaderFooterView : UIView <NSCoding, UIAppearance, UIAppearanceContainer>


#pragma mark Initializing the View

- (instancetype) initWithReuseIdentifier:(NSString*)reuseIdentifier;


#pragma mark Accessing the Content Views

@property (nonatomic, readonly, retain) UIView* contentView;
@property (nonatomic, retain) UIView* backgroundView;


#pragma mark Managing View Reuse

@property (nonatomic, readonly, copy) NSString* reuseIdentifier;
- (void) prepareForReuse;


#pragma mark Accessing the Default View Content

@property (nonatomic, readonly, retain) UILabel* textLabel;
@property (nonatomic, readonly, retain) UILabel* detailTextLabel;
@property (nonatomic, retain) UIColor* tintColor;

@end
