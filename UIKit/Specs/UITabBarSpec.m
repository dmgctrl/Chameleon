SPEC_BEGIN(UITabBarSpec)
describe(@"UITabBar", ^{
    context(@"default", ^{
        UITabBar* tabBar = [[UITabBar alloc] init];
        it(@"should exist", ^{
            [[tabBar should] beNonNil];
        });
        it(@"should be member of right class", ^{
            [[tabBar should] beKindOfClass:[UITabBar class]];
        });
        context(@"property", ^{

            context(@"items", ^{
                it(@"should be empty", ^{
                    [[@([[tabBar items]count]) should] equal:@(0)];
                });
            });
            context(@"selectedItem", ^{
                it(@"should not be", ^{
                    [[[tabBar selectedItem] should] beNil];
                });
            });
            context(@"backgroundImage", ^{
                it(@"should not be", ^{
                    [[[tabBar backgroundImage] should] beNil];
                });
            });
            context(@"selectedImageTintColor", ^{
                it(@"should not be", ^{
                    [[[tabBar selectedImageTintColor] should] beNil];
                });
            });
            context(@"selectionIndicatorImage", ^{
                it(@"should not be", ^{
                    [[[tabBar selectionIndicatorImage] should] beNil];
                });
            });
            context(@"shadowImage", ^{
                it(@"should not be", ^{
                    [[[tabBar shadowImage] should] beNil];
                });
            });
            context(@"tintColor", ^{
                it(@"should not be", ^{
                    [[[tabBar tintColor] should] beNil];
                });
            });
        });

        context(@"instance method", ^{
            context(@"isCustomizing", ^{
                it(@"should be no", ^{
                    [[@([tabBar isCustomizing]) should] beNo];
                });
            });
        });
    });
});
SPEC_END