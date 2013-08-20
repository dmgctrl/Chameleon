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
            context(@"timestamp", ^{
                it(@"should equal 0", ^{
                    [[@([event timestamp]) should] equal:@(0)];
                });
            });
            context(@"type", ^{
                it(@"should be none", ^{
                    [[@([event type]) should] equal:@(-1)];
                });
            });
            context(@"subtype", ^{
                it(@"should be none", ^{
                    [[@([event subtype]) should] equal:@(UIEventSubtypeNone)];
                });
            });
        });
        context(@"instance method", ^{
            context(@"allTouches", ^{
                it(@"", ^{
                    [[@([[event allTouches] count]) should] equal:@(0)];
                });
            });
        });
    });
});
SPEC_END