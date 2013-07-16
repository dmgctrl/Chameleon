#import <UIKit/UIKit.h>

@interface UICollectionView : UIScrollView

#pragma mark Initializing a Collection View

- (id)initWithFrame:(CGRect)frame collectionViewLayout:(UICollectionViewLayout *)layout;

#pragma mark Configuring the Collection View

@property (nonatomic, retain) UICollectionViewLayout *collectionViewLayout;
- (void)setCollectionViewLayout:(UICollectionViewLayout *)layout animated:(BOOL)animated;
@property (nonatomic, assign) id <UICollectionViewDelegate> delegate;
@property (nonatomic, assign) id <UICollectionViewDataSource> dataSource;
@property (nonatomic, retain) UIView *backgroundView;

#pragma mark Creating Collection View Cells

- (void)registerClass:(Class)cellClass forCellWithReuseIdentifier:(NSString *)identifier;
- (void)registerNib:(UINib *)nib forCellWithReuseIdentifier:(NSString *)identifier;
- (void)registerClass:(Class)viewClass forSupplementaryViewOfKind:(NSString *)elementKind withReuseIdentifier:(NSString *)identifier;
- (void)registerNib:(UINib *)nib forSupplementaryViewOfKind:(NSString *)kind withReuseIdentifier:(NSString *)identifier;
- (id)dequeueReusableCellWithReuseIdentifier:(NSString *)identifier forIndexPath:(NSIndexPath*)indexPath;
- (id)dequeueReusableSupplementaryViewOfKind:(NSString*)elementKind withReuseIdentifier:(NSString *)identifier forIndexPath:(NSIndexPath*)indexPath;

#pragma mark Reloading Content

- (void)reloadData;
- (void)reloadSections:(NSIndexSet *)sections;
- (void)reloadItemsAtIndexPaths:(NSArray *)indexPaths;

#pragma mark Getting the State of the Collection View

- (NSInteger)numberOfSections;
- (NSInteger)numberOfItemsInSection:(NSInteger)section;
- (NSArray *)visibleCells;

#pragma mark Inserting, Moving, and Deleting Items

- (void)insertItemsAtIndexPaths:(NSArray *)indexPaths;
- (void)moveItemAtIndexPath:(NSIndexPath *)indexPath toIndexPath:(NSIndexPath *)newIndexPath;
- (void)deleteItemsAtIndexPaths:(NSArray *)indexPaths;

#pragma mark Inserting, Moving, and Deleting Sections

- (void)insertSections:(NSIndexSet *)sections;
- (void)moveSection:(NSInteger)section toSection:(NSInteger)newSection;
- (void)deleteSections:(NSIndexSet *)sections;

#pragma mark Managing the Selection

@property (nonatomic) BOOL allowsSelection;
@property (nonatomic) BOOL allowsMultipleSelection;
- (NSArray *)indexPathsForSelectedItems;
- (void)selectItemAtIndexPath:(NSIndexPath *)indexPath animated:(BOOL)animated scrollPosition:(UICollectionViewScrollPosition)scrollPosition;
- (void)deselectItemAtIndexPath:(NSIndexPath *)indexPath animated:(BOOL)animated;

#pragma mark Locating Items in the Collection View

- (NSIndexPath *)indexPathForItemAtPoint:(CGPoint)point;
- (NSArray *)indexPathsForVisibleItems;
- (NSIndexPath *)indexPathForCell:(UICollectionViewCell *)cell;
- (UICollectionViewCell *)cellForItemAtIndexPath:(NSIndexPath *)indexPath;

#pragma mark Getting Layout Information

- (UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath;
- (UICollectionViewLayoutAttributes *)layoutAttributesForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath;

#pragma mark Scrolling an Item Into View

- (void)scrollToItemAtIndexPath:(NSIndexPath *)indexPath atScrollPosition:(UICollectionViewScrollPosition)scrollPosition animated:(BOOL)animated;

#pragma mark Animating Multiple Changes to the Collection View

- (void)performBatchUpdates:(void (^)(void))updates completion:(void (^)(BOOL finished))completion;

@end
