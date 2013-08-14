SPEC_BEGIN(UITouchSpec)
describe(@"UITouch", ^{
    context(@"default", ^{
        UITouch* touch = [[UITouch alloc] init];
        context(@"property", ^{
            context(@"view", ^{
                it(@"should ", ^{
                    [[[touch view] should] beNil];
                });
            });
        });
    });
});
SPEC_END