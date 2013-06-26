SPEC_BEGIN(UILabelSpec)

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
                        [label sizeToFit];
                        [[NSStringFromCGSize([label bounds].size) should] equal:NSStringFromCGSize(CGSizeMake(191, 63))];
                    });
                });
                context(@"with constrained height", ^{
                    it(@"has correct size", ^{
                        [[NSStringFromCGSize([label sizeThatFits:size]) should] equal:NSStringFromCGSize(CGSizeMake(187, 63))];
                    });
                });
            });
            
            context(@"has 1 line", ^{
                beforeEach(^{
                    [label setNumberOfLines:1];
                });
                context(@"when unconstrained", ^{
                    it(@"has correct size", ^{
                        [label sizeToFit];
                        [[NSStringFromCGSize([label bounds].size) should] equal:NSStringFromCGSize(CGSizeMake(367, 21))];
                    });
                });
                context(@"with constrained height", ^{
                    it(@"has correct size", ^{
                        [[NSStringFromCGSize([label sizeThatFits:size]) should] equal:NSStringFromCGSize(CGSizeMake(367, 21))];
                    });
                });
            });

            context(@"has 2 lines", ^{
                beforeEach(^{
                    [label setNumberOfLines:2];
                });
                context(@"when unconstrained", ^{
                    it(@"has correct size", ^{
                        [label sizeToFit];
                        [[NSStringFromCGSize([label bounds].size) should] equal:NSStringFromCGSize(CGSizeMake(191, 42))];
                    });
                });
                context(@"with constrained height", ^{
                    it(@"has correct size", ^{
                        [[NSStringFromCGSize([label sizeThatFits:size]) should] equal:NSStringFromCGSize(CGSizeMake(187, 42))];
                    });
                });
            });

            context(@"has 3 lines", ^{
                beforeEach(^{
                    [label setNumberOfLines:3];
                });
                context(@"when unconstrained", ^{
                    it(@"has correct size", ^{
                        [label sizeToFit];
                        [[NSStringFromCGSize([label bounds].size) should] equal:NSStringFromCGSize(CGSizeMake(191, 63))];
                    });
                });
                context(@"with constrained height", ^{
                    it(@"has correct size", ^{
                        [[NSStringFromCGSize([label sizeThatFits:size]) should] equal:NSStringFromCGSize(CGSizeMake(187, 63))];
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
                        [label sizeToFit];
                        [[NSStringFromCGSize([label bounds].size) should] equal:NSStringFromCGSize(CGSizeMake(191, 63))];
                    });
                });
                context(@"with constrained height", ^{
                    it(@"has correct size", ^{
                        [[NSStringFromCGSize([label sizeThatFits:size]) should] equal:NSStringFromCGSize(CGSizeMake(187, 63))];
                    });
                });
            });

            context(@"has 1 line", ^{
                beforeEach(^{
                    [label setNumberOfLines:1];
                });
                context(@"when unconstrained", ^{
                    it(@"has correct size", ^{
                        [label sizeToFit];
                        [[NSStringFromCGSize([label bounds].size) should] equal:NSStringFromCGSize(CGSizeMake(132, 21))];
                    });
                });
                context(@"with constrained height", ^{
                    it(@"has correct size", ^{
                        [[NSStringFromCGSize([label sizeThatFits:size]) should] equal:NSStringFromCGSize(CGSizeMake(132, 21))];
                    });
                });
            });
            
            context(@"has 2 lines", ^{
                beforeEach(^{
                    [label setNumberOfLines:2];
                });
               context(@"when unconstrained", ^{
                    it(@"has correct size", ^{
                        [label sizeToFit];
                        [[NSStringFromCGSize([label bounds].size) should] equal:NSStringFromCGSize(CGSizeMake(218, 42))];
                    });
                });
                context(@"with constrained height", ^{
                    it(@"has correct size", ^{
                        [[NSStringFromCGSize([label sizeThatFits:size]) should] equal:NSStringFromCGSize(CGSizeMake(187, 42))];
                    });
                });
            });
            
            context(@"has 3 lines", ^{
                beforeEach(^{
                    [label setNumberOfLines:3];
                });
                context(@"when unconstrained", ^{
                    it(@"has correct size", ^{
                        [label sizeToFit];
                        [[NSStringFromCGSize([label bounds].size) should] equal:NSStringFromCGSize(CGSizeMake(191, 63))];
                    });
                });
                context(@"with constrained height", ^{
                    it(@"has correct size", ^{
                        [[NSStringFromCGSize([label sizeThatFits:size]) should] equal:NSStringFromCGSize(CGSizeMake(187, 63))];
                    });
                });
            });
        });
    });
});

SPEC_END