SPEC_BEGIN(UIWebViewSpec)
describe(@"UIWebView", ^{
    context(@"default", ^{
        UIWebView* webView = [[UIWebView alloc] init];
        context(@"property", ^{
            context(@"delegate", ^{
                it(@"should not be", ^{
                    [[[webView delegate] should] beNil];
                });
            });
            context(@"request", ^{
                it(@"should not be", ^{
                    [[[webView request] should] beNil];
                });
            });
            context(@"loading", ^{
                it(@"should be no", ^{
                    [[@([webView isLoading]) should] beNo];
                });
            });
            context(@"canGoBack", ^{
                it(@"should be no", ^{
                    [[@([webView canGoBack]) should] beNo];
                });
            });
            context(@"canGoForward", ^{
                it(@"should be no", ^{
                    [[@([webView canGoForward]) should] beNo];
                });
            });
            context(@"scalesPageToFit", ^{
                it(@"should be no", ^{
                    [[@([webView scalesPageToFit]) should] beNo];
                });
            });
            context(@"scrollView", ^{
                it(@"should be", ^{
                    [[[webView scrollView] should] beNonNil];
                });
            });
            context(@"suppressesIncrementalRendering", ^{
                it(@"should be no", ^{
                    [[@([webView suppressesIncrementalRendering]) should] beNo];
                });
            });
            context(@"keyboardDisplayRequiresUserAction", ^{
                it(@"should be yes", ^{
                    [[@([webView keyboardDisplayRequiresUserAction]) should] beYes];
                });
            });
            context(@"dataDetectorTypes", ^{
                it(@"should be phone number", ^{
                    [[@([webView dataDetectorTypes]) should] equal:@(UIDataDetectorTypePhoneNumber)];
                });
            });
            context(@"allowsInlineMediaPlayback", ^{
                it(@"should be no", ^{
                    [[@([webView allowsInlineMediaPlayback]) should] beNo];
                });
            });
            context(@"mediaPlaybackAllowsAirPlay", ^{
                it(@"should be yes", ^{
                    [[@([webView mediaPlaybackAllowsAirPlay]) should] beYes];
                });
            });
        });
    });
});
SPEC_END