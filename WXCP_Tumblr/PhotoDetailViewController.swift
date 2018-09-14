//
//  PhotoDetailViewController.swift
//  WXCP_Tumblr
//
//  Created by Will Xu  on 9/13/18.
//  Copyright © 2018 Will Xu . All rights reserved.
//

import UIKit
import AlamofireImage
class PhotoDetailViewController: UIViewController {

    @IBOutlet weak var postImageView: UIImageView!
    var post: [String: Any]!
    override func viewDidLoad() {
        super.viewDidLoad()
        if let photos = post["photos"] as? [[String: Any]] {
            let photo = photos[0]
            let originalSize = photo["original_size"] as! [String: Any]
            let urlString = originalSize["url"] as! String
            let url = URL(string: urlString)

            let imageView = self.postImageView
            let placeholderImage = UIImage(named: "tumblrLogo")!

            imageView?.af_setImage(withURL: url!, placeholderImage: placeholderImage)
        }
    }
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
