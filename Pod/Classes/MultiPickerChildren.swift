import UIKit
import Photos


//MARK: - Children
class AlbumList: UITableViewController, MultiPickerChild, PHPhotoLibraryChangeObserver
{
    //MARK: Data Model
    private var fetchResults: [PHFetchResult] = []
    private var assetCollections: [PHAssetCollection]!
    
    private func updateAssetCollections()
    {
        self.assetCollections = []
        
        // Filter albums
        var smartAlbums: [PHAssetCollectionSubtype: PHAssetCollection] = [:]
        var userAlbums: [PHAssetCollection] = []
        
        self.fetchResults.forEach { (result: PHFetchResult) -> () in
            result.enumerateObjectsUsingBlock { (object: AnyObject, index: Int, stop: UnsafeMutablePointer<ObjCBool>) -> Void in
                if let assetCollection = object as? PHAssetCollection {
                    if assetCollection.assetCollectionSubtype == .AlbumRegular {
                        userAlbums.append(assetCollection)
                    } else if self.multiPicker.subtypes.contains(assetCollection.assetCollectionSubtype) {
                        smartAlbums.updateValue(assetCollection, forKey: assetCollection.assetCollectionSubtype)
                    }
                }
            }
        }
        
        // Fetch smart albums
        self.multiPicker.subtypes.forEach { (subtype: PHAssetCollectionSubtype) -> () in
            if let assetCollection = smartAlbums[subtype] {
                self.assetCollections.append(assetCollection)
            }
        }
        
        // Fetch user albums
        userAlbums.forEach { (album: PHAssetCollection) -> () in
            self.assetCollections.append(album)
        }
    }
    
    //MARK: UI Elements
    @IBOutlet var doneBarButtonItem: UIBarButtonItem!
    @IBOutlet var cancelBarButtonItem: UIBarButtonItem!
    @IBOutlet var clearBarButtonItem: UIBarButtonItem!
    
    //MARK: View Controller Life Cycle
    deinit {
        PHPhotoLibrary.sharedPhotoLibrary().unregisterChangeObserver(self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = NSLocalizedString("Photos", comment: "")
        self.navigationItem.prompt = self.multiPicker.prompt
        
        self.fetchResults.append(PHAssetCollection.fetchAssetCollectionsWithType(.SmartAlbum, subtype: .Any, options: nil))
        self.fetchResults.append(PHAssetCollection.fetchAssetCollectionsWithType(.Album, subtype: .Any, options: nil))
        
        PHPhotoLibrary.sharedPhotoLibrary().registerChangeObserver(self)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        self.updateUI()
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        super.prepareForSegue(segue, sender: sender)
        
        if let controller = segue.destinationViewController as? AssetGrid {
            controller.multiPicker = self.multiPicker
            controller.assetCollection = self.assetCollections[self.tableView.indexPathForSelectedRow!.row]
        }
    }
    
    //MARK: Scroll View Delegate
    private var scrolling = false
    
    override func scrollViewWillBeginDragging(scrollView: UIScrollView) {
        self.scrolling = true
    }
    
    override func scrollViewDidEndDragging(scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if decelerate {
            return
        }
        self.scrolling = false
        self.updateVisibleCells()
    }
    
    override func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        self.scrolling = false
        self.updateVisibleCells()
    }
    
    override func scrollViewDidEndScrollingAnimation(scrollView: UIScrollView) {
        self.scrolling = false
        self.updateVisibleCells()
    }
    
