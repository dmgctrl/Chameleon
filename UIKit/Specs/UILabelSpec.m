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
            context(@"0, 2,3,...", ^{
                
                context(@"plain text", ^{
                    
                    context(@"unconstrained", ^{
                        
                        context(@"numberOfLines is 0", ^{
                            
                            UILabel* label = [[UILabel alloc] init];
                            [label setText:text];
                            [label setNumberOfLines:0];
                            [label sizeToFit];
                            it(@"computes the right size", ^{
                                [[NSStringFromCGSize([label bounds].size) should] equal:NSStringFromCGSize(CGSizeMake(191, 63))];
                            });
                        });

                        context(@"numberOfLines is 2", ^{
                            
                            UILabel* label = [[UILabel alloc] init];
                            [label setText:text];
                            [label setNumberOfLines:2];
                            [label sizeToFit];
                            it(@"computes the right size", ^{
                                [[NSStringFromCGSize([label bounds].size) should] equal:NSStringFromCGSize(CGSizeMake(191, 42))];
                            });
                        });

                        context(@"numberOfLines is 3", ^{
                            
                            UILabel* label = [[UILabel alloc] init];
                            [label setText:text];
                            [label setNumberOfLines:3];
                            [label sizeToFit];
                            it(@"computes the right size", ^{
                                [[NSStringFromCGSize([label bounds].size) should] equal:NSStringFromCGSize(CGSizeMake(191, 63))];
                            });
                        });
                    });
                    
                    context(@"constrained to hight of 50", ^{
                        
                        CGSize size = CGSizeMake(187, 50);
                        context(@"numberOfLines is 0", ^{
                            
                            UILabel* label = [[UILabel alloc] init];
                            [label setText:text];
                            [label setNumberOfLines:0];
                            it(@"computes the right size", ^{
                                [[NSStringFromCGSize([label sizeThatFits:size]) should] equal:NSStringFromCGSize(CGSizeMake(187, 63))];
                            });
                        });
                        
                        context(@"numberOfLines is 2", ^{
                            
                            UILabel* label = [[UILabel alloc] init];
                            [label setText:text];
                            [label setNumberOfLines:2];
                            it(@"computes the right size", ^{
                                [[NSStringFromCGSize([label sizeThatFits:size]) should] equal:NSStringFromCGSize(CGSizeMake(187, 42))];
                            });
                        });
                        
                        context(@"numberOfLines is 3", ^{
                            
                            UILabel* label = [[UILabel alloc] init];
                            [label setText:text];
                            [label setNumberOfLines:3];
                            it(@"computes the right size", ^{
                                [[NSStringFromCGSize([label sizeThatFits:size]) should] equal:NSStringFromCGSize(CGSizeMake(187, 63))];
                            });
                        });
                    });
                });
                
                context(@"attributed text", ^{
                    NSAttributedString* attributedText = [[NSAttributedString alloc] initWithString:text];
                    context(@"unconstrained", ^{
                        
                        context(@"numberOfLines is 0", ^{
                            UILabel* label = [[UILabel alloc] init];
                            [label setAttributedText:attributedText];
                            [label setNumberOfLines:0];
                            [label sizeToFit];
                            it(@"computes the right size", ^{
                                [[NSStringFromCGSize([label bounds].size) should] equal:NSStringFromCGSize(CGSizeMake(191, 63))];
                            });
                        });

                        context(@"numberOfLines is 2", ^{
                            
                            UILabel* label = [[UILabel alloc] init];
                            [label setAttributedText:attributedText];
                            [label setNumberOfLines:2];
                            [label sizeToFit];
                            it(@"computes the right size", ^{
                                [[NSStringFromCGSize([label bounds].size) should] equal:NSStringFromCGSize(CGSizeMake(218, 42))];
                            });
                        });
                        
                        context(@"numberOfLines is 3", ^{
                            
                            UILabel* label = [[UILabel alloc] init];
                            [label setAttributedText:attributedText];
                            [label setNumberOfLines:3];
                            [label sizeToFit];
                            it(@"computes the right size", ^{
                                [[NSStringFromCGSize([label bounds].size) should] equal:NSStringFromCGSize(CGSizeMake(191, 63))];
                            });
                        });
                    });
                    
                    context(@"constrained to 50", ^{
                        CGSize size = CGSizeMake(187, 50);

                        context(@"numberOfLines is 0", ^{
                            UILabel* label = [[UILabel alloc] init];
                            [label setAttributedText:attributedText];
                            [label setNumberOfLines:0];
                            it(@"computes the right size", ^{
                                [[NSStringFromCGSize([label sizeThatFits:size]) should] equal:NSStringFromCGSize(CGSizeMake(187, 63))];
                            });
                        });
                        
                        context(@"numberOfLines is 2", ^{
                            UILabel* label = [[UILabel alloc] init];
                            [label setAttributedText:attributedText];
                            [label setNumberOfLines:2];
                            it(@"computes the right size", ^{
                                [[NSStringFromCGSize([label sizeThatFits:size]) should] equal:NSStringFromCGSize(CGSizeMake(187, 42))];
                            });
                        });
                        
                        context(@"numberOfLines is 3", ^{
                            UILabel* label = [[UILabel alloc] init];
                            [label setAttributedText:attributedText];
                            [label setNumberOfLines:3];
                            it(@"computes the right size", ^{
                                [[NSStringFromCGSize([label sizeThatFits:size]) should] equal:NSStringFromCGSize(CGSizeMake(187, 63))];
                            });
                        });
                    });
                });
                
                context(@"number of lines is 1", ^{
                    
                    context(@"plain text", ^{
                        
                        context(@"unconstrained", ^{
                            
                            UILabel* label = [[UILabel alloc] init];
                            [label setText:text];
                            [label setNumberOfLines:1];
                            [label sizeToFit];
                            it(@"computes the right size", ^{
                                [[NSStringFromCGSize([label bounds].size) should] equal:NSStringFromCGSize(CGSizeMake(367, 21))];
                            });
                        });
                        
                        context(@"constrained height to 50", ^{
                            CGSize size = CGSizeMake(187, 50);
                            UILabel* label = [[UILabel alloc] init];
                            [label setText:text];
                            [label setNumberOfLines:1];
                            it(@"computes the right size", ^{
                                [[NSStringFromCGSize([label sizeThatFits:size]) should] equal:NSStringFromCGSize(CGSizeMake(367, 21))];
                            });
                        });
                    });
                    
                    context(@"attributed text", ^{
                        NSAttributedString* attributedText = [[NSAttributedString alloc] initWithString:text];

                        context(@"unconstrained", ^{
                            
                            UILabel* label = [[UILabel alloc] init];
                            [label setAttributedText:attributedText];
                            [label setNumberOfLines:1];
                            [label sizeToFit];
                            it(@"computes the right size", ^{
                                [[NSStringFromCGSize([label bounds].size) should] equal:NSStringFromCGSize(CGSizeMake(132, 21))];
                            });
                        });
                        
                        context(@"constrained height to 50", ^{
                            CGSize size = CGSizeMake(187, 50);
                            UILabel* label = [[UILabel alloc] init];
                            [label setAttributedText:attributedText];
                            [label setNumberOfLines:1];
                            it(@"computes the right size", ^{
                                [[NSStringFromCGSize([label sizeThatFits:size]) should] equal:NSStringFromCGSize(CGSizeMake(132, 21))];
                            });
                        });
                    });
                });
            });
        });
    });
});

SPEC_END