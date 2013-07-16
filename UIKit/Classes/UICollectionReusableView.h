#import <UIKit/UIKit.h>

@interface UICollectionReusableView : UIView
#pragma mark Reusing Cells

@property (nonatomic, readonly, copy) NSString *reuseIdentifier;
- (void)prepareForReuse;

#pragma mark Managing Layout Changes

- (void) applyLayoutAttributes:(UICollectionViewLayoutAttributes*)layoutAttributes;
- (void) willTransitionFromLayout:(UICollectionViewLayout*)oldLayout toLayout:(UICollectionViewLayout*)newLayout;
- (void) didTransitionFromLayout:(UICollectionViewLayout*)oldLayout toLayout:(UICollectionViewLayout*)newLayout;

@end
