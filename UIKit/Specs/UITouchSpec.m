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
            context(@"tapCount", ^{
                it(@"should be zero", ^{
                    [[@([touch tapCount]) should] equal:@(0)];
                });
            });
            context(@"timestamp", ^{
                it(@"should be zero", ^{
                    [[@([touch timestamp]) should] equal:@(0)];
                });
            });
            context(@"phase", ^{
                it(@"should've begun", ^{
                    [[@([touch timestamp]) should] equal:@(UITouchPhaseBegan)];
                });
            });
            context(@"gestureRecognizers", ^{
                it(@"should've begun", ^{
                    [[@([[touch gestureRecognizers] count]) should] equal:@(0)];
                });
            });
        });
    });
});
SPEC_END