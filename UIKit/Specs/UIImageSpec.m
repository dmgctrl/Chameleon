SPEC_BEGIN(UIImageSpec)

describe(@"UIImage", ^{
    context(@"-imageWithContentsOfFile:", ^{
        it(@"should return nil when passed a nil path", ^{
            UIImage* image = [[UIImage alloc] initWithContentsOfFile:nil];
            [image shouldBeNil];
        });
    });
});

SPEC_END