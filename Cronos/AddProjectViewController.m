//
//  AddProjectViewController.m
//  Cronos
//
//  Created by Samuel Lichlyter on 4/6/15.
//  Copyright (c) 2015 Samuel Lichlyter. All rights reserved.
//

#import "AppDelegate.h"
#import "AddProjectViewController.h"
#import <CronosKit/CronosKit.h>


@interface AddProjectViewController ()

@end

@implementation AddProjectViewController

@synthesize titleTextField;
@synthesize datePickerSwitch;
@synthesize startDatePicker;
@synthesize managedObjectContext;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    titleTextField.delegate = self;
    
    [startDatePicker setHidden:YES];
    
    [startDatePicker addTarget:self action:@selector(toggleDatePicker:) forControlEvents:UIControlEventValueChanged];
    
    [titleTextField becomeFirstResponder];
}

- (IBAction)toggleDatePicker:(id)sender {
    if (datePickerSwitch.isOn) {
        [startDatePicker setHidden:NO];
    } else {
        [startDatePicker setHidden:YES];
    }
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    return  YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
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
    //dismiss save view controller
    [self dismissViewControllerAnimated:YES completion:nil];
    
    //setup save
    AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    self.managedObjectContext = delegate.managedObjectContext;
    NSEntityDescription *projectEntity = [NSEntityDescription entityForName:@"Project" inManagedObjectContext:self.managedObjectContext];
    
    //set newProject to user input
    Project *newProject = [[Project alloc] initWithEntity:projectEntity insertIntoManagedObjectContext:self.managedObjectContext];
    newProject.title = titleTextField.text;
    newProject.numberOfTasks = [NSNumber numberWithInt:0];
    newProject.tasks = [NSSet set];
    if (datePickerSwitch.isOn) {
        newProject.startDate = startDatePicker.date;
    } else {
        newProject.startDate = [NSDate date];
    }
    
    //save
    if ([self.managedObjectContext hasChanges]) {
        NSError *error = nil;
        [self.managedObjectContext save:&error];
        
        //check for errors
        if (error) {
            NSLog(@"error: %@ %@", error, [error userInfo]);
            abort();
        }
    }
        
}

- (IBAction)cancelSelected:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
