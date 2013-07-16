//
//  UICollectionViewLayout.m
//  UIKit
//
//  Created by Andrew Heim on 7/16/13.
//
//

#import "UICollectionViewLayout.h"
#import "UINib.h"

@implementation UICollectionViewLayout

#pragma mark Providing Layout Attributes

- (void) prepareLayout
{
}

- (NSArray*) layoutAttributesForElementsInRect:(CGRect)rect
{
}

- (UICollectionViewLayoutAttributes*) layoutAttributesForItemAtIndexPath:(NSIndexPath*)indexPath
{
}

- (UICollectionViewLayoutAttributes*) layoutAttributesForSupplementaryViewOfKind:(NSString*)kind atIndexPath:(NSIndexPath *)indexPath
{
}

- (UICollectionViewLayoutAttributes*) layoutAttributesForDecorationViewOfKind:(NSString*)decorationViewKind atIndexPath:(NSIndexPath*)indexPath
{
}

- (CGPoint) targetContentOffsetForProposedContentOffset:(CGPoint)proposedContentOffset withScrollingVelocity:(CGPoint)velocity
{
}

#pragma mark Responding to Collection View Updates

- (void)prepareForCollectionViewUpdates:(NSArray *)updateItems
{    
}
- (void)finalizeCollectionViewUpdates
{
}

- (UICollectionViewLayoutAttributes*) initialLayoutAttributesForAppearingItemAtIndexPath:(NSIndexPath*)itemIndexPath
{
}

- (UICollectionViewLayoutAttributes*) initialLayoutAttributesForAppearingSupplementaryElementOfKind:(NSString*)elementKind atIndexPath:(NSIndexPath*)elementIndexPath
{
}

- (UICollectionViewLayoutAttributes*) initialLayoutAttributesForAppearingDecorationElementOfKind:(NSString*)elementKind atIndexPath:(NSIndexPath*)elementIndexPath
{
}

- (UICollectionViewLayoutAttributes*) finalLayoutAttributesForDisappearingItemAtIndexPath:(NSIndexPath*)itemIndexPath
{
}

- (UICollectionViewLayoutAttributes*) finalLayoutAttributesForDisappearingSupplementaryElementOfKind:(NSString*)elementKind atIndexPath:(NSIndexPath*)elementIndexPath
{
}

- (UICollectionViewLayoutAttributes*) finalLayoutAttributesForDisappearingDecorationElementOfKind:(NSString*)elementKind atIndexPath:(NSIndexPath*)elementIndexPath
{
}

#pragma mark Invalidating the Layout

- (void)invalidateLayout
{
}

- (BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)newBounds
{
}

#pragma mark Coordinating Animated Changes

- (void)prepareForAnimatedBoundsChange:(CGRect)oldBounds
{
}

- (void)finalizeAnimatedBoundsChange
{
}

#pragma mark Registering Decoration Views

- (void)registerClass:(Class)viewClass forDecorationViewOfKind:(NSString *)decorationViewKind
{
}

- (void)registerNib:(UINib *)nib forDecorationViewOfKind:(NSString *)decorationViewKind
{
}

@end
