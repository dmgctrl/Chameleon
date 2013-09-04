SPEC_BEGIN(UIImageViewSpec)
describe(@"UIImageView", ^{
    context(@"default", ^{
        UIImageView* imageView = [[UIImageView alloc] init];
        context(@"property", ^{
            context(@"image", ^{
                it(@"should not be", ^{
                    [[[imageView image] should] beNil];
                });
            });
            context(@"highlightedImage", ^{
                it(@"should not be", ^{
                    [[[imageView highlightedImage] should] beNil];
                });
            });
            context(@"animationImages", ^{
                it(@"should be empty", ^{
                    [[@([[imageView animationImages] count]) should] equal:@(0)];
                });
            });
            context(@"highlightedAnimationImages", ^{
                it(@"should be empty", ^{
                    [[@([[imageView highlightedAnimationImages] count]) should] equal:@(0)];
                });
            });
            context(@"animationDuration", ^{
                it(@"should be zero", ^{
                    [[@([imageView animationDuration]) should] equal:0.0 withDelta:1e-13];
                });
            });
            context(@"animationRepeatCount", ^{
                it(@"should be zero", ^{
                    [[@([imageView animationRepeatCount]) should] equal:@(0)];
                });
            });
            context(@"userInteractionEnabled", ^{
                it(@"should be no", ^{
                    [[@([imageView isUserInteractionEnabled]) should] beNo];
                });
            });
            context(@"highlighted", ^{
                it(@"should be no", ^{
                    [[@([imageView isHighlighted]) should] beNo];
                });
            });
        });
        context(@"instance method", ^{
            context(@"isAnimating", ^{
                it(@"should be no", ^{
                    [[@([imageView isAnimating]) should] beNo];
                });
            });
        });
    });
});
SPEC_END