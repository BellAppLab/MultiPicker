import UIKit


//MARK: Loading Protocols

@objc public protocol UILoaderDelegate: NSObjectProtocol
{
    var loader: UILoader! { get }
    func didChangeLoadingStatus(loading: Bool)
    weak var spinningThing: UIActivityIndicatorView? { get }
}

//MARK: Default Implemententation

public class UILoader: NSObject
{
    private var loadingCount = 0
    private weak var delegate: UILoaderDelegate?
    
    public init(delegate: UILoaderDelegate)
    {
        super.init()
        self.delegate = delegate
    }
    
    public var loading: Bool {
        get {
            return loadingCount > 0
        }
        set {
            let oldValue = self.loading
            
            var shouldNotify = false
            
            if newValue {
                shouldNotify = ++loadingCount == 1
            } else {
                shouldNotify = --loadingCount == 0
                if loadingCount < 0 {
                    loadingCount = 0
                }
            }
            
            if (newValue != oldValue && shouldNotify)
            {
                self.willChangeValueForKey("loading")
                dispatch_async(dispatch_get_main_queue(), { [unowned self] () -> Void in
                    if !newValue {
                        self.delegate?.spinningThing?.stopAnimating()
                    } else {
                        self.delegate?.spinningThing?.startAnimating()
                    }
                    self.delegate?.didChangeLoadingStatus(newValue)
                })
                self.didChangeValueForKey("loading")
            }
        }
    }
}
