#import <UIKit/UIKit.h>
#import "T2Overlay.h"
__attribute__((constructor)) static void take2_entry(void){ dispatch_after(dispatch_time(DISPATCH_TIME_NOW,(int64_t)(1.5*NSEC_PER_SEC)),dispatch_get_main_queue(),^{ [[T2Overlay shared] install]; }); }
