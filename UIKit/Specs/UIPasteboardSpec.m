SPEC_BEGIN(UIPasteboardSpec)
describe(@"UIPasteboard", ^{
    context(@"withUniqueName", ^{
        UIPasteboard* pasteboard = [UIPasteboard pasteboardWithUniqueName];
        it(@"should exist", ^{
            [[pasteboard should] beNonNil];
        });
        it(@"should be member of UIPasteboard", ^{
            [[pasteboard should] beKindOfClass:[UIPasteboard class]];
        });

        context(@"property", ^{
            context(@"name", ^{
                it(@"should be", ^{
                    [[[pasteboard name] should] beNonNil];
                });
            });
            context(@"isPersistent", ^{
                it(@"should be no", ^{
                    [[@([pasteboard isPersistent]) should] beNo];
                });
            });
            context(@"changeCount", ^{
                it(@"should be", ^{
                    [[@([pasteboard changeCount]) should] beNonNil];
                });
            });
            context(@"numberOfItems", ^{
                it(@"should be 0", ^{
                    [[@([pasteboard numberOfItems]) should] equal:@(0)];
                });
            });
            context(@"items", ^{
                it(@"should be empty", ^{
                    [[@([[pasteboard items] count]) should] equal:@(0)];
                });
            });
            context(@"string", ^{
                it(@"should not be", ^{
                    [[[pasteboard string] should] beNil];
                });
            });
            context(@"strings", ^{
                it(@"should not be", ^{
                    [[[pasteboard strings] should] beNil];
                });
            });
            context(@"image", ^{
                it(@"should not be", ^{
                    [[[pasteboard image] should] beNil];
                });
            });
            context(@"images", ^{
                it(@"should not be", ^{
                    [[[pasteboard images] should] beNil];
                });
            });
            context(@"URL", ^{
                it(@"should not be", ^{
                    [[[pasteboard URL] should] beNil];
                });
            });
            context(@"URLs", ^{
                it(@"should not be", ^{
                    [[[pasteboard URLs] should] beNil];
                });
            });
            context(@"color", ^{
                it(@"should not be", ^{
                    [[[pasteboard color] should] beNil];
                });
            });
            context(@"colors", ^{
                it(@"should not be", ^{
                    [[[pasteboard colors] should] beNil];
                });
            });
        });

        context(@"instance method", ^{
            context(@"pasteboardTypes", ^{
                it(@"should be correct", ^{
                    [[[pasteboard pasteboardTypes] should] beNil];
                });
            });
        });
    });
    
    context(@"withUniqueName", ^{
        UIPasteboard* pasteboard = [UIPasteboard generalPasteboard];
        it(@"should exist", ^{
            [[pasteboard should] beNonNil];
        });
        it(@"should be member of UIPasteboard", ^{
            [[pasteboard should] beKindOfClass:[UIPasteboard class]];
        });

        context(@"property", ^{
            context(@"name", ^{
                it(@"should be correct", ^{
                    [[[pasteboard name] should] equal:@"com.apple.UIKit.pboard.general"];
                });
            });
            context(@"isPersistent", ^{
                it(@"should be yes", ^{
                    [[@([pasteboard isPersistent]) should] beYes];
                });
            });
            context(@"changeCount", ^{
                it(@"should be", ^{
                    [[@([pasteboard changeCount]) should] beNonNil];
                });
            });
            context(@"numberOfItems", ^{
                it(@"should be", ^{
                    [[@([pasteboard numberOfItems]) should] beNonNil];
                });
            });
            context(@"items", ^{
                it(@"should be", ^{
                    [[[pasteboard items] should] beNonNil];
                });
            });
        });

        context(@"instance method", ^{
            context(@"pasteboardTypes", ^{
                it(@"should be correct", ^{
                    [[@([[pasteboard pasteboardTypes] isEqualToArray:[NSArray arrayWithObjects:@"public.text", @"Apple Web Archive pasteboard type", nil]]) should] beYes];
                });
            });
        });
    });
});
SPEC_END