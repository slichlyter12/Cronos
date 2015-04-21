//
//  AddProjectViewController.h
//  Cronos
//
//  Created by Samuel Lichlyter on 4/6/15.
//  Copyright (c) 2015 Samuel Lichlyter. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AddProjectViewController : UIViewController <UITextFieldDelegate>

@property (nonatomic, weak) IBOutlet UITextField *titleTextField;
@property (nonatomic, weak) IBOutlet UISwitch *datePickerSwitch;
@property (nonatomic, weak) IBOutlet UIDatePicker *startDatePicker;

@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;

- (IBAction)doneSelected:(id)sender;
- (IBAction)cancelSelected:(id)sender;

@end
