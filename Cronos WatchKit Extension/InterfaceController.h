//
//  InterfaceController.h
//  Cronos WatchKit Extension
//
//  Created by Samuel Lichlyter on 4/20/15.
//  Copyright (c) 2015 Samuel Lichlyter. All rights reserved.
//

#import <WatchKit/WatchKit.h>
#import <Foundation/Foundation.h>

@interface InterfaceController : WKInterfaceController

@property (weak, nonatomic) IBOutlet WKInterfaceTable *table;
@property (weak, nonatomic) IBOutlet WKInterfaceLabel *emptyLabel;

- (IBAction)doAddProject:(id)sender;

@end
