//
//  PSHorizontalTableView.m
//  QQMSFContact
//
//  Created by exitingchen on 14/11/18.
//
//

#import "PSHorizontalTableView.h"
#import "PSHorizontalTableCell.h"

#if ! __has_feature(objc_arc)
#error This file must be compiled with ARC. Use -fobjc-arc flag (or convert project to ARC).
#endif

typedef enum PSTemplateContainerScrollDirection{
    PSTemplateContainerScrollDirectionLeft,
    PSTemplateContainerScrollDirectionRight,
    PSTemplateContainerScrollDirectionStill
}PSTemplateContainerScrollDirection;

static const CGFloat kColumMargin = 0;
static const CGFloat kColumWidth = 80;


//////////////////////////////////////////////////////////////////////////////
//PSHorizontalTableView
@interface PSHorizontalTableView ()
@property (nonatomic,strong) NSArray *columModels;
@property (nonatomic,strong) NSMutableArray *resuableColumes;
@property (nonatomic,strong) NSMutableIndexSet *visibleColums;

@end


@implementation PSHorizontalTableView

- (id)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        _columModels = @[] ;
        _resuableColumes = [NSMutableArray array];
        _visibleColums = [[NSMutableIndexSet alloc] init];
        self.showsHorizontalScrollIndicator = NO;
        self.showsVerticalScrollIndicator = NO;
    }
    
    return self;
}

- (void) reloadData
{
    [self returnNonVisibleColumsToThePool: nil];
    [self generateHeightAndOffsetData];
    [self layoutTableColums];
}


- (CGFloat )columWidth
{
    return kColumWidth;
}

- (void) generateHeightAndOffsetData
{
    CGFloat currentOffsetX = 0.0;
    
    BOOL checkWidthForEachColum = [[self delegate] respondsToSelector: @selector(ps_tableViewWidthForColum:colum:)];
    
    NSMutableArray* newColumModels = [NSMutableArray array];
    
    NSInteger numberOfColums = [[self dataSource] numberOfColums:self];
    
    for (NSInteger colum = 0; colum < numberOfColums; colum++)
    {
        PSHorizontalTableCellModel* columModel = [[PSHorizontalTableCellModel alloc] init];
        
        CGFloat columWidth = checkWidthForEachColum ? [[self delegate] ps_tableViewWidthForColum:self colum:colum] : [self columWidth];
        
        columModel.width = columWidth + kColumMargin;
        columModel.startX = currentOffsetX + kColumMargin;
        
        [newColumModels addObject:columModel];
        
        currentOffsetX += (columWidth + kColumMargin);
    }
    
    self.columModels = newColumModels;
    
    [self setContentSize: CGSizeMake(currentOffsetX, self.bounds.size.height)];
}

- (NSInteger) findColumForOffsetX: (CGFloat) xPosition inRange: (NSRange) range
{
    if ([[self columModels] count] == 0) return 0;
    
    PSHorizontalTableCellModel* cellModel = [[PSHorizontalTableCellModel alloc] init];
    cellModel.startX = xPosition;
    
    NSInteger returnValue = [[self columModels] indexOfObject: cellModel
                                                inSortedRange: range
                                                      options: NSBinarySearchingInsertionIndex
                                              usingComparator: ^NSComparisonResult(PSHorizontalTableCellModel* cellModel1, PSHorizontalTableCellModel* cellModel2){
                                                     if (cellModel1.startX < cellModel2.startX)
                                                         return NSOrderedAscending;
                                                     return NSOrderedDescending;
                                             }];
    if (returnValue == 0) return 0;
    return returnValue-1;
}

