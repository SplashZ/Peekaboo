//
//  ViewController.m
//  Peekaboo
//
//  Created by splashz on 2017/1/11.
//  Copyright © 2017 splashz. All rights reserved.
//

#import "ViewController.h"
#import "PeekabooViewController.h"

@implementation ViewController

- (IBAction)btnClicked:(id)sender {
    PeekabooViewController *vc = [PeekabooViewController new];
    [self.navigationController pushViewController:vc animated:YES];
}

@end
