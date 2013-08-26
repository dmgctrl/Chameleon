SPEC_BEGIN(UITabBarControllerSpec)
describe(@"UITabBarController", ^{
    context(@"default", ^{
        UITabBarController* tabBarController = [[UITabBarController alloc] init];
        it(@"should exist", ^{
            [[tabBarController should] beNonNil];
        });
        it(@"should be member of right class", ^{
            [[tabBarController should] beKindOfClass:[UITabBarController class]];
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