SPEC_BEGIN(UICollectionViewCellSpec)
describe(@"UICollectionViewCell", ^{
    
    context(@"default", ^{
        UICollectionViewCell* collectionViewCell = [[UICollectionViewCell alloc] init];
        context(@"property", ^{
            context(@"contentView", ^{
                it(@"should be", ^{
                    [[[collectionViewCell contentView] should] beNonNil];
                });
            });
            context(@"backgroundView", ^{
                it(@"should not be", ^{
                    [[[collectionViewCell backgroundView] should] beNil];
                });
            });
            context(@"selectedBackgroundView", ^{
                it(@"should not be", ^{
                    [[[collectionViewCell selectedBackgroundView] should] beNil];
                });
            });
            context(@"selected", ^{
                it(@"should not be", ^{
                    [[@([collectionViewCell isSelected]) should] beNo];
                });
            });
            context(@"highlighted", ^{
                it(@"should not be", ^{
                    [[@([collectionViewCell isHighlighted]) should] beNo];
                });
            });
        });
    });
});

SPEC_END