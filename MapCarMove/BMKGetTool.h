//
//  BMKGetTool.h
//  MapCarMove
//
//  Created by ruigao on 2017/5/27.
//  Copyright © 2017年 coco. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <BaiduMapAPI_Search/BMKSearchComponent.h>//引入检索功能所有的头文件
#import <BaiduMapAPI_Utils/BMKUtilsComponent.h>//引入计算工具所有的头文件
@interface BMKGetTool : NSObject
@property (nonatomic,copy) void(^SearchResult)(NSMutableArray *array);

//检索路线
- (void)searchStartPt:(CLLocationCoordinate2D)startPt endPt:(CLLocationCoordinate2D)endPt;
/**
 通过百度api计算两经纬度距离
 */
+ (float)getDistanceLat:(float)latitude Lng:(float)longitude pt:(CLLocationCoordinate2D)pt;

/**
 计算两个经纬度之间的与水平方向的角度
 */
+ (float)getAngleSPt:(CLLocationCoordinate2D)sPt endPt:(CLLocationCoordinate2D)ePt;
@end
