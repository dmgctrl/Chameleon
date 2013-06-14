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

        context(@"When given iphone example 01", ^{
            __block UIStoryboard* storyboard;
            beforeAll(^{
                storyboard = [UIStoryboard storyboardWithName:@"iphone-example-01" bundle:nil];
            });
            
            it(@"should not return nil", ^{
                [[storyboard should] beNonNil];
            });
            
            it(@"should be an instance of UIStoryboard", ^{
                [[storyboard should] beKindOfClass:[UIStoryboard class]];
            });

            it(@"should not have an initialViewController", ^{
                [[[storyboard instantiateInitialViewController] should] beNil];
            });
        });

        context(@"When given iphone example 02", ^{
            __block UIStoryboard* storyboard;
            beforeAll(^{
                storyboard = [UIStoryboard storyboardWithName:@"iphone-example-02" bundle:nil];
            });
            
            it(@"should not return nil", ^{
                [[storyboard should] beNonNil];
            });
            
            it(@"should be an instance of UIStoryboard", ^{
                [[storyboard should] beKindOfClass:[UIStoryboard class]];
            });
            
            it(@"should not have an initialViewController", ^{
                UIViewController* viewController = [storyboard instantiateInitialViewController];
                [[viewController should] beNonNil];
            });
        });
    });
});

SPEC_END