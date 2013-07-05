SPEC_BEGIN(UICollectionReusableViewSpec)
describe(@"UICollectionReusableView", ^{
    context(@"default", ^{
        UICollectionReusableView* collectionReusableView = [[UICollectionReusableView alloc] init];
        context(@"property", ^{
            context(@"reuseIdentifier", ^{
                it(@"should be nil", ^{
                    NSString* collectionReusableViewCopy = [[collectionReusableView reuseIdentifier] copy];
                    [[collectionReusableViewCopy should] beNil];
                });
            });
        });
    });
});
SPEC_END