    //MARK: Table View Data Source
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.assetCollections.count
    }
    
    private static let cellId = "AlbumCell"
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(AlbumList.cellId, forIndexPath: indexPath) as! ListCell
        
        self.update(cell, indexPath)
        
        return cell
    }
    
    private func updateVisibleCells() {
        if let visibleIndexPaths = self.tableView.indexPathsForVisibleRows {
            for indexPath in visibleIndexPaths {
                if let cell = self.tableView.cellForRowAtIndexPath(indexPath) as? ListCell {
                    self.update(cell, indexPath)
                }
            }
        }
    }
    
    private func update(cell: ListCell, _ indexPath: NSIndexPath) {
        // Thumbnail
        let assetCollection = self.assetCollections[indexPath.row]
        let options = PHFetchOptions()
        options.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: true)]
        options.predicate = NSPredicate(format: "mediaType == %ld", argumentArray: [PHAssetMediaType.Image.rawValue])
        
        let fetchResult = PHAsset.fetchAssetsInAssetCollection(assetCollection, options: options)
        
        if !self.scrolling {
            let manager = PHImageManager.defaultManager()
            
            func configureImageView(atIndex index: Int) {
                if let imageView = cell.view(atIndex: index) {
                    if fetchResult.count >= index {
                        imageView.hidden = false
                        
                        manager.requestImageForAsset(fetchResult[fetchResult.count - index] as! PHAsset, targetSize: ScaledSize.make(imageView.frame.size), contentMode: .AspectFill, options: nil, resultHandler:
                            { (result: UIImage?, info: [NSObject : AnyObject]?) -> Void in
                                imageView.image = result
                        })
                    } else if fetchResult.count == 0 {
                        imageView.hidden = false
                        // Set placeholder image
                        imageView.image = UIImage.placeholder(imageView.frame.size)
                    }
                }
            }
            
            configureImageView(atIndex: 3)
            configureImageView(atIndex: 2)
            configureImageView(atIndex: 1)
        }
        
        // Album title
        cell.titleLabel.text = assetCollection.localizedTitle
        
        // Number of photos
        cell.countLabel.text = String(format: "%lu", arguments: [fetchResult.count])
    }
    
    //MARK: Multi Picker Child
    weak var multiPicker: MultiPicker!
    
    func updateUI() {
        if self.multiPicker.cancelButtonVisible {
            self.navigationItem.setLeftBarButtonItem(self.cancelBarButtonItem, animated: true)
        }
        if self.multiPicker.doneButtonVisible {
            self.doneBarButtonItem.enabled = self.multiPicker.doneButtonEnabled
            self.navigationItem.setRightBarButtonItem(self.doneBarButtonItem, animated: true)
            if self.multiPicker.showsCount {
                self.setToolbarItems(defaultToolbarItems(defaultTitle(self.multiPicker.selected.count)), animated: true)
            }
            return
        }
        self.navigationItem.setRightBarButtonItem(nil, animated: true)
        if self.multiPicker.clearButtonVisible {
            self.navigationItem.setLeftBarButtonItem(self.clearBarButtonItem, animated: true)
            if self.multiPicker.showsCount {
                self.setToolbarItems(defaultToolbarItems(defaultTitle(self.multiPicker.selected.count)), animated: true)
            }
            return
        }
        self.navigationItem.setLeftBarButtonItem(nil, animated: true)
        self.setToolbarItems(nil, animated: true)
    }
    
    //MARK: Photo Library Change Observer
    func photoLibraryDidChange(changeInstance: PHChange) {
        var fetchResults: [PHFetchResult] = []
        fetchResults.appendContentsOf(self.fetchResults)
        dispatch_async(dispatch_get_main_queue(), { [unowned self] () -> Void in
            for var i=0; i<self.fetchResults.count; i++ {
                if let changeDetails = changeInstance.changeDetailsForFetchResult(self.fetchResults[i]) {
                    fetchResults[i] = changeDetails.fetchResultAfterChanges
                }
            }
            
            if self.fetchResults != fetchResults {
                self.fetchResults = fetchResults
                
                self.updateAssetCollections()
                self.tableView.reloadData()
            }
        })
    }
    
    //MARK: Actions
    @IBAction func donePressed(sender: UIBarButtonItem) {
        self.multiPicker.donePressed(sender)
    }
    
    @IBAction func cancelPressed(sender: UIBarButtonItem) {
        self.multiPicker.cancelPressed(sender)
    }
    
    @IBAction func clearPressed(sender: UIBarButtonItem) {
        self.multiPicker.clear()
        self.updateUI()
    }
}

