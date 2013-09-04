SPEC_BEGIN(UICollectionViewSpec)
describe(@"UICollectionView", ^{
    context(@"default", ^{
        // in conflict with documentation collection view must be initialized with non-nil layout
        UICollectionView* collectionView = [[UICollectionView alloc]initWithFrame:CGRectInfinite collectionViewLayout:[[UICollectionViewLayout alloc]init]];
        context(@"property", ^{
            context(@"collectionViewLayout", ^{
                it(@"should be as initialized", ^{
                    [[[collectionView collectionViewLayout] should] beNonNil];
                });
            });
            context(@"delegate", ^{
                it(@"should not be", ^{
                    [[(NSObject*)[collectionView delegate] should] beNil];
                });
            });
            context(@"dataSource", ^{
                it(@"should not be", ^{
                    [[(NSObject*)[collectionView dataSource] should] beNil];
                });
            });
            context(@"backgroundView", ^{
                it(@"should not be", ^{
                    [[[collectionView backgroundView] should] beNil];
                });
            });
            context(@"allowsSelection", ^{
                it(@"should not be", ^{
                    [[@([collectionView allowsSelection]) should] beYes];
                });
            });
            context(@"allowsMultipleSelection", ^{
                it(@"should not be", ^{
                    [[@([collectionView allowsMultipleSelection]) should] beNo];
                });
            });
        });
        context(@"instance method", ^{
            context(@"numberOfSections", ^{
                it(@"should be 1", ^{
                    [[@([collectionView numberOfSections]) should] equal:@(1)];
                });
            });
            context(@"numberOfItemsInSection", ^{
                it(@"should be 0", ^{
                    [[@([collectionView numberOfItemsInSection:0]) should] equal:@(0)];
                });
            });
            context(@"visibleCells", ^{
                it(@"should be 1", ^{
                    [[@([[collectionView visibleCells] count]) should] equal:@(0)];
                });
            });
        });
    });
});

SPEC_END