SPEC_BEGIN(UILabelSpec)

describe(@"UILabel", ^{
    context(@"when using the default constructor", ^{
        UILabel* label = [[UILabel alloc] init];
        
        context(@"the text property", ^{
            NSString* text = [label text];
            
            it(@"is empty", ^{
                [[text should] equal:@""];
            });
        });
        
        context(@"the font property", ^{
            UIFont* font = [label font];
            
            it(@"is system-font of size 17.0", ^{
                [[font should] equal:[UIFont systemFontOfSize:17.0f]];
            });
        });
    });
});

SPEC_END