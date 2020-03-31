//
//  ExhibitionCollectionViewCelll.swift
//  DiscovAr
//
//  Created by paly on 11/16/18.
//  Copyright © 2018 paly. All rights reserved.
//

import UIKit

class ExhibitionCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var galleryThumbnail: UIImageView!
    @IBOutlet weak var galleryName: UILabel!
    @IBOutlet weak var bottomView: UIView!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var gallerContainerView: UIView!
    @IBOutlet weak var removeImage: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        //bottomView.layer.cornerRadius = 10
        //galleryThumbnail.layer.cornerRadius = 10
        
        galleryThumbnail.layer.masksToBounds = true
        gallerContainerView.layer.cornerRadius = 10
        priceLabel.layer.masksToBounds = true
        priceLabel.layer.cornerRadius = 10
        priceLabel.layer.maskedCorners = [ .layerMinXMinYCorner, .layerMaxXMaxYCorner]
        
    }

}
