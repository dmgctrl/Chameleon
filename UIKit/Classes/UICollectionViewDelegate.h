#import <Foundation/Foundation.h>
@class UICollectionView;
@class UICollectionViewCell;
@class UICollectionReusableView;

@protocol UICollectionViewDelegate <UIScrollViewDelegate>
#pragma mark Managing the Selected Cells

- (BOOL) collectionView:(UICollectionView*)collectionView shouldSelectItemAtIndexPath:(NSIndexPath*)indexPath;
- (void) collectionView:(UICollectionView*)collectionView didSelectItemAtIndexPath:(NSIndexPath*)indexPath;
- (BOOL) collectionView:(UICollectionView*)collectionView shouldDeselectItemAtIndexPath:(NSIndexPath*)indexPath;
- (void) collectionView:(UICollectionView*)collectionView didDeselectItemAtIndexPath:(NSIndexPath*)indexPath;

#pragma mark Managing Cell Highlighting

- (BOOL) collectionView:(UICollectionView*)collectionView shouldHighlightItemAtIndexPath:(NSIndexPath*)indexPath;
- (void) collectionView:(UICollectionView*)collectionView didHighlightItemAtIndexPath:(NSIndexPath*)indexPath;
- (void) collectionView:(UICollectionView*)collectionView didUnhighlightItemAtIndexPath:(NSIndexPath*)indexPath;

#pragma mark Tracking the Removal of Views

- (void) collectionView:(UICollectionView*)collectionView didEndDisplayingCell:(UICollectionViewCell*)cell forItemAtIndexPath:(NSIndexPath*)indexPath;
- (void) collectionView:(UICollectionView*)collectionView didEndDisplayingSupplementaryView:(UICollectionReusableView*)view forElementOfKind:(NSString*)elementKind atIndexPath:(NSIndexPath *)indexPath;

#pragma mark Managing Actions for Cells

- (BOOL) collectionView:(UICollectionView*)collectionView shouldShowMenuForItemAtIndexPath:(NSIndexPath*)indexPath;
- (BOOL) collectionView:(UICollectionView*)collectionView canPerformAction:(SEL)action forItemAtIndexPath:(NSIndexPath*)indexPath withSender:(id)sender;
- (void) collectionView:(UICollectionView*)collectionView performAction:(SEL)action forItemAtIndexPath:(NSIndexPath*)indexPath withSender:(id)sender;

@end
