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
    
    context(@"-textRectForBounds:limitedToNumberOfLines:", ^{
        context(@"when given a string", ^{
            UILabel* label = [[UILabel alloc] initWithFrame:(CGRect){}];
            label.font = [UIFont fontWithName:@"Courier" size:17.0];
            label.text = \
                @"The quick brown\n" \
                @"fox jumps over\n"
                @"the lazy dog";
            
            context(@"constrained to 100x100 and one line", ^{
                CGRect rect = [label textRectForBounds:CGRectMake(0, 0, 100, 100) limitedToNumberOfLines:1];
                
                it(@"should compute a size of 92x21", ^{
                    [[NSStringFromCGRect(rect) should] equal:NSStringFromCGRect(CGRectMake(0, 0, 92, 21))];
                });
            });
        });
    });
});

SPEC_END