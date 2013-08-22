SPEC_BEGIN(UITapGestureRecognizerSpec)
describe(@"UITapGestureRecognizer", ^{
    context(@"default", ^{
        UITapGestureRecognizer* tapGestureRecognizer = [[UITapGestureRecognizer alloc] init];
        it(@"should exist", ^{
            [[tapGestureRecognizer should] beNonNil];
        });
        it(@"should be member of right class", ^{
            [[tapGestureRecognizer should] beKindOfClass:[UITapGestureRecognizer class]];
        });
        context(@"property", ^{

            context(@"numberOfTapsRequired", ^{
                it(@"should ", ^{
                    [[@([tapGestureRecognizer numberOfTapsRequired]) should] equal:@(1)];
                });
            });
            context(@"numberOfTouchesRequired", ^{
                it(@"should ", ^{
                    [[@([tapGestureRecognizer numberOfTouchesRequired]) should] equal:@(1)];
                });
            });
        });
    });
});
SPEC_END