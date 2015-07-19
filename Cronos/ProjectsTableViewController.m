//
//  ProjectsTableViewController.m
//  Cronos
//
//  Created by Samuel Lichlyter on 4/9/15.
//  Copyright (c) 2015 Samuel Lichlyter. All rights reserved.
//

#import <CronosKit/CronosKit.h>
#import "AppDelegate.h"
#import "ProjectsTableViewController.h"
#import "ProjectsTableViewCell.h"
#import "TasksTableViewController.h"

@interface ProjectsTableViewController () {
    NSArray *projectArray;
}

@end

@implementation ProjectsTableViewController
@synthesize managedObjectContext;
@synthesize cronosDefaults;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.leftBarButtonItem = self.editButtonItem;
    AppDelegate *delegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    self.managedObjectContext = delegate.managedObjectContext;
    
    self.cronosDefaults = [[NSUserDefaults alloc] initWithSuiteName:@"group.com.samuellichlyter.cronos"];
    
    [self loadData];
    [self checkCompatibility];
    [self shareProjectTitles];
    [self shareTaskTitles];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self loadData];
    [self shareProjectTitles];
    [self shareTaskTitles];
    [self.tableView reloadData];
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

- (void)checkCompatibility {
    //get watch titles
    NSArray *watchTitles = [cronosDefaults valueForKey:@"projectTitlesArray"];
    
    //generate phone titles list
    NSMutableArray *phoneTitles = [[NSMutableArray alloc] init];
    for (NSInteger i = 0; i < [projectArray count]; i++) {
        Project *project = [projectArray objectAtIndex:i];
        NSString *title = project.title;
        
        [phoneTitles addObject:(id)title];
    }
    
    //create syncing alert controller
    UIAlertController *syncAlert = [UIAlertController alertControllerWithTitle:@"Syncing..." message:nil preferredStyle:UIAlertControllerStyleAlert];
    
    //checking state of data
//    if ([phoneTitles isEqualToArray:watchTitles]) {
//        return;
//    } else
    
    
    if (watchTitles.count == phoneTitles.count && [watchTitles isEqualToArray:phoneTitles]) {
        NSLog(@"Arrays are the same, continue");
        return;
    } else if (watchTitles.count > phoneTitles.count) {
        //if projects were added to watch, update phone
        
        NSLog(@"Error: data out of sync");
        [self presentViewController:syncAlert animated:YES completion:nil];
        
        NSLog(@"phoneTitles: %@ watchTitles: %@", phoneTitles, watchTitles);
        
        //sync data here
        NSMutableArray *toAdd = [[NSMutableArray alloc] initWithArray:watchTitles];
        for (NSInteger i = phoneTitles.count-1; i >= 0; i--) {
            for (NSInteger j = watchTitles.count-1; j >= 0; j--) {
                if ([[phoneTitles objectAtIndex:i] isEqualToString:[watchTitles objectAtIndex:j]]) {
                    NSLog(@"removing: %@ atIndex: %li", [toAdd objectAtIndex:j], (long)j);
                    [toAdd removeObject:(id)[watchTitles objectAtIndex:j]];
                }
            }
        }
        
        NSLog(@"projectsToAdd: %@", toAdd);
        
        //add watch projects to Core Data
        NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"Project" inManagedObjectContext:self.managedObjectContext];
        for (NSInteger i = 0; i < toAdd.count; i++) {
            Project *newProject = [[Project alloc] initWithEntity:entityDescription insertIntoManagedObjectContext:self.managedObjectContext];
            newProject.title = [toAdd objectAtIndex:i];
            newProject.tasks = [NSSet set];
            newProject.numberOfTasks = [NSNumber numberWithInt:0];
            
            //add tasks
            NSString *watchTaskKey = [NSString stringWithFormat:@"%@_tasks", newProject.title];
            NSArray *watchTaskTitles = (NSArray*)[self.cronosDefaults objectForKey:watchTaskKey];
            NSMutableArray *watchTasks = [NSMutableArray array];
            NSEntityDescription *taskEntityDescription = [NSEntityDescription entityForName:@"Task" inManagedObjectContext:self.managedObjectContext];
            for (NSInteger j = 0; j < watchTaskTitles.count; j++) {
                Task *newTask = [[Task alloc] initWithEntity:taskEntityDescription insertIntoManagedObjectContext:self.managedObjectContext];
                newTask.title = [watchTaskTitles objectAtIndex:j];
                newTask.timeElapsed = [NSNumber numberWithInt:0];
                newTask.startDate = [NSDate date];
                newTask.project = newProject;
                
                [watchTasks addObject:(id)newTask];
            }
            NSSet *tasksToAdd = [NSSet setWithArray:watchTasks];
            newProject.tasks = tasksToAdd;
            newProject.numberOfTasks = [NSNumber numberWithInteger:tasksToAdd.count];
        }
        
        //save
        NSError *error = nil;
        [self.managedObjectContext save:&error];
        
        //check for errors
        if (error) {
            NSLog(@"error: %@ %@", error, [error userInfo]);
            abort();
        }
        
        [self dismissViewControllerAnimated:YES completion:nil];
    } else {
        UIAlertController *unknownAlert = [UIAlertController alertControllerWithTitle:@"Uh Oh!" message:@"An unkown error ocurred" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *sucksAction = [UIAlertAction actionWithTitle:@"well that sucks" style:UIAlertActionStyleDefault handler:nil];
        [unknownAlert addAction:sucksAction];
        [self presentViewController:unknownAlert animated:YES completion:nil];
    }
    
    //check if tasks are the same
    NSLog(@"Starting task sync");
    for (NSInteger i = 0; i < watchTitles.count; i++) {
        NSString *key = [NSString stringWithFormat:@"%@_tasks", [watchTitles objectAtIndex:i]];
        NSArray *watchTasks = (NSArray*)[self.cronosDefaults objectForKey:key];
        
        for (NSInteger j = 0; j < projectArray.count; j++) {
            Project *phoneProject = [projectArray objectAtIndex:j];
            if ([phoneProject.title isEqualToString:[watchTitles objectAtIndex:i]]) {
                NSArray *phoneTasks = (NSArray*)phoneProject.tasks;
                NSMutableArray *phoneTaskTitles = [NSMutableArray array];
                for (NSInteger k = 0; k < phoneTasks.count; k++) {
                    Task *task = [phoneTasks objectAtIndex:k];
                    [phoneTaskTitles addObject:(id)task.title];
                }
                
                if (![watchTasks isEqualToArray:phoneTaskTitles]) {
                    //sync tasks
                    NSLog(@"need to sync tasks in %@", phoneProject.title);
                }
            }
        }
    }
}

- (void)shareProjectTitles {
    NSMutableArray *projectTitles = [[NSMutableArray alloc] init];
    for (NSInteger i = 0; i < [projectArray count]; i++) {
        Project *project = [projectArray objectAtIndex:i];
        NSString *title = project.title;
        
        [projectTitles addObject:(id)title];
    }
    
    [self.cronosDefaults setObject:(id)projectTitles forKey:@"projectTitlesArray"];
    [self.cronosDefaults synchronize];
}

- (void)shareTaskTitles {
    for (NSInteger i = 0; i < [projectArray count]; i++) {
        Project *project = [projectArray objectAtIndex:i];
        NSArray *taskArray = [project.tasks allObjects];
        NSMutableArray *taskTitles = [[NSMutableArray alloc] init];
        for (NSInteger j = 0; j < [taskArray count]; j++) {
            Task *task = [taskArray objectAtIndex:j];
            [taskTitles addObject:(id)task.title];
        }
        NSString *projectTitle = project.title;
        [self.cronosDefaults setObject:(id)taskTitles forKey:[NSString stringWithFormat:@"%@_tasks", projectTitle]];
    }
    [self.cronosDefaults synchronize];
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
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
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
