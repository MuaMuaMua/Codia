//
//  CodiaService.h
//  SSHARE
//
//  Created by wuhaibin on 16/2/21.
//  Copyright © 2016年 wuhaibin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AFNetworking.h>

typedef void (^ DTZSuccessBlock)(NSDictionary * successBlock);

typedef void (^ DTZFailBlock)(NSDictionary * failBlock);

typedef void (^ DTZDataBlock)(NSData * dataSuccessBlock);

typedef void (^ DTZErrorBlock)(NSError * errorBlock);

@interface CodiaService : NSObject

@property (strong, nonatomic) AFHTTPRequestOperationManager * networkingManager;

+ (CodiaService *)sharedInstance;

- (void)uploadRecordKey:(NSString *)key fileUrl:(NSString *)fileUrlString DTZSuccessBlock:(DTZSuccessBlock)dtzSuccessBlock DTZFailBlock:(DTZFailBlock)dtzFailBlock ;

- (NSDictionary *)getTokenAndKey :(DTZSuccessBlock)dtzSuccessBlock DTZFailBlock:(DTZFailBlock)dtzFailBlock ;

- (void)getVoiceRecordData:(NSString *)voiceUrl DTZDataBlock:(DTZDataBlock)dtzSuccessBlock DTZErrorBlock:(DTZErrorBlock)dtzErrorBlock ;

@end
