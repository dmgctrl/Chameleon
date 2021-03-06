#import <UIKit/UITextInput.h>
#import "_UITextViewPosition.h"


@interface _UITextViewRange : UITextRange

+ (instancetype) rangeWithNSRange:(NSRange)range;

- (instancetype) initWithStart:(_UITextViewPosition*)start end:(_UITextViewPosition*)end;

@property (nonatomic, readonly) _UITextViewPosition* start;
@property (nonatomic, readonly) _UITextViewPosition* end;
@property (nonatomic, readonly) NSRange NSRange;

@end

