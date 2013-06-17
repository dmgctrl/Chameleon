SPEC_BEGIN(UIStoryboardSpec)

describe(@"UIStoryboard", ^{
    [NSBundle pushMainBundle:[NSBundle bundleForClass:[UIStoryboardSpec class]]];
    
    context(@"+storyboardWithName:bundle:", ^{
        it(@"should throw an assertion failure when passed a nil name", ^{
            @try {
                [UIStoryboard storyboardWithName:nil bundle:nil];
                fail(@"Didn't throw an exception");
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

        it(@"has instantiateInitialViewController", ^{
            [[theValue([storyboard respondsToSelector:@selector(instantiateInitialViewController)]) should] equal:@(YES)];
        });

        context(@"it's initialViewController", ^{
            UIViewController* controller = [storyboard instantiateInitialViewController];
            [[controller should] beNonNil];

            it(@"should load a view", ^{
                [[[controller view] should] beNonNil];
            });
            
            it(@"has performSegueWithIdentifier:sender:", ^{
                [[theValue([controller respondsToSelector:@selector(performSegueWithIdentifier:sender:)]) should] equal:@(YES)];
            });

            context(@"when performing a segue with a nil identifier, the exception", ^{
                @try {
                    [controller performSegueWithIdentifier:nil sender:nil];
                    fail(@"Didn't throw an exception");
                } @catch (NSException* exception) {
                    it(@"is an NSInvalidArgumentException", ^{
                        [[[exception name] should] equal:NSInvalidArgumentException];
                    });
                }
            });

            context(@"when performing a segue with an unknown identifier, the exception", ^{
                @try {
                    [controller performSegueWithIdentifier:@"unknown" sender:nil];
                    fail(@"Didn't throw an exception");
                } @catch (NSException* exception) {
                    it(@"is an NSInvalidArgumentException", ^{
                        [[[exception name] should] equal:NSInvalidArgumentException];
                    });
                }
            });

            context(@"when performing a valid Modal segue", ^{
                @try {
                    [controller performSegueWithIdentifier:@"Modal" sender:nil];
                } @catch (id exception) {
                    fail(@"Shoudln't throw: %@", exception);
                }
            });

            context(@"when performing a valid Custom segue", ^{
                @try {
                    [controller performSegueWithIdentifier:@"Custom" sender:nil];
                } @catch (id exception) {
                    fail(@"Shoudln't throw: %@", exception);
                }
            });

            context(@"when performing a valid Push segue", ^{
                @try {
                    [controller performSegueWithIdentifier:@"Push" sender:nil];
                } @catch (id exception) {
                    fail(@"Shoudln't throw: %@", exception);
                }
            });
        });
    });
    
    [NSBundle popMainBundle];
});

SPEC_END


@interface _UIStoryboardSpecCustomSegue : UIStoryboardSegue
@end

@implementation _UIStoryboardSpecCustomSegue
- (void) perform
{
    // DO NOTHING
}
@end