#import <Foundation/Foundation.h>
@interface T2Runtime : NSObject
+ (instancetype)shared;
- (NSArray<NSDictionary *> *)smartFeatures;
- (NSArray<NSDictionary *> *)editableValues;
- (NSArray<NSDictionary *> *)searchExactNumber:(double)value;
- (BOOL)setObject:(id)obj key:(NSString *)key number:(NSNumber *)value error:(NSString **)error;
@end
