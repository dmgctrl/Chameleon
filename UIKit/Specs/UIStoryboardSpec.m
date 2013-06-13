SPEC_BEGIN(UIStoryboardSpec)

describe(@"UIStoryboard", ^{
    context(@"+storyboardWithName:bundle:", ^{
        beforeAll(^{
            [NSBundle pushMainBundle:[NSBundle bundleForClass:[UIStoryboardSpec class]]];
        });
        
        afterAll(^{
            [NSBundle popMainBundle];
        });
        
        it(@"should throw an assertion failure when passed a nil name", ^{
            @try {
                UIStoryboard* storyboard = [UIStoryboard storyboardWithName:nil bundle:nil];
                [storyboard shouldBeNil];
            } @catch (id x) {
                [[[x description] should] equal:@"Invalid parameter not satisfying: [name length] > 0"];
            }
        });
    });
});

SPEC_END