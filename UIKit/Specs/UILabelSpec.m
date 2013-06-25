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
        
        context(@"with number of lines", ^{
            NSString* text = @"The quick brown \nfox jumped over the lazy \ndog.";
            NSAttributedString* attributedText = [[NSAttributedString alloc] initWithString:text];
            CGSize size = CGSizeMake(187, 50);
            __block UILabel* label;
            
            beforeEach(^{
                label = [[UILabel alloc] init];
            });

                
            context(@"plain text", ^{
                
                beforeEach(^{
                    [label setText:text];
                });
                    
                context(@"numberOfLines is 0", ^{
                    
                    beforeEach(^{
                        [label setNumberOfLines:0];
                    });
                    
                    it(@"computes the right size when unconstrained", ^{
                        [label sizeToFit];
                        [[NSStringFromCGSize([label bounds].size) should] equal:NSStringFromCGSize(CGSizeMake(191, 63))];
                    });
                    
                    it(@"computes the right size when heigh is constrained to 50", ^{
                        [[NSStringFromCGSize([label sizeThatFits:size]) should] equal:NSStringFromCGSize(CGSizeMake(187, 63))];
                    });
                });
                
                context(@"numberOfLines is 1", ^{
                    
                    beforeEach(^{
                        [label setNumberOfLines:1];
                    });
                    
                    it(@"computes the right size when unconstrained", ^{
                        [label sizeToFit];
                        [[NSStringFromCGSize([label bounds].size) should] equal:NSStringFromCGSize(CGSizeMake(367, 21))];
                    });
                    
                    it(@"computes the right size when height is constrained to 50", ^{
                        [[NSStringFromCGSize([label sizeThatFits:size]) should] equal:NSStringFromCGSize(CGSizeMake(367, 21))];
                    });
                });

                context(@"numberOfLines is 2", ^{
                    
                    beforeEach(^{
                        [label setNumberOfLines:2];
                    });
                    
                    it(@"computes the right size when unconstrained", ^{
                        [label sizeToFit];
                        [[NSStringFromCGSize([label bounds].size) should] equal:NSStringFromCGSize(CGSizeMake(191, 42))];
                    });
                    
                    it(@"computes the right size when height is constrained to 50", ^{
                        [[NSStringFromCGSize([label sizeThatFits:size]) should] equal:NSStringFromCGSize(CGSizeMake(187, 42))];
                    });
                });

                context(@"numberOfLines is 3", ^{
                    
                    beforeEach(^{
                        [label setNumberOfLines:3];
                    });
                    
                    it(@"computes the right size", ^{
                        [label sizeToFit];
                        [[NSStringFromCGSize([label bounds].size) should] equal:NSStringFromCGSize(CGSizeMake(191, 63))];
                    });
                    
                    it(@"computes the right size", ^{
                        [[NSStringFromCGSize([label sizeThatFits:size]) should] equal:NSStringFromCGSize(CGSizeMake(187, 63))];
                    });
                });
            });
            
            context(@"attributed text", ^{
                
                beforeEach(^{
                    [label setAttributedText:attributedText];
                });

                context(@"unconstrained", ^{
                    
                    context(@"numberOfLines is 0", ^{
                        
                        it(@"computes the right size", ^{
                            [label setNumberOfLines:0];
                            [label sizeToFit];
                            [[NSStringFromCGSize([label bounds].size) should] equal:NSStringFromCGSize(CGSizeMake(191, 63))];
                        });
                    });

                    context(@"numberOfLines is 1", ^{
                        
                        it(@"computes the right size", ^{
                            [label setNumberOfLines:1];
                            [label sizeToFit];
                            [[NSStringFromCGSize([label bounds].size) should] equal:NSStringFromCGSize(CGSizeMake(132, 21))];
                        });
                    });
                    context(@"numberOfLines is 2", ^{
                        
                        it(@"computes the right size", ^{
                            [label setNumberOfLines:2];
                            [label sizeToFit];
                            [[NSStringFromCGSize([label bounds].size) should] equal:NSStringFromCGSize(CGSizeMake(218, 42))];
                        });
                    });
                    
                    context(@"numberOfLines is 3", ^{
                        
                        it(@"computes the right size", ^{
                            [label setNumberOfLines:3];
                            [label sizeToFit];
                            [[NSStringFromCGSize([label bounds].size) should] equal:NSStringFromCGSize(CGSizeMake(191, 63))];
                        });
                    });
                });
                
                context(@"constrained to 50", ^{

                    context(@"numberOfLines is 0", ^{
                        
                        it(@"computes the right size", ^{
                            [label setNumberOfLines:0];
                            [[NSStringFromCGSize([label sizeThatFits:size]) should] equal:NSStringFromCGSize(CGSizeMake(187, 63))];
                        });
                    });
                    
                    context(@"numberOfLines is 1", ^{
                        
                        it(@"computes the right size", ^{
                            [label setNumberOfLines:1];
                            [[NSStringFromCGSize([label sizeThatFits:size]) should] equal:NSStringFromCGSize(CGSizeMake(132, 21))];
                        });
                    });
                    
                    context(@"numberOfLines is 2", ^{
                        
                        it(@"computes the right size", ^{
                            [label setNumberOfLines:2];
                            [[NSStringFromCGSize([label sizeThatFits:size]) should] equal:NSStringFromCGSize(CGSizeMake(187, 42))];
                        });
                    });
                    
                    context(@"numberOfLines is 3", ^{
                        
                        it(@"computes the right size", ^{
                            [label setNumberOfLines:3];
                            [[NSStringFromCGSize([label sizeThatFits:size]) should] equal:NSStringFromCGSize(CGSizeMake(187, 63))];
                        });
                    });
                });
            });
        });
    });
});

SPEC_END