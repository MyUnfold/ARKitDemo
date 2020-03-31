/*
See LICENSE folder for this sample’s licensing information.

Abstract:
Popover view controller for choosing virtual objects to place in the AR scene.
*/

import UIKit
import ARKit

// MARK: - ObjectCell

class ObjectCell: UITableViewCell {
    static let reuseIdentifier = "ObjectCell"
    
    @IBOutlet weak var objectTitleLabel: UILabel!
    @IBOutlet weak var objectImageView: UIImageView!
    @IBOutlet weak var vibrancyView: UIVisualEffectView!
    
    var modelName = "" {
        didSet {
            objectTitleLabel.text = modelName.capitalized
            objectImageView.image = UIImage(named: modelName)
        }
    }
}

// MARK: - VirtualObjectSelectionViewControllerDelegate

/// A protocol for reporting which objects have been selected.
protocol VirtualObjectSelectionViewControllerDelegate: class {
    func virtualObjectSelectionViewController(_ selectionViewController: VirtualObjectSelectionViewController, didSelectObject: VirtualObject)
    func virtualObjectSelectionViewController(_ selectionViewController: VirtualObjectSelectionViewController, didDeselectObject: VirtualObject)
}

/// A custom table view controller to allow users to select `VirtualObject`s for placement in the scene.
class VirtualObjectSelectionViewController: UICollectionViewController {
    
    /// The collection of `VirtualObject`s to select from.
    var virtualObjects = [VirtualObject]()
    
    /// The rows of the currently selected `VirtualObject`s.
    var selectedVirtualObjectRows = IndexSet()
    
    /// The rows of the 'VirtualObject's that are currently allowed to be placed.
    var enabledVirtualObjectRows = Set<Int>()
    
    weak var delegate: VirtualObjectSelectionViewControllerDelegate?
    
    weak var sceneView: ARSCNView?

