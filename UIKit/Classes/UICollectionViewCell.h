#import <UIKit/UIKit.h>

@interface UICollectionViewCell : UIView // should be UICollectionReusableView
#pragma mark Accessing the Cell’s Views

@property (nonatomic, readonly) UIView *contentView;
@property (nonatomic, retain) UIView *backgroundView;
@property (nonatomic, retain) UIView *selectedBackgroundView;

#pragma mark Managing the Cell’s State

@property (nonatomic, getter=isSelected) BOOL selected;
@property (nonatomic, getter=isHighlighted) BOOL highlighted;
@end
