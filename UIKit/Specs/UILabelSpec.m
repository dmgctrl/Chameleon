SPEC_BEGIN(UILabelSpec)

static CGSize kUnconstrainedSize = (CGSize){ CGFLOAT_MAX, CGFLOAT_MAX };

describe(@"UILabel", ^{
    context(@"default", ^{
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
    
    context(@"with text", ^{
        NSString* text = @"The quick brown \nfox jumped over the lazy \ndog.";
        CGSize size = CGSizeMake(187, 50);
        __block UILabel* label;
        beforeEach(^{
            label = [[UILabel alloc] init];
        });

        context(@"that is plain", ^{
            beforeEach(^{
                [label setText:text];
            });
                
            context(@"has '0' lines", ^{
                beforeEach(^{
                    [label setNumberOfLines:0];
                });
                context(@"when unconstrained", ^{
                    it(@"has correct size", ^{
                        [[NSStringFromCGSize([label sizeThatFits:kUnconstrainedSize]) should] equal:NSStringFromCGSize(CGSizeMake(191, 63))];
                    });
                    it(@"-sizeToFit agrees", ^{
                        [label sizeToFit];
                        [[NSStringFromCGSize([label sizeThatFits:kUnconstrainedSize]) should] equal:NSStringFromCGSize([label bounds].size)];
                    });
                });
                context(@"with constrained height", ^{
                    it(@"has correct size", ^{
                        [[NSStringFromCGSize([label sizeThatFits:size]) should] equal:NSStringFromCGSize(CGSizeMake(187, 63))];
                    });
                    it(@"-sizeToFit agrees", ^{
                        [label sizeToFit];
                        [[NSStringFromCGSize([label sizeThatFits:kUnconstrainedSize]) should] equal:NSStringFromCGSize([label bounds].size)];
                    });
                });
            });
            
            context(@"has 1 line", ^{
                beforeEach(^{
                    [label setNumberOfLines:1];
                });
                context(@"when unconstrained", ^{
                    it(@"has correct size", ^{
                        [[NSStringFromCGSize([label sizeThatFits:kUnconstrainedSize]) should] equal:NSStringFromCGSize(CGSizeMake(367, 21))];
                    });
                    it(@"-sizeToFit agrees", ^{
                        [label sizeToFit];
                        [[NSStringFromCGSize([label sizeThatFits:kUnconstrainedSize]) should] equal:NSStringFromCGSize([label bounds].size)];
                    });
                });
                context(@"with constrained height", ^{
                    it(@"has correct size", ^{
                        [[NSStringFromCGSize([label sizeThatFits:size]) should] equal:NSStringFromCGSize(CGSizeMake(367, 21))];
                    });
                    it(@"-sizeToFit agrees", ^{
                        [label sizeToFit];
                        [[NSStringFromCGSize([label sizeThatFits:kUnconstrainedSize]) should] equal:NSStringFromCGSize([label bounds].size)];
                    });
                });
            });

            context(@"has 2 lines", ^{
                beforeEach(^{
                    [label setNumberOfLines:2];
                });
                context(@"when unconstrained", ^{
                    it(@"has correct size", ^{
                        [[NSStringFromCGSize([label sizeThatFits:kUnconstrainedSize]) should] equal:NSStringFromCGSize(CGSizeMake(191, 42))];
                    });
                    it(@"-sizeToFit agrees", ^{
                        [label sizeToFit];
                        [[NSStringFromCGSize([label sizeThatFits:kUnconstrainedSize]) should] equal:NSStringFromCGSize([label bounds].size)];
                    });
                });
                context(@"with constrained height", ^{
                    it(@"has correct size", ^{
                        [[NSStringFromCGSize([label sizeThatFits:size]) should] equal:NSStringFromCGSize(CGSizeMake(187, 42))];
                    });
                    it(@"-sizeToFit agrees", ^{
                        [label sizeToFit];
                        [[NSStringFromCGSize([label sizeThatFits:kUnconstrainedSize]) should] equal:NSStringFromCGSize([label bounds].size)];
                    });
                });
            });

            context(@"has 3 lines", ^{
                beforeEach(^{
                    [label setNumberOfLines:3];
                });
                context(@"when unconstrained", ^{
                    it(@"has correct size", ^{
                        [[NSStringFromCGSize([label sizeThatFits:kUnconstrainedSize]) should] equal:NSStringFromCGSize(CGSizeMake(191, 63))];
                    });
                    it(@"-sizeToFit agrees", ^{
                        [label sizeToFit];
                        [[NSStringFromCGSize([label sizeThatFits:kUnconstrainedSize]) should] equal:NSStringFromCGSize([label bounds].size)];
                    });
                });
                context(@"with constrained height", ^{
                    it(@"has correct size", ^{
                        [[NSStringFromCGSize([label sizeThatFits:size]) should] equal:NSStringFromCGSize(CGSizeMake(187, 63))];
                    });
                    it(@"-sizeToFit agrees", ^{
                        [label sizeToFit];
                        [[NSStringFromCGSize([label sizeThatFits:kUnconstrainedSize]) should] equal:NSStringFromCGSize([label bounds].size)];
                    });
                });
            });
        });
        
        context(@"that is attributed", ^{
            NSAttributedString* attributedText = [[NSAttributedString alloc] initWithString:text];
            beforeEach(^{
                [label setAttributedText:attributedText];
            });
                
            context(@"has '0' lines", ^{
                beforeEach(^{
                    [label setNumberOfLines:0];
                });
                context(@"when unconstrained", ^{
                    it(@"has correct size", ^{
                        [[NSStringFromCGSize([label sizeThatFits:kUnconstrainedSize]) should] equal:NSStringFromCGSize(CGSizeMake(191, 63))];
                    });
                    it(@"-sizeToFit agrees", ^{
                        [label sizeToFit];
                        [[NSStringFromCGSize([label sizeThatFits:kUnconstrainedSize]) should] equal:NSStringFromCGSize([label bounds].size)];
                    });
                });
                context(@"with constrained height", ^{
                    it(@"has correct size", ^{
                        [[NSStringFromCGSize([label sizeThatFits:size]) should] equal:NSStringFromCGSize(CGSizeMake(187, 63))];
                    });
                    it(@"-sizeToFit agrees", ^{
                        [label sizeToFit];
                        [[NSStringFromCGSize([label sizeThatFits:kUnconstrainedSize]) should] equal:NSStringFromCGSize([label bounds].size)];
                    });
                });
            });

            context(@"has 1 line", ^{
                beforeEach(^{
                    [label setNumberOfLines:1];
                });
                context(@"when unconstrained", ^{
                    it(@"has correct size", ^{
                        [[NSStringFromCGSize([label sizeThatFits:kUnconstrainedSize]) should] equal:NSStringFromCGSize(CGSizeMake(132, 21))];
                    });
                    it(@"-sizeToFit agrees", ^{
                        [label sizeToFit];
                        [[NSStringFromCGSize([label sizeThatFits:kUnconstrainedSize]) should] equal:NSStringFromCGSize([label bounds].size)];
                    });
                });
                context(@"with constrained height", ^{
                    it(@"has correct size", ^{
                        [[NSStringFromCGSize([label sizeThatFits:size]) should] equal:NSStringFromCGSize(CGSizeMake(132, 21))];
                    });
                    it(@"-sizeToFit agrees", ^{
                        [label sizeToFit];
                        [[NSStringFromCGSize([label sizeThatFits:kUnconstrainedSize]) should] equal:NSStringFromCGSize([label bounds].size)];
                    });
                });
            });
            
            context(@"has 2 lines", ^{
                beforeEach(^{
                    [label setNumberOfLines:2];
                });
                context(@"when unconstrained", ^{
                    it(@"has correct size", ^{
                        [[NSStringFromCGSize([label sizeThatFits:kUnconstrainedSize]) should] equal:NSStringFromCGSize(CGSizeMake(218, 42))];
                    });
                    it(@"-sizeToFit agrees", ^{
                        [label sizeToFit];
                        [[NSStringFromCGSize([label sizeThatFits:kUnconstrainedSize]) should] equal:NSStringFromCGSize([label bounds].size)];
                    });
                });
                context(@"with constrained height", ^{
                    it(@"has correct size", ^{
                        [[NSStringFromCGSize([label sizeThatFits:size]) should] equal:NSStringFromCGSize(CGSizeMake(187, 42))];
                    });
                    it(@"-sizeToFit agrees", ^{
                        [label sizeToFit];
                        [[NSStringFromCGSize([label sizeThatFits:kUnconstrainedSize]) should] equal:NSStringFromCGSize([label bounds].size)];
                    });
                });
            });
            
            context(@"has 3 lines", ^{
                beforeEach(^{
                    [label setNumberOfLines:3];
                });
                context(@"when unconstrained", ^{
                    it(@"has correct size", ^{
                        [[NSStringFromCGSize([label sizeThatFits:kUnconstrainedSize]) should] equal:NSStringFromCGSize(CGSizeMake(191, 63))];
                    });
                    it(@"-sizeToFit agrees", ^{
                        [label sizeToFit];
                        [[NSStringFromCGSize([label sizeThatFits:kUnconstrainedSize]) should] equal:NSStringFromCGSize([label bounds].size)];
                    });
                });
                context(@"with constrained height", ^{
                    it(@"has correct size", ^{
                        [[NSStringFromCGSize([label sizeThatFits:size]) should] equal:NSStringFromCGSize(CGSizeMake(187, 63))];
                    });
                    it(@"-sizeToFit agrees", ^{
                        [label sizeToFit];
                        [[NSStringFromCGSize([label sizeThatFits:kUnconstrainedSize]) should] equal:NSStringFromCGSize([label bounds].size)];
                    });
                });
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