class AssetGrid: UICollectionViewController, MultiPickerChild, PHPhotoLibraryChangeObserver, UICollectionViewDelegateFlowLayout
{
    //MARK: Data Model
    var assetCollection: PHAssetCollection! {
        didSet {
            if assetCollection != nil {
                let options = PHFetchOptions()
                options.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: true)]
                options.predicate = NSPredicate(format: "mediaType == %ld", argumentArray: [PHAssetMediaType.Image.rawValue])
                
                self.fetchResult = PHAsset.fetchAssetsInAssetCollection(self.assetCollection, options:options)
            } else {
                self.fetchResult = nil
            }
        }
    }
    private var fetchResult: PHFetchResult!
    
    private lazy var manager: PHCachingImageManager = {
        return PHCachingImageManager()
    }()
    
    //MARK: UI Elements
    @IBOutlet var doneBarButtonItem: UIBarButtonItem!
    
    //MARK: View Controller Life Cycle
    deinit {
        PHPhotoLibrary.sharedPhotoLibrary().unregisterChangeObserver(self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = self.assetCollection.localizedTitle
        self.navigationItem.prompt = self.multiPicker.prompt
        
        self.collectionView?.allowsMultipleSelection = self.multiPicker.multiple
        
        PHPhotoLibrary.sharedPhotoLibrary().registerChangeObserver(self)
        
        self.manager.startCachingImagesForAssets(self.fetchResult.objectsAtIndexes(NSIndexSet(indexesInRange: NSMakeRange(0, self.fetchResult.count))) as! [PHAsset], targetSize: ScaledSize.make((self.collectionViewLayout as! UICollectionViewFlowLayout).itemSize), contentMode: .AspectFill, options: nil)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        self.updateUI()
        
        // Scroll to bottom
        if self.fetchResult.count > 0 && self.isMovingToParentViewController() {
            self.collectionView?.scrollToItemAtIndexPath(NSIndexPath(forItem: self.fetchResult.count - 1, inSection: 0), atScrollPosition: .Top, animated: false)
        }
    }
    
    override func viewWillDisappear(animated: Bool) {
        self.manager.stopCachingImagesForAllAssets()
        
        super.viewWillDisappear(animated)
    }
    
    //MARK: Scroll View Delegate
    private var scrolling = false
    
    override func scrollViewWillBeginDragging(scrollView: UIScrollView) {
        self.scrolling = true
    }
    
    override func scrollViewDidEndDragging(scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if decelerate {
            return
        }
        self.scrolling = false
        self.updateVisibleCells()
    }
    
    override func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        self.scrolling = false
        self.updateVisibleCells()
    }
    
    override func scrollViewDidEndScrollingAnimation(scrollView: UIScrollView) {
        self.scrolling = false
        self.updateVisibleCells()
    }
    
    //MARK: Collection View Delegate
    override func collectionView(collectionView: UICollectionView, shouldSelectItemAtIndexPath indexPath: NSIndexPath) -> Bool {
        if let cell = collectionView.cellForItemAtIndexPath(indexPath) as? GridCell {
            return self.multiPicker.shouldAdd(cell.asset)
        }
        return false
    }
    
    override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        if let cell = collectionView.cellForItemAtIndexPath(indexPath) as? GridCell {
            cell.tag = self.multiPicker.add(cell.asset)
            self.updateUI()
        }
    }
    
    override func collectionView(collectionView: UICollectionView, shouldDeselectItemAtIndexPath indexPath: NSIndexPath) -> Bool {
        if let cell = collectionView.cellForItemAtIndexPath(indexPath) as? GridCell {
            return self.multiPicker.shouldRemove(assetAtIndex: cell.tag)
        }
        return false
    }
    
    override func collectionView(collectionView: UICollectionView, didDeselectItemAtIndexPath indexPath: NSIndexPath) {
        if let cell = collectionView.cellForItemAtIndexPath(indexPath) as? GridCell {
            cell.tag = self.multiPicker.remove(assetAtIndex: cell.tag)
            self.updateUI()
        }
    }
    
    //MARK: Collection View Data Source
    private static let cellId = "GridCell"
    
    override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.fetchResult.count
    }
    
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(AssetGrid.cellId, forIndexPath: indexPath) as! GridCell
        
        if !self.multiPicker.multiple {
            cell.selectedView?.removeFromSuperview()
            cell.selectedView = nil
        }
        
        self.update(cell, indexPath)
        
        return cell
    }
    
    private func updateVisibleCells() {
        if let visibleIndexPaths = self.collectionView?.indexPathsForVisibleItems() {
            for indexPath in visibleIndexPaths {
                if let cell = self.collectionView?.cellForItemAtIndexPath(indexPath) as? GridCell {
                    self.update(cell, indexPath)
                }
            }
        }
    }
    
    private func update(cell: GridCell, _ indexPath: NSIndexPath) {
        if self.scrolling {
            if let loader = cell.loader {
                if loader.loading {
                    return
                }
            }
            cell.loader?.loading = true
            return
        }
        
        cell.loader?.loading = false
        
        // Image
        let asset = self.fetchResult[indexPath.item] as! PHAsset
        
        self.manager.requestImageForAsset(asset, targetSize: (self.collectionView!.collectionViewLayout as! UICollectionViewFlowLayout).itemSize, contentMode: .AspectFill, options: nil)
        { (result: UIImage?, info: [NSObject : AnyObject]?) -> Void in
            cell.imageView.image = result
        }
        
        // Selection state
        let selected = self.multiPicker.selected.contains { (item: (Int, PHAsset)) -> Bool in
            let result = item.1 == asset
            cell.tag = result ? item.0 : 0
            return result
        }
        cell.selected = selected
        if selected {
            self.collectionView!.selectItemAtIndexPath(indexPath, animated: false, scrollPosition: .None)
        }
    }
    
    //MARK: Collection View Delegate Flow Layout
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        var width = 120
        var columns = 1
        var result: CGFloat = 0
        let spacing = Int(self.multiPicker.cellSpacing)
        while width <= 60 {
            result = CGFloat((width * columns) + ((columns + 1) * spacing))
            while result <= collectionView.frame.size.width {
                if result == collectionView.frame.size.width {
                    return CGSizeMake(CGFloat(width), CGFloat(width))
                }
                columns++
            }
            width--
            columns = 1
        }
        return CGSizeMake(CGFloat(width), CGFloat(width))
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAtIndex section: Int) -> CGFloat {
        return self.multiPicker.cellSpacing
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAtIndex section: Int) -> CGFloat {
        return self.multiPicker.cellSpacing
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAtIndex section: Int) -> UIEdgeInsets {
        return UIEdgeInsetsMake(self.multiPicker.cellSpacing, self.multiPicker.cellSpacing, self.multiPicker.cellSpacing, self.multiPicker.cellSpacing)
    }
    
    //MARK: Multi Picker Child
    weak var multiPicker: MultiPicker!
    
    func updateUI() {
        if self.multiPicker.doneButtonVisible {
            self.doneBarButtonItem.enabled = self.multiPicker.doneButtonEnabled
            self.navigationItem.setRightBarButtonItem(self.doneBarButtonItem, animated: true)
            self.setToolbarItems(defaultToolbarItems(defaultTitle(self.multiPicker.selected.count)), animated: true)
            return
        }
        self.navigationItem.setRightBarButtonItem(nil, animated: true)
        if self.multiPicker.clearButtonVisible {
            self.setToolbarItems(defaultToolbarItems(defaultTitle(self.multiPicker.selected.count)), animated: true)
            return
        }
        self.setToolbarItems(nil, animated: true)
    }
    
    //MARK: Photo Library Change Observer
    func photoLibraryDidChange(changeInstance: PHChange) {
        dispatch_async(dispatch_get_main_queue()) { [unowned self] () -> Void in
            if let collectionChanges = changeInstance.changeDetailsForFetchResult(self.fetchResult) {
                // Get the new fetch result
                self.fetchResult = collectionChanges.fetchResultAfterChanges
                
                if !collectionChanges.hasIncrementalChanges || collectionChanges.hasMoves {
                    // We need to reload all if the incremental diffs are not available
                    self.collectionView?.reloadData()
                } else {
                    // If we have incremental diffs, tell the collection view to animate insertions and deletions
                    self.collectionView!.performBatchUpdates({ [unowned self] () -> Void in
                        if let removed = collectionChanges.removedIndexes {
                            self.collectionView?.deleteItemsAtIndexPaths(removed.indexPaths(forSection: 0))
                        }
                        if let inserted = collectionChanges.insertedIndexes {
                            self.collectionView?.insertItemsAtIndexPaths(inserted.indexPaths(forSection: 0))
                        }
                        if let changed = collectionChanges.changedIndexes {
                            self.collectionView?.reloadItemsAtIndexPaths(changed.indexPaths(forSection: 0))
                        }
                    }, completion: nil)
                }
            }
        }
    }
    
    //MARK: Actions
    @IBAction func donePressed(sender: UIBarButtonItem) {
        self.multiPicker.donePressed(sender)
    }
    
    @IBAction func cancelPressed(sender: UIBarButtonItem) {
        self.multiPicker.cancelPressed(sender)
    }
    
    @IBAction func clearPressed(sender: UIBarButtonItem) {
        self.multiPicker.clear()
        self.updateUI()
    }
}


