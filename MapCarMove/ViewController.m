//
//  ViewController.m
//  MapCarMove
//
//  Created by ruigao on 2017/5/27.
//  Copyright © 2017年 coco. All rights reserved.
//

#import "ViewController.h"
#import "MapPointModel.h"
#import "UIImage+CoCo.h"
#import "BMKGetTool.h"
#import <BaiduMapAPI_Map/BMKMapView.h>//只引入所需的单个头文件
#import <BaiduMapAPI_Base/BMKBaseComponent.h>//引入base相关所有的头文件
#import <BaiduMapAPI_Map/BMKMapComponent.h>//引入地图功能所有的头文件
#import <BaiduMapAPI_Location/BMKLocationComponent.h>//引入定位功能所有的头文件
#import <BaiduMapAPI_Search/BMKSearchComponent.h>//引入检索功能所有的头文件
#import <BaiduMapAPI_Utils/BMKUtilsComponent.h>//引入计算工具所有的头文件

@interface ViewController ()<BMKMapViewDelegate,BMKLocationServiceDelegate>
{
    NSInteger           _count;
    NSMutableArray     *_pointArr;
    BMKPointAnnotation *_annotationPoint;
    BMKAnnotationView  *_markView;
    BMKMapView         *_mapV;
}


@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _pointArr = [NSMutableArray arrayWithCapacity:0];
    
    _count = 0;
    
    _mapV = [[BMKMapView alloc]initWithFrame:self.view.bounds];
    _mapV.delegate = self;
    [self.view addSubview:_mapV];

}
- (void)mapViewDidFinishLoading:(BMKMapView *)mapView
{
    [self startRouteSearch];
}
#pragma mark -- 发起路线检索
- (void)startRouteSearch
{
    //起点经纬度
    CLLocationCoordinate2D annotationCoordS;
    annotationCoordS.latitude = 22.602079;//纬度－－y坐标
    annotationCoordS.longitude = 114.011904;//经度－－x坐标
    //目的经纬度
    CLLocationCoordinate2D annotationCoordE;
    annotationCoordE.latitude = 22.536516;//纬度－－y坐标
    annotationCoordE.longitude = 114.066336;//经度－－x坐标
    
    //设置地图比例范围
    CLLocationCoordinate2D center = CLLocationCoordinate2DMake((22.602079 + 22.536516) / 2, (114.011904 + 114.066336) / 2);
    BMKCoordinateSpan span = BMKCoordinateSpanMake(fabs(22.602079 - 22.536516) , fabs(114.011904 - 114.066336));
    BMKCoordinateRegion region ;
    region.span.latitudeDelta = span.latitudeDelta * 1.2;
    region.span.longitudeDelta = span.longitudeDelta * 1.2;
    region.center = center;
    [_mapV setRegion:region animated:YES];
    
    CLLocationCoordinate2D annotationCoord;
    annotationCoord.latitude = 22.602079;
    annotationCoord.longitude = 114.011904;
    _annotationPoint = [[BMKPointAnnotation alloc]init];
    _annotationPoint.coordinate = annotationCoord;
    [_mapV addAnnotation:_annotationPoint];
    
    BMKGetTool *search = [[BMKGetTool alloc]init];//路线检索
    [search searchStartPt:annotationCoordS endPt:annotationCoordE];
    __weak __typeof(self) weakSelf = self;
    search.SearchResult = ^(NSMutableArray *array){
        if (array) {
            BMKDrivingRouteLine *planLine = [array firstObject];
            //在此处理正常结果
            int i = 0;
            //收集轨迹点
            for (int j = 0; j < planLine.steps.count; j++) {
                BMKDrivingStep* transitStep = [planLine.steps objectAtIndex:j];
                int k=0;
                for(k=0;k<transitStep.pointsCount;k++) {
                    CLLocationCoordinate2D pt = BMKCoordinateForMapPoint(transitStep.points[k]);
                    MapPointModel *model = [[MapPointModel alloc]init];
                    model.lat = pt.latitude;
                    model.lon = pt.longitude;
                    if (k>0) {
                        CLLocationCoordinate2D lastPt = BMKCoordinateForMapPoint(transitStep.points[k-1]);
                        model.angle = [BMKGetTool getAngleSPt:lastPt endPt:pt];
                    }
                    [_pointArr addObject:model];
                    i++;
                }
            }
            //计算轨迹点之间的距离
            for (int i = 0; i<_pointArr.count; i++) {
                if (i<_pointArr.count-1) {
                    MapPointModel *model = _pointArr[i];
                    MapPointModel *model1 = _pointArr[i+1];
                    CLLocationCoordinate2D pt;
                    pt.latitude = model.lat;
                    pt.longitude = model.lon;
                    float distance = [BMKGetTool getDistanceLat:model1.lat Lng:model1.lon pt:pt];
                    model1.distance = distance;
                    
                }
            }
            [weakSelf moveAnnotionV];
        }
    };
}
- (void)moveAnnotionV
{
    MapPointModel *model = _pointArr[_count];
    [UIView animateWithDuration:model.distance/40 animations:^{
        
        if ([_mapV.annotations containsObject:_annotationPoint]) {
            CLLocationCoordinate2D coor;
            coor.latitude = model.lat;
            coor.longitude = model.lon;
            _annotationPoint.coordinate = coor;
            
            UIImage * pinImage = [UIImage imageNamed:@"car2"];
            if (model.angle) {
                _markView.image = [pinImage imageRotatedByAngle:model.angle];
            }else{
                if (_count>0) {
                    MapPointModel *model = _pointArr[_count-1];
                    _markView.image = [pinImage imageRotatedByAngle:model.angle];
                }
            }
        }
        
    } completion:^(BOOL finished) {
        if (_count<_pointArr.count-1) {
            MapPointModel *model1 = _pointArr[_count+1];
            CLLocationCoordinate2D center = CLLocationCoordinate2DMake((model.lat + model1.lat) / 2, (model.lon + model1.lon) / 2);
            BMKCoordinateRegion region ;
            region.span.latitudeDelta = 0.005;
            region.span.longitudeDelta = 0.005;
            region.center = center;
            [_mapV setRegion:region animated:YES];
        }
        _count++;
        if (_count == _pointArr.count-1) {
            return;
        }
        [self moveAnnotionV];
    }];
    
}

#pragma mark -- 返回各种点的标注图
- (BMKAnnotationView *)mapView:(BMKMapView *)mapView viewForAnnotation:(id <BMKAnnotation>)annotation
{
    if ([annotation isKindOfClass:[BMKPointAnnotation class]]) {
        static NSString* annoId = @"Anno";
        BMKAnnotationView *markView = [[BMKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:annoId];
        _markView = markView;
        return markView;
    }
    return nil;
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
