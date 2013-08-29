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
            context(@"badgeValue", ^{
                it(@"should not be", ^{
                    [[[tabBarItem badgeValue] should] beNil];
                });
            });
        });

        context(@"instance method", ^{
            context(@"finishedSelectedImage", ^{
                it(@"should not be", ^{
                    [[[tabBarItem finishedSelectedImage] should] beNil];
                });
            });
            context(@"finishedUnselectedImage", ^{
                it(@"should not be", ^{
                    [[[tabBarItem finishedUnselectedImage] should] beNil];
                });
            });
            context(@"titlePositionAdjustment", ^{
                it(@"should not be", ^{
                    [[@(UIOffsetEqualToOffset(UIOffsetZero, [tabBarItem titlePositionAdjustment])) should] beYes];
                });
            });
        });
    });
});
SPEC_END