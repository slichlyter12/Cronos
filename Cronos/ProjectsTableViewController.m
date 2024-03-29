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
    self.navigationItem.leftBarButtonItem = self.editButtonItem;
    AppDelegate *delegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    self.managedObjectContext = delegate.managedObjectContext;
    
    self.cronosDefaults = [[NSUserDefaults alloc] initWithSuiteName:@"group.com.samuellichlyter.cronos"];
    
    // Initialize the refresh control
    self.refreshControl = [[UIRefreshControl alloc] init];
    self.refreshControl.backgroundColor = [UIColor purpleColor];
    self.refreshControl.tintColor = [UIColor whiteColor];
    [self.refreshControl addTarget:self action:@selector(refreshData) forControlEvents:UIControlEventValueChanged];
}

- (void)viewDidAppear:(BOOL)animated {
    [self refreshData];
    NSLog(@"ending viewDidAppear");
}

- (void)refreshData {
    [self loadData];
    [self checkCompatibility];
    [self.tableView reloadData];
    if ([self.refreshControl isRefreshing]) {
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"MMM d, h:mm a"];
        NSString *title = [NSString stringWithFormat:@"Last updated: %@", [formatter stringFromDate:[NSDate date]]];
        NSDictionary *attributesDictionary = [NSDictionary dictionaryWithObject:[UIColor whiteColor] forKey:NSForegroundColorAttributeName];
        NSAttributedString *attributedString = [[NSAttributedString alloc] initWithString:title attributes:attributesDictionary];
        self.refreshControl.attributedTitle = attributedString;
        [self.refreshControl endRefreshing];
    }
}

- (void)loadData {
    NSLog(@"Starting Load Data");
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
    
    //checking state of data
    if (watchTitles.count == phoneTitles.count && [watchTitles isEqualToArray:phoneTitles]) {
        NSLog(@"Arrays are the same, continue");
    } else if (watchTitles == NULL && [phoneTitles isEqualToArray:[NSMutableArray array]]){
        NSLog(@"There are no Projects, nothing to sync");
    } else if (watchTitles.count > phoneTitles.count) {
        //if projects were added to watch, update phone
        
        NSLog(@"Error: data out of sync");
        
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
        
    } else if (phoneTitles.count > watchTitles.count) {
        
        NSLog(@"Sharing all data with CronosDefaults");
        [self shareProjectTitles];
        [self shareTaskTitles];
        
    } else {
        UIAlertController *unknownAlert = [UIAlertController alertControllerWithTitle:@"Uh Oh!" message:@"An unkown error ocurred" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *sucksAction = [UIAlertAction actionWithTitle:@"well that sucks" style:UIAlertActionStyleDefault handler:nil];
        [unknownAlert addAction:sucksAction];
        [self presentViewController:unknownAlert animated:YES completion:nil];
    }
    
    //check if tasks are the same
    for (NSInteger i = 0; i < watchTitles.count; i++) {
        NSLog(@"Starting task sync");
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
    if (projectArray.count > 0) {
        self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
        self.tableView.backgroundView = nil;
        return 1;
    } else {
        UILabel *emptyLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height)];
        
        emptyLabel.text = @"You have no projects. Add one by tapping the plus in the top right.\n\nOr pull to refresh if you created projects on your Apple Watch.";
        emptyLabel.textColor = [UIColor blackColor];
        emptyLabel.numberOfLines = 0;
        emptyLabel.textAlignment = NSTextAlignmentCenter;
//        emptyLabel.font = [UIFont systemFontOfSize:20];
        emptyLabel.font = [UIFont fontWithName:@"Palatino-Italic" size:20];
        [emptyLabel sizeToFit];
        
        self.tableView.backgroundView = emptyLabel;
        self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    }
    
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
        // Select project to delete
        Project *projectToDelete = [projectArray objectAtIndex:indexPath.row];
        
        // Delete the row from the data source
        [self.managedObjectContext deleteObject:projectToDelete];
        NSError *error = nil;
        [self.managedObjectContext save:&error];
                
        // Sync managedObjectContext to projectArray
        [self loadData];
        [self shareProjectTitles];
        
        // Animate delete
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }  
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
