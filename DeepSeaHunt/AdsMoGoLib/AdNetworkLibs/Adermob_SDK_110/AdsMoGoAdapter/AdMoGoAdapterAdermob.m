//
//  AdMoGoAdapterAdermob.m
//  TestMOGOSDKAPP
//
//  Created on 13-2-16.
//
//

#import "AdMoGoAdapterAdermob.h"
#import "AdMoGoAdNetworkRegistry.h"
#import "AdMoGoAdNetworkConfig.h"
#import "AdMoGoConfigData.h"
#import "AdMoGoConfigDataCenter.h"

@implementation AdMoGoAdapterAdermob

+ (NSDictionary *)networkType {
	return [self makeNetWorkType:AdMoGoAdNetworkTypeAdermob IsSDK:YES isApi:NO isBanner:YES isFullScreen:NO];
}

+ (void)load {
	[[AdMoGoAdNetworkRegistry sharedRegistry] registerClass:self];
}

- (void)getAd {
    isStop = NO;
    isLoaded = NO;
    [adMoGoCore adDidStartRequestAd];
    CGRect adFrame = CGRectMake(0, 0, 320, 50);
    AdMoGoConfigDataCenter *configDataCenter = [AdMoGoConfigDataCenter singleton];
    
    AdMoGoConfigData *configData = [configDataCenter.config_dict objectForKey:adMoGoCore.config_key];
    AdViewType type = [configData.ad_type intValue];
    switch (type) {
        case AdViewTypeNormalBanner:
            adFrame = CGRectMake(0, 0, 320, 50);
            break;
        case AdViewTypeLargeBanner:
            adFrame = CGRectMake(0, 0, 728, 90);
            break;
        default:
            [adMoGoCore adapter:self didGetAd:@"adermob"];
            [adMoGoCore adapter:self didFailAd:nil];
            return;
            break;
    }
    
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, adFrame.size.width, adFrame.size.height)];

    [AderSDK startAdService:view appID:[self.ration objectForKey:@"key"] adFrame:adFrame model:MODEL_RELEASE];
    [AderSDK setDelegate:self];
    self.adNetworkView = view;
    [view release];
    timer = [[NSTimer scheduledTimerWithTimeInterval:AdapterTimeOut15 target:self selector:@selector(loadAdTimeOut:) userInfo:nil repeats:NO] retain];
}

- (void)stopBeingDelegate{
    UIView *dummyView = self.adNetworkView;
    if (dummyView != nil) {
        [AderSDK setDelegate:nil];
        [AderSDK stopAdService];
    }
//    self.adNetworkView = nil;
}

- (void)stopAd{
    [self stopTimer];
    [self stopBeingDelegate];
    isStop = YES;
}

- (void)dealloc {
    NSLog(@"ader dealloc");
    [self stopTimer];
    [AderSDK setDelegate:nil];
    [AderSDK stopAdService];
	[super dealloc];
}

- (void)didSucceedToReceiveAd:(NSInteger)count{
    
    if (isStop) {
        return;
    }
    if (!isLoaded) {
        isLoaded = YES;
    }else{
        return;
    }
    [self stopTimer];

    [adMoGoCore adapter:self didGetAd:@"adermob"];
    [adMoGoCore adapter:self didReceiveAdView:adNetworkView];
}

- (void) didReceiveError:(NSError *)error{
    NSLog(@"error is %@",error);
    if (isStop) {
        return;
    }
    [self stopTimer];
    [adMoGoCore adapter:self didGetAd:@"adermob"];
    [adMoGoCore adapter:self didFailAd:nil];
}

- (void)stopTimer {
    if (timer) {
        [timer invalidate];
        [timer release];
        timer = nil;
    }
}

/*2013*/
- (void)loadAdTimeOut:(NSTimer*)theTimer {
    if (isStop) {
        return;
    }
    [self stopTimer];
    [self stopBeingDelegate];
    [adMoGoCore adapter:self didFailAd:nil];
}
@end