- (void) layoutTableColums
{
    if (_columModels.count <= 0) {
        return;
    }
    
    CGFloat currentStartX = [self contentOffset].x;
    CGFloat currentEndX = currentStartX + [self frame].size.width;
    
    NSInteger columToDisplay = [self findColumForOffsetX:currentStartX inRange:NSMakeRange(0, _columModels.count)];
    
    NSMutableIndexSet* newVisibleColums = [[NSMutableIndexSet alloc] init];
    
    CGFloat xOrgin;
    CGFloat columWidth;
    do
    {
        [newVisibleColums addIndex: columToDisplay];
        
        xOrgin = [self cellModelAtIndex:columToDisplay].startX;
        columWidth = [self cellModelAtIndex:columToDisplay].width;
        
        PSHorizontalTableCell *cell = [self cellModelAtIndex:columToDisplay].cachedCell;
        
        if (!cell)
        {
            cell = [[self dataSource] ps_tableView:self columForIndexPath:columToDisplay];
            [self cellModelAtIndex:columToDisplay].cachedCell = cell;
            
            cell.frame = CGRectMake(xOrgin, 0, columWidth - kColumMargin, self.bounds.size.height);
            [self addSubview: cell];
        }
        
        columToDisplay++;
    }
    while (xOrgin + columWidth < currentEndX && columToDisplay < _columModels.count);
    
    
//    NSLog(@"laying out %ld row", [_columModels count]);
    
    [self returnNonVisibleColumsToThePool:newVisibleColums];
}

- (PSHorizontalTableCellModel *)cellModelAtIndex:(NSUInteger)columIndex
{
    if (columIndex < _columModels.count) {
        return _columModels[columIndex];
    }
    
    return nil;
}

- (PSHorizontalTableCell *)dequeueReusableCellWithIdentifier:(NSString *)reuseIdentifier
{
    PSHorizontalTableCell *poolCell = nil;
    
    for(PSHorizontalTableCell *cell in _resuableColumes){
        if ([cell.reusableIdentifier isEqual:reuseIdentifier]) {
            poolCell = cell;
            break;
        }
    }
    
    if (poolCell) {
        [_resuableColumes removeObject:poolCell];
    }
    
    return poolCell;
}

- (void) returnNonVisibleColumsToThePool: (NSMutableIndexSet*) currentVisibleColums
{
    [_visibleColums removeIndexes:currentVisibleColums];
    [_visibleColums enumerateIndexesUsingBlock:^(NSUInteger columIdx, BOOL *stop)
     {
         PSHorizontalTableCell* tableViewCell = [self cellModelAtIndex:columIdx].cachedCell;
         if (tableViewCell)
         {
             [_resuableColumes addObject:tableViewCell];
             [tableViewCell removeFromSuperview];
             [self cellModelAtIndex:columIdx].cachedCell = nil;
         }
     }];
    
    self.visibleColums = currentVisibleColums;
}


- (void)adjustCellAt:(NSUInteger)index
{
    if ([_visibleColums containsIndex:index]) {
        CGFloat coumWidth = [self cellModelAtIndex:index].width;
        CGFloat offset = self.contentOffset.x;
        PSHorizontalTableCellModel *model = _columModels[index];
        CGFloat cellX = model.startX;
        if (cellX < offset) {
            CGPoint adjustedOffset = self.contentOffset;
            adjustedOffset.x -= (offset - cellX);
            [self setContentOffset:adjustedOffset animated:YES];
            return;
        }
        
        if (cellX + coumWidth > self.contentOffset.x + self.frame.size.width) {
            CGFloat delta =  (cellX + coumWidth) - (offset + self.frame.size.width);
            CGPoint adjustedOffset = self.contentOffset;
            adjustedOffset.x += delta;
            [self setContentOffset:adjustedOffset animated:YES];
            return;
        }

    }
}

- (void)setContentOffset:(CGPoint)contentOffset
{
    [super setContentOffset:contentOffset];
    [self layoutTableColums];
}

- (NSIndexSet*) indexSetOfVisibleColumIndexes
{
    return [_visibleColums copy];
}

@end

//////////////////////////////////////////////////////////////////////////////
//PSHorizontalTableCellModel
@implementation PSHorizontalTableCellModel

@end
