
//
//  CodiaService.m
//  SSHARE
//
//  Created by wuhaibin on 16/2/21.
//  Copyright © 2016年 wuhaibin. All rights reserved.
//

#import "CodiaService.h"
#import <AFNetworking.h>
#import <QiniuSDK.h>
#import "NSData+GZIP.h"



#define QNDomain @"http://7xr2vw.com1.z0.glb.clouddn.com"

#define vincentUrl @"http://139.129.16.89:20002/getUpToken.php"


@implementation CodiaService {
    QNUploadManager * _qiniuUploadManager;
}

+ (CodiaService *)sharedInstance {
    static CodiaService * _instance;
    @synchronized(self) {
        if (!_instance) {
            _instance = [[CodiaService alloc]init];
            _instance.networkingManager = [[AFHTTPRequestOperationManager alloc]init];
            _instance.networkingManager.responseSerializer = [[AFHTTPResponseSerializer alloc]init];
            _instance.networkingManager.requestSerializer.timeoutInterval = 20;
            return _instance;
        }
    }
    return _instance;
}

- (void)uploadRecordKey:(NSString *)key fileUrl:(NSString *)fileUrlString DTZSuccessBlock:(DTZSuccessBlock)dtzSuccessBlock DTZFailBlock:(DTZFailBlock)dtzFailBlock {
    NSData * data = [NSData dataWithContentsOfURL:[NSURL URLWithString:fileUrlString]];
    
    data = [data gzippedDataWithCompressionLevel:1.0];
    
    QNUploadManager *upManager = [[QNUploadManager alloc] init];
    NSString * token = [[NSUserDefaults standardUserDefaults]objectForKey:@"upload_token"];
    NSString * qiniuKey = [[NSUserDefaults standardUserDefaults]objectForKey:@"key"];
    
    
    [upManager putData:data key:qiniuKey token:token complete:^(QNResponseInfo *info, NSString *key, NSDictionary *resp) {
        NSLog(@"%@",info);
        NSURL * _tmpFile = [NSURL fileURLWithPath:
                    [NSTemporaryDirectory() stringByAppendingPathComponent:
                     [NSString stringWithFormat: @"%@.%@",
                      @"DTZ",
                      @"caf"]]];
        [data writeToFile:[_tmpFile absoluteString] atomically:YES];
        if (info.statusCode == 200) {
            dtzSuccessBlock(nil);
        }else {
            dtzFailBlock(nil);
        }
        //        [[NSNotificationCenter defaultCenter]postNotificationName:@"getData" object:data];
    } option:nil];
    
}

- (NSDictionary *)getTokenAndKey :(DTZSuccessBlock)dtzSuccessBlock DTZFailBlock:(DTZFailBlock)dtzFailBlock{

    [self.networkingManager GET:vincentUrl parameters:nil success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
        NSDictionary * responseData = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
        NSLog(@"%@",responseData);
        [[NSUserDefaults standardUserDefaults]setObject:[responseData objectForKey:@"key"] forKey:@"key"];
        [[NSUserDefaults standardUserDefaults]setObject:[responseData objectForKey:@"upload_token"] forKey:@"upload_token"];
        dtzSuccessBlock(responseData);
    } failure:^(AFHTTPRequestOperation * _Nullable operation, NSError * _Nonnull error) {
//        dtzFailBlock(error);
    }];
    return nil;
}

- (void)getVoiceRecordData:(NSString *)voiceUrl DTZDataBlock:(DTZDataBlock)dtzSuccessBlock DTZErrorBlock:(DTZErrorBlock)dtzErrorBlock {
    
    NSString * voiceDownloadString = [QNDomain stringByAppendingString:[NSString stringWithFormat:@"//%@",voiceUrl]];
    [self.networkingManager GET:voiceDownloadString parameters:nil success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
        NSDictionary * responseData = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
        NSLog(@"%@",responseData);
        dtzSuccessBlock(responseObject);
    } failure:^(AFHTTPRequestOperation * _Nullable operation, NSError * _Nonnull error) {
        dtzErrorBlock(error);
        NSLog(@"下载data 失败");
//        dtzFailBlock(error);
    }];
}

@end
