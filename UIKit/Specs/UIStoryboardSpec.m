SPEC_BEGIN(UIStoryboardSpec)

describe(@"UIStoryboard", ^{
    [NSBundle pushMainBundle:[NSBundle bundleForClass:[UIStoryboardSpec class]]];
    
    context(@"+storyboardWithName:bundle:", ^{
        it(@"should throw an assertion failure when passed a nil name", ^{
            @try {
                UIStoryboard* storyboard = [UIStoryboard storyboardWithName:nil bundle:nil];
                [storyboard shouldBeNil];
            } @catch (id x) {
                [[[x description] should] equal:@"Invalid parameter not satisfying: [name length] > 0"];
            }
        });

        context(@"When given iphone example 01", ^{
            UIStoryboard* storyboard = [UIStoryboard storyboardWithName:@"iphone-example-01" bundle:nil];
            
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
            UIStoryboard* storyboard = [UIStoryboard storyboardWithName:@"iphone-example-02" bundle:nil];
            
            it(@"should not return nil", ^{
                [[storyboard should] beNonNil];
            });
            
            it(@"should be an instance of UIStoryboard", ^{
                [[storyboard should] beKindOfClass:[UIStoryboard class]];
            });
            
            it(@"should have an initialViewController", ^{
                UIViewController* viewController = [storyboard instantiateInitialViewController];
                [[viewController should] beNonNil];
            });
        });
    });
    
    context(@"When given a valid storyboard", ^{
        UIStoryboard* storyboard = [UIStoryboard storyboardWithName:@"iphone-example-02" bundle:nil];
        [[storyboard should] beNonNil];

        context(@"and it's initialViewController", ^{
            UIViewController* controller = [storyboard instantiateInitialViewController];
            [[controller should] beNonNil];
            
            it(@"should load it's view", ^{
                [[[controller view] should] beNonNil];
            });
        });
    });
    
    [NSBundle popMainBundle];
});

SPEC_END