import Foundation
import AsyncDisplayKit

public final class ContextMenuControllerPresentationArguments {
    fileprivate let sourceNodeAndRect: () -> (ASDisplayNode, CGRect, ASDisplayNode, CGRect)?
    
    public init(sourceNodeAndRect: @escaping () -> (ASDisplayNode, CGRect, ASDisplayNode, CGRect)?) {
        self.sourceNodeAndRect = sourceNodeAndRect
    }
}

public final class ContextMenuController: ViewController {
    private var contextMenuNode: ContextMenuNode {
        return self.displayNode as! ContextMenuNode
    }
    
    private let actions: [ContextMenuAction]
    private let catchTapsOutside: Bool
    
    private var layout: ContainerViewLayout?
    
    public var dismissed: (() -> Void)?
    
    public init(actions: [ContextMenuAction], catchTapsOutside: Bool = false) {
        self.actions = actions
        self.catchTapsOutside = catchTapsOutside
        
        super.init(navigationBarPresentationData: nil)
    }
    
    required public init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    open override func loadDisplayNode() {
        self.displayNode = ContextMenuNode(actions: self.actions, dismiss: { [weak self] in
            self?.dismissed?()
            self?.contextMenuNode.animateOut {
                self?.presentingViewController?.dismiss(animated: false)
            }
        }, catchTapsOutside: self.catchTapsOutside)
        self.displayNodeDidLoad()
    }
    
    override public func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        self.contextMenuNode.animateIn()
    }
    
    override public func dismiss(completion: (() -> Void)? = nil) {
        self.dismissed?()
        self.contextMenuNode.animateOut { [weak self] in
            self?.presentingViewController?.dismiss(animated: false)
        }
    }
    
    override open func containerLayoutUpdated(_ layout: ContainerViewLayout, transition: ContainedViewLayoutTransition) {
        super.containerLayoutUpdated(layout, transition: transition)
        
        if self.layout != nil && self.layout! != layout {
            self.dismissed?()
            self.contextMenuNode.animateOut { [weak self] in
                self?.presentingViewController?.dismiss(animated: false)
            }
        } else {
            self.layout = layout
            
            if let presentationArguments = self.presentationArguments as? ContextMenuControllerPresentationArguments, let (sourceNode, sourceRect, containerNode, containerRect) = presentationArguments.sourceNodeAndRect() {
                self.contextMenuNode.sourceRect = sourceNode.view.convert(sourceRect, to: nil)
                self.contextMenuNode.containerRect = containerNode.view.convert(containerRect, to: nil)
            } else {
                self.contextMenuNode.sourceRect = nil
                self.contextMenuNode.containerRect = nil
            }
            
            self.contextMenuNode.containerLayoutUpdated(layout, transition: transition)
        }
    }
    
    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.contextMenuNode.animateIn()
    }
}
