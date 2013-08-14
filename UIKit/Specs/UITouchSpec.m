SPEC_BEGIN(UITouchSpec)
describe(@"UITouch", ^{
    context(@"default", ^{
        UITouch* touch = [[UITouch alloc] init];
        context(@"property", ^{
            context(@"view", ^{
                it(@"should not be", ^{
                    [[[touch view] should] beNil];
                });
            });
            context(@"view", ^{
                it(@"should not be", ^{
                    [[[touch window] should] beNil];
                });
            });
        });
    });
});
SPEC_END