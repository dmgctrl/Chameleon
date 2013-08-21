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
        NSInteger mediumOffset = 16;
        NSInteger unitOffset = 1;
        NSString* loremText = @"Lorem ipsum dolor sit er elit lamet, consectetaur cillium";
        UITextView* loremTextView = [[UITextView alloc] initWithFrame:(CGRect){ .size = { 100, 100 } }];
        [loremTextView setFont:[UIFont systemFontOfSize:14]];
        [loremTextView setText:loremText];

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
                        UITextPosition* beginningOfDocument = [loremTextView beginningOfDocument];
                        context(@"from given position on second line", ^{
                            UITextPosition* position = [loremTextView positionFromPosition:beginningOfDocument offset:mediumOffset];
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
                            UITextPosition* prePosition = [loremTextView positionFromPosition:beginningOfDocument offset:mediumOffset];
                            context(@"left", ^{
                                context(@"offset > 0", ^{
                                    UITextPosition* newPosition = [loremTextView positionFromPosition:prePosition inDirection:UITextLayoutDirectionLeft offset:unitOffset];
                                    NSInteger newIndex = [loremTextView offsetFromPosition:beginningOfDocument toPosition:newPosition];
                                    it(@"index should be < starting index", ^{
                                        [[@(newIndex) should] equal:@(mediumOffset - unitOffset)];
                                    });
                                });
#if (!TARGET_IPHONE_SIMULATOR && !TARGET_IPHONE_DEVICE) // Bug: iOS version returns, but it takes *minutes*. (This test is in response to ticket #1549)
                                context(@"offset < 0", ^{
                                    UITextPosition* newPosition = [loremTextView positionFromPosition:prePosition inDirection:UITextLayoutDirectionLeft offset:-unitOffset];
                                    NSInteger newIndex = [loremTextView offsetFromPosition:beginningOfDocument toPosition:newPosition];
                                    it(@"index should be > starting index", ^{
                                        [[@(newIndex) should] equal:@(mediumOffset + unitOffset)];
                                    });
                                });
#endif
                            });
                            context(@"right", ^{
                                context(@"offset > 0", ^{
                                    UITextPosition* newPosition = [loremTextView positionFromPosition:prePosition inDirection:UITextLayoutDirectionRight offset:unitOffset];
                                    NSInteger newIndex = [loremTextView offsetFromPosition:beginningOfDocument toPosition:newPosition];
                                    it(@"index should be < starting index", ^{
                                        [[@(newIndex) should] equal:@(mediumOffset + unitOffset)];
                                    });
                                });
#if (!TARGET_IPHONE_SIMULATOR && !TARGET_IPHONE_DEVICE) // Bug: iOS version returns, but it takes *minutes*. (This test is in response to ticket #1549)
                                context(@"offset < 0", ^{
                                    UITextPosition* newPosition = [loremTextView positionFromPosition:prePosition inDirection:UITextLayoutDirectionRight offset:-unitOffset];
                                    NSInteger newIndex = [loremTextView offsetFromPosition:beginningOfDocument toPosition:newPosition];
                                    it(@"index should be > starting index", ^{
                                        [[@(newIndex) should] equal:@(mediumOffset - unitOffset)];
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

                context(@"with direction to without", ^{
                    UITextPosition* beginningOfDocument = [loremTextView beginningOfDocument];
                    UITextPosition* position = [loremTextView positionFromPosition:beginningOfDocument offset:mediumOffset];
                    context(@"right", ^{
                        UITextPosition* positionOneToRight = [loremTextView positionFromPosition:position inDirection:UITextLayoutDirectionRight offset:unitOffset];
                        UITextPosition* positionPlusOne = [loremTextView positionFromPosition:position offset:unitOffset];
                        it(@"should be same", ^{
                            [[@([loremTextView comparePosition:positionOneToRight toPosition:positionPlusOne]) should] equal:@(NSOrderedSame)];
                        });
                    });
                    context(@"left", ^{
                        UITextPosition* positionOneToLeft = [loremTextView positionFromPosition:position inDirection:UITextLayoutDirectionLeft offset:unitOffset];
                        UITextPosition* positionMinusOne = [loremTextView positionFromPosition:position offset:-unitOffset];
                        it(@"should be same", ^{
                            [[@([loremTextView comparePosition:positionOneToLeft toPosition:positionMinusOne]) should] equal:@(NSOrderedSame)];
                        });
                    });
                });
            });

            context(@"from point", ^{
                context(@"not considering range", ^{
                    UITextPosition* beginningOfLoremText = [loremTextView beginningOfDocument];
                    context(@"origin", ^{
                        UITextPosition* postitionClosestToOrigin = [loremTextView closestPositionToPoint:CGPointZero];
                        it(@"should be beginning of document", ^{
                            [[@([loremTextView comparePosition:postitionClosestToOrigin toPosition:beginningOfLoremText]) should] equal:@(NSOrderedSame)];
                        });
                    });
                    context(@"far corner", ^{
                        UITextPosition* endOfLoremText = [loremTextView endOfDocument];
                        UITextPosition* postitionClosestToFarCorner = [loremTextView closestPositionToPoint:CGPointMake(100, 100)];
                        it(@"should be end of document", ^{
                            [[@([loremTextView comparePosition:postitionClosestToFarCorner toPosition:endOfLoremText]) should] equal:@(NSOrderedSame)];
                        });
                    });
                    context(@"center", ^{
                        UITextPosition* truePositionAtCenter = [loremTextView positionFromPosition:beginningOfLoremText offset:33];
                        UITextPosition* positionClosestToCenter = [loremTextView closestPositionToPoint:[loremTextView center]];
                        it(@"should be near middle of document", ^{
                            [[@([loremTextView comparePosition:positionClosestToCenter toPosition:truePositionAtCenter]) should] equal:@(NSOrderedSame)];
                        });
                    });
                });
                context(@"considering partial range", ^{
                    UITextPosition* beginningOfLoremText = [loremTextView beginningOfDocument];
                    UITextPosition* beginningOfSampleRange = [loremTextView positionFromPosition:beginningOfLoremText offset:12];
                    UITextPosition* endOfSampleRange = [loremTextView positionFromPosition:beginningOfLoremText offset:28];
                    UITextRange* sampleRange = [loremTextView textRangeFromPosition:beginningOfSampleRange toPosition:endOfSampleRange];
                    context(@"before range,", ^{
                        UITextPosition* positionInSampleRangeClosestToOrigin = [loremTextView closestPositionToPoint:CGPointZero withinRange:sampleRange];
                        it(@"should be beginning of that range", ^{
                            [[@([loremTextView comparePosition:positionInSampleRangeClosestToOrigin toPosition:beginningOfSampleRange]) should] equal:@(NSOrderedSame)];
                        });
                    });
                    context(@"after range,", ^{
                        UITextPosition* postionInSampleRangeClosestToFarCorner = [loremTextView closestPositionToPoint:CGPointMake(100, 100) withinRange:sampleRange];
                        it(@"should be end of that range", ^{
                            [[@([loremTextView comparePosition:postionInSampleRangeClosestToFarCorner toPosition:endOfSampleRange]) should] equal:@(NSOrderedSame)];
                        });
                    });
                    context(@"point within range", ^{
                        CGRect sampleRect = [loremTextView firstRectForRange:sampleRange];
                        CGPoint pointAtCenterOfSampleRange = CGPointMake(sampleRect.origin.x + sampleRect.size.width/2.0, sampleRect.origin.y + sampleRect.size.height/2.0);
                        UITextPosition* truePositionInSampleRangeClosestToCenterOfSampleRange = [loremTextView positionFromPosition:beginningOfLoremText offset:17];
                        UITextPosition* positionInSampleRangeClosestToCenterOfSampleRange = [loremTextView closestPositionToPoint:pointAtCenterOfSampleRange withinRange:sampleRange];
                        it(@"should be position somewhere within range", ^{
                            [[@([loremTextView comparePosition:positionInSampleRangeClosestToCenterOfSampleRange toPosition:truePositionInSampleRangeClosestToCenterOfSampleRange]) should] equal:@(NSOrderedSame)];
                        });
                    });
                });
            });

            context(@"text direction", ^{
                context(@"beginning of document", ^{
                    context(@"forward text storage", ^{
                        it(@"should be l-to-r", ^{
                            [[@([textView baseWritingDirectionForPosition:beginningOfDocument inDirection:UITextStorageDirectionForward]) should] equal:@(UITextWritingDirectionLeftToRight)];
                        });
                    });
                    context(@"reverse text storage", ^{
                        it(@"should be l-to-r", ^{
                            [[@([textView baseWritingDirectionForPosition:beginningOfDocument inDirection:UITextStorageDirectionBackward]) should] equal:@(UITextWritingDirectionLeftToRight)];
                        });
                    });
                });
                context(@"end of document", ^{
                    context(@"forward text storage", ^{
                        it(@"should be l-to-r", ^{
                            [[@([textView baseWritingDirectionForPosition:endOfDocument inDirection:UITextStorageDirectionForward]) should] equal:@(UITextWritingDirectionLeftToRight)];
                        });
                    });
                    context(@"reverse text storage", ^{
                        it(@"should be l-to-r", ^{
                            [[@([textView baseWritingDirectionForPosition:endOfDocument inDirection:UITextStorageDirectionBackward]) should] equal:@(UITextWritingDirectionLeftToRight)];
                        });
                    });
                });
                context(@"at medium offset", ^{
                    UITextPosition* position = [textView positionFromPosition:beginningOfDocument offset:mediumOffset];
                    context(@"forward text storage", ^{
                        it(@"should be l-to-r", ^{
                            [[@([textView baseWritingDirectionForPosition:position inDirection:UITextStorageDirectionForward]) should] equal:@(UITextWritingDirectionLeftToRight)];
                        });
                    });
                    context(@"reverse text storage", ^{
                        it(@"should be l-to-r", ^{
                            [[@([textView baseWritingDirectionForPosition:position inDirection:UITextStorageDirectionBackward]) should] equal:@(UITextWritingDirectionLeftToRight)];
                        });
                    });
                });
            });
        });

        context(@"Composed characters", ^{
            NSString* composedText = @"0e\u030A3e\u030A6e\u030A9e\u030A2e\u030A";
            // |0|1,2|3|4,5|6|7,8|9|10,11|12|13,14 character index
            // |0|eo |3|eo |6|eo |9|eo   |2 |eo    character (ignore space and |)
            // |0|e̊  |3|e̊  |6|e̊  |9|e̊    |2 |e̊     glyph (ignore space and |)
            // |0|1  |2|3  |4|5  |6|7    |8 |9     glyph index
            UITextView* composedTextView = [[UITextView alloc] initWithFrame:(CGRect){ .size = { 100, 100 } }];
            [composedTextView setText:composedText];
            [composedTextView setFont:[UIFont systemFontOfSize:14]];
            NSInteger tinyOffset = 2;
            UITextPosition* beginningOfDocument = [composedTextView beginningOfDocument];
            UITextPosition* endOfDocument = [composedTextView endOfDocument];
            UITextPosition* prePosition = [composedTextView positionFromPosition:beginningOfDocument offset:smallOffset];
            NSInteger preIndex = [composedTextView offsetFromPosition:beginningOfDocument toPosition:prePosition];
            context(@"positions", ^{
                context(@"measurements", ^{
                    context(@"positive", ^{
                        it(@"should start at correct character index", ^{
                            [[@(preIndex) should] equal:@(7)];
                        });
                        UITextPosition* position = [composedTextView positionFromPosition:prePosition offset:tinyOffset];
                        context(@"positions from offsets", ^{
                            UITextPosition* positionFromBeginning = [composedTextView positionFromPosition:beginningOfDocument offset:(smallOffset + tinyOffset)];
                            it(@"should be correct", ^{
                                [[@([composedTextView comparePosition:position toPosition:positionFromBeginning]) should] equal:@(NSOrderedSame)];
                            });
                        });
                        context(@"offsets from position", ^{
                            NSInteger positionIndex = [composedTextView offsetFromPosition:beginningOfDocument toPosition:position];
                            it(@"should be sum of start and offset", ^{
                                [[@(positionIndex) should] equal:@(10)];
                            });
                        });
                    });
                    context(@"negative", ^{
                        UITextPosition* position = [composedTextView positionFromPosition:prePosition offset:-tinyOffset];
                        context(@"positions from offsets", ^{
                            UITextPosition* positionFromBeginning = [composedTextView positionFromPosition:beginningOfDocument offset:(smallOffset - tinyOffset)];
                            it(@"should be correct", ^{
                                [[@([composedTextView comparePosition:position toPosition:positionFromBeginning]) should] equal:@(NSOrderedSame)];
                            });
                        });
                        context(@"offsets from position", ^{
                            NSInteger positionIndex = [composedTextView offsetFromPosition:beginningOfDocument toPosition:position];
                            it(@"should be sum of start and offset", ^{
                                [[@(positionIndex) should] equal:@(4)];
                            });
                        });
                    });
                });
#if (TARGET_IPHONE_SIMULATOR || TARGET_IPHONE_DEVICE) //remove once characterRangeByExtendingPostion:inDirection implemented for UIKit
                context(@"characterRangeByExtendingPostion:inDirection", ^{
                    context(@"for composed character in middle", ^{
                        UITextPosition* position = [composedTextView positionFromPosition:beginningOfDocument offset:3];
                        UITextPosition* postPosition = [composedTextView positionFromPosition:beginningOfDocument offset:4];
                        context(@"right", ^{
                            UITextRange* rangeExtendedRight = [composedTextView characterRangeByExtendingPosition:position inDirection:UITextLayoutDirectionRight];
                            context(@"start", ^{
                                it(@"should = position", ^{
                                    [[@([composedTextView comparePosition:[rangeExtendedRight start] toPosition:position]) should] equal:@(NSOrderedSame)];
                                });
                            });
                            context(@"end", ^{
                                it(@"should = position + 1", ^{
                                    [[@([composedTextView comparePosition:[rangeExtendedRight end] toPosition:postPosition]) should] equal:@(NSOrderedSame)];
                                });
                            });
                        });
                        context(@"left", ^{
                            UITextRange* rangeExtendedLeft = [composedTextView characterRangeByExtendingPosition:position inDirection:UITextLayoutDirectionLeft];
                            context(@"start", ^{
                                it(@"should = position", ^{
                                    [[@([composedTextView comparePosition:[rangeExtendedLeft start] toPosition:position]) should] equal:@(NSOrderedSame)];
                                });
                            });
                            context(@"end", ^{
                                it(@"should = position + 1", ^{
                                    [[@([composedTextView comparePosition:[rangeExtendedLeft end] toPosition:postPosition]) should] equal:@(NSOrderedSame)];
                                });
                            });
                        });
                        context(@"up", ^{
                            UITextRange* rangeExtendedUp = [composedTextView characterRangeByExtendingPosition:position inDirection:UITextLayoutDirectionUp];
                            context(@"start", ^{
                                it(@"should = position", ^{
                                    [[@([composedTextView comparePosition:[rangeExtendedUp start] toPosition:position]) should] equal:@(NSOrderedSame)];
                                });
                            });
                            context(@"end", ^{
                                it(@"should = position + 1", ^{
                                    [[@([composedTextView comparePosition:[rangeExtendedUp end] toPosition:postPosition]) should] equal:@(NSOrderedSame)];
                                });
                            });
                        });
                        context(@"down", ^{
                            UITextRange* rangeExtendedDown = [composedTextView characterRangeByExtendingPosition:position inDirection:UITextLayoutDirectionDown];
                            context(@"start", ^{
                                it(@"should = position", ^{
                                    [[@([composedTextView comparePosition:[rangeExtendedDown start] toPosition:position]) should] equal:@(NSOrderedSame)];
                                });
                            });
                            context(@"end", ^{
                                it(@"should = position + 1", ^{
                                    [[@([composedTextView comparePosition:[rangeExtendedDown end] toPosition:postPosition]) should] equal:@(NSOrderedSame)];
                                });
                            });
                        });
                    });
                    context(@"beginning of document", ^{
                        UITextPosition* unitPosition = [composedTextView positionFromPosition:beginningOfDocument offset:1];
                        context(@"right", ^{
                            UITextRange* rangeExtendedRight = [composedTextView characterRangeByExtendingPosition:beginningOfDocument inDirection:UITextLayoutDirectionRight];
                            context(@"start", ^{
                                it(@"should = beginning of document", ^{
                                    [[@([composedTextView comparePosition:[rangeExtendedRight start] toPosition:beginningOfDocument]) should] equal:@(NSOrderedSame)];
                                });
                            });
                            context(@"end", ^{
                                it(@"should = to second position", ^{
                                    [[@([composedTextView comparePosition:[rangeExtendedRight end] toPosition:unitPosition]) should] equal:@(NSOrderedSame)];
                                });
                            });
                        });
                        context(@"left", ^{
                            UITextRange* rangeExtendedLeft = [composedTextView characterRangeByExtendingPosition:beginningOfDocument inDirection:UITextLayoutDirectionLeft];
                            context(@"start", ^{
                                it(@"should = beginning of document", ^{
                                    [[@([composedTextView comparePosition:[rangeExtendedLeft start] toPosition:beginningOfDocument]) should] equal:@(NSOrderedSame)];
                                });
                            });
                            context(@"end", ^{
                                it(@"should = to second position", ^{
                                    [[@([composedTextView comparePosition:[rangeExtendedLeft end] toPosition:unitPosition]) should] equal:@(NSOrderedSame)];
                                });
                            });
                        });
                        context(@"up", ^{
                            UITextRange* rangeExtendedUp = [composedTextView characterRangeByExtendingPosition:beginningOfDocument inDirection:UITextLayoutDirectionUp];
                            context(@"start", ^{
                                it(@"should = beginning of document", ^{
                                    [[@([composedTextView comparePosition:[rangeExtendedUp start] toPosition:beginningOfDocument]) should] equal:@(NSOrderedSame)];
                                });
                            });
                            context(@"end", ^{
                                it(@"should = to second position", ^{
                                    [[@([composedTextView comparePosition:[rangeExtendedUp end] toPosition:unitPosition]) should] equal:@(NSOrderedSame)];
                                });
                            });
                        });
                        context(@"down", ^{
                            UITextRange* rangeExtendedDown = [composedTextView characterRangeByExtendingPosition:beginningOfDocument inDirection:UITextLayoutDirectionDown];
                            context(@"start", ^{
                                it(@"should = to beginning of document", ^{
                                    [[@([composedTextView comparePosition:[rangeExtendedDown start] toPosition:beginningOfDocument]) should] equal:@(NSOrderedSame)];
                                });
                            });
                            context(@"end", ^{
                                it(@"should = to second position", ^{
                                    [[@([composedTextView comparePosition:[rangeExtendedDown end] toPosition:unitPosition]) should] equal:@(NSOrderedSame)];
                                });
                            });
                        });
                    });
                    context(@"end of document", ^{
                        UITextPosition* penultimatePosition = [composedTextView positionFromPosition:endOfDocument offset:-1];
                        context(@"right", ^{
                            UITextRange* rangeExtendedRight = [composedTextView characterRangeByExtendingPosition:endOfDocument inDirection:UITextLayoutDirectionRight];
                            context(@"start", ^{
                                it(@"should = beginning of document", ^{
                                    [[@([composedTextView comparePosition:[rangeExtendedRight start] toPosition:penultimatePosition]) should] equal:@(NSOrderedSame)];
                                });
                            });
                            context(@"end", ^{
                                it(@"should = to second position", ^{
                                    [[@([composedTextView comparePosition:[rangeExtendedRight end] toPosition:endOfDocument]) should] equal:@(NSOrderedSame)];
                                });
                            });
                        });
                        context(@"left", ^{
                            UITextRange* rangeExtendedLeft = [composedTextView characterRangeByExtendingPosition:endOfDocument inDirection:UITextLayoutDirectionLeft];
                            context(@"start", ^{
                                it(@"should = beginning of document", ^{
                                    [[@([composedTextView comparePosition:[rangeExtendedLeft start] toPosition:penultimatePosition]) should] equal:@(NSOrderedSame)];
                                });
                            });
                            context(@"end", ^{
                                it(@"should = to second position", ^{
                                    [[@([composedTextView comparePosition:[rangeExtendedLeft end] toPosition:endOfDocument]) should] equal:@(NSOrderedSame)];
                                });
                            });
                        });
                        context(@"up", ^{
                            UITextRange* rangeExtendedUp = [composedTextView characterRangeByExtendingPosition:endOfDocument inDirection:UITextLayoutDirectionUp];
                            context(@"start", ^{
                                it(@"should = beginning of document", ^{
                                    [[@([composedTextView comparePosition:[rangeExtendedUp start] toPosition:penultimatePosition]) should] equal:@(NSOrderedSame)];
                                });
                            });
                            context(@"end", ^{
                                it(@"should = to second position", ^{
                                    [[@([composedTextView comparePosition:[rangeExtendedUp end] toPosition:endOfDocument]) should] equal:@(NSOrderedSame)];
                                });
                            });
                        });
                        context(@"down", ^{
                            UITextRange* rangeExtendedDown = [composedTextView characterRangeByExtendingPosition:endOfDocument inDirection:UITextLayoutDirectionDown];
                            context(@"start", ^{
                                it(@"should = to beginning of document", ^{
                                    [[@([composedTextView comparePosition:[rangeExtendedDown start] toPosition:penultimatePosition]) should] equal:@(NSOrderedSame)];
                                });
                            });
                            context(@"end", ^{
                                it(@"should = to second position", ^{
                                    [[@([composedTextView comparePosition:[rangeExtendedDown end] toPosition:endOfDocument]) should] equal:@(NSOrderedSame)];
                                });
                            });
                        });
                    });
                });
#endif
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

                    context(@"Measurements", ^{
                        it(@"should not be empty", ^{
                            [[@([entireTextRange isEmpty]) should] beNo];
                        });
                        context(@"range lenght", ^{
                            NSInteger rangeOffsetFromBeginning = [textView offsetFromPosition:[entireTextRange start] toPosition:[entireTextRange end]];
                            it(@"should be same as text length", ^{
                                [[@(rangeOffsetFromBeginning) should] equal: @(textLength)];
                            });
                        });
                        context(@"range text", ^{
                            NSString* textInRange = [textView textInRange:entireTextRange];
                            it(@"should be same as text", ^{
                                [[@([textInRange isEqualToString:text]) should] beYes];
                            });
                        });
                    });
                    
                    context(@"Comparisons", ^{
                        it(@"start should be < end", ^{
                            [[@([textView comparePosition:[entireTextRange start] toPosition:[entireTextRange end]]) should] equal:@(NSOrderedAscending)];
                        });
#if (TARGET_IPHONE_SIMULATOR || TARGET_IPHONE_DEVICE)
                        // This is not yet implemented in UIKit. It is written in response to ticket #1567. It tests an optional method in the UITextInput protocol
                        // that the harness implements.
                        context(@"-positionWithinRange:farthestInDirection:", ^{
                            context(@"layout direction", ^{
                                context(@"up", ^{
                                    UITextPosition* terminus = [textView positionWithinRange:entireTextRange farthestInDirection:UITextLayoutDirectionUp];
                                    it(@"should equal end of document", ^{
                                        [[@([textView comparePosition:terminus toPosition:endOfDocument]) should] equal:@(NSOrderedSame)];
                                    });
                                });
                                context(@"left", ^{
                                    UITextPosition* terminus = [textView positionWithinRange:entireTextRange farthestInDirection:UITextLayoutDirectionLeft];
                                    it(@"should equal end of document", ^{
                                        [[@([textView comparePosition:terminus toPosition:endOfDocument]) should] equal:@(NSOrderedSame)];
                                    });
                                });
                                context(@"down", ^{
                                    UITextPosition* terminus = [textView positionWithinRange:entireTextRange farthestInDirection:UITextLayoutDirectionDown];
                                    it(@"should equal end of document", ^{
                                        [[@([textView comparePosition:terminus toPosition:beginningOfDocument]) should] equal:@(NSOrderedSame)];
                                    });
                                });
                                context(@"right", ^{
                                    UITextPosition* terminus = [textView positionWithinRange:entireTextRange farthestInDirection:UITextLayoutDirectionRight];
                                    it(@"should equal end of document", ^{
                                        [[@([textView comparePosition:terminus toPosition:beginningOfDocument]) should] equal:@(NSOrderedSame)];
                                    });
                                });
                            });
                        });
#endif
                    });
                });

                context(@"no length", ^{
                    context(@"Measurements", ^{
                        UITextRange* zeroTextRange = [textView textRangeFromPosition:beginningOfDocument toPosition:beginningOfDocument];
                        it(@"should measure zero", ^{
                            [[@([textView offsetFromPosition:[zeroTextRange start] toPosition:[zeroTextRange end]]) should] equal:@(0)];
                        });
                        it(@"should be empty", ^{
                            [[@([zeroTextRange isEmpty]) should] beYes];
                        });
                        it(@"should have no text", ^{
                            [[@([[textView textInRange:zeroTextRange] isEqualToString:@""]) should] beYes];
                        });
                    });
                    context(@"Comparisons", ^{
                        UITextRange* zeroTextRange = [textView textRangeFromPosition:beginningOfDocument toPosition:beginningOfDocument];
                        it(@"start should = end", ^{
                            [[@([textView comparePosition:[zeroTextRange start] toPosition:[zeroTextRange end]]) should] equal:@(NSOrderedSame)];
                        });
#if (TARGET_IPHONE_SIMULATOR || TARGET_IPHONE_DEVICE)
                        // This is not yet implemented in UIKit. It is written in response to ticket #1569. It tests an optional method in the UITextInput protocol
                        // that the harness implements.
                        context(@"-positionWithinRange:farthestInDirection:", ^{
                            context(@"layout direction", ^{
                                context(@"up", ^{
                                    UITextPosition* terminus = [textView positionWithinRange:zeroTextRange farthestInDirection:UITextLayoutDirectionUp];
                                    it(@"should equal end of document", ^{
                                        [[@([textView comparePosition:terminus toPosition:beginningOfDocument]) should] equal:@(NSOrderedSame)];
                                    });
                                });
                                context(@"left", ^{
                                    UITextPosition* terminus = [textView positionWithinRange:zeroTextRange farthestInDirection:UITextLayoutDirectionLeft];
                                    it(@"should equal end of document", ^{
                                        [[@([textView comparePosition:terminus toPosition:beginningOfDocument]) should] equal:@(NSOrderedSame)];
                                    });
                                });
                                context(@"down", ^{
                                    UITextPosition* terminus = [textView positionWithinRange:zeroTextRange farthestInDirection:UITextLayoutDirectionDown];
                                    it(@"should equal end of document", ^{
                                        [[@([textView comparePosition:terminus toPosition:beginningOfDocument]) should] equal:@(NSOrderedSame)];
                                    });
                                });
                                context(@"right", ^{
                                    UITextPosition* terminus = [textView positionWithinRange:zeroTextRange farthestInDirection:UITextLayoutDirectionRight];
                                    it(@"should equal end of document", ^{
                                        [[@([textView comparePosition:terminus toPosition:beginningOfDocument]) should] equal:@(NSOrderedSame)];
                                    });
                                });
                            });
                        });
#endif
                    });
                });
            });
        });

        context(@"Selection", ^{
            NSString* selectionText = @"The quick brown fox /n/njumped over the lazy dog.";
            context(@"entire document", ^{
                UITextView* selectionTextView = [[UITextView alloc] initWithFrame:(CGRect){ .size = { 100, 100 } }];
                [selectionTextView setText:selectionText];
                UITextPosition* beginningOfDocument = [selectionTextView beginningOfDocument];
                UITextPosition* endOfDocument = [selectionTextView endOfDocument];
                UITextRange* fullSelectionRange = [selectionTextView textRangeFromPosition:beginningOfDocument toPosition:endOfDocument];
                [selectionTextView setSelectedTextRange:fullSelectionRange];
                context(@"when set then gotten", ^{
                    UITextRange* selectedTextRange = [selectionTextView selectedTextRange];
                    UITextPosition* start = [fullSelectionRange start];
                    UITextPosition* end = [fullSelectionRange end];
                    it(@"should not be empty", ^{
                        [[@([selectedTextRange isEmpty]) should] beNo];
                    });
                    it(@"should have correct start", ^{
                        [[@([selectionTextView comparePosition:start toPosition:beginningOfDocument]) should] equal:@(NSOrderedSame)];
                    });
                    it(@"should have correct end", ^{
                        [[@([selectionTextView comparePosition:end toPosition:endOfDocument]) should] equal:@(NSOrderedSame)];
                    });
                    context(@"when selected range has not been explicitly set", ^{
                        NSInteger startCharacterOffset = [selectionTextView offsetFromPosition:beginningOfDocument toPosition:start];
                        NSInteger endCharacterOffset = [selectionTextView offsetFromPosition:beginningOfDocument toPosition:end];
                        NSRange selectedTextCharacterRange = NSMakeRange(startCharacterOffset, endCharacterOffset);
                        it(@"should = selected range", ^{
                            [[@(NSEqualRanges(selectedTextCharacterRange, [selectionTextView selectedRange])) should] beYes];
                        });
                    });
                });
            });
            context(@"not set", ^{
                context(@"when the text's selectionRange is set", ^{
                    UITextView* selectionTextView = [[UITextView alloc] initWithFrame:(CGRect){ .size = { 100, 100 } }];
                    [selectionTextView setText:selectionText];
                    [selectionTextView setSelectedRange:NSMakeRange(0, [selectionText length])];
                    UITextPosition* beginningOfDocument = [selectionTextView beginningOfDocument];
                    UITextRange* selectedTextRange = [selectionTextView selectedTextRange];
                    NSInteger startCharacterOffset = [selectionTextView offsetFromPosition:beginningOfDocument toPosition:[selectedTextRange start]];
                    NSInteger endCharacterOffset = [selectionTextView offsetFromPosition:beginningOfDocument toPosition:[selectedTextRange end]];
                    it(@"should get set", ^{
                        [[@(NSEqualRanges([selectionTextView selectedRange], NSMakeRange(startCharacterOffset, endCharacterOffset))) should] beYes];
                    });
                });
                context(@"when the text's selectionRange will not be set", ^{
                    UITextView* selectionTextView = [[UITextView alloc] initWithFrame:(CGRect){ .size = { 100, 100 } }];
                    [selectionTextView setText:selectionText];
                    UITextRange* selectionTextRange = [selectionTextView selectedTextRange];
                    it(@"should be", ^{
                        [[selectionTextRange should] beNonNil];
                    });
                    it(@"should have and empty range", ^{
                        [[@([selectionTextRange isEmpty]) should] beYes];
                    });
                    it(@"should be caret at end of document", ^{
                        [[@([selectionTextView comparePosition:[selectionTextRange start] toPosition:[selectionTextView endOfDocument]]) should] equal:@(NSOrderedSame)];
                    });
                });
                context(@"when text is not yet set", ^{
                    UITextView* selectionTextView = [[UITextView alloc] initWithFrame:(CGRect){ .size = { 100, 100 } }];
                    UITextRange* selectionTextRange = [selectionTextView selectedTextRange];
                    it(@"should be nil", ^{
                        [[selectionTextRange should] beNil];
                    });
                });
            });
            context(@"when set to nil", ^{
                UITextView* selectionTextView = [[UITextView alloc] initWithFrame:(CGRect){ .size = { 100, 100 } }];
                [selectionTextView setText:selectionText];
                [selectionTextView setSelectedTextRange:nil];
                it(@"should be nil", ^{
                    [[[selectionTextView selectedTextRange] should] beNil];
                });
            });
            context(@"affinity", ^{
                UITextView* selectionTextView = [[UITextView alloc] initWithFrame:(CGRect){ .size = { 100, 100 } }];
                [selectionTextView setText:selectionText];
                UITextPosition* beginningOfDocument = [selectionTextView beginningOfDocument];
                UITextPosition* endOfFirstLine = [selectionTextView positionFromPosition:beginningOfDocument offset:19];
                UITextRange* selectedTextRange = [selectionTextView textRangeFromPosition:beginningOfDocument toPosition:endOfFirstLine];
                [selectionTextView setSelectedTextRange:selectedTextRange];
                [selectionTextView setSelectionAffinity:UITextStorageDirectionBackward]; //setter seems to ignore input in harness. Haven't found instance of Backward
                it(@"should be forward", ^{
                    [[@([selectionTextView selectionAffinity]) should] equal:@(UITextStorageDirectionForward)];
                });
            });
        });
    });
});
SPEC_END