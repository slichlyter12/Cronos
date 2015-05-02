//
//  TasksInterfaceController.m
//  Cronos
//
//  Created by Samuel Lichlyter on 4/29/15.
//  Copyright (c) 2015 Samuel Lichlyter. All rights reserved.
//

#import "TasksInterfaceController.h"
#import "RowType.h"

@interface TasksInterfaceController () {
    NSArray *taskArray;
}

@end

@implementation TasksInterfaceController
@synthesize table;
@synthesize emptyLabel;
@synthesize projectTitle;

- (void)awakeWithContext:(id)context {
    [super awakeWithContext:context];
    
    // Configure interface objects here.
    self.projectTitle = context;
    NSUserDefaults *cronosDefaults = [[NSUserDefaults alloc] initWithSuiteName:@"group.com.samuellichlyter.cronos"];
    NSString *taskKey = [NSString stringWithFormat:@"%@_tasks", self.projectTitle];
    taskArray = [cronosDefaults valueForKey:taskKey];
    if ([taskArray isEqualToArray:@[]]) {
        [emptyLabel setHidden:NO];
    } else {
        [self configureTableWithData:taskArray];
    }
}

- (void)configureTableWithData:(NSArray*)tableData {
    [self.table setNumberOfRows:[tableData count] withRowType:@"taskRow"];
    for (NSInteger i = 0; i < self.table.numberOfRows; i++) {
        RowType *row = [self.table rowControllerAtIndex:i];
        NSString *title = [tableData objectAtIndex:i];
        
        [row.label setText:title];
    }
}

- (void)doAddTask:(id)sender {
    NSLog(@"Add Task");
}

- (void)willActivate {
    // This method is called when watch view controller is about to be visible to user
    [super willActivate];
}

- (void)didDeactivate {
    // This method is called when watch view controller is no longer visible
    [super didDeactivate];
}

@end



