//
//  PSHorizontalTableView.h
//  QQMSFContact
//
//  Created by exitingchen on 14/11/18.
//
//

#import <UIKit/UIKit.h>
#import "PSHorizontalTableCell.h"

//////////////////////////////////////////////////////////////////////////////
//PSHorizontalTableView
@class PSHorizontalTableCell;
@class PSHorizontalTableView;

@protocol PSHorizontalTableViewDataSource;

//////////////////////////////////////////////////////////////////////////////
//PSHorizontalTableViewDelegate
@protocol PSHorizontalTableViewDelegate <NSObject,UIScrollViewDelegate>
@required
- (CGFloat)ps_tableViewWidthForColum:(PSHorizontalTableView *)tableView colum:(NSUInteger)colum;
@end

@interface PSHorizontalTableView : UIScrollView
@property (nonatomic,weak) id<PSHorizontalTableViewDelegate> delegate;
@property (nonatomic,weak) id<PSHorizontalTableViewDataSource> dataSource;

- (PSHorizontalTableCell *)dequeueReusableCellWithIdentifier: (NSString*) reuseIdentifier;
- (void)reloadData;
- (NSIndexSet*) indexSetOfVisibleColumIndexes;
- (void)adjustCellAt:(NSUInteger)index;
@end


//////////////////////////////////////////////////////////////////////////////
//PSHorizontalTableCellModel
@interface PSHorizontalTableCellModel : NSObject
//@property (nonatomic,assign) CGRect columFrame;
//@property (nonatomic,assign) NSUInteger columIndex;

@property (nonatomic,assign) CGFloat startX;
@property (nonatomic,assign) CGFloat width;
@property (nonatomic,assign) PSHorizontalTableCell *cachedCell;
@end


//////////////////////////////////////////////////////////////////////////////
//PSHorizontalTableViewDataSource
@protocol PSHorizontalTableViewDataSource <NSObject>
@required
- (PSHorizontalTableCell *)ps_tableView:(PSHorizontalTableView *)tableView columForIndexPath:(NSUInteger)index;
- (NSUInteger)numberOfColums:(PSHorizontalTableView *)tableView;
@end