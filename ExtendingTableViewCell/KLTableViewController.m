//
//  KLTableViewController.m
//  ExtendingTableViewCell
//
//  Created by Kevin Chen on 7/7/14.
//  Copyright (c) 2014 KnightLord Universe Technolegies Ltd. All rights reserved.
//

#import "KLTableViewController.h"
#import "KLPickerViewCell.h"
#import "KLDatePickerViewCell.h"

@interface KLTableViewController () <UIPickerViewDataSource, UIPickerViewDelegate>

@property (nonatomic, strong) NSMutableArray* tableData;
@property (nonatomic, strong) NSIndexPath *selectedIndexPath;
@property (nonatomic, strong) NSDateFormatter *dateFormatter;

@end

@implementation KLTableViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    // Intialize some table view cell data
    self.tableData = [@[
                        @{@"title" : @"Address", @"type" : @"normal", @"value" : @"1 Infinite Loop Cupertino, CA 95014"},
                        @{@"title" : @"Birthday", @"type" : @"datepicker"},
                        @{@"title" : @"Gender", @"type" : @"picker", @"value" : @"Male"},
                        @{@"title" : @"Wake Up", @"type" : @"datepicker"},
                        @{@"title" : @"Telephone", @"type" : @"normal", @"value" : @"1(408)-996-1010"}
                        ] mutableCopy];
    
    self.dateFormatter = [[NSDateFormatter alloc] init];
    self.dateFormatter.dateStyle = NSDateFormatterShortStyle;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (BOOL)hasInlineExtendingCell {
    return (self.selectedIndexPath != nil);
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // In this sample, we only have one section
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger numberOfRows = [self.tableData count];
    if ([self hasInlineExtendingCell]) {
        numberOfRows += 1;
    }
    
    return numberOfRows;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger dataRow = indexPath.row;
    if (self.selectedIndexPath && self.selectedIndexPath.section == indexPath.section && indexPath.row > self.selectedIndexPath.row) {
        dataRow -= 1;
    }
    
    NSDictionary *rowData = self.tableData[dataRow];
    NSString *type = rowData[@"type"];
    
    if (self.selectedIndexPath
        && self.selectedIndexPath.section == indexPath.section
        && self.selectedIndexPath.row == (indexPath.row - 1))  {
        // In this sample we always put the inline cell under the selected cell
        
        
        if ([type isEqualToString:@"picker"]) {
            NSString *gender = rowData[@"value"];
            KLPickerViewCell *pickerViewCell = [tableView dequeueReusableCellWithIdentifier:@"PickerViewCell"];
            pickerViewCell.pickerView.delegate = self;
            pickerViewCell.pickerView.dataSource = self;
            [pickerViewCell.pickerView reloadAllComponents];
            
            if (gender) {
                [pickerViewCell.pickerView selectRow: (([gender isEqualToString:@"Male"]) ? 0 : 1)
                                         inComponent:0
                                            animated:YES];
            }
            
            return pickerViewCell;
            
        } else if ([type isEqualToString:@"datepicker"]) {
            
            KLDatePickerViewCell *datePickerViewCell = [tableView dequeueReusableCellWithIdentifier:@"DatePickerViewCell"];
            NSDate *date = rowData[@"value"];
            NSString *title = rowData[@"title"];
            if ([title isEqualToString:@"Birthday"]) {
                datePickerViewCell.datePicker.datePickerMode = UIDatePickerModeDate;
                
            } else if ([title isEqualToString:@"Wake Up"]) {
                datePickerViewCell.datePicker.datePickerMode = UIDatePickerModeTime;
            }
            
            if ([self respondsToSelector:@selector(targetForAction:withSender:)]) {
                // iOS 7 above
                if ([datePickerViewCell.datePicker targetForAction:@selector(handleDatePickerValueChanged:)
                                                        withSender:datePickerViewCell.datePicker] == nil) {
                    [datePickerViewCell.datePicker addTarget:self
                                                      action:@selector(handleDatePickerValueChanged:)
                                            forControlEvents:UIControlEventValueChanged];

                }
            } else {
                // below iOS 7
                [datePickerViewCell.datePicker addTarget:self
                                                  action:@selector(handleDatePickerValueChanged:)
                                        forControlEvents:UIControlEventValueChanged];

            }
            
            if (date) {
                [datePickerViewCell.datePicker setDate:date animated:YES];
            }
            
            return datePickerViewCell;
        }

        
        // here return the inline cell
        
    }
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"NormalCell"];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"NormalCell"];
    }
    
     NSString *title = rowData[@"title"];
    
    cell.textLabel.text = title;
    if ([type isEqualToString:@"datepicker"]) {
        if ([title isEqualToString:@"Birthday"]) {
            self.dateFormatter.dateStyle = NSDateFormatterShortStyle;
            self.dateFormatter.dateFormat = nil;
        } else if ([title isEqualToString:@"Wake Up"]) {
            self.dateFormatter.dateStyle = NSDateFormatterNoStyle;
            self.dateFormatter.dateFormat = @"hh:mm a";
        }
        cell.detailTextLabel.text = rowData[@"value"] ? [self.dateFormatter stringFromDate:rowData[@"value"]] : @"Any";
    } else {
        cell.detailTextLabel.text = rowData[@"value"] ? rowData[@"value"] : @"Any";
    }
    
    return cell;
    
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat heightForRow = tableView.rowHeight;
    
    
    if (self.selectedIndexPath
        && self.selectedIndexPath.section == indexPath.section
        && self.selectedIndexPath.row == indexPath.row - 1) {
        // Inline PickerView always the one after the selected normal cell
        heightForRow = 216.0f;
    }
    
    
    return heightForRow;
    

}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSInteger dataRow = indexPath.row;
    
    if (self.selectedIndexPath && self.selectedIndexPath.section == indexPath.section && indexPath.row > self.selectedIndexPath.row) {
        dataRow -= 1;
        
    }
    
    NSDictionary *rowData = self.tableData[dataRow];
    
    if (![rowData[@"type"] isEqualToString:@"normal"]) {
        
         [self displayOrHideInlinePickerViewForIndexPath:indexPath];
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    [self.tableView scrollToRowAtIndexPath:self.selectedIndexPath ? self.selectedIndexPath : indexPath
                          atScrollPosition:UITableViewScrollPositionTop
                                  animated:YES];
    
}

