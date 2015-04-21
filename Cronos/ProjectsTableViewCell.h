//
//  ProjectsTableViewCell.h
//  Cronos
//
//  Created by Samuel Lichlyter on 4/9/15.
//  Copyright (c) 2015 Samuel Lichlyter. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ProjectsTableViewCell : UITableViewCell

@property (nonatomic, weak) IBOutlet UILabel *titleLabel;
@property (nonatomic, weak) IBOutlet UILabel *numberOfTasksLabel;

@end
