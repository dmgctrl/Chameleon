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
            context(@"", ^{
                it(@"should ", ^{

                });
            });
        });
    });
});
SPEC_END