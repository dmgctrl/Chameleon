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
                it(@"should have max location and zero size", ^{
                    NSRange selectedRange = [textView selectedRange];
                    [[@(NSEqualRanges(selectedRange, NSMakeRange(NSIntegerMax, 0))) should] beYes];
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
        context(@"unselected", ^{
            UITextView* textView = [[UITextView alloc] initWithFrame:(CGRect){ .size = { 100, 100 } }];
            [textView setText:text];
            beforeEach(^{
                [textView setSelectedRange:NSMakeRange(0, 0)];
            });
            
            context(@"-beginningOfDocument", ^{
                UITextPosition* position = [textView beginningOfDocument];
                it(@"returns a value", ^{
                    [[position should] beNonNil];
                });
            });

            context(@"-endOfDocument", ^{
                UITextPosition* position = [textView endOfDocument];
                it(@"returns a value", ^{
                    [[position should] beNonNil];
                });
            });

            context(@"-textInRange", ^{
                [textView setSelectedTextRange:[textView textRangeFromPosition:[textView beginningOfDocument] toPosition:[textView beginningOfDocument]]];
                it(@"should be empty", ^{
                    [[@([[textView selectedTextRange] isEmpty]) should] beYes];
                });
            });
        });

        context(@"of fully selected", ^{
            UITextView* textView = [[UITextView alloc] initWithFrame:(CGRect){ .size = { 100, 100 } }];
            [textView setText:text];
            
            UITextRange* fullTextRange = [textView textRangeFromPosition:[textView beginningOfDocument] toPosition:[textView endOfDocument]];
            [textView setSelectedTextRange:fullTextRange];
            UITextPosition* start = [[textView selectedTextRange] start];
            UITextPosition* end = [[textView selectedTextRange] end];
            [textView setMarkedText:text selectedRange:NSMakeRange(0, [text length])];
            NSString* fullText = [textView textInRange:fullTextRange];
            NSLog(@"asd");
            context(@"selected range when set to full", ^{
                it(@"should not be empty", ^{
                    [[@([fullTextRange isEmpty]) should] beYes];
                });
            });
            
            context(@"-textInRange", ^{
                it(@"should be text if range is entire", ^{
                    [[@([fullText isEqualToString:text]) should] beYes];
                });
            });

            context(@"-replaceRange:withText", ^{
                [textView replaceRange:fullTextRange withText:text];
                it(@"should work ", ^{
                    [[@([fullText isEqualToString:text]) should] beYes];
                });
                [textView setSelectedTextRange:fullTextRange];
            });
            
            context(@"marked vs selected text range", ^{
                it(@"can be made consistent", ^{
                    [[@([textView comparePosition:[[textView markedTextRange]end] toPosition:end]) should] equal:@(NSOrderedSame)];
                });
            });

            context(@"-comparePositionToPosition", ^{
                it(@"should have start < end", ^{
                    [[@([textView comparePosition:start toPosition:end]) should] equal:@(NSOrderedAscending)];
                });
            });
            
            context(@"-offestFromPositionToPosition", ^{
                [[@([textView offsetFromPosition:start toPosition:end]) should] equal:@([text length])];
            });
        });
    });
});
SPEC_END