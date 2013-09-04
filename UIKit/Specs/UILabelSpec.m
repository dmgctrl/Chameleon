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
        
        context(@"lineBreakMode", ^{ //Deprecated. Use NSLineBreakMode instead.
            UILineBreakMode lineBreakMode = [label lineBreakMode];
            it(@"is TailTruncation'", ^{
                [[@(lineBreakMode) should] equal:@(UILineBreakModeTailTruncation)];
            });
        });

        context(@"lineBreakMode", ^{
            NSLineBreakMode lineBreakMode = [label lineBreakMode];
            it(@"is TailTruncation'", ^{
                [[@(lineBreakMode) should] equal:@(NSLineBreakByTruncatingTail)];
            });
        });
        
        context(@"enabled", ^{
            BOOL enabled = [label isEnabled];
            it(@"YES", ^{
                [[@(enabled) should] beYes];
            });
        });

        context(@"adjustsFontSizeToFitWidth", ^{
            BOOL adjustsFontSizeToFitWidth = [label adjustsFontSizeToFitWidth];
            // More tests to add:
            // This property is effective only when the numberOfLines property is set to 1.
            // If you change it to YES, you should also set an appropriate minimum font size by modifying the minimumFontSize property.
            // If this property is set to YES, it is a programmer error to set the lineBreakMode property to a value that causes text to wrap to another line.
            it(@"is NO'", ^{
                [[@(adjustsFontSizeToFitWidth) should] beNo];
            });
        });
        
        context(@"adjustsLetterSpacingToFitWidth", ^{
            BOOL adjustsLetterSpacingToFitWidth = [label adjustsLetterSpacingToFitWidth];
            // More tests to add:
            // When this property is YES, the label may alter the letter spacing of the label text to make that text fit better within the label’s bounds.
            // This property is applied to the string regardless of the current line break mode.
            // If YES, ignore attempts by tighteningFactorForTruncation on any NSParagraphStyle objects associated with the label text.
            // If this property is set to YES, it is a programmer error to set the lineBreakMode property to a value that causes text to wrap to another line.
            it(@"NO", ^{
                [[@(adjustsLetterSpacingToFitWidth) should] beNo];
            });
        });
        
        context(@"baselineAdjustment", ^{
            int baselineAdjustment = [label baselineAdjustment];
            it(@"UIBaselineAdjustmentAlignBaselines", ^{
                [[@(baselineAdjustment) should] equal:@(UIBaselineAdjustmentAlignBaselines)];
            });
        });
        
        context(@"minimumScaleFactor", ^{
            CGFloat minimumScaleFactor = [label minimumScaleFactor];
            // More tests to add:
            // If you specify a value of 0 for this property, the current font size is used as the smallest font size.
            it(@"0", ^{
                [[@(minimumScaleFactor) should] equal:@(0)];
            });
        });
        
        context(@"numberOfLines", ^{
            NSInteger numberOfLines = [label numberOfLines];
            it(@"1", ^{
                [[@(numberOfLines) should] equal:@(1)];
            });
        });
        
        context(@"highlightedTextColor", ^{
            UIColor *highlightedTextColor = [label highlightedTextColor];
            it(@"nil", ^{
                [[highlightedTextColor should] beNil];
            });
        });
        
        context(@"highlighted", ^{
            BOOL highlighted = [label isHighlighted];
            it(@"No", ^{
                [[@(highlighted) should] beNo];
            });
        });
        
        context(@"shadowColor", ^{
            UIColor *shadowColor = [label shadowColor];
            it(@"nil", ^{
                [[shadowColor should] beNil];
            });
        });
        
        context(@"shadowColor", ^{
            UIColor *shadowColor = [label shadowColor];
            it(@"nil", ^{
                [[shadowColor should] beNil];
            });
        });
        
        context(@"shadowOffset", ^{
            CGSize shadowOffset = [label shadowOffset];
            it(@"width is 0", ^{
                [[@(shadowOffset.width) should] equal:@(0)];
            });
            it(@"height is -1", ^{
                [[@(shadowOffset.height) should] equal:@(-1)];
            });
        });
        
        context(@"userInteractionEnabled", ^{
            BOOL userInteractionEnabled = [label isUserInteractionEnabled];
            it(@"No", ^{
                [[@(userInteractionEnabled) should] beNo];
            });
        });
        
        context(@"preferredMaxLayoutWidth", ^{
            CGFloat preferredMaxLayoutWidth = [label preferredMaxLayoutWidth];
            it(@"No", ^{
                [[@(preferredMaxLayoutWidth) should] equal:@(0)];
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