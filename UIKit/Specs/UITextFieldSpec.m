SPEC_BEGIN(UITextFieldSpec)
describe(@"UITextField", ^{

    context(@"default properties", ^{
    
        UITextField* textField = [[UITextField alloc] init];
        
        context(@"text", ^{
            it(@"should be nil", ^{
                [[[textField text] should] beNil];
            });
        });
    
        context(@"attributedText", ^{
            it(@"should be nil", ^{
                [[[textField attributedText] should] beNil];
            });
        });

        context(@"placeholder", ^{
            //More tests: default color should be 70% gray
            it(@"should be nil", ^{
                [[[textField placeholder] should] beNil];
            });
        });
        
        context(@"attributedPlaceholder", ^{
            //More tests: default color should be 70% gray
            it(@"should be nil", ^{
                [[[textField attributedPlaceholder] should] beNil];
            });
        });
        
        context(@"font", ^{
            it(@"should be sytem font with label size", ^{
                [[[textField font] should] equal:[UIFont systemFontOfSize:[UIFont labelFontSize]]];
            });
        });
        
        context(@"textColor", ^{
            // More tests:
            // if set to nil should raise an exception
            it(@"should be black", ^{
                [[[textField textColor] should] equal:[UIColor blackColor]];
            });
        });
        
        context(@"textAlignment", ^{
            it(@"should be left", ^{
                [[@([textField textAlignment]) should] equal:@(UITextAlignmentLeft)];//Deprecated use NSTextAlignment
            });
        });
        
        context(@"typingAttributes", ^{
            it(@"should be nil", ^{
                [[[textField typingAttributes] should] beNil];
            });
        });
        
        context(@"adjustsFontSizeToFitWidth", ^{
            it(@"should be no", ^{
                [[@([textField adjustsFontSizeToFitWidth]) should] beNo];
            });
        });
        
        context(@"minimumFontSize", ^{
            it(@"should be 0", ^{
                [[@([textField minimumFontSize]) should] equal:0.0 withDelta:0.00001];
            });
        });
        
        context(@"editing", ^{
            it(@"should be no", ^{
                [[@([textField isEditing]) should] beNo];
            });
        });
        
        context(@"clearsOnBeginEditing", ^{
            it(@"should be no", ^{
                [[@([textField clearsOnBeginEditing]) should] beNo];
            });
        });
        
        context(@"clearsOnInsertion", ^{
            it(@"should be no", ^{
                [[@([textField clearsOnInsertion]) should] beNo];
            });
        });
        
        context(@"allowsEditingTextAttributes", ^{
            it(@"should be No", ^{
                [[@([textField allowsEditingTextAttributes]) should] beNo];
            });
        });
        
        context(@"borderStyle", ^{
            it(@"should be none", ^{
                [[@([textField borderStyle]) should] equal:@(UITextBorderStyleNone)];
            });
        });
        
        context(@"background", ^{
            it(@"should be nil", ^{
                [[[textField background] should] beNil];
            });
        });
        
        context(@"disabledBackground", ^{
            it(@"should be nil", ^{
                [[[textField disabledBackground] should] beNil];
            });
        });
        
        context(@"clearButtonMode", ^{
            it(@"should be Never", ^{
                [[@([textField clearButtonMode]) should] equal:@(UITextFieldViewModeNever)];
            });
        });
        
        context(@"leftView", ^{
            it(@"should be nil", ^{
                [[[textField leftView] should] beNil];
            });
        });
        
        context(@"leftViewMode", ^{
            it(@"should be Never", ^{
                [[@([textField leftViewMode]) should] equal:@(UITextFieldViewModeNever)];
            });
        });
        
        context(@"rightView", ^{
            it(@"should be nil", ^{
                [[[textField rightView] should] beNil];
            });
        });
        
        context(@"rightViewMode", ^{
            it(@"should be Never", ^{
                [[@([textField rightViewMode]) should] equal:@(UITextFieldViewModeNever)];
            });
        });

        context(@"delegate", ^{
            it(@"should be nil", ^{
                [[(NSObject*)[textField delegate] should] beNil];
            });
        });
        
        context(@"inputView", ^{
            it(@"should be nil", ^{
                [[[textField inputView] should] beNil];
            });
        });
        
        context(@"inputAccessoryView", ^{
            it(@"should be nil", ^{
                [[[textField inputAccessoryView] should] beNil];
            });
        });
    });
    context(@"with text of type", ^{
        NSString* string = @"The quick brown \nfox jumped over the lazy \ndog.";
        NSString* stringSubstitutingSpaceForLineBreak = @"The quick brown  fox jumped over the lazy  dog.";
        NSAttributedString* attributedString = [[NSAttributedString alloc] initWithString:string];
        NSAttributedString* attributedStringSubstitutingSpaceForLineBreak = [[NSAttributedString alloc] initWithString:stringSubstitutingSpaceForLineBreak];

        context(@"attributedText", ^{
            __block UITextField* textField;
            beforeEach(^{
                textField = [[UITextField alloc] init];
                [textField setAttributedText:attributedString];
            });
            it(@"has similar text. space substitutes for linebreak", ^{
                [[[textField text] should] equal:stringSubstitutingSpaceForLineBreak];
            });
            context(@"when scaled", ^{
                it(@"should be same", ^{
                    [textField setAdjustsFontSizeToFitWidth:YES];
                    [[[textField attributedText] should] equal:attributedStringSubstitutingSpaceForLineBreak];
                });
            });

            context(@"with minimumFontSize", ^{
                beforeEach(^{
                    [textField setMinimumFontSize:11];
                });
                it(@"can setFont lower", ^{
                    UIFont *font = [UIFont fontWithName:@"Times" size:(CGFloat)10.0];
                    [textField setFont:font];
                    [[[textField font]should ] equal:font];
                });
            });
            
            context(@"TextAlignment", ^{
                beforeEach(^{
                    [textField setTextAlignment:UITextAlignmentCenter];
                });
                it(@"should set", ^{
                    [[@([textField textAlignment]) should] equal:@(UITextAlignmentCenter)];
                });
            });
            
            context(@"TextColor", ^{
                beforeEach(^{
                    [textField setTextColor:[UIColor purpleColor]];
                });
                it(@"should set", ^{
                    [[[textField textColor] should] equal:[UIColor purpleColor]];
                });
            });
        });
        
        context(@"attributedPlaceholder", ^{
            UITextField* textField = [[UITextField alloc] init];
            [textField setAttributedPlaceholder:attributedString];
            it(@"should set placeholder", ^{
                [[[textField placeholder] should]equal:string];
            });
        });
        
        context(@"plain", ^{
            __block UITextField* textField;
            beforeEach(^{
                textField = [[UITextField alloc] init];
                [textField setText:string];
            });
            it(@"should set", ^{
                [[[textField text] should] equal:string];
            });
            
            context(@"when scaled", ^{
                it(@"should be same", ^{
                    [textField setAdjustsFontSizeToFitWidth:YES];
                    [[[textField text] should] equal:string];
                });
            });
        });
    });
});
SPEC_END