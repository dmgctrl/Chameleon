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
            context(@"", ^{
                it(@"should ", ^{

                });
            });
        });
    });
});
SPEC_END