//MARK: - Aux
private func defaultTitle(items: Int) -> String
{
    return String(format: items == 1 ? NSLocalizedString("%d item selected", comment: "") : NSLocalizedString("%d items selected", comment: ""), arguments: [items])
}

private func defaultToolbarItems(title: String) -> [UIBarButtonItem]
{
    return [UIBarButtonItem(barButtonSystemItem: .FlexibleSpace, target: nil, action: nil), UIBarButtonItem(title: title, style: .Plain, target: nil, action: nil), UIBarButtonItem(barButtonSystemItem: .FlexibleSpace, target: nil, action: nil)]
}

struct ScaledSize
{
    private static let scale = UIScreen.mainScreen().scale
    
    static func make(size: CGSize) -> CGSize
    {
        return CGSizeMake(size.width * self.scale, size.height * self.scale)
    }
}

extension UIImage
{
    static func placeholder(size: CGSize) -> UIImage
    {
        UIGraphicsBeginImageContext(size)
        let context = UIGraphicsGetCurrentContext()
        
        let backgroundColor = UIColor.placeholderBackgroundColor()
        let iconColor = UIColor.placeholderIconColor()
        
        // Background
        CGContextSetFillColorWithColor(context, backgroundColor.CGColor)
        CGContextFillRect(context, CGRectMake(0, 0, size.width, size.height))
        
        // Icon (back)
        let backIconRect = CGRectMake(size.width * (16.0 / 68.0),
            size.height * (20.0 / 68.0),
            size.width * (32.0 / 68.0),
            size.height * (24.0 / 68.0))
        
        CGContextSetFillColorWithColor(context, iconColor.CGColor)
        CGContextFillRect(context, backIconRect);
        
        CGContextSetFillColorWithColor(context, backgroundColor.CGColor)
        CGContextFillRect(context, CGRectInset(backIconRect, 1.0, 1.0))
        
        // Icon (front)
        let frontIconRect = CGRectMake(size.width * (20.0 / 68.0),
            size.height * (24.0 / 68.0),
            size.width * (32.0 / 68.0),
            size.height * (24.0 / 68.0))
        
        CGContextSetFillColorWithColor(context, backgroundColor.CGColor)
        CGContextFillRect(context, CGRectInset(frontIconRect, -1.0, -1.0))
        
        CGContextSetFillColorWithColor(context, iconColor.CGColor)
        CGContextFillRect(context, frontIconRect)
        
        CGContextSetFillColorWithColor(context, backgroundColor.CGColor)
        CGContextFillRect(context, CGRectInset(frontIconRect, 1.0, 1.0))
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return image
    }
}

extension UIColor
{
    static func placeholderBackgroundColor() -> UIColor
    {
        return UIColor(red: 239.0 / 255.0, green: 239.0 / 255.0, blue: 244.0 / 255.0, alpha: 1)
    }
    
    static func placeholderIconColor() -> UIColor
    {
        return UIColor(red: 179.0 / 255.0, green: 179.0 / 255.0, blue: 182.0 / 255.0, alpha: 1)
    }
}

extension NSIndexSet
{
    func indexPaths(forSection section: Int) -> [NSIndexPath]
    {
        var result: [NSIndexPath] = []
        self.enumerateIndexesUsingBlock { (index: Int, stop: UnsafeMutablePointer<ObjCBool>) -> Void in
            result.append(NSIndexPath(forItem: index, inSection: section))
        }
        return result
    }
}
