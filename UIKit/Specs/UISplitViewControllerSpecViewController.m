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
            context(@"viewControllers", ^{
                it(@"should be empty", ^{
                    [[@([[splitViewController viewControllers] count]) should] equal:@(0)];
                });
            });
            context(@"presentsWithGesture", ^{
                it(@"should be yes", ^{
                    [[@([splitViewController presentsWithGesture]) should] beYes];
                });
            });
        });
    });
});
SPEC_END