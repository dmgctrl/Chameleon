SPEC_BEGIN(UIWindowSpec)
describe(@"UIWindow", ^{
    context(@"default", ^{
        UIWindow* window = [[UIWindow alloc] init];
        it(@"should exist", ^{
            [[window should] beNonNil];
        });
        it(@"should be member of right class", ^{
            [[window should] beKindOfClass:[UIWindow class]];
        });

        context(@"property", ^{
            context(@"windowLevel", ^{
                it(@"should be Normal", ^{
                    [[@([window windowLevel]) should] equal:@(UIWindowLevelNormal)];
                });
            });
            context(@"screen", ^{
                it(@"should be", ^{
                    [[[window screen] should] beNonNil];
                });
            });
            context(@"rootViewController", ^{
                it(@"should not be", ^{
                    [[[window rootViewController] should] beNil];
                });
            });
            context(@"isKeyWindow", ^{
                it(@"should be no", ^{
                    [[@([window isKeyWindow]) should] beNo];
                });
            });
        });

        context(@"instance method", ^{
            context(@"superview", ^{
                it(@"should not be", ^{
                    [[[window superview] should] beNil];
                });
            });
            context(@"window", ^{
                it(@"should not be", ^{
                    [[[window window] should] beNil];
                });
            });
            context(@"nextResponder", ^{
                it(@"should be", ^{
                    [[[window nextResponder] should] beNonNil];
                });
            });
            context(@"undoManager", ^{
                it(@"should be", ^{
                    [[[window undoManager] should] beNonNil];
                });
            });
        });
    });
});
SPEC_END