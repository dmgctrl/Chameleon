SPEC_BEGIN(UIFontSpec)

describe(@"UIFont", ^{
    context(@"+fontWithName:size:", ^{
        
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