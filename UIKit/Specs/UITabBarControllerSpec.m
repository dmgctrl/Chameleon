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

            context(@"tabBar", ^{
                it(@"should be", ^{
                    [[[tabBarController tabBar] should] beNonNil];
                });
            });
            context(@"viewControllers", ^{
                it(@"should be empty", ^{
                    [[@([[tabBarController viewControllers]count]) should] equal:@(0)];
                });
            });
            context(@"customizableViewControllers", ^{
                it(@"should be empty", ^{
                    [[@([[tabBarController customizableViewControllers]count]) should] equal:@(0)];
                });
            });
            context(@"moreNavigationController", ^{
                it(@"should be", ^{
                    [[[tabBarController moreNavigationController] should] beNonNil];
                });
            });
            context(@"selectedViewController", ^{
                it(@"should not be", ^{
                    [[[tabBarController selectedViewController] should] beNil];
                });
            });
            context(@"selectedIndex", ^{
                it(@"should be 0", ^{
                    [[@([tabBarController selectedIndex]) should] equal:@(NSIntegerMax)];
                });
            });
        });
    });
});
SPEC_END