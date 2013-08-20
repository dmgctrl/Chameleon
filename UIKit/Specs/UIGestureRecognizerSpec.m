SPEC_BEGIN(UIGestureRecognizerSpec)
describe(@"UIGestureRecognizer", ^{
    context(@"default", ^{
        UIGestureRecognizer* gestureRecognizer = [[UIGestureRecognizer alloc] init];
        it(@"should exist", ^{
            [[gestureRecognizer should] beNonNil];
        });
        it(@"should be member of right class", ^{
            [[gestureRecognizer should] beKindOfClass:[UIGestureRecognizer class]];
        });
        context(@"property", ^{

            context(@"state", ^{
                it(@"should be possible", ^{
                    [[@([gestureRecognizer state]) should] equal:@(UIGestureRecognizerStatePossible)];
                });
            });
            context(@"view", ^{
                it(@"should not be", ^{
                    [[[gestureRecognizer view] should] beNil];
                });
            });
            context(@"view", ^{
                it(@"should not be", ^{
                    [[[gestureRecognizer view] should] beNil];
                });
            });
            context(@"isEnabled", ^{
                it(@"should be yes", ^{
                    [[@([gestureRecognizer isEnabled]) should] beYes];
                });
            });
            context(@"cancelsTouchesInView", ^{
                it(@"should be yes", ^{
                    [[@([gestureRecognizer cancelsTouchesInView]) should] beYes];
                });
            });
            context(@"delaysTouchesBegan", ^{
                it(@"should be no", ^{
                    [[@([gestureRecognizer delaysTouchesBegan]) should] beNo];
                });
            });
            context(@"delaysTouchesEnded", ^{
                it(@"should be yes", ^{
                    [[@([gestureRecognizer delaysTouchesEnded]) should] beYes];
                });
            });
            context(@"delegate", ^{
                it(@"should be responded to", ^{
                    [[@([gestureRecognizer respondsToSelector:@selector(delegate)]) should] beYes];
                });
            });
        });
        context(@"instance method", ^{
            context(@"numberOfTouches", ^{
                context(@"should be 0", ^{
                    it(@"should be yes", ^{
                        [[@([gestureRecognizer numberOfTouches]) should] equal:@(0)];
                    });
                });
            });
        });
    });
});
SPEC_END