- (void)displayOrHideInlinePickerViewForIndexPath:(NSIndexPath *)indexPath {
    
    [self.tableView beginUpdates];
    
    if (self.selectedIndexPath == nil) {
        self.selectedIndexPath = indexPath;
        [self.tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:(indexPath.row + 1) inSection:indexPath.section]]
                              withRowAnimation:UITableViewRowAnimationFade];
        
    } else if (self.selectedIndexPath.section == indexPath.section && self.selectedIndexPath.row == indexPath.row) {
        
        [self.tableView deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:(indexPath.row + 1) inSection:indexPath.section]]
                              withRowAnimation:UITableViewRowAnimationFade];
        self.selectedIndexPath = nil;
        
    } else if (self.selectedIndexPath.section != indexPath.section || self.selectedIndexPath.row != indexPath.row) {
        
        [self.tableView deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:(self.selectedIndexPath.row + 1) inSection:self.selectedIndexPath.section]]
                              withRowAnimation:UITableViewRowAnimationFade];
        
        // After the deletion operation the then indexPath of original table view changed to the resulting table view
        if (indexPath.section == self.selectedIndexPath.section && indexPath.row > self.selectedIndexPath.row) {
            
            [self.tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:indexPath.row inSection:indexPath.section]]
                                  withRowAnimation:UITableViewRowAnimationFade];
            self.selectedIndexPath = [NSIndexPath indexPathForRow:indexPath.row - 1 inSection:indexPath.section];
            
        } else {
            [self.tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:(indexPath.row + 1) inSection:indexPath.section]]
                                  withRowAnimation:UITableViewRowAnimationFade];
            self.selectedIndexPath = indexPath;
        }
    }
    
    
    
    [self.tableView endUpdates];
}

#pragma mark - UIPickerView

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    return 2;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    NSString *titleForRow = nil;
    switch (row) {
        case 0:
            titleForRow = @"Male";
            break;
            
        case 1:
            titleForRow = @"Female";
            break;
            
        default:
            break;
    }
    
    return titleForRow;
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    NSMutableDictionary *rowData = [self.tableData[self.selectedIndexPath.row] mutableCopy];
    rowData[@"value"] = (row == 0) ? @"Male" : @"Female";
    
    self.tableData[self.selectedIndexPath.row] = rowData;
    
    [self.tableView reloadRowsAtIndexPaths:@[self.selectedIndexPath]
                          withRowAnimation:UITableViewRowAnimationAutomatic];
    
}

- (void)handleDatePickerValueChanged:(UIDatePicker *)datePicker {
    NSMutableDictionary *rowData = [self.tableData[self.selectedIndexPath.row] mutableCopy];
    rowData[@"value"] = datePicker.date;
    
    self.tableData[self.selectedIndexPath.row] = rowData;
    
    [self.tableView reloadRowsAtIndexPaths:@[self.selectedIndexPath]
                          withRowAnimation:UITableViewRowAnimationAutomatic];
    
}

@end
