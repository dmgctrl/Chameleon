SPEC_BEGIN(UIEventSpec)
describe(@"UIEvent", ^{
    context(@"default", ^{
        UIEvent* event = [[UIEvent alloc] init];
        it(@"should exist", ^{
            [[event should] beNonNil];
        });
        it(@"should be member of right class", ^{
            [[event should] beKindOfClass:[UIEvent class]];
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