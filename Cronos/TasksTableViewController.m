//
//  TasksTableViewController.m
//  Cronos
//
//  Created by Samuel Lichlyter on 4/11/15.
//  Copyright (c) 2015 Samuel Lichlyter. All rights reserved.
//

#import "AppDelegate.h"
#import "TaskTableViewCell.h"
#import "TasksTableViewController.h"
#import "AddTaskViewController.h"

@interface TasksTableViewController () {
    NSMutableArray *taskArray;
}

@end

@implementation TasksTableViewController
@synthesize managedObjectContext;
@synthesize project;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
//     self.navigationItem.leftBarButtonItem = self.editButtonItem;
    
    AppDelegate *delegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    self.managedObjectContext = delegate.managedObjectContext;
    
    [self loadData];
    
}

- (void)loadData {
    
    NSSortDescriptor *startDateSortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"startDate" ascending:NO];
    NSSortDescriptor *timeElapsedSortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"timeElapsed" ascending:NO];

    NSArray *sortDescriptors = [NSArray arrayWithObjects:timeElapsedSortDescriptor, startDateSortDescriptor, nil];
    
    NSError *error = nil;
    if (!(taskArray = (NSMutableArray*)[self.project.tasks sortedArrayUsingDescriptors:sortDescriptors])) {
        NSLog(@"error: %@ %@", error, [error userInfo]);
        abort();
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self loadData];
    [self.tableView reloadData];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return [taskArray count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    TaskTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"TaskCell" forIndexPath:indexPath];
    
    Task *task = [taskArray objectAtIndex:indexPath.row];
    
    cell.titleLabel.text = task.title;
    cell.timeLabel.text = [NSString stringWithFormat:@"%@", task.timeElapsed];
    
    return cell;
}



// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}



// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Get task to delete
        Task *taskToDelete = [taskArray objectAtIndex:indexPath.row];
        
        // Decrement number of tasks from project
        int taskNumber = [self.project.numberOfTasks intValue];
        taskNumber--;
        self.project.numberOfTasks = [NSNumber numberWithInt:taskNumber];
        
        // Delete task from Core Data
        [self.managedObjectContext deleteObject:taskToDelete];
        NSError *error = nil;
        [self.managedObjectContext save:&error];
        
        // Refresh table data
        [self loadData];
        
        // Animate delete
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }
}



// Override to support rearranging the table view.
//- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {}


// Override to support conditional rearranging of the table view.
//- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
//    // Return NO if you do not want the item to be re-orderable.
//    return YES;
//}



#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if ([[segue identifier] isEqualToString:@"addTask"]) {
        UINavigationController *navController = (UINavigationController*)[segue destinationViewController];
        AddTaskViewController *addTaskVC = [[AddTaskViewController alloc] init];
        addTaskVC = (AddTaskViewController*)[navController topViewController];
        addTaskVC.project = self.project;
    }
}


@end
