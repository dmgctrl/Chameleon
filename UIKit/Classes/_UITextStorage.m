#import "_UITextStorage.h"

@implementation _UITextStorage {
    NSMutableAttributedString* _attributedString;
}

- (instancetype) init
{
    if (nil != (self = [super init])) {
        _attributedString = [[NSMutableAttributedString alloc] init];
    }
    return self;
}

- (NSString*) string
{
    return [_attributedString string];
}

- (NSDictionary*) attributesAtIndex:(NSUInteger)index effectiveRange:(NSRangePointer)range
{
    return [_attributedString attributesAtIndex:index effectiveRange:range];
}

- (void) replaceCharactersInRange:(NSRange)range withString:(NSString*)string
{
    [_attributedString replaceCharactersInRange:range withString:string];
    [self edited:NSTextStorageEditedCharacters|NSTextStorageEditedAttributes range:range changeInLength:[string length] - range.length];
}

- (void) setAttributes:(NSDictionary*)attributes range:(NSRange)range
{
    [_attributedString setAttributes:attributes range:range];
    [self edited:NSTextStorageEditedAttributes range:range changeInLength:0];
}

@end
