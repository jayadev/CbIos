//
//  QSMenuViewController.m
//  CubeSale
//
//  Copyright (c) 2014 None. All rights reserved.
//

#import "QSMenuViewController.h"

@interface QSMenuViewController ()
{
    UITableView *menuList;
}
@property(nonatomic,strong)NSMutableArray *items;
@end

@implementation QSMenuViewController

@synthesize items;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.items = [NSMutableArray arrayWithObjects:@"Home", @"My Listings", @"Settings", @"Feedback", nil];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.view.backgroundColor = [UIColor colorWithRed:17.0f/255.0f green:28.0f/255.0f blue:38.0f/255.0f alpha:1];
    menuList = [[UITableView alloc] initWithFrame:CGRectMake(0, 55, self.view.frame.size.width, items.count*44) style:UITableViewStylePlain];
    menuList.backgroundColor = [UIColor clearColor];
    menuList.dataSource = self;
    menuList.delegate = self;
    menuList.scrollEnabled = NO;
    [self.view addSubview:menuList];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma marl - UITableView Data Source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	return items.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	static NSString *cellIdentifier = @"Cell";
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
	if (nil == cell)
	{
		cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellIdentifier];
        cell.backgroundColor = [UIColor clearColor];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.textLabel.textColor = [UIColor whiteColor];
	}

	cell.textLabel.text = [items objectAtIndex:indexPath.row];

	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{

}



@end
