//
//  AddTaskViewController.h
//  Cronos
//
//  Created by Samuel Lichlyter on 4/11/15.
//  Copyright (c) 2015 Samuel Lichlyter. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Project.h"

@interface AddTaskViewController : UIViewController <UITextFieldDelegate>

@property (nonatomic, weak) IBOutlet UITextField *titleTextField;
@property (nonatomic, weak) Project *project;

@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;

@end
