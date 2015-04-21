//
//  TaskTableViewCell.h
//  Cronos
//
//  Created by Samuel Lichlyter on 4/11/15.
//  Copyright (c) 2015 Samuel Lichlyter. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TaskTableViewCell : UITableViewCell

@property (nonatomic, weak) IBOutlet UILabel *titleLabel;
@property (nonatomic, weak) IBOutlet UILabel *timeLabel;

@end
