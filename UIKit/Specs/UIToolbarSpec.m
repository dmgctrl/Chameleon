SPEC_BEGIN(UIToolbarSpec)
describe(@"UIToolbar", ^{
    context(@"default", ^{
        UIToolbar* toolbar = [[UIToolbar alloc] init];
        it(@"should exist", ^{
            [[toolbar should] beNonNil];
        });
        it(@"should be member of right class", ^{
            [[toolbar should] beKindOfClass:[UIToolbar class]];
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