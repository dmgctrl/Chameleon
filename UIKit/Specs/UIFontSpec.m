SPEC_BEGIN(UIFontSpec)

describe(@"UIFont", ^{
    context(@"with negative sizes", ^{
        UIFont* font1 = [UIFont fontWithName:@"Times" size:-10];
        context(@"+fontWithName:size:", ^{
            it(@"returns same bogus size", ^{
                [[theValue([font1 pointSize]) should] equal:theValue(-10.0)];
            });
            it(@"returns same font name", ^{
                [[[font1 fontName] should] equal:@"TimesNewRomanPSMT"];
            });
        });
        context(@"-fontWithSize:", ^{
            UIFont* font2 = [font1 fontWithSize:-13];
            it(@"should return same bogus size", ^{
                [[@([font2 pointSize]) should] equal:@(-13.0)];
            });
        });
        context(@"systemFontOfSize", ^{
            UIFont* font2 = [UIFont systemFontOfSize:-10];
            it(@"should return same bogus number", ^{
                [[@([font2 pointSize]) should] equal:@(-10)];
            });
            it(@"should have the correct name", ^{
                [[[font2 fontName] should] equal:@".HelveticaNeueUI"];
            });
        });
        context(@"boldSystemFontOfSize", ^{
            UIFont* font2 = [UIFont boldSystemFontOfSize:-10];
            it(@"should return same bogus number", ^{
                [[@([font2 pointSize]) should] equal:@(-10)];
            });
            it(@"should have the correct name", ^{
                [[[font2 fontName] should] equal:@".HelveticaNeueUI-Bold"];
            });
        });
        context(@"italicSystemFontOfSize", ^{
            UIFont* font2 = [UIFont italicSystemFontOfSize:-10];
            it(@"should return same bogus number", ^{
                [[@([font2 pointSize]) should] equal:@(-10)];
            });
            it(@"should have the correct name", ^{
                [[[font2 fontName] should] equal:@".HelveticaNeueUI-Italic"];
            });
        });
    });
    context(@"fonty arrays", ^{
        NSArray* families = [UIFont familyNames];
        context(@"familyNames", ^{
            it(@"should return an NSArray", ^{
                [[families should] beKindOfClass:[NSArray class]];
            });
            it(@"should be non zero in count", ^{
                [[@([families count]) should] beGreaterThan:@(0)];
            });
            it(@"elements should be NSStrings", ^{
                [[[families lastObject] should] beKindOfClass:[NSString class]];
            });
        });
        context(@"fontNamesForFamilyName", ^{
            NSArray* fonts = [UIFont fontNamesForFamilyName:[families lastObject]];
            UIFont* font = [UIFont fontWithName:[fonts lastObject] size:10];
            it(@"should return an NSArray", ^{
                [[fonts should] beKindOfClass:[NSArray class]];
            });
            it(@"should be non zero in count", ^{
                [[@([fonts count]) should] beGreaterThan:@(0)];
            });
            it(@"elements should be NSStrings", ^{
                [[[fonts lastObject] should] beKindOfClass:[NSString class]];
            });            
            it(@"should be full of font names with which one can instantiate a font", ^{
                [[font should] beNonNil];
            });
            it(@"font family should be that of the one used from array used to instantiate", ^{
                [[[font familyName] should ] equal:[families lastObject]];
            });
        });
    });
    context(@"properties", ^{
        UIFont* font = [UIFont systemFontOfSize:10];
        it(@"ascender should exist", ^{
            [[@([font ascender]) should] beNonNil];
        });
        it(@"descender should exist", ^{
            [[@([font descender]) should] beNonNil];
        });
        it(@"capHeight should exist", ^{
            [[@([font capHeight]) should] beNonNil];
        });
        it(@"xHeight should exist", ^{
            [[@([font xHeight]) should] beNonNil];
        });
        it(@"lineHeight should exist", ^{
            [[@([font lineHeight]) should] beNonNil];
        });
    });
    context(@"system font info", ^{
        it(@"labelFontSize should return a font size", ^{
            [[@([UIFont labelFontSize]) should] beNonNil];
        });
        it(@"buttonFontSize should return a font size", ^{
            [[@([UIFont buttonFontSize]) should] beNonNil];
        });
        it(@"smallSystemFontSize should return a font size", ^{
            [[@([UIFont smallSystemFontSize]) should] beNonNil];
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