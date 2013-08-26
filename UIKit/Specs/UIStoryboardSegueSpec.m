SPEC_BEGIN(UIStoryboardSegueSpec)
describe(@"UIStoryboardSegue", ^{
    context(@"default", ^{
        UIStoryboardSegue* storyboardSegue = [[UIStoryboardSegue alloc] init];
        it(@"should exist", ^{
            [[storyboardSegue should] beNonNil];
        });
        it(@"should be member of right class", ^{
            [[storyboardSegue should] beKindOfClass:[UIStoryboardSegue class]];
        });

        context(@"property", ^{
            context(@"sourceViewController", ^{
                it(@"should not be", ^{
                    [[[storyboardSegue sourceViewController] should] beNil];
                });
            });
            context(@"destinationViewController", ^{
                it(@"should not be", ^{
                    [[[storyboardSegue destinationViewController] should] beNil];
                });
            });
            context(@"identifier", ^{
                it(@"should not be", ^{
                    [[[storyboardSegue identifier] should] beNil];
                });
            });
        });
    });
});
SPEC_END