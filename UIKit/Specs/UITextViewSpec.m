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
                    context(@"of 5 after beginning", ^{
                        UITextPosition* beginningOfDocumentOffsetByFive = [textView positionFromPosition:beginningOfDocument offset:5];
                        NSInteger offsetByFiveFromBeginning = [textView offsetFromPosition:beginningOfDocument toPosition:beginningOfDocumentOffsetByFive];
                        it(@"should be 5 after beginning", ^{
                            [[@(offsetByFiveFromBeginning) should] equal:@(5)];
                        });
                    });
                    context(@"of 5 before end", ^{
                        UITextPosition* endOfDocumentOffsetByFive = [textView positionFromPosition:endOfDocument offset:-5];
                        NSInteger offsetByFiveFromEnd = [textView offsetFromPosition:endOfDocument toPosition:endOfDocumentOffsetByFive];
                        it(@"should be 5 before end", ^{
                            [[@(offsetByFiveFromEnd) should] equal:@(-5)];
                        });
                    });
                });
            });
            
            context(@"Comparisons", ^{
                context(@"postitions", ^{
                    UITextPosition* beginningOfDocumentOffsetByFive = [textView positionFromPosition:beginningOfDocument offset:5];
                    UITextPosition* endOfDocumentOffsetByFive = [textView positionFromPosition:endOfDocument offset:-5];
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
                        context(@"when compared to five after beginning", ^{
                            it(@"should be <", ^{
                                [[@([textView comparePosition:beginningOfDocument toPosition:beginningOfDocumentOffsetByFive]) should] equal:@(NSOrderedAscending)];
                            });
                        });
                        context(@"when compared to five before end", ^{
                            it(@"should be <", ^{
                                [[@([textView comparePosition:beginningOfDocument toPosition:endOfDocumentOffsetByFive]) should] equal:@(NSOrderedAscending)];
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
                        context(@"when compared to five after beginning", ^{
                            it(@"should be <", ^{
                                [[@([textView comparePosition:endOfDocument toPosition:beginningOfDocumentOffsetByFive]) should] equal:@(NSOrderedDescending)];
                            });
                        });
                        context(@"when compared to five before end", ^{
                            it(@"should be <", ^{
                                [[@([textView comparePosition:endOfDocument toPosition:endOfDocumentOffsetByFive]) should] equal:@(NSOrderedDescending)];
                            });
                        });
                    });
                    context(@"5 after beginning", ^{
                        context(@"when compared to beginning", ^{
                            it(@"should be >", ^{
                                [[@([textView comparePosition:beginningOfDocumentOffsetByFive toPosition:beginningOfDocument]) should] equal:@(NSOrderedDescending)];
                            });
                        });
                        context(@"when compared to end", ^{
                            it(@"should be =", ^{
                                [[@([textView comparePosition:beginningOfDocumentOffsetByFive toPosition:endOfDocument]) should] equal:@(NSOrderedAscending)];
                            });
                        });
                        context(@"when compared to five after beginning", ^{
                            it(@"should be <", ^{
                                [[@([textView comparePosition:beginningOfDocumentOffsetByFive toPosition:beginningOfDocumentOffsetByFive]) should] equal:@(NSOrderedSame)];
                            });
                        });
                        context(@"when compared to 5 before end", ^{
                            it(@"should be <", ^{
                                [[@([textView comparePosition:beginningOfDocumentOffsetByFive toPosition:endOfDocumentOffsetByFive]) should] equal:@(NSOrderedAscending)];
                            });
                        });
                    });
                    context(@"5 before end", ^{
                        context(@"when compared to beginning", ^{
                            it(@"should be >", ^{
                                [[@([textView comparePosition:endOfDocumentOffsetByFive toPosition:beginningOfDocument]) should] equal:@(NSOrderedDescending)];
                            });
                        });
                        context(@"when compared to end", ^{
                            it(@"should be =", ^{
                                [[@([textView comparePosition:endOfDocumentOffsetByFive toPosition:endOfDocument]) should] equal:@(NSOrderedAscending)];
                            });
                        });
                        context(@"when compared to five after beginning", ^{
                            it(@"should be <", ^{
                                [[@([textView comparePosition:endOfDocumentOffsetByFive toPosition:beginningOfDocumentOffsetByFive]) should] equal:@(NSOrderedDescending)];
                            });
                        });
                        context(@"when compared to 5 before end", ^{
                            it(@"should be <", ^{
                                [[@([textView comparePosition:endOfDocumentOffsetByFive toPosition:endOfDocumentOffsetByFive]) should] equal:@(NSOrderedSame)];
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