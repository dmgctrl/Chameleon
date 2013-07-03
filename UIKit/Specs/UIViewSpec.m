SPEC_BEGIN(UIViewSpec)
describe(@"UIView", ^{
    context(@"default", ^{
        UIView* view = [[UIView alloc] init];
        context(@"property", ^{
            context(@"backgroundColor", ^{
                it(@"should be nil", ^{
                    [[[view backgroundColor] should] beNil];
                });
            });
            context(@"hidden", ^{
                it(@"should be no", ^{
                    [[@([view isHidden]) should] beNo];
                });
            });
            context(@"alpha", ^{
                it(@"should be 1", ^{
                    [[@([view alpha]) should] equal:1.0 withDelta:0.000001];
                });
            });
            context(@"Opaque", ^{
                it(@"should be yes", ^{
                    [[@([view isOpaque]) should] beYes];
                });
            });
            context(@"clipsToBounds", ^{
                it(@"should be no", ^{
                    [[@([view clipsToBounds]) should] beNo];
                });
            });
            context(@"clearsContextBeforeDrawing", ^{
                it(@"should be yes", ^{
                    [[@([view clearsContextBeforeDrawing]) should] beYes];
                });
            });
            context(@"layer", ^{
                it(@"should be", ^{
                    [[[view layer] should] beNonNil];
                });
            });
            context(@"userInteractionEnabled", ^{
                it(@"should be yes", ^{
                    [[@([view isUserInteractionEnabled]) should] beYes];
                });
            });
            context(@"multipleTouchEnabled", ^{
                it(@"should be no", ^{
                    [[@([view isMultipleTouchEnabled]) should] beNo];
                });
            });
            context(@"exclusiveTouch", ^{
                it(@"should be no", ^{
                    [[@([view isExclusiveTouch]) should] beNo];
                });
            });
            context(@"frame", ^{
                it(@"should be zero", ^{
                    [[@(CGRectEqualToRect([view frame], CGRectZero)) should] beYes];
                });
            });
            context(@"bounds", ^{
                it(@"should be zero", ^{
                    [[@(CGRectEqualToRect([view bounds], CGRectZero)) should] beYes];
                });
            });
            context(@"center", ^{
                it(@"should be zero", ^{
                    [[@(CGPointEqualToPoint([view center], CGPointZero)) should] beYes];
                });
            });
            context(@"transform", ^{
                it(@"should be identity", ^{
                    [[@(CGAffineTransformEqualToTransform([view transform], CGAffineTransformIdentity)) should] beYes];
                });
            });
            context(@"superview", ^{
                it(@"should not be", ^{
                    [[[view superview] should] beNil];
                });
            });
            context(@"subviews", ^{
                it(@"should be empty", ^{
                    [[@([[view subviews] count ]) should] equal:@(0)];
                });
            });
            context(@"window", ^{
                it(@"should not be", ^{
                    [[[view window] should] beNil];
                });
            });
            context(@"autoresizingMask", ^{
                it(@"should be none", ^{
                    [[@([view autoresizingMask]) should] equal:@(UIViewAutoresizingNone)];
                });
            });
            context(@"autoresizesSubviews", ^{
                it(@"should be yes", ^{
                    [[@([view autoresizesSubviews]) should] beYes];
                });
            });
            context(@"contentMode", ^{
                it(@"should scale to fill", ^{
                    [[@([view contentMode]) should] equal:@(UIViewContentModeScaleToFill)];
                });
            });
            context(@"contentScaleFactor", ^{
                it(@"should scale to fill", ^{
                    [[@([view contentScaleFactor]) should] equal:1.0 withDelta:0.000001];
                });
            });
            context(@"gestureRecognizers", ^{
                it(@"should be empty", ^{
                    [[@([[view gestureRecognizers] count ]) should] equal:@(0)];
                });
            });
            context(@"restorationIdentifier", ^{
                it(@"should not be", ^{
                    [[[view restorationIdentifier] should] beNil];
                });
            });
            context(@"tag", ^{
                it(@"should not be", ^{
                    [[@([view tag]) should] equal:@(0)];
                });
            });
        });//
    });
});
SPEC_END