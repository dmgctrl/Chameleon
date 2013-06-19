SPEC_BEGIN(UIFontSpec)

describe(@"UIFont", ^{
    context(@"+fontWithName:size:", ^{
        UIFont* font1 = [UIFont fontWithName:@"Times" size:-10];
        it(@"returns same bogus size", ^{
            [[theValue([font1 pointSize]) should] equal:theValue(-10.0)];
        });
        it(@"returns same font name", ^{
            [[[font1 fontName] should] equal:@"TimesNewRomanPSMT"];
        });
    });
    context(@"+systemFontOfSize:", ^{
        context(@"when called with 17.0", ^{
            UIFont* font1 = [UIFont systemFontOfSize:17.0];
            context(@"called with 17.0 a second time", ^{
                UIFont* font2 = [UIFont systemFontOfSize:17.0];
                it(@"returns the same font", ^{
                    [[font1 should] equal:font2];
                });
            });
        });
    });
});

SPEC_END