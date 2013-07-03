SPEC_BEGIN(UIScrollViewSpec)
describe(@"UIScrollView", ^{
    context(@"default", ^{
        UIScrollView* scrollView = [[UIScrollView alloc] init];
        context(@"property", ^{
            context(@"contentOffset", ^{
                it(@"should be 0", ^{
                    [[@(CGPointEqualToPoint([scrollView contentOffset], CGPointZero)) should] beYes];
                });
            });
            context(@"contentSize", ^{
                it(@"should be 0", ^{
                    [[@(CGSizeEqualToSize([scrollView contentSize], CGSizeZero)) should] beYes];
                });
            });
            context(@"contentInset", ^{
                it(@"should be 0", ^{
                    [[@(UIEdgeInsetsEqualToEdgeInsets([scrollView contentInset], UIEdgeInsetsZero)) should] beYes];
                });
            });
            context(@"scrollEnabled", ^{
                it(@"should be yes", ^{
                    [[@([scrollView isScrollEnabled]) should] beYes];
                });
            });
            context(@"pagingEnabled", ^{
                it(@"should be no", ^{
                    [[@([scrollView isPagingEnabled]) should] beNo];
                });
            });
            context(@"bounces", ^{
                it(@"should be yes", ^{
                    [[@([scrollView bounces]) should] beYes];
                });
            });
            context(@"alwaysBounceVertical", ^{
                it(@"should be no", ^{
                    [[@([scrollView alwaysBounceVertical]) should] beNo];
                });
            });
            context(@"alwaysBounceHorizontal", ^{
                it(@"should be no", ^{
                    [[@([scrollView alwaysBounceHorizontal]) should] beNo];
                });
            });
            context(@"canCancelContentTouches", ^{
                it(@"should be yes", ^{
                    [[@([scrollView canCancelContentTouches]) should] beYes];
                });
            });
            context(@"delaysContentTouches", ^{
                it(@"should be yes", ^{
                    [[@([scrollView delaysContentTouches]) should] beYes];
                });
            });
            context(@"decelerationRate", ^{
                it(@"should be Normal", ^{
                    [[@([scrollView decelerationRate]) should] equal:UIScrollViewDecelerationRateNormal withDelta:0.000001];
                });
            });
            context(@"dragging", ^{
                it(@"should be no", ^{
                    [[@([scrollView isDragging]) should] beNo];
                });
            });
            context(@"tracking", ^{
                it(@"should be no", ^{
                    [[@([scrollView isTracking]) should] beNo];
                });
            });
            context(@"decelerating", ^{
                it(@"should be no", ^{
                    [[@([scrollView isDecelerating]) should] beNo];
                });
            });
            context(@"indicatorStyle", ^{
                it(@"should be default", ^{
                    [[@([scrollView indicatorStyle]) should] equal:@(UIScrollViewIndicatorStyleDefault)];
                });
            });
            context(@"scrollIndicatorInsets", ^{
                it(@"should be 0", ^{
                    [[@(UIEdgeInsetsEqualToEdgeInsets([scrollView scrollIndicatorInsets], UIEdgeInsetsZero)) should] beYes];
                });
            });
            context(@"showsHorizontalScrollIndicator", ^{
                it(@"should be yes", ^{
                    [[@([scrollView showsHorizontalScrollIndicator]) should] beYes];
                });
            });
            context(@"showsHorizontalScrollIndicator", ^{
                it(@"should be yes", ^{
                    [[@([scrollView showsHorizontalScrollIndicator]) should] beYes];
                });
            });
            context(@"panGestureRecognizer", ^{
                it(@"should be", ^{
                    [[[scrollView panGestureRecognizer] should] beNonNil];
                });
            });
            context(@"pinchGestureRecognizer", ^{
                it(@"should not be", ^{
                    [[[scrollView pinchGestureRecognizer] should] beNil];
                });
            });
            context(@"zoomScale", ^{
                it(@"should be 1", ^{
                    [[@([scrollView zoomScale]) should] equal:1.0 withDelta:0.000001];
                });
            });
            context(@"maximumZoomScale", ^{
                it(@"should be 1", ^{
                    [[@([scrollView maximumZoomScale]) should] equal:1.0 withDelta:0.000001];
                });
            });
            context(@"minimumZoomScale", ^{
                it(@"should be 1", ^{
                    [[@([scrollView minimumZoomScale]) should] equal:1.0 withDelta:0.000001];
                });
            });
            context(@"zoomBouncing", ^{
                it(@"should be no", ^{
                    [[@([scrollView isZoomBouncing]) should] beNo];
                });
            });
            context(@"zooming", ^{
                it(@"should be no", ^{
                    [[@([scrollView isZooming]) should] beNo];
                });
            });
            context(@"bouncesZoom", ^{
                it(@"should be yes", ^{
                    [[@([scrollView bouncesZoom]) should] beYes];
                });
            });
            context(@"delegate", ^{
                it(@"should not be", ^{
                    [[[scrollView delegate] should] beNil];
                });
            });
        });
    });
});
SPEC_END