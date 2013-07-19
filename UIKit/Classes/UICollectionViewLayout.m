#import "UICollectionViewLayout.h"
#import "UINib.h"

@implementation UICollectionViewLayout

#pragma mark Getting the Collection View Information

- (CGSize)collectionViewContentSize
{
    return CGSizeZero;
}

#pragma mark Providing Layout Attributes

- (void) prepareLayout
{
}

- (NSArray*) layoutAttributesForElementsInRect:(CGRect)rect
{
    return nil;
}

- (UICollectionViewLayoutAttributes*) layoutAttributesForItemAtIndexPath:(NSIndexPath*)indexPath
{
    return nil;
}

- (UICollectionViewLayoutAttributes*) layoutAttributesForSupplementaryViewOfKind:(NSString*)kind atIndexPath:(NSIndexPath *)indexPath
{
    return nil;
}

- (UICollectionViewLayoutAttributes*) layoutAttributesForDecorationViewOfKind:(NSString*)decorationViewKind atIndexPath:(NSIndexPath*)indexPath
{
    return nil;
}

- (CGPoint) targetContentOffsetForProposedContentOffset:(CGPoint)proposedContentOffset withScrollingVelocity:(CGPoint)velocity
{
    return CGPointZero;
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
    return nil;
}

- (UICollectionViewLayoutAttributes*) initialLayoutAttributesForAppearingSupplementaryElementOfKind:(NSString*)elementKind atIndexPath:(NSIndexPath*)elementIndexPath
{
    return nil;
}

- (UICollectionViewLayoutAttributes*) initialLayoutAttributesForAppearingDecorationElementOfKind:(NSString*)elementKind atIndexPath:(NSIndexPath*)elementIndexPath
{
    return nil;
}

- (UICollectionViewLayoutAttributes*) finalLayoutAttributesForDisappearingItemAtIndexPath:(NSIndexPath*)itemIndexPath
{
}

- (UICollectionViewLayoutAttributes*) finalLayoutAttributesForDisappearingSupplementaryElementOfKind:(NSString*)elementKind atIndexPath:(NSIndexPath*)elementIndexPath
{
    return nil;
}

- (UICollectionViewLayoutAttributes*) finalLayoutAttributesForDisappearingDecorationElementOfKind:(NSString*)elementKind atIndexPath:(NSIndexPath*)elementIndexPath
{
    return nil;
}

#pragma mark Invalidating the Layout

- (void)invalidateLayout
{
}

- (BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)newBounds
{
    return NO;
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
