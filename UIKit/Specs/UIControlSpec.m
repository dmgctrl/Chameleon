SPEC_BEGIN(UIControlSpec)
describe(@"UIControl", ^{
    context(@"default", ^{
        UIControl* control = [[UIControl alloc] init];
        context(@"property", ^{
            context(@"state", ^{
                it(@"should be normal", ^{
                    [[@([control state]) should] equal:@(UIControlStateNormal)];
                });
            });
        });
    });
});
SPEC_END