SPEC_BEGIN(UIToolbarSpec)
describe(@"UIToolbar", ^{
    context(@"default", ^{
        UIToolbar* toolbar = [[UIToolbar alloc] init];
        it(@"should exist", ^{
            [[toolbar should] beNonNil];
        });
        it(@"should be member of right class", ^{
            [[toolbar should] beKindOfClass:[UIToolbar class]];
        });
        context(@"property", ^{

            context(@"barStyle", ^{
                it(@"should be default", ^{
                    [[@([toolbar barStyle]) should] equal:@(UIBarStyleDefault)];
                });
            });
            context(@"isTranslucent", ^{
                it(@"should be no", ^{
                    [[@([toolbar isTranslucent]) should] beNo];
                });
            });
            context(@"items", ^{
                it(@"should be no", ^{
                    [[@([[toolbar items] count]) should] equal:@(0)];
                });
            });
            context(@"tintColor", ^{
                it(@"should be no", ^{
                    [[[toolbar tintColor] should] beNil];
                });
            });
        });
    });
});
SPEC_END