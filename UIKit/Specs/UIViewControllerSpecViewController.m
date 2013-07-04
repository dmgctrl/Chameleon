SPEC_BEGIN(UIViewControllerSpec)
describe(@"UIViewController", ^{
    context(@"default", ^{
        UIViewController* viewController = [[UIViewController alloc] init];
        context(@"property", ^{
            context(@"nibName", ^{
                it(@"should not be", ^{
                    [[[viewController nibName] should] beNil];
                });
            });
            context(@"nibBundle", ^{
                it(@"should be", ^{
                    [[[viewController nibBundle] should] beNonNil];
                });
            });
            context(@"storyboard", ^{
                it(@"should not be", ^{
                    [[[viewController storyboard] should] beNil];
                });
            });
            context(@"view", ^{
                it(@"should be", ^{//contrary to documentation
                    [[[viewController view] should] beNonNil];
                });
            });
            context(@"title", ^{
                it(@"should not be", ^{
                    [[[viewController title] should] beNil];
                });
            });
            context(@"wantsFullScreenLayout", ^{
                it(@"should be no", ^{
                    [[@([viewController wantsFullScreenLayout]) should] beNo];
                });
            });
            context(@"interfaceOrientation", ^{
                it(@"should be portrait", ^{
                    [[@([viewController interfaceOrientation]) should] equal:@(UIInterfaceOrientationPortrait)];
                });
            });
            context(@"editing", ^{
                it(@"should be no", ^{
                    [[@([viewController isEditing]) should] beNo];
                });
            });
            context(@"restorationIdentifier", ^{
                it(@"should not be", ^{
                    [[[viewController restorationIdentifier] should] beNil];
                });
            });
            context(@"restorationClass", ^{
                it(@"should not be", ^{
                    [[[viewController restorationClass] should] beNil];
                });
            });
            context(@"modalTransitionStyle", ^{
                it(@"should be CoverVertical", ^{
                    [[@([viewController modalTransitionStyle]) should] equal:@(UIModalTransitionStyleCoverVertical)];
                });
            });
            context(@"modalPresentationStyle", ^{
                it(@"should be full screen", ^{
                    [[@([viewController modalTransitionStyle]) should] equal:@(UIModalPresentationFullScreen)];
                });
            });
            context(@"definesPresentationContext", ^{
                it(@"should be no", ^{
                    [[@([viewController definesPresentationContext]) should] beNo];
                });
            });
            context(@"providesPresentationContextTransitionStyle", ^{
                it(@"should be no", ^{
                    [[@([viewController providesPresentationContextTransitionStyle]) should] beNo];
                });
            });
            context(@"presentingViewController", ^{
                it(@"should not be", ^{
                    [[[viewController presentingViewController] should] beNil];
                });
            });
            context(@"presentedViewController", ^{
                it(@"should not be", ^{
                    [[[viewController presentedViewController] should] beNil];
                });
            });
            context(@"parentViewController", ^{
                it(@"should not be", ^{
                    [[[viewController parentViewController] should] beNil];
                });
            });
            context(@"navigationController", ^{
                it(@"should not be", ^{
                    [[[viewController navigationController] should] beNil];
                });
            });
            context(@"splitViewController", ^{
                it(@"should not be", ^{
                    [[[viewController splitViewController] should] beNil];
                });
            });
            context(@"tabBarController", ^{
                it(@"should not be", ^{
                    [[[viewController tabBarController] should] beNil];
                });
            });
            context(@"searchDisplayController", ^{
                it(@"should not be", ^{
                    [[[viewController searchDisplayController] should] beNil];
                });
            });
            context(@"childViewControllers", ^{
                it(@"should be empty", ^{
                    [[@([[viewController childViewControllers] count]) should] equal:@(0)];
                });
            });
            context(@"navigationItem", ^{
                it(@"should be", ^{
                    [[[viewController navigationItem] should] beNonNil];
                });
            });
            context(@"hidesBottomBarWhenPushed", ^{
                it(@"should be no", ^{
                    [[@([viewController hidesBottomBarWhenPushed]) should] beNo];
                });
            });
            context(@"toolbarItems", ^{
                it(@"should be empty", ^{
                    [[@([[viewController toolbarItems] count]) should] equal:@(0)];
                });
            });
            context(@"tabBarItem", ^{
                it(@"should be", ^{
                    [[[viewController tabBarItem] should] beNonNil];
                });
            });
            context(@"contentSizeForViewInPopover", ^{
                it(@"should be 320×1100", ^{
                    [[@(CGSizeEqualToSize([viewController contentSizeForViewInPopover],CGSizeMake(320, 1100))) should] beYes];
                });
            });
        });
    });
});
SPEC_END