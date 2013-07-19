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
                    [[@(NSEqualRanges(selectedRange, NSMakeRange(NSIntegerMax, 0))) should]beYes];
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
        
        context(@"", ^{
            NSArray* subviews = [textView subviews];
            NSLog(@"%@", subviews);
        });
    });
});
SPEC_END