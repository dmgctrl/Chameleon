SPEC_BEGIN(UIControlSpec)
describe(@"UIControl", ^{
    context(@"default", ^{
        UIControl* control = [[UIControl alloc] init];
        context(@"property", ^{
            context(@"state", ^{
                it(@"should be normal", ^{
                    [[@([control state]) should] equal:@(UIControlStateNormal)];
                });
                context(@"enabled", ^{
                    it(@"should be yes", ^{
                        [[@([control isEnabled]) should] beYes];
                    });
                });
                context(@"selected", ^{
                    it(@"should be no", ^{
                        [[@([control isSelected]) should] beNo];
                    });
                });
                context(@"highlighted", ^{
                    it(@"should be no", ^{
                        [[@([control isHighlighted]) should] beNo];
                    });
                });
                context(@"contentVerticalAlignment", ^{
                    it(@"should be center", ^{
                        [[@([control contentVerticalAlignment]) should] equal:@(UIControlContentVerticalAlignmentCenter)];
                    });
                });
                context(@"contentHorizontalAlignment", ^{
                    it(@"should be center", ^{
                        [[@([control contentVerticalAlignment]) should] equal:@(UIControlContentHorizontalAlignmentCenter)];
                    });
                });
                
                context(@"tracking", ^{
                    it(@"should be no", ^{
                        [[@([control isTracking]) should] beNo];
                    });
                });
                context(@"touchInside", ^{
                    it(@"should be no", ^{
                        [[@([control isTouchInside]) should] beNo];
                    });
                });
            });
            
            context(@"instance method", ^{
                context(@"allTargets", ^{
                    it(@"should be none", ^{
                        [[@([[control allTargets] count]) should] equal:@(0)];
                    });
                });
                context(@"allControlEvents", ^{
                    it(@"should be 0", ^{
                        [[@([control allControlEvents]) should] equal:@(0)];
                    });
                });
            });
        });
    });
});
SPEC_END