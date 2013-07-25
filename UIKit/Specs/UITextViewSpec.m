SPEC_BEGIN(UITextViewSpec)
describe(@"UITextView", ^{

    context(@"default", ^{
        UITextView* textView = [[UITextView alloc] init];
        context(@"property", ^{
            context(@"text", ^{
                it(@"should be empty", ^{
                    [[[textView text] should] equal:@""];
                });
            });
            context(@"attributedText", ^{
                it(@"should be empty", ^{
                    [[[textView attributedText] should] equal:[[NSAttributedString alloc] initWithString:@""]];
                });
            });
            context(@"font", ^{
                it(@"should be system, small", ^{
                    [[[textView font] should] equal:[UIFont systemFontOfSize:[UIFont smallSystemFontSize]]];
                });
            });
            context(@"textColor", ^{
                it(@"should be black", ^{
                    [[[textView textColor] should] equal:[UIColor blackColor]];
                });
            });
            context(@"isEditable", ^{
                it(@"should yes", ^{
                    [[@([textView isEditable]) should] beYes];
                });
            });
            context(@"allowsEditingTextAttributes", ^{
                it(@"should no", ^{
                    [[@([textView allowsEditingTextAttributes]) should] beNo];
                });
            });
            context(@"dataDetectorTypes", ^{
                it(@"should be none", ^{
                    [[@([textView dataDetectorTypes]) should] equal:@(UIDataDetectorTypeNone)];
                });
            });
            context(@"textAlignment", ^{
                it(@"should left", ^{
                    [[@([textView textAlignment]) should] equal:@(NSTextAlignmentLeft)];
                });
            });
            context(@"typingAttributes", ^{
                // The getter of this property causes an error. According to stack overflow
                // one needs to delay it similar to the following
                // [textView  performSelector:@selector(typingAttributes) withObject:nil afterDelay:0.1];
                // Because performSelector:withObject:afterDelay returns a void, the above line is not useful.
                // It might be necessary to extent the UITextView to have an instance method that will
                // accept and modify but not return a mutable dictionary and delay a call to that.
            });
            context(@"selectedRange", ^{
                it(@"should be NSNotFound and zero length", ^{
                    NSRange selectedRange = [textView selectedRange];
                    [[@(NSEqualRanges(selectedRange, NSMakeRange(NSNotFound, 0))) should] beYes];
                });
            });
            context(@"clearsOnInsertion", ^{
                it(@"should be no", ^{
                    [[@([textView clearsOnInsertion]) should] beNo];
                });
            });
            context(@"delegate", ^{
                it(@"should be nil", ^{
                    [[(NSObject*)[textView delegate] should] beNil];
                });
            });
            context(@"inputView", ^{
                it(@"should be nil", ^{
                    [[[textView inputView] should] beNil];
                });
            });
            context(@"inputAccessoryView", ^{
                it(@"should be nil", ^{
                    [[[textView inputAccessoryView] should] beNil];
                });
            });
        });
        context(@"method", ^{
            context(@"hasText", ^{
                it(@"should be no", ^{
                    [[@([textView hasText]) should] beNo];
                });
            });
        });
    });

    context(@"UITextInput Support", ^{
        NSString* text = @"The quick brown fox jumped over the lazy dog.";
        NSInteger textLength = [text length];
        NSInteger smallOffset = 5;
        context(@"Text Positions", ^{
            UITextView* textView = [[UITextView alloc] initWithFrame:(CGRect){ .size = { 100, 100 } }];
            [textView setText:text];

            UITextPosition* beginningOfDocument = [textView beginningOfDocument];
            context(@"-beginningOfDocument", ^{
                it(@"returns an object", ^{
                    [[beginningOfDocument should] beNonNil];
                });
                it(@"returns an instance of UITextRange", ^{
                    [[beginningOfDocument should] beKindOfClass:[UITextPosition class]];
                });
            });
            
            UITextPosition* endOfDocument = [textView endOfDocument];
            context(@"-endOfDocument", ^{
                it(@"returns an object", ^{
                    [[endOfDocument should] beNonNil];
                });
                it(@"returns an instance of UITextRange", ^{
                    [[endOfDocument should] beKindOfClass:[UITextPosition class]];
                });
            });
            
            context(@"Measurements", ^{
    
                context(@"offsets given position", ^{
                    context(@"w/o direction", ^{
                        context(@"beginning of document", ^{
                            it(@"should be 0", ^{
                                [[@([textView offsetFromPosition:beginningOfDocument toPosition:beginningOfDocument]) should] equal:@(0)];
                            });
                        });
                        context(@"end of document", ^{
                            it(@"should be 0", ^{
                                [[@([textView offsetFromPosition:endOfDocument toPosition:endOfDocument]) should] equal:@(0)];
                            });
                        });
                        context(@"beginning of document to end", ^{
                            it(@"should be length of text", ^{
                                [[@([textView offsetFromPosition:beginningOfDocument toPosition:endOfDocument]) should] equal:@(textLength)];
                            });
                        });
                        context(@"end of document to beginning", ^{
                            it(@"should be 0", ^{
                                [[@([textView offsetFromPosition:endOfDocument toPosition:beginningOfDocument]) should] equal:@(-textLength)];
                            });
                        });
                    });

                    context(@"with direction", ^{
                        NSString* loremText = @"Lorem ipsum dolor sit er elit lamet, consectetaur cillium";
                        UITextView* loremTextView = [[UITextView alloc] initWithFrame:(CGRect){ .size = { 100, 100 } }];
                        [loremTextView setFont:[UIFont systemFontOfSize:14]];
                        [loremTextView setText:loremText];
                        UITextPosition* beginningOfDocument = [loremTextView beginningOfDocument];
                        context(@"from given position on second line", ^{
                            UITextPosition* position = [loremTextView positionFromPosition:beginningOfDocument offset:16];
                            context(@"up", ^{
                                context(@"once", ^{
                                    UITextPosition* upOne = [loremTextView positionFromPosition:position inDirection:UITextLayoutDirectionUp offset:1];
                                    NSInteger upOneOffset = [loremTextView offsetFromPosition:beginningOfDocument toPosition:upOne];
                                    it(@"should be 4", ^{
                                        [[@(upOneOffset) should] equal:@(4)];
                                    });
                                });
                                context(@"twice", ^{
                                    UITextPosition* upTwo = [loremTextView positionFromPosition:position inDirection:UITextLayoutDirectionUp offset:2];
                                    NSInteger upTwoOffset = [loremTextView offsetFromPosition:beginningOfDocument toPosition:upTwo];
                                    it(@"should be 4", ^{
                                        [[@(upTwoOffset) should] equal:@(0)];
                                    });
                                });
                            });
                            context(@"down", ^{
                                context(@"once", ^{
                                    UITextPosition* downOne = [loremTextView positionFromPosition:position inDirection:UITextLayoutDirectionDown offset:1];
                                    NSInteger downOneOffset = [loremTextView offsetFromPosition:beginningOfDocument toPosition:downOne];
                                    it(@"should be", ^{
                                        [[@(downOneOffset) should] equal:@(31)];
                                    });
                                });
                                context(@"twice", ^{
                                    UITextPosition* downTwo = [loremTextView positionFromPosition:position inDirection:UITextLayoutDirectionDown offset:2];
                                    NSInteger downTwoOffset = [loremTextView offsetFromPosition:beginningOfDocument toPosition:downTwo];
                                    it(@"should be", ^{
                                        [[@(downTwoOffset) should] equal:@(40)];
                                    });
                                });
                                context(@"thrice", ^{
                                    UITextPosition* downThree = [loremTextView positionFromPosition:position inDirection:UITextLayoutDirectionDown offset:3];
                                    NSInteger downThreeOffset = [loremTextView offsetFromPosition:beginningOfDocument toPosition:downThree];
                                    it(@"should be", ^{
                                        [[@(downThreeOffset) should] equal:@(56)];
                                    });
                                });
                                context(@"four times", ^{
                                    UITextPosition* downFour = [loremTextView positionFromPosition:position inDirection:UITextLayoutDirectionDown offset:4];
                                    NSInteger downFourOffset = [loremTextView offsetFromPosition:beginningOfDocument toPosition:downFour];
                                    it(@"should be", ^{
                                        [[@(downFourOffset) should] equal:@([loremText length])];
                                    });
                                });
                            });
                        });
                        context(@"from one line down from second line", ^{
                            NSInteger startingIndex = 16;
                            NSInteger unitOffset = 1;
                            UITextPosition* prePosition = [loremTextView positionFromPosition:beginningOfDocument offset:startingIndex];
                            context(@"left", ^{
                                context(@"offset > 0", ^{
                                    UITextPosition* newPosition = [loremTextView positionFromPosition:prePosition inDirection:UITextLayoutDirectionLeft offset:unitOffset];
                                    NSInteger newIndex = [loremTextView offsetFromPosition:beginningOfDocument toPosition:newPosition];
                                    it(@"index should be < starting index", ^{
                                        [[@(newIndex) should] equal:@(startingIndex - unitOffset)];
                                    });
                                });
#if (!TARGET_IPHONE_SIMULATOR && !TARGET_IPHONE_DEVICE) // Bug: iOS version returns, but it takes *minutes*. (This test is in response to ticket #1549)
                                context(@"offset < 0", ^{
                                    UITextPosition* newPosition = [loremTextView positionFromPosition:prePosition inDirection:UITextLayoutDirectionLeft offset:-unitOffset];
                                    NSInteger newIndex = [loremTextView offsetFromPosition:beginningOfDocument toPosition:newPosition];
                                    it(@"index should be > starting index", ^{
                                        [[@(newIndex) should] equal:@(startingIndex + unitOffset)];
                                    });
                                });
#endif
                            });
                            context(@"right", ^{
                                context(@"offset > 0", ^{
                                    UITextPosition* newPosition = [loremTextView positionFromPosition:prePosition inDirection:UITextLayoutDirectionRight offset:unitOffset];
                                    NSInteger newIndex = [loremTextView offsetFromPosition:beginningOfDocument toPosition:newPosition];
                                    it(@"index should be < starting index", ^{
                                        [[@(newIndex) should] equal:@(startingIndex + unitOffset)];
                                    });
                                });
#if (!TARGET_IPHONE_SIMULATOR && !TARGET_IPHONE_DEVICE) // Bug: iOS version returns, but it takes *minutes*. (This test is in response to ticket #1549)
                                context(@"offset < 0", ^{
                                    UITextPosition* newPosition = [loremTextView positionFromPosition:prePosition inDirection:UITextLayoutDirectionRight offset:-unitOffset];
                                    NSInteger newIndex = [loremTextView offsetFromPosition:beginningOfDocument toPosition:newPosition];
                                    it(@"index should be > starting index", ^{
                                        [[@(newIndex) should] equal:@(startingIndex - unitOffset)];
                                    });
                                });
#endif
                            });
                            UITextPosition* position = [loremTextView positionFromPosition:prePosition inDirection:UITextLayoutDirectionDown offset:1];
                            context(@"up", ^{
                                context(@"twice", ^{
                                    UITextPosition* upTwo = [loremTextView positionFromPosition:position inDirection:UITextLayoutDirectionUp offset:2];
                                    NSInteger upTwoOffset = [loremTextView offsetFromPosition:beginningOfDocument toPosition:upTwo];
                                    it(@"should be", ^{
                                        [[@(upTwoOffset) should] equal:@(3)];
                                    });
                                });
                            });
                            prePosition = [loremTextView positionFromPosition:beginningOfDocument offset:30];
                            position = [loremTextView positionFromPosition:prePosition inDirection:UITextLayoutDirectionUp offset:1];
                            context(@"down", ^{
                                context(@"once", ^{
                                    UITextPosition* downOne = [loremTextView positionFromPosition:position inDirection:UITextLayoutDirectionDown offset:1];
                                    NSInteger downOneOffset = [loremTextView offsetFromPosition:beginningOfDocument toPosition:downOne];
                                    it(@"should be", ^{
                                        [[@(downOneOffset) should] equal:@(29)];
                                    });
                                });
                            });
                        });
                    });
                });
                context(@"positions given offsets", ^{
                    context(@"of zero from beginning", ^{
                        UITextPosition* beginningOfDocumentOffsetByZero = [textView positionFromPosition:beginningOfDocument offset:0];
                        it(@"should be beginning", ^{
                            [[@([textView comparePosition:beginningOfDocumentOffsetByZero toPosition:beginningOfDocument]) should] equal:@(NSOrderedSame)];
                        });
                    });
                    context(@"of text length from beginning", ^{
                        UITextPosition* beginningOfDocumentOffsetByTextLength = [textView positionFromPosition:beginningOfDocument offset:textLength];
                        it(@"should be end", ^{
                            [[@([textView comparePosition:beginningOfDocumentOffsetByTextLength toPosition:endOfDocument]) should] equal:@(NSOrderedSame)];
                        });
                    });
                    context(@"of zero from end", ^{
                        UITextPosition* endOfDocumentOffsetByZero = [textView positionFromPosition:endOfDocument offset:0];
                        it(@"should be end", ^{
                            [[@([textView comparePosition:endOfDocumentOffsetByZero toPosition:endOfDocument]) should] equal:@(NSOrderedSame)];
                        });
                    });
                    context(@"of -text length before end", ^{
                        UITextPosition* endOfDocumentOffsetByTextLength = [textView positionFromPosition:endOfDocument offset:-textLength];
                        it(@"should be beginning", ^{
                            [[@([textView comparePosition:endOfDocumentOffsetByTextLength toPosition:beginningOfDocument]) should] equal:@(NSOrderedSame)];
                        });
                    });
                });
                context(@"offsets from positions from offsets", ^{
                    context(@"of small offset after beginning", ^{
                        UITextPosition* beginningOfDocumentOffsetBySmallOffset = [textView positionFromPosition:beginningOfDocument offset:smallOffset];
                        NSInteger offsetBySmallOffsetFromBeginning = [textView offsetFromPosition:beginningOfDocument toPosition:beginningOfDocumentOffsetBySmallOffset];
                        it(@"should be small offset after beginning", ^{
                            [[@(offsetBySmallOffsetFromBeginning) should] equal:@(smallOffset)];
                        });
                        NSInteger offsetBySmallOffsetAfterBeginningFromEnd = [textView offsetFromPosition:endOfDocument toPosition:beginningOfDocumentOffsetBySmallOffset];
                        it(@"should be -text length + small offset from end", ^{
                            [[@(offsetBySmallOffsetAfterBeginningFromEnd) should] equal:@(smallOffset - textLength)];
                        });
                    });
                    context(@"of small offset before end", ^{
                        UITextPosition* endOfDocumentOffsetBySmallOffset = [textView positionFromPosition:endOfDocument offset:-smallOffset];
                        NSInteger offsetBySmallOffsetBeforeEnd = [textView offsetFromPosition:endOfDocument toPosition:endOfDocumentOffsetBySmallOffset];
                        it(@"should be small offset before end", ^{
                            [[@(offsetBySmallOffsetBeforeEnd) should] equal:@(-smallOffset)];
                        });
                        NSInteger offsetBySmallOffsetBeforeEndFromBeginning = [textView offsetFromPosition:beginningOfDocument toPosition:endOfDocumentOffsetBySmallOffset];
                        it(@"should be text length - small offset from beginning", ^{
                            [[@(offsetBySmallOffsetBeforeEndFromBeginning) should] equal:@(textLength - smallOffset)];
                        });
                    });
                });
            });
            
            context(@"Comparisons", ^{
                context(@"postitions", ^{
                    UITextPosition* beginningOfDocumentOffsetBySmallOffset = [textView positionFromPosition:beginningOfDocument offset:smallOffset];
                    UITextPosition* endOfDocumentOffsetBySmallOffset = [textView positionFromPosition:endOfDocument offset:-smallOffset];
                    context(@"beginning of document", ^{
                        context(@"when compared to end", ^{
                            it(@"should be <", ^{
                                [[@([textView comparePosition:beginningOfDocument toPosition:endOfDocument]) should] equal:@(NSOrderedAscending)];
                            });
                        });
                        context(@"when compared to beginning", ^{
                            it(@"should be =", ^{
                                [[@([textView comparePosition:beginningOfDocument toPosition:beginningOfDocument]) should] equal:@(NSOrderedSame)];
                            });
                        });
                        context(@"when compared to small offset after beginning", ^{
                            it(@"should be <", ^{
                                [[@([textView comparePosition:beginningOfDocument toPosition:beginningOfDocumentOffsetBySmallOffset]) should] equal:@(NSOrderedAscending)];
                            });
                        });
                        context(@"when compared to small offset before end", ^{
                            it(@"should be <", ^{
                                [[@([textView comparePosition:beginningOfDocument toPosition:endOfDocumentOffsetBySmallOffset]) should] equal:@(NSOrderedAscending)];
                            });
                        });
                    });
                    context(@"end of document", ^{
                        context(@"when compared to beginning", ^{
                            it(@"should be >", ^{
                                [[@([textView comparePosition:endOfDocument toPosition:beginningOfDocument]) should] equal:@(NSOrderedDescending)];
                            });
                        });
                        context(@"when compared to end", ^{
                            it(@"should be =", ^{
                                [[@([textView comparePosition:endOfDocument toPosition:endOfDocument]) should] equal:@(NSOrderedSame)];
                            });
                        });
                        context(@"when compared to small offset after beginning", ^{
                            it(@"should be <", ^{
                                [[@([textView comparePosition:endOfDocument toPosition:beginningOfDocumentOffsetBySmallOffset]) should] equal:@(NSOrderedDescending)];
                            });
                        });
                        context(@"when compared to small offset before end", ^{
                            it(@"should be <", ^{
                                [[@([textView comparePosition:endOfDocument toPosition:endOfDocumentOffsetBySmallOffset]) should] equal:@(NSOrderedDescending)];
                            });
                        });
                    });
                    context(@"small offset after beginning", ^{
                        context(@"when compared to beginning", ^{
                            it(@"should be >", ^{
                                [[@([textView comparePosition:beginningOfDocumentOffsetBySmallOffset toPosition:beginningOfDocument]) should] equal:@(NSOrderedDescending)];
                            });
                        });
                        context(@"when compared to end", ^{
                            it(@"should be =", ^{
                                [[@([textView comparePosition:beginningOfDocumentOffsetBySmallOffset toPosition:endOfDocument]) should] equal:@(NSOrderedAscending)];
                            });
                        });
                        context(@"when compared to small offset after beginning", ^{
                            it(@"should be <", ^{
                                [[@([textView comparePosition:beginningOfDocumentOffsetBySmallOffset toPosition:beginningOfDocumentOffsetBySmallOffset]) should] equal:@(NSOrderedSame)];
                            });
                        });
                        context(@"when compared to small offset before end", ^{
                            it(@"should be <", ^{
                                [[@([textView comparePosition:beginningOfDocumentOffsetBySmallOffset toPosition:endOfDocumentOffsetBySmallOffset]) should] equal:@(NSOrderedAscending)];
                            });
                        });
                    });
                    context(@"small offset before end", ^{
                        context(@"when compared to beginning", ^{
                            it(@"should be >", ^{
                                [[@([textView comparePosition:endOfDocumentOffsetBySmallOffset toPosition:beginningOfDocument]) should] equal:@(NSOrderedDescending)];
                            });
                        });
                        context(@"when compared to end", ^{
                            it(@"should be =", ^{
                                [[@([textView comparePosition:endOfDocumentOffsetBySmallOffset toPosition:endOfDocument]) should] equal:@(NSOrderedAscending)];
                            });
                        });
                        context(@"when compared to small offset after beginning", ^{
                            it(@"should be <", ^{
                                [[@([textView comparePosition:endOfDocumentOffsetBySmallOffset toPosition:beginningOfDocumentOffsetBySmallOffset]) should] equal:@(NSOrderedDescending)];
                            });
                        });
                        context(@"when compared to small offset before end", ^{
                            it(@"should be <", ^{
                                [[@([textView comparePosition:endOfDocumentOffsetBySmallOffset toPosition:endOfDocumentOffsetBySmallOffset]) should] equal:@(NSOrderedSame)];
                            });
                        });
                    });
                });
            });
        });

        context(@"Text Ranges", ^{
            UITextView* textView = [[UITextView alloc] initWithFrame:(CGRect){ .size = { 100, 100 } }];
            [textView setText:text];
            UITextPosition* beginningOfDocument = [textView beginningOfDocument];
            UITextPosition* endOfDocument = [textView endOfDocument];
            UITextRange* entireTextRange = [textView textRangeFromPosition:beginningOfDocument toPosition:endOfDocument];
            context(@"-textRangeFromPosition:toPosition:", ^{
                context(@"when given beginning and end of document", ^{
                    it(@"returns an object", ^{
                        [[entireTextRange should] beNonNil];
                    });
                    it(@"returns an instance of UITextRange", ^{
                        [[entireTextRange should] beKindOfClass:[UITextRange class]];
                    });
                    it(@"has a start property equal to beginningOfDocument", ^{
                        [[[entireTextRange start] should] equal:beginningOfDocument];
                    });
                    it(@"has an end property equal to endOfDocument", ^{
                        [[[entireTextRange end] should] equal:endOfDocument];
                    });
                });
            });

            context(@"Measurements", ^{
            });
            
            context(@"Comparisons", ^{
            });
        });
    });
});
SPEC_END