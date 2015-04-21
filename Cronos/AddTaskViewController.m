//
//  AddTaskViewController.m
//  Cronos
//
//  Created by Samuel Lichlyter on 4/11/15.
//  Copyright (c) 2015 Samuel Lichlyter. All rights reserved.
//

#import "AddTaskViewController.h"
#import "AppDelegate.h"
#import "Task.h"

@interface AddTaskViewController ()

@end

@implementation AddTaskViewController
@synthesize titleTextField;
@synthesize managedObjectContext;
@synthesize project;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    titleTextField.delegate = self;
    
    [titleTextField becomeFirstResponder];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [titleTextField resignFirstResponder];
    return YES;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
- (IBAction)doneSelected:(id)sender {
    
    AppDelegate *delegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    self.managedObjectContext = delegate.managedObjectContext;
    NSEntityDescription *taskEntity = [NSEntityDescription entityForName:@"Task" inManagedObjectContext:self.managedObjectContext];
    
    Task *newTask = [[Task alloc] initWithEntity:taskEntity insertIntoManagedObjectContext:self.managedObjectContext];
    
    //setup task
    newTask.title = titleTextField.text;
    newTask.timeElapsed = [NSNumber numberWithInt:0];
    newTask.startDate = [NSDate date];
    
    //update task.project
    newTask.project = self.project;
    int numberTasks = [newTask.project.numberOfTasks intValue];
    numberTasks++;
    newTask.project.numberOfTasks = [NSNumber numberWithInt:numberTasks];
    
    [newTask.project addTasksObject:newTask];
    
    NSError *error = nil;
    if(![self.managedObjectContext save:&error]) {
        NSLog(@"error: %@ %@", error, [error userInfo]);
        abort();
    }
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)cancelSelected:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
