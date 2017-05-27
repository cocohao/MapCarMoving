//
//  BMKGetTool.m
//  MapCarMove
//
//  Created by ruigao on 2017/5/27.
//  Copyright © 2017年 coco. All rights reserved.
//

#import "BMKGetTool.h"

@interface BMKGetTool()<BMKRouteSearchDelegate>
{
    BMKRouteSearch   *_routeSearcher;
}
@end

@implementation BMKGetTool

- (instancetype)init
{
    self = [super init];
    if (self) {
        
    }
    return self;
}
#pragma mark -- 检索路线
- (void)searchStartPt:(CLLocationCoordinate2D)startPt endPt:(CLLocationCoordinate2D)endPt
{
    //初始化检索对象
    if (!_routeSearcher) {
        _routeSearcher = [[BMKRouteSearch alloc]init];
        _routeSearcher.delegate = self;
    }
    //发起检索
    //起点经纬度位置
    BMKPlanNode* start = [[BMKPlanNode alloc]init];
    start.pt = startPt;
    //终点经纬度位置
    BMKPlanNode* end = [[BMKPlanNode alloc]init];
    end.pt = endPt;
    BMKDrivingRoutePlanOption *transitRouteSearchOption =  [[BMKDrivingRoutePlanOption alloc]init];
    transitRouteSearchOption.drivingPolicy = BMK_DRIVING_DIS_FIRST;
    transitRouteSearchOption.from = start;
    transitRouteSearchOption.to = end;
    
    
    BOOL flag = [_routeSearcher drivingSearch:transitRouteSearchOption];
    if(flag)
    {
        NSLog(@"路线检索发送成功");
    }
    else
    {
        NSLog(@"路线检索发送失败");
    }
}
#pragma mark -- 驾车路线检索结果回调
-(void)onGetDrivingRouteResult:(BMKRouteSearch *)searcher result:(BMKDrivingRouteResult *)result errorCode:(BMKSearchErrorCode)error
{
    
    if (error == BMK_SEARCH_NO_ERROR) {
        //在此处理正常结果
        if (result.routes>0) {
            NSMutableArray *array = [NSMutableArray arrayWithArray:result.routes];
            if (self.SearchResult) {
                self.SearchResult(array);
            }
        }
        
    }else if (error == BMK_SEARCH_AMBIGUOUS_ROURE_ADDR){
        //当路线起终点有歧义时通，获取建议检索起终点
        //result.routeAddrResult
    }else {
        NSLog(@"抱歉，未找到结果");
    }
    
}

+ (float)getDistanceLat:(float)latitude Lng:(float)longitude pt:(CLLocationCoordinate2D)pt
{
    BMKMapPoint point1 = BMKMapPointForCoordinate(pt);
    BMKMapPoint point2 = BMKMapPointForCoordinate(CLLocationCoordinate2DMake(latitude, longitude));
    CLLocationDistance distance = BMKMetersBetweenMapPoints(point1,point2);
    
    return distance;
}
/**
 计算两个经纬度之间的与水平方向的角度
 */
+ (float)getAngleSPt:(CLLocationCoordinate2D)sPt endPt:(CLLocationCoordinate2D)ePt
{
    //起点经纬度
    CLLocationCoordinate2D annotationCoordS;
    annotationCoordS.latitude = sPt.latitude;//纬度－－y坐标
    annotationCoordS.longitude = sPt.longitude;//经度－－x坐标
    //目的经纬度
    CLLocationCoordinate2D annotationCoordE;
    annotationCoordE.latitude = ePt.latitude;//纬度－－y坐标
    annotationCoordE.longitude = ePt.longitude;//经度－－x坐标
    
    float y = annotationCoordE.latitude - annotationCoordS.latitude;
    
    float x = annotationCoordE.longitude - annotationCoordS.longitude;
    
    float pi_angle;
    
    float angle;
    
    if (x>0&&y>0) {
        pi_angle = atan(fabs((x/y)));
        angle= pi_angle*180/M_PI+270;
    }else if (x>0&&y<0){
        pi_angle = atan(fabs((y/x)));
        angle= pi_angle*180/M_PI;
    }else if (x<0&&y<0){
        pi_angle = atan(fabs((x/y)));
        angle= pi_angle*180/M_PI+90;
    }else{
        pi_angle = atan(fabs((y/x)));
        angle= pi_angle*180/M_PI+180;
    }
    return angle;
    
}

@end
