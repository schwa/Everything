// swiftlint:disable indentation_width

#if os(macOS)
    import Foundation

    //
    public extension SVGContainer {
        func optimise() {
            flatten()
            combine()
        }

        func flatten() {
//        // TODO: Search for references to remove group
//
//        // Don't modify tree as we're walking it - so keep a list of groups to flatten
//        var parents: [SVGGroup] = []
//
//        // Find group elements with exactly 1 child
//        SVGElement.walker.walk(self) {
//            (element: SVGElement, depth: Int) -> Void in
//            if let group = element as? SVGGroup where group.children.count == 1 {
//                parents.append(group)
//            }
//        }
//
//        // Now process the found groups
//        for parent in parents {
//
//            let child = parent.children[0]
//
//            // Concat the parent style with the child style
//            let style = (parent.style ?? Style()) + (child.style ?? Style())
//            if style.isEmpty == false {
//                child.style = style
//            }
//
//            // Concat the parent transform with the child transform
//            let transform = (parent.transform ?? IdentityTransform()) + (child.transform ?? IdentityTransform())
//            if transform.isIdentity == false {
//                child.transform = transform
//            }
//
//            // Replace the parent with the child
//            if let grandParent = parent.parent {
//                try! grandParent.replace(parent, with: child)
//            }
//        }
        }

        func combine() {
//        for child in children {
//            if let container = child as? SVGContainer {
//                container.combine()
//            }
//        }
//
//        var combinedFlag = false
//
//        repeat {
//            combinedFlag = false
//            var lastChild: SVGElement?
//            for (index, child) in children.enumerate() {
//                if let lastChild {
//                    guard let child = child as? SVGPath, let lastChild = lastChild as? SVGPath else {
//                        continue
//                    }
//
//                    guard child.style == lastChild.style else {
//                        continue
//                    }
//
//                    guard child.transform?.toCGAffineTransform() == lastChild.transform?.toCGAffineTransform() else {
//                        continue
//                    }
//
//                    let newPath = lastChild.cgpath + child.cgpath
//                    lastChild.cgpath = newPath
//
//                    children.removeAtIndex(index)
//
//                    combinedFlag = true
//                    break
//
//                }
//                lastChild = child
//            }
//        }
//        while combinedFlag == true
        }
    }
#endif // os(macOS)
