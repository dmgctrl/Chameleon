SPEC_BEGIN(UILabelSpec)

describe(@"UILabel", ^{
    context(@"when using the default constructor", ^{
        UILabel* label = [[UILabel alloc] init];
        
        context(@"text", ^{
            NSString* text = [label text];
            
            it(@"is empty", ^{
                [[text should] equal:@""];
            });
        });

        context(@"attributedText", ^{
            NSAttributedString* attributedText = [label attributedText];
            
            it(@"is empty", ^{
                [[attributedText should] equal:[[NSAttributedString alloc] initWithString:@""]];
            });
        });

        context(@"font", ^{
            UIFont* font = [label font];
            
            it(@"is system-font of size 17.0", ^{
                [[font should] equal:[UIFont systemFontOfSize:17.0f]];
            });
        });
        
        context(@"textColor", ^{
            UIColor* textColor = [label textColor];
            
            it(@"is black", ^{
                [[textColor should] equal:[UIColor blackColor]];
            });
        });

        context(@"textAlignment", ^{
            UITextAlignment textAlignment = [label textAlignment];
            
            it(@"is NSTextAlignmentLeft", ^{
                [[@(textAlignment) should] equal:@(UITextAlignmentLeft)];
            });
        });
    });
});

SPEC_END