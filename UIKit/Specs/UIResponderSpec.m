SPEC_BEGIN(UIResponderSpec)
describe(@"UIResponder", ^{
    context(@"default", ^{
        UIResponder* responder = [[UIResponder alloc] init];
        context(@"property", ^{
            context(@"inputView", ^{
                it(@"should not be", ^{
                    [[responder should] beNonNil];
                });
            });
            context(@"inputView", ^{
                it(@"should not be", ^{
                    [[[responder inputAccessoryView] should] beNil];
                });
            });
            
            context(@"undoManager", ^{
                it(@"should not be", ^{
                    [[[responder undoManager] should] beNil];
                });
            });
        });
        
        context(@"instance method", ^{
            context(@"nextResponder", ^{
                it(@"should not be", ^{
                    [[[responder nextResponder] should] beNil];
                });
            });
            context(@"isFirstResponder", ^{
                it(@"should be no", ^{
                    [[@([responder isFirstResponder]) should] beNo];
                });
            });
            context(@"canBecomeFirstResponder", ^{
                it(@"should be no", ^{
                    [[@([responder canBecomeFirstResponder]) should] beNo];
                });
            });
            context(@"becomeFirstResponder", ^{
                it(@"should be no", ^{
                    [[@([responder becomeFirstResponder]) should] beNo];
                });
            });
            context(@"canResignFirstResponder", ^{
                it(@"should be no", ^{
                    [[@([responder canResignFirstResponder]) should] beNonNil];
                });
            });
            context(@"resignFirstResponder", ^{
                it(@"should be no", ^{
                    [[@([responder resignFirstResponder]) should] beNo];
                });
            });
            
            context(@"canPerformAction:withSender:", ^{
                it(@"should be no", ^{
                    [[@([responder canPerformAction:@selector(copy) withSender: responder]) should] beYes];
                });
            });
        });
    });
});
SPEC_END