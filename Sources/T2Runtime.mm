#import "T2Runtime.h"
#import <UIKit/UIKit.h>
#import <objc/runtime.h>

@implementation T2Runtime
+ (instancetype)shared { static id x; static dispatch_once_t once; dispatch_once(&once, ^{ x=[self new]; }); return x; }

static BOOL T2Blocked(NSString *s){
    NSString *x=s.lowercaseString;
    NSArray *bad=@[@"password",@"token",@"cookie",@"auth",@"credential",@"secret",@"session",@"keychain",@"purchase",@"payment",@"receipt"];
    for(NSString *k in bad) if([x containsString:k]) return YES;
    return NO;
}
static NSInteger T2Score(NSString *n){
    NSString *x=n.lowercaseString; NSInteger s=0;
    for(NSString *k in @[@"enabled",@"enable",@"disabled",@"visible",@"available",@"debug",@"mode",@"speed",@"count",@"limit",@"lives",@"level",@"coins",@"gems",@"score",@"volume",@"opacity",@"scale"]) if([x containsString:k]) s+=2;
    if([x hasPrefix:@"is"] || [x hasPrefix:@"has"] || [x hasPrefix:@"can"]) s+=2;
    return s;
}
static NSString *T2Arabic(NSString *n){
    NSString *x=n.lowercaseString;
    NSArray *m=@[
      @[@"speed",@"السرعة"],@[@"coins",@"العملة"],@[@"gems",@"الجواهر"],@[@"lives",@"المحاولات"],
      @[@"level",@"المستوى"],@[@"enabled",@"التفعيل"],@[@"visible",@"الظهور"],@[@"debug",@"وضع المطور"],
      @[@"volume",@"الصوت"],@[@"opacity",@"الشفافية"],@[@"scale",@"الحجم"],@[@"limit",@"الحد"],@[@"count",@"العدد"],@[@"mode",@"الوضع"]];
    for(NSArray *p in m) if([x containsString:p[0]]) return p[1];
    return @"قيمة قابلة للفحص";
}
static NSString *T2Confidence(NSInteger s){ return s>=5?@"عالي":(s>=2?@"متوسط":@"منخفض"); }

- (NSArray *)objects {
    NSMutableArray *a=[NSMutableArray array];
    for(UIWindow *w in UIApplication.sharedApplication.windows){
        NSMutableArray *q=[NSMutableArray arrayWithObject:w];
        while(q.count){ UIView *v=q.lastObject; [q removeLastObject]; [a addObject:v]; [q addObjectsFromArray:v.subviews];
            UIResponder *r=v.nextResponder; if(r && ![a containsObject:r]) [a addObject:r];
        }
    }
    return a;
}
- (NSArray<NSDictionary *> *)scan:(BOOL)features {
    NSMutableArray *out=[NSMutableArray array]; NSMutableSet *seen=[NSMutableSet set];
    for(id obj in [self objects]){
        Class c=[obj class]; unsigned int n=0; objc_property_t *ps=class_copyPropertyList(c,&n);
        for(unsigned i=0;i<n;i++){
            NSString *name=@(property_getName(ps[i])?:""); if(!name.length||T2Blocked(name)) continue;
            NSInteger score=T2Score(name); if(features && score<2) continue;
            SEL g=NSSelectorFromString(name); if(![obj respondsToSelector:g]) continue;
            Method gm=class_getInstanceMethod(c,g); if(!gm) continue; char rt[32]={0}; method_getReturnType(gm,rt,sizeof(rt));
            BOOL numeric=strchr("BcCsSiIlLqQfd",rt[0])!=NULL; if(!numeric) continue;
            NSString *key=[NSString stringWithFormat:@"%p-%@",obj,name]; if([seen containsObject:key]) continue; [seen addObject:key];
            NSNumber *val=nil; @try {
                if(rt[0]=='f') val=@(((float(*)(id,SEL))objc_msgSend)(obj,g));
                else if(rt[0]=='d') val=@(((double(*)(id,SEL))objc_msgSend)(obj,g));
                else val=@(((long long(*)(id,SEL))objc_msgSend)(obj,g));
            } @catch(__unused NSException *e){}
            if(!val) continue;
            NSString *setter=[NSString stringWithFormat:@"set%@%@:",[[name substringToIndex:1] uppercaseString],[name substringFromIndex:1]];
            BOOL writable=[obj respondsToSelector:NSSelectorFromString(setter)];
            [out addObject:@{@"object":obj,@"class":NSStringFromClass(c),@"name":name,@"ar":T2Arabic(name),@"value":val,@"confidence":T2Confidence(score),@"writable":@(writable)}];
            if(out.count>=250) break;
        } free(ps); if(out.count>=250) break;
    }
    return out;
}
- (NSArray *)smartFeatures { return [self scan:YES]; }
- (NSArray *)editableValues { return [self scan:NO]; }
- (NSArray *)searchExactNumber:(double)value {
    NSMutableArray *a=[NSMutableArray array]; for(NSDictionary *d in [self editableValues]) if(fabs([d[@"value"] doubleValue]-value)<1e-7) [a addObject:d]; return a;
}
- (BOOL)setObject:(id)obj key:(NSString *)key number:(NSNumber *)value error:(NSString **)error {
    if(!obj||!key.length){ if(error)*error=@"عنصر غير صالح"; return NO; }
    NSString *setter=[NSString stringWithFormat:@"set%@%@:",[[key substringToIndex:1] uppercaseString],[key substringFromIndex:1]]; SEL s=NSSelectorFromString(setter);
    Method m=class_getInstanceMethod([obj class],s); if(!m){if(error)*error=@"لا يوجد setter آمن";return NO;}
    char t[32]={0}; method_getArgumentType(m,2,t,sizeof(t)); @try {
        switch(t[0]){ case 'B': ((void(*)(id,SEL,BOOL))objc_msgSend)(obj,s,value.boolValue); break; case 'f': ((void(*)(id,SEL,float))objc_msgSend)(obj,s,value.floatValue); break; case 'd': ((void(*)(id,SEL,double))objc_msgSend)(obj,s,value.doubleValue); break; case 'i': case 's': case 'c': ((void(*)(id,SEL,int))objc_msgSend)(obj,s,value.intValue); break; default: ((void(*)(id,SEL,long long))objc_msgSend)(obj,s,value.longLongValue); break; }
        return YES;
    } @catch(NSException *e){if(error)*error=e.reason;return NO;}
}
@end
