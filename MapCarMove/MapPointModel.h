//
//  MapPointModel.h
//  CarRental
//
//  Created by ruigao on 2017/5/25.
//  Copyright © 2017年 ruigao. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MapPointModel : NSObject
@property (nonatomic,assign) double lat;
@property (nonatomic,assign) double lon;
@property (nonatomic,assign) float angle;
@property (nonatomic,assign) float distance;
@end
