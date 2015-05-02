//
//  InterfaceController.m
//  Cronos WatchKit Extension
//
//  Created by Samuel Lichlyter on 4/20/15.
//  Copyright (c) 2015 Samuel Lichlyter. All rights reserved.
//

#import "InterfaceController.h"
#import "RowType.h"
#import "Project.h"
#import "TasksInterfaceController.h"

@interface InterfaceController() {
    NSArray *projectArray;
}

@end


@implementation InterfaceController
@synthesize table;
@synthesize emptyLabel;

- (void)awakeWithContext:(id)context {
    [super awakeWithContext:context];

    // Configure interface objects here.
    NSUserDefaults *cronosDefaults = [[NSUserDefaults alloc] initWithSuiteName:@"group.com.samuellichlyter.cronos"];
    projectArray = [cronosDefaults valueForKey:@"projectTitlesArray"];
    if ([projectArray isEqualToArray:@[]]) {
        [emptyLabel setHidden:NO];
    } else {
        [self configureTableWithData:projectArray];
    }
}

- (void)configureTableWithData:(NSArray*)tableData {
    [self.table setNumberOfRows:[tableData count] withRowType:@"projectRow"];
    for (NSInteger i = 0; i < self.table.numberOfRows; i++) {
        RowType *row = [self.table rowControllerAtIndex:i];
        NSString *title = [tableData objectAtIndex:i];
        
        [row.label setText:title];
    }
}

- (id)contextForSegueWithIdentifier:(NSString *)segueIdentifier inTable:(WKInterfaceTable *)table rowIndex:(NSInteger)rowIndex {
    if ([segueIdentifier isEqualToString:@"showTasks"]) {
        if ([projectArray isEqualToArray:@[]]) {
            return nil;
        }
        
        NSString *context = [projectArray objectAtIndex:rowIndex];
        return context;
    }
    return nil;
}

- (void)doAddProject:(id)sender {
    NSArray *cannedResponses = [NSArray arrayWithObjects:@"Homework", @"App Development", @"Random", nil];
    [self presentTextInputControllerWithSuggestions:cannedResponses allowedInputMode:WKTextInputModeAllowEmoji completion:^(NSArray *results){
        if (results && results.count > 0) {
            id aResult = [results objectAtIndex:0];
            NSLog(@"Selected: %@", aResult);
        } else {
            [self dismissTextInputController];
        }
    }];
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



