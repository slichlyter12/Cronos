//
//  ProjectsTableViewController.m
//  Cronos
//
//  Created by Samuel Lichlyter on 4/9/15.
//  Copyright (c) 2015 Samuel Lichlyter. All rights reserved.
//

#import "AppDelegate.h"
#import "ProjectsTableViewController.h"
#import "ProjectsTableViewCell.h"
#import "Project.h"
#import "TasksTableViewController.h"

@interface ProjectsTableViewController () {
    NSArray *projectArray;
}

@end

@implementation ProjectsTableViewController
@synthesize managedObjectContext;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.leftBarButtonItem = self.editButtonItem;
    
    AppDelegate *delegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    self.managedObjectContext = delegate.managedObjectContext;
    
    [self loadData];
    
}

- (void)loadData {
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setFetchBatchSize:20];
    
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"Project" inManagedObjectContext:self.managedObjectContext];
    [request setEntity:entityDescription];
    
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"numberOfTasks" ascending:NO];
    NSArray *sortDescriptors = @[sortDescriptor];
    [request setSortDescriptors:sortDescriptors];
    
    NSError *error = nil;
    if (!(projectArray = [self.managedObjectContext executeFetchRequest:request error:&error])) {
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
    return [projectArray count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    ProjectsTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ProjectCell" forIndexPath:indexPath];
    
    Project *project = [projectArray objectAtIndex:indexPath.row];
    
    cell.titleLabel.text = project.title;
    cell.numberOfTasksLabel.text = [NSString stringWithFormat:@"%@", project.numberOfTasks];
    
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
        // Delete the row from the data source
        Project *projectToDelete = [projectArray objectAtIndex:indexPath.row];
        [self.managedObjectContext deleteObject:projectToDelete];
        NSError *error = nil;
        [self.managedObjectContext save:&error];
        [self loadData];
        [self.tableView reloadData];
//        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }
//    else if (editingStyle == UITableViewCellEditingStyleInsert) {
//        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
//    }   
}



// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {}



// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}



#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    
    if ([[segue identifier] isEqualToString:@"showTask"]) {
        NSIndexPath *selectedRow = [[self tableView] indexPathForSelectedRow];
        UINavigationController *navController = (UINavigationController *)[segue destinationViewController];
        TasksTableViewController *taskViewController = [[TasksTableViewController alloc] init];
        taskViewController = (TasksTableViewController *)[navController topViewController];
        Project *selectedProject = [projectArray objectAtIndex:selectedRow.row];
        taskViewController.navigationItem.title = selectedProject.title;
        taskViewController.project = selectedProject;
    }
}


@end
