//
//  Task.h
//  Cronos
//
//  Created by Samuel Lichlyter on 4/17/15.
//  Copyright (c) 2015 Samuel Lichlyter. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Project;

@interface Task : NSManagedObject

@property (nonatomic, retain) NSNumber * timeElapsed;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSDate * startDate;
@property (nonatomic, retain) Project * project;

@end
