//
//  CreateIssueViewController.h
//  Moovizi
//
//  Created by Tchikovani on 01/02/2015.
//  Copyright (c) 2015 Tchikovani. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol CreateIssueDelegate <NSObject>

@required
- (void)issueCreated:(NSDictionary *)issue;

@end

@interface CreateIssueViewController : UIViewController

@property (nonatomic, weak) id <CreateIssueDelegate> delegate;

@end
