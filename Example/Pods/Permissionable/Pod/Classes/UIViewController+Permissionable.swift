import UIKit


public extension UIViewController
{
    public func request(permission: Permission, _ block: Permission.Result?)
    {
        permission.request(self, block)
    }
}
