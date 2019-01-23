//
//  ViewController.m
//  HFHookMessageForward
//
//  Created by hui hong on 2019/1/23.
//  Copyright © 2019 hui hong. All rights reserved.
//

#import "ViewController.h"
#import "Persion.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    Persion *person = [Persion new];
    [person printInfo];
}


@end
