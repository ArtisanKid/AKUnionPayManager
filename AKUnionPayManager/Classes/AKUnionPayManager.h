//
//  AKUnionPayManager.h
//  Pods
//
//  Created by 李翔宇 on 2017/3/27.
//
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

extern const NSString * const AKUnionPayManagerErrorCodeKey;
extern const NSString * const AKUnionPayManagerErrorMessageKey;
extern const NSString * const AKUnionPayManagerErrorDetailKey;

typedef void (^AKUnionPayManagerSuccess)();
typedef void (^AKUnionPayManagerFailure)(NSError *error);

/**
 SDK文档：https://open.unionpay.com/ajweb/help/file/toDetailPage?id=557&flag=2
 */

@interface AKUnionPayManager : NSObject

/**
 标准单例模式
 
 @return AKQQManager
 */
+ (AKUnionPayManager *)manager;

@property (class, nonatomic, assign, getter=isDebug) BOOL debug;
@property (class, nonatomic, strong) NSString *scheme;

//处理从Application回调方法获取的URL
+ (BOOL)handleOpenURL:(NSURL *)url;

/**
 支付
 
 @param orderID 订单信息
 @param success 成功的Block
 @param failure 失败的Block
 */
+ (void)pay:(NSString *)order
    success:(AKUnionPayManagerSuccess _Nullable)success
    failure:(AKUnionPayManagerFailure _Nullable)failure;

@end

NS_ASSUME_NONNULL_END
