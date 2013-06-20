#import <CoreText/CoreText.h>

SPEC_BEGIN(UIFontSpec)

describe(@"UIFont", ^{
    context(@"with negative sizes", ^{
        CGFloat negativeSize = -10;
        UIFont* font1 = [UIFont fontWithName:@"Times" size:negativeSize];
        context(@"+fontWithName:size:", ^{
            it(@"returns same bogus size", ^{
                [[@([font1 pointSize]) should] equal:@(negativeSize)];
            });
        });
        context(@"-fontWithSize:", ^{
            UIFont* font2 = [font1 fontWithSize:negativeSize];
            it(@"should return same bogus size", ^{
                [[@([font2 pointSize]) should] equal:@(negativeSize)];
            });
        });
        context(@"+systemFontOfSize:", ^{
            UIFont* font2 = [UIFont systemFontOfSize:negativeSize];
            it(@"should return same bogus number", ^{
                [[@([font2 pointSize]) should] equal:@(negativeSize)];
            });
        });
        context(@"+boldSystemFontOfSize:", ^{
            UIFont* font2 = [UIFont boldSystemFontOfSize:negativeSize];
            it(@"should return same bogus number", ^{
                [[@([font2 pointSize]) should] equal:@(negativeSize)];
            });
        });
        context(@"+italicSystemFontOfSize:", ^{
            UIFont* font2 = [UIFont italicSystemFontOfSize:negativeSize];
            it(@"should return same bogus number", ^{
                [[@([font2 pointSize]) should] equal:@(negativeSize)];
            });
        });
    });
    
    context(@"font arrays", ^{
        context(@"familyNames", ^{
            NSArray* families = [UIFont familyNames];
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
            NSString* familyName = [[UIFont familyNames] lastObject];
            NSArray* fonts = [UIFont fontNamesForFamilyName:familyName];
            UIFont* font = [UIFont fontWithName:[fonts lastObject] size:10];
            it(@"returns an NSArray", ^{
                [[fonts should] beKindOfClass:[NSArray class]];
            });
            it(@"has a non zero count", ^{
                [[@([fonts count]) should] beGreaterThan:@(0)];
            });
            it(@"has elements that are NSString", ^{
                [[[fonts lastObject] should] beKindOfClass:[NSString class]];
            });            
            it(@"should be full of font names with which one can instantiate a font", ^{
                [[font should] beNonNil];
            });
            it(@"font family should be that of the one used from array used to instantiate", ^{
                [[[font familyName] should] equal:familyName];
            });
            it(@"font family should be that of the one used from array used to instantiate", ^{
                [[[font fontName] should] equal:[fonts lastObject]];
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
        it(@"systemFontSize should return a font size", ^{
            [[@([UIFont systemFontSize]) should] beNonNil];
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
    
    context(@"with a known font, of a known size", ^{
        NSString* name = @"Baskerville";
        CGFloat pointSize = 17.0;
        UIFont* font = [UIFont fontWithName:name size:pointSize];

        it(@"has the correct fontName", ^{
            [[[font fontName] should] equal:name];
        });

        it(@"has the correct familyName", ^{
            [[[font fontName] should] equal:name];
        });

        it(@"has the correct pointSize", ^{
            [[@([font pointSize]) should] equal:@(pointSize)];
        });

        it(@"has the correct ascender", ^{
            [[@([font ascender]) should] equal:15.265f withDelta:0.01f];
        });

        it(@"has the correct descender", ^{
            [[@([font descender]) should] equal:-4.183f withDelta:0.01f];
        });

        it(@"has the correct capHeight", ^{
            [[@([font capHeight]) should] equal:11.363f withDelta:0.01f];
        });
        
        it(@"has the correct xHeight", ^{
            [[@([font xHeight]) should] equal:6.939f withDelta:0.01f];
        });

        it(@"has the correct lineHeight", ^{
            [[@([font lineHeight]) should] equal:@(21.0f)];
        });
        
        it(@"has the correct leading", ^{
            [[@([font leading]) should] equal:@(21.0f)];
        });
    });
});

SPEC_END