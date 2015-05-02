//
//  TasksTableViewController.h
//  Cronos
//
//  Created by Samuel Lichlyter on 4/11/15.
//  Copyright (c) 2015 Samuel Lichlyter. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CronosKit/CronosKit.h>

@interface TasksTableViewController : UITableViewController

@property (nonatomic, weak) Project *project;

@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;

@end
