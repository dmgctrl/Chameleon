SPEC_BEGIN(UISplitViewControllerSpec)
describe(@"UISplitViewController", ^{
    context(@"default", ^{
        UISplitViewController* splitViewController = [[UISplitViewController alloc] init];
        it(@"should exist", ^{
            [[splitViewController should] beNonNil];
        });
        it(@"should be member of right class", ^{
            [[splitViewController should] beKindOfClass:[UISplitViewController class]];
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