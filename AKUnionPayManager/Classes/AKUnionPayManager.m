//
//  AKUnionPayManager.m
//  Pods
//
//  Created by 李翔宇 on 2017/3/27.
//
//

#import "AKUnionPayManager.h"
#import <AKUnionPaySDK/UPPaymentControl.h>
#import "AKUnionPayManagerMacro.h"

const NSString * const AKUnionPayManagerErrorCodeKey = @"code";
const NSString * const AKUnionPayManagerErrorMessageKey = @"message";
const NSString * const AKUnionPayManagerErrorDetailKey = @"detail";

static const NSString * const AKUnionPayManagerResultSuccess = @"suceess";
static const NSString * const AKUnionPayManagerResultFailure = @"fail";
static const NSString * const AKUnionPayManagerResultCancel = @"cancel";

@interface AKUnionPayManager ()

@property (nonatomic, strong) AKUnionPayManagerSuccess paySuccess;
@property (nonatomic, strong) AKUnionPayManagerFailure payFailure;

@end

@implementation AKUnionPayManager

+ (AKUnionPayManager *)manager {
    static AKUnionPayManager *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[super allocWithZone:NULL] init];
    });
    return sharedInstance;
}

+ (id)alloc {
    return [self manager];
}

+ (id)allocWithZone:(NSZone * _Nullable)zone {
    return [self manager];
}

- (id)copy {
    return self;
}

- (id)copyWithZone:(NSZone * _Nullable)zone {
    return self;
}

#pragma mark- Public Method
+ (BOOL)handleOpenURL:(NSURL *)url {
    __block BOOL handle = YES;
    [[UPPaymentControl defaultControl] handlePaymentResult:url completeBlock:^(NSString *code, NSDictionary *data) {
        //code表示支付结果，取值为suceess、fail、cancel分别表示支付成功、支付失败、支付取消
        if([code isEqualToString:AKUnionPayManagerResultSuccess]) {
            !self.manager.paySuccess ? : self.manager.paySuccess();
            self.manager.paySuccess = nil;
            self.manager.payFailure = nil;
            handle = YES;
        } else if([code isEqualToString:AKUnionPayManagerResultFailure]) {
            [self.manager failure:self.manager.payFailure message:@"支付失败"];
        } else if([code isEqualToString:AKUnionPayManagerResultCancel]) {
            [self.manager failure:self.manager.payFailure message:@"支付取消"];
        } else {
            handle = NO;
        }
    }];
    return handle;
}

+ (void)pay:(NSString *)order
    success:(AKUnionPayManagerSuccess)success
    failure:(AKUnionPayManagerFailure)failure {
    AKUnionPay_String_Nilable_Return(self.scheme, NO, {
        [self.manager failure:failure message:@"未设置scheme"];
    });
    
    AKUnionPay_String_Nilable_Return(order, NO, {
        [self.manager failure:failure message:@"未设置order"];
    });

    NSString *mode = @"00";
    if(self.isDebug) {
        mode = @"01";
    }
    
    BOOL result = [[UPPaymentControl defaultControl] startPay:order
                                     fromScheme:self.scheme
                                           mode:mode
                                 viewController:UIApplication.sharedApplication.keyWindow.rootViewController];
    if(!result) {
        [self.manager failure:failure message:@"Pay请求发送失败"];
        return;
    }
    
    self.manager.paySuccess = success;
    self.manager.payFailure = failure;
}

#pragma mark- Private Method

- (void)failure:(AKUnionPayManagerFailure)failure message:(NSString *)message {
    if(AKUnionPayManager.isDebug) {
        AKUnionPayManagerLog(@"%@", message);
    }
    
    NSDictionary *userInfo = nil;
    if([message isKindOfClass:[NSString class]]
       && message.length) {
        userInfo = @{AKUnionPayManagerErrorMessageKey : message};
    }
    
    NSError *error = [NSError errorWithDomain:NSStringFromClass([self class])
                                         code:0
                                     userInfo:userInfo];
    !failure ? : failure(error);
}

@end
