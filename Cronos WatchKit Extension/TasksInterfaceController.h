//
//  TasksInterfaceController.h
//  Cronos
//
//  Created by Samuel Lichlyter on 4/29/15.
//  Copyright (c) 2015 Samuel Lichlyter. All rights reserved.
//

#import <WatchKit/WatchKit.h>
#import <Foundation/Foundation.h>

@interface TasksInterfaceController : WKInterfaceController

@property (weak, nonatomic) IBOutlet WKInterfaceTable *table;
@property (weak, nonatomic) IBOutlet WKInterfaceLabel *emptyLabel;
@property (strong, nonatomic) NSString *projectTitle;

- (IBAction)doAddTask:(id)sender;

@end
