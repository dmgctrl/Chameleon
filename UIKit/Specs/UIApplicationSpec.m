SPEC_BEGIN(UIApplicationSpec)
describe(@"UIApplication", ^{
    context(@"shared", ^{
        UIApplication* application = [UIApplication sharedApplication];
        it(@"should exist", ^{
            [[application should] beNonNil];
        });
        it(@"should be member of right class", ^{
            [[application should] beKindOfClass:[UIApplication class]];
        });

        context(@"property", ^{
            context(@"delegate", ^{
                it(@"should be responded to", ^{
                    [[@([application respondsToSelector:@selector(delegate)]) should] beYes];
                });
            });
            context(@"keyWindow", ^{
                it(@"should exist", ^{
                    [[[application keyWindow] should] beNonNil];
                });
            });
            context(@"windows", ^{
                it(@"should be one", ^{
                    [[@([[application windows] count]) should] equal:@(1)];
                });
                it(@"first of which should be key", ^{
                    [[@([[application windows][0]isEqual:[application keyWindow]]) should] beYes];
                });
            });
            context(@"applicationSupportsShakeToEdit", ^{
                it(@"should be yes", ^{
                    [[@([application applicationSupportsShakeToEdit]) should] beYes];
                });
            });
            context(@"isIdleTimerDisabled", ^{
                it(@"should be no", ^{
                    [[@([application isIdleTimerDisabled]) should] beNo];
                });
            });
            context(@"applicationState", ^{
                it(@"should be active", ^{
                    [[@([application applicationState]) should] equal:@(UIApplicationStateActive)];
                });
            });
            context(@"backgroundTimeRemaining", ^{
                it(@"should be large", ^{
                    [[@([application backgroundTimeRemaining]) should] equal:@(DBL_MAX)];
                });
            });
            context(@"scheduledLocalNotifications", ^{
                it(@"should be 0", ^{
                    [[@([[application scheduledLocalNotifications] count]) should] equal:@(0)];
                });
            });
            context(@"protectedDataAvailable", ^{
                it(@"should be yes", ^{
                    [[@([application isProtectedDataAvailable]) should] beYes];
                });
            });
            context(@"statusBarOrientation", ^{
                it(@"should be portrait", ^{
                    [[@([application statusBarOrientation]) should] equal:@(UIInterfaceOrientationPortrait)];
                });
            });
            context(@"statusBarOrientationAnimationDuration", ^{
                it(@"should be 0.3", ^{
                    [[@([application statusBarOrientationAnimationDuration]) should] equal:0.3 withDelta:0.0000001];
                });
            });
            context(@"isStatusBarHidden", ^{
                it(@"should be no", ^{
                    [[@([application isStatusBarHidden]) should] beNo];
                });
            });
            context(@"statusBarStyle", ^{
                it(@"should be default", ^{
                    [[@([application statusBarStyle]) should] equal:@(UIStatusBarStyleDefault)];
                });
            });
            context(@"statusBarFrame", ^{
                it(@"should be default", ^{
                    [[@(CGRectEqualToRect([application statusBarFrame], CGRectMake(0.0, 0.0, 768.0, 20.0))) should] beYes];
                });
            });
            context(@"isNetworkActivityIndicatorVisible", ^{
                it(@"should be no", ^{
                    [[@([application isNetworkActivityIndicatorVisible]) should] beNo];
                });
            });
            context(@"applicationIconBadgeNumber", ^{
                it(@"should be 0", ^{
                    [[@([application applicationIconBadgeNumber]) should] equal:@(0)];
                });
            });
            context(@"userInterfaceLayoutDirection", ^{
                it(@"should be L-to-R", ^{
                    [[@([application userInterfaceLayoutDirection]) should] equal:@(UIUserInterfaceLayoutDirectionLeftToRight)];
                });
            });
        });

        context(@"instance method", ^{
            context(@"isIgnoringInteractionEvents", ^{
                it(@"should be no", ^{
                    [[@([application isIgnoringInteractionEvents]) should] beNo];
                });
            });
        });
    });
});
SPEC_END