#import <Foundation/Foundation.h>

@protocol UICollectionViewDataSource <NSObject>
#pragma mark Getting Item and Section Metrics

- (NSInteger)collectionView:(UICollectionView*)collectionView numberOfItemsInSection:(NSInteger)section;
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView*)collectionView;

#pragma mark Getting Views for Items

- (UICollectionViewCell*)collectionView:(UICollectionView*)collectionView cellForItemAtIndexPath:(NSIndexPath*)indexPath;
- (UICollectionReusableView*)collectionView:(UICollectionView*)collectionView viewForSupplementaryElementOfKind:(NSString*)kind atIndexPath:(NSIndexPath*)indexPath;
@end
