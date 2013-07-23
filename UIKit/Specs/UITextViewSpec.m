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