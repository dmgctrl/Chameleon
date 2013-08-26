SPEC_BEGIN(UISwipeGestureRecognizerSpec)
describe(@"UISwipeGestureRecognizer", ^{
    context(@"default", ^{
        UISwipeGestureRecognizer* swipeGestureRecognizer = [[UISwipeGestureRecognizer alloc] init];
        it(@"should exist", ^{
            [[swipeGestureRecognizer should] beNonNil];
        });
        it(@"should be member of right class", ^{
            [[swipeGestureRecognizer should] beKindOfClass:[UISwipeGestureRecognizer class]];
        });

        context(@"property", ^{
            context(@"direction", ^{
                it(@"should be right", ^{
                    [[@([swipeGestureRecognizer direction]) should] equal:@(UISwipeGestureRecognizerDirectionRight)];
                });
            });
            context(@"numberOfTouchesRequired", ^{
                it(@"should be one", ^{
                    [[@([swipeGestureRecognizer numberOfTouchesRequired]) should] equal:@(1)];
                });
            });
        });
    });
});
SPEC_END