SPEC_BEGIN(UITabBarItemSpec)
describe(@"UITabBarItem", ^{
    context(@"default", ^{
        UITabBarItem* tabBarItem = [[UITabBarItem alloc] init];
        it(@"should exist", ^{
            [[tabBarItem should] beNonNil];
        });
        it(@"should be member of right class", ^{
            [[tabBarItem should] beKindOfClass:[UITabBarItem class]];
        });
        context(@"property", ^{

            context(@"", ^{
                it(@"should ", ^{

                });
            });
        });
    });
});
SPEC_END