    private var lastObjectAvailabilityUpdateTimestamp: TimeInterval?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.register(UINib(nibName: "ExhibitionCollectionViewCell", bundle: nil), forCellWithReuseIdentifier:"ExhibitionCollectionViewCell")
        (collectionView.collectionViewLayout as? UICollectionViewFlowLayout)?.itemSize = CGSize.init(width: 106,
        height: 200)
        collectionView.contentInset.left = 20
        collectionView.contentInset.right = 20
        collectionView.allowsMultipleSelection = true
    }
    
    override func viewWillLayoutSubviews() {
        preferredContentSize = CGSize(width: 300, height: 220)
    }
    
    func updateObjectAvailability() {
        guard let sceneView = sceneView else { return }
        
        // Update object availability only if the last update was at least half a second ago.
        if let lastUpdateTimestamp = lastObjectAvailabilityUpdateTimestamp,
            let timestamp = sceneView.session.currentFrame?.timestamp,
            timestamp - lastUpdateTimestamp < 0.5 {
            return
        } else {
            lastObjectAvailabilityUpdateTimestamp = sceneView.session.currentFrame?.timestamp
        }
                
        var newEnabledVirtualObjectRows = Set<Int>()
        let objects = VirtualObject.getObjects(forData: [VirtualObjectData.init(image: #imageLiteral(resourceName: "photo1"), text: "Mona Lisa", audioUrl: "https://file-examples.com/wp-content/uploads/2017/11/file_example_MP3_700KB.mp3"),
        VirtualObjectData.init(image: #imageLiteral(resourceName: "photo3"), text: "Second Image", audioUrl: "https://file-examples.com/wp-content/uploads/2017/11/file_example_MP3_700KB.mp3"),
        VirtualObjectData.init(image: #imageLiteral(resourceName: "photo5"), text: "Third Image", audioUrl: "https://file-examples.com/wp-content/uploads/2017/11/file_example_MP3_700KB.mp3"),
        VirtualObjectData.init(image: #imageLiteral(resourceName: "photo2"), text: "Fourth Image", audioUrl: "https://file-examples.com/wp-content/uploads/2017/11/file_example_MP3_700KB.mp3"),
        VirtualObjectData.init(image: #imageLiteral(resourceName: "photo4"), text: "Fifth Image", audioUrl: "https://file-examples.com/wp-content/uploads/2017/11/file_example_MP3_700KB.mp3")])
        for (row, object) in objects.enumerated() {
            print (object.childNodes)
            // Enable row always if item is already placed, in order to allow the user to remove it.
            if selectedVirtualObjectRows.contains(row) {
                newEnabledVirtualObjectRows.insert(row)
            }
            
            // Enable row if item can be placed at the current location
            if let query = sceneView.getRaycastQuery(for: .horizontal),
                let result = sceneView.castRay(for: query).first {
                object.mostRecentInitialPlacementResult = result
                object.raycastQuery = query
                newEnabledVirtualObjectRows.insert(row)
            } else {
                object.mostRecentInitialPlacementResult = nil
                object.raycastQuery = nil
            }
        }
        
        // Only reload changed rows
        let changedRows = newEnabledVirtualObjectRows.symmetricDifference(enabledVirtualObjectRows)
        enabledVirtualObjectRows = newEnabledVirtualObjectRows
        let indexPaths = changedRows.map { row in IndexPath(row: row, section: 0) }

        DispatchQueue.main.async {
            self.collectionView.reloadItems(at: indexPaths)
        }
    }
    
    // MARK: - UITableViewDelegate
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
//        let cellIsEnabled = enabledVirtualObjectRows.contains(indexPath.row)
//        guard cellIsEnabled else { return }
//
        let object = virtualObjects[indexPath.row]
//
//        // Check if the current row is already selected, then deselect it.
//        if selectedVirtualObjectRows.contains(indexPath.row) {
//            delegate?.virtualObjectSelectionViewController(self, didDeselectObject: object)
//        } else {
            delegate?.virtualObjectSelectionViewController(self, didSelectObject: object)
//        }

        dismiss(animated: true, completion: nil)
    }
    
    override func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        let object = virtualObjects[indexPath.row]
        delegate?.virtualObjectSelectionViewController(self, didDeselectObject: object)
        dismiss(animated: true, completion: nil)
    }
        
    // MARK: - UITableViewDataSource
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return virtualObjects.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ExhibitionCollectionViewCell", for: indexPath) as! ExhibitionCollectionViewCell
        cell.removeImage.isHidden = true
        cell.galleryThumbnail.image = #imageLiteral(resourceName: "photo1")
        
//        if selectedVirtualObjectRows.contains(indexPath.row) {
            cell.removeImage.isHidden = false
            cell.layer.borderColor = UIColor.green.cgColor
            cell.layer.borderWidth = 1.0
//        } else {
//            cell.layer.borderWidth = 0.0
//        }
        return cell
    }
    
//    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        guard let cell = tableView.dequeueReusableCell(withIdentifier: ObjectCell.reuseIdentifier, for: indexPath) as? ObjectCell else {
//            fatalError("Expected `\(ObjectCell.self)` type for reuseIdentifier \(ObjectCell.reuseIdentifier). Check the configuration in Main.storyboard.")
//        }
//
//        cell.modelName = virtualObjects[indexPath.row].modelName
//
//        if selectedVirtualObjectRows.contains(indexPath.row) {
//            cell.accessoryType = .checkmark
//        } else {
//            cell.accessoryType = .none
//        }
//
//        let cellIsEnabled = enabledVirtualObjectRows.contains(indexPath.row)
//        if cellIsEnabled {
//            cell.vibrancyView.alpha = 1.0
//        } else {
//            cell.vibrancyView.alpha = 0.1
//        }
//
//        return cell
//    }
    
//    override func tableView(_ tableView: UITableView, didHighlightRowAt indexPath: IndexPath) {
//        let cellIsEnabled = enabledVirtualObjectRows.contains(indexPath.row)
//        guard cellIsEnabled else { return }
//
//        let cell = tableView.cellForRow(at: indexPath)
//        cell?.backgroundColor = UIColor.lightGray.withAlphaComponent(0.5)
//    }
    
//    override func tableView(_ tableView: UITableView, didUnhighlightRowAt indexPath: IndexPath) {
//        let cellIsEnabled = enabledVirtualObjectRows.contains(indexPath.row)
//        guard cellIsEnabled else { return }
//
//        let cell = tableView.cellForRow(at: indexPath)
//        cell?.backgroundColor = .clear
//